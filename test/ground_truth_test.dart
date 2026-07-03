import 'package:quran_page_weight/quran_page_weight.dart';
import 'package:test/test.dart';

void main() {
  late QuranPageWeight quran;

  setUpAll(() async {
    quran = await QuranPageWeight.load();
  });

  test('each juz is roughly 20 pages', () {
    // First ayah of each juz (standard 30-juz division).
    const juzStarts = [
      Ayah(1, 1), Ayah(2, 142), Ayah(2, 253), Ayah(3, 93), Ayah(4, 24),
      Ayah(4, 148), Ayah(5, 82), Ayah(6, 111), Ayah(7, 88), Ayah(8, 41),
      Ayah(9, 93), Ayah(11, 6), Ayah(12, 53), Ayah(15, 1), Ayah(17, 1),
      Ayah(18, 75), Ayah(21, 1), Ayah(23, 1), Ayah(25, 21), Ayah(27, 56),
      Ayah(29, 46), Ayah(33, 31), Ayah(36, 28), Ayah(39, 32), Ayah(41, 47),
      Ayah(46, 1), Ayah(51, 31), Ayah(58, 1), Ayah(67, 1), Ayah(78, 1), //
    ];
    for (var j = 0; j < 30; j++) {
      final start = juzStarts[j];
      final endExclusive = j == 29 ? null : juzStarts[j + 1];
      final end = endExclusive == null
          ? const Ayah(114, 6)
          : _previousAyah(quran, endExclusive);
      final p = quran.pages(start: start, end: end);
      // Most ajza' are ~20 pages; juz 1 is ~21 (short ornamental first
      // pages) and juz 30 is ~23 (pages 582-604).
      expect(p, inInclusiveRange(17.0, 23.5),
          reason: 'juz ${j + 1}: $start..$end');
    }
  });

  test('additivity: split ranges sum to the whole', () {
    const cases = [
      (Ayah(1, 1), Ayah(2, 100), Ayah(2, 286)),
      (Ayah(15, 5), Ayah(16, 128), Ayah(18, 100)),
      (Ayah(2, 255), Ayah(2, 256), Ayah(3, 1)),
      (Ayah(100, 1), Ayah(105, 5), Ayah(114, 6)),
    ];
    for (final (a, b, c) in cases) {
      final whole = quran.pages(start: a, end: c);
      final part1 = quran.pages(start: a, end: b);
      final part2 = quran.pages(start: _nextAyah(quran, b), end: c);
      expect(part1 + part2, closeTo(whole, 1e-9), reason: 'split $a..$c at $b');
    }
  });

  test('user acceptance: 15:5 to 18:100 gives a plausible page count', () {
    final p = quran.pages(start: const Ayah(15, 5), end: const Ayah(18, 100));
    // 15:5 is on page ~263; 18:100 is on page ~304 → about 41-42 pages.
    expect(p, closeTo(41.5, 2));
  });
}

Ayah _nextAyah(QuranPageWeight q, Ayah a) => a.aya < q.ayahCount(a.sura)
    ? Ayah(a.sura, a.aya + 1)
    : Ayah(a.sura + 1, 1);

Ayah _previousAyah(QuranPageWeight q, Ayah a) => a.aya > 1
    ? Ayah(a.sura, a.aya - 1)
    : Ayah(a.sura - 1, q.ayahCount(a.sura - 1));
