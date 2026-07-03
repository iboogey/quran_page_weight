import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  late QuranPageWeight quran;

  setUpAll(() async {
    quran = await QuranPageWeight.load();
  });

  group('endOfPortion', () {
    test('1.0 page from 1:1 ends at 1:7 (Al-Fatiha fills page 1)', () {
      expect(quran.endOfPortion(start: const Ayah(1, 1), pages: 1.0),
          const Ayah(1, 7));
    });

    test('604 pages from 1:1 ends at 114:6', () {
      expect(quran.endOfPortion(start: const Ayah(1, 1), pages: 604),
          const Ayah(114, 6));
    });

    test('clamps at the end of the Quran when asking for too much', () {
      expect(quran.endOfPortion(start: const Ayah(110, 1), pages: 50),
          const Ayah(114, 6));
    });

    test('round-trips with pages()', () {
      const cases = [
        (Ayah(2, 30), Ayah(2, 100)),
        (Ayah(15, 5), Ayah(18, 100)),
        (Ayah(67, 1), Ayah(70, 20)),
        (Ayah(1, 1), Ayah(2, 141)), // ~juz 1
      ];
      for (final (start, end) in cases) {
        final p = quran.pages(start: start, end: end);
        expect(quran.endOfPortion(start: start, pages: p), end,
            reason: 'round trip for $start..$end ($p pages)');
      }
    });

    test('result never undershoots the requested amount', () {
      const start = Ayah(3, 10);
      final end = quran.endOfPortion(start: start, pages: 2.5);
      expect(quran.pages(start: start, end: end),
          greaterThanOrEqualTo(2.5 - 1e-9));
    });

    test('rejects non-positive pages', () {
      expect(() => quran.endOfPortion(start: const Ayah(1, 1), pages: 0),
          throwsArgumentError);
      expect(() => quran.endOfPortion(start: const Ayah(1, 1), pages: -1),
          throwsArgumentError);
    });
  });
}
