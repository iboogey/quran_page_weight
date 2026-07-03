import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  late QuranPageWeight quran;

  setUpAll(() async {
    quran = await QuranPageWeight.load();
  });

  group('suraStartPage', () {
    test('known start pages', () {
      expect(quran.suraStartPage(1), 1);
      expect(quran.suraStartPage(2), 2);
      expect(quran.suraStartPage(18), 293); // Al-Kahf
      expect(quran.suraStartPage(36), 440); // Ya-Sin
      expect(quran.suraStartPage(114), 604);
    });

    test('rejects invalid sura', () {
      expect(() => quran.suraStartPage(0), throwsArgumentError);
      expect(() => quran.suraStartPage(115), throwsArgumentError);
    });
  });

  group('suraPages', () {
    test('Al-Fatiha is exactly one page', () {
      expect(quran.suraPages(1), closeTo(1.0, 1e-9));
    });

    test('Al-Baqara is about 48 pages (pages 2-49)', () {
      expect(quran.suraPages(2), closeTo(48, 2));
    });

    test('Al-Kahf is about 11 pages (pages 293-304)', () {
      expect(quran.suraPages(18), closeTo(11, 2));
    });

    test('all 114 suras sum to exactly 604 pages', () {
      var sum = 0.0;
      for (var s = 1; s <= 114; s++) {
        sum += quran.suraPages(s);
      }
      expect(sum, closeTo(604.0, 1e-6));
    });
  });
}
