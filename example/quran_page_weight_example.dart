import 'package:quran_page_weight/quran_page_weight.dart';

Future<void> main() async {
  final quran = await QuranPageWeight.load();

  // How many pages is a range? (inclusive on both ends)
  final portion =
      quran.pages(start: const Ayah(15, 5), end: const Ayah(18, 100));
  print('15:5 → 18:100 is ${portion.toStringAsFixed(1)} pages');

  // Where does a 2-page daily portion starting at 15:5 end?
  final end = quran.endOfPortion(start: const Ayah(15, 5), pages: 2.0);
  print('2 pages from 15:5 ends at $end');

  // Single-ayah weight and sura info.
  print('2:282 weighs '
      '${quran.ayahWeight(const Ayah(2, 282)).toStringAsFixed(2)} pages');
  print('Sura 18 starts on page ${quran.suraStartPage(18)} '
      'and is ${quran.suraPages(18).toStringAsFixed(1)} pages long');
}
