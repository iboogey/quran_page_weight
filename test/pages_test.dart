import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  late QuranPageWeight quran;

  setUpAll(() async {
    quran = await QuranPageWeight.load();
  });

  group('pages', () {
    test('Al-Fatiha fills page 1 exactly', () {
      expect(quran.pages(start: const Ayah(1, 1), end: const Ayah(1, 7)),
          closeTo(1.0, 1e-9));
    });

    test('whole Quran is exactly 604 pages', () {
      expect(quran.pages(start: const Ayah(1, 1), end: const Ayah(114, 6)),
          closeTo(604.0, 1e-9));
    });

    test('within one sura, same page: fraction between 0 and 1', () {
      final p = quran.pages(start: const Ayah(2, 1), end: const Ayah(2, 3));
      expect(p, greaterThan(0));
      expect(p, lessThan(1));
    });

    test('cross-sura range spans expected page distance', () {
      // 15:5 is on some page ps, 18:100 on page pe; result must lie
      // between (pe - ps - 1) and (pe - ps + 1).
      final ps = quran.pageOf(const Ayah(15, 5));
      final pe = quran.pageOf(const Ayah(18, 100));
      final p =
          quran.pages(start: const Ayah(15, 5), end: const Ayah(18, 100));
      expect(p, greaterThan((pe - ps - 1).toDouble()));
      expect(p, lessThan((pe - ps + 1).toDouble()));
    });

    test('single ayah range equals ayahWeight', () {
      expect(quran.pages(start: const Ayah(2, 255), end: const Ayah(2, 255)),
          closeTo(quran.ayahWeight(const Ayah(2, 255)), 1e-12));
    });

    test('rejects start after end', () {
      expect(
        () => quran.pages(start: const Ayah(3, 1), end: const Ayah(2, 286)),
        throwsA(isA<ArgumentError>()
            .having((e) => e.message, 'message', contains('after'))),
      );
      expect(
        () => quran.pages(start: const Ayah(2, 10), end: const Ayah(2, 9)),
        throwsArgumentError,
      );
    });
  });

  group('ayahWeight', () {
    test('ayat al-dayn (2:282) is most of a page', () {
      final w = quran.ayahWeight(const Ayah(2, 282));
      expect(w, greaterThan(0.5));
      expect(w, lessThanOrEqualTo(1.0));
    });

    test('a short ayah is a small fraction', () {
      expect(quran.ayahWeight(const Ayah(55, 64)), lessThan(0.2));
    });

    test('all ayahs on one page sum to exactly 1.0', () {
      // Page 604 holds suras 112-114 and nothing else.
      var sum = 0.0;
      for (final sura in [112, 113, 114]) {
        for (var a = 1; a <= quran.ayahCount(sura); a++) {
          sum += quran.ayahWeight(Ayah(sura, a));
        }
      }
      expect(sum, closeTo(1.0, 1e-9));
    });
  });
}
