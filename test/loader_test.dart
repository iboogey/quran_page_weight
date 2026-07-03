import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  late QuranPageWeight quran;

  setUpAll(() async {
    quran = await QuranPageWeight.load();
  });

  group('ayahCount', () {
    test('known sura lengths', () {
      expect(quran.ayahCount(1), 7);
      expect(quran.ayahCount(2), 286);
      expect(quran.ayahCount(114), 6);
    });

    test('rejects sura out of range', () {
      expect(() => quran.ayahCount(0), throwsArgumentError);
      expect(() => quran.ayahCount(115), throwsArgumentError);
    });
  });

  group('pageOf', () {
    test('known page anchors', () {
      expect(quran.pageOf(const Ayah(1, 1)), 1);
      expect(quran.pageOf(const Ayah(2, 1)), 2);
      expect(quran.pageOf(const Ayah(18, 1)), 293); // Al-Kahf
      expect(quran.pageOf(const Ayah(36, 1)), 440); // Ya-Sin
      expect(quran.pageOf(const Ayah(114, 6)), 604);
    });

    test('rejects invalid ayah with a clear message', () {
      expect(() => quran.pageOf(const Ayah(0, 1)), throwsArgumentError);
      expect(() => quran.pageOf(const Ayah(115, 1)), throwsArgumentError);
      expect(() => quran.pageOf(const Ayah(1, 0)), throwsArgumentError);
      // Sura 1 has only 7 ayat:
      expect(
        () => quran.pageOf(const Ayah(1, 15)),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', contains('between 1 and 7'))),
      );
    });
  });
}
