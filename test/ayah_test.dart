import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  group('Ayah', () {
    test('holds sura and aya', () {
      const a = Ayah(15, 5);
      expect(a.sura, 15);
      expect(a.aya, 5);
    });

    test('equality and hashCode by value', () {
      expect(const Ayah(2, 255), const Ayah(2, 255));
      expect(const Ayah(2, 255).hashCode, const Ayah(2, 255).hashCode);
      expect(const Ayah(2, 255), isNot(const Ayah(2, 256)));
      expect(const Ayah(2, 255), isNot(const Ayah(3, 255)));
    });

    test('toString is readable', () {
      expect(const Ayah(18, 100).toString(), 'Ayah(18, 100)');
    });
  });
}
