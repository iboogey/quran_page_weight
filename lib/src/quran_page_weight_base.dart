import 'ayah.dart';
import 'data/quran_data.g.dart' as data;

/// Page-weight calculator for the standard 604-page Madani mushaf (Hafs).
///
/// Obtain an instance with [load]. All data is bundled; no I/O or network.
class QuranPageWeight {
  final List<int> _suraOffsets; // 114: global index of (sura, 1)
  final List<double> _cumWeights; // 6237: prefix sums of ayah weights
  final List<double> _pageTotals; // 604: total weight per page

  QuranPageWeight._(this._suraOffsets, this._cumWeights, this._pageTotals);

  /// Loads the bundled mushaf data. Instant and offline; async only to
  /// keep the API stable if a future version streams data.
  static Future<QuranPageWeight> load() async {
    final offsets = List<int>.filled(114, 0);
    var acc = 0;
    for (var s = 0; s < 114; s++) {
      offsets[s] = acc;
      acc += data.suraAyahCounts[s];
    }
    final cum = List<double>.filled(data.ayahWeights.length + 1, 0);
    for (var i = 0; i < data.ayahWeights.length; i++) {
      cum[i + 1] = cum[i] + data.ayahWeights[i];
    }
    final totals = List<double>.filled(604, 0);
    for (var p = 0; p < 604; p++) {
      totals[p] = cum[_pageEnd(p) + 1] - cum[data.pageFirstAyahIndex[p]];
    }
    return QuranPageWeight._(offsets, cum, totals);
  }

  /// Number of ayahs in [sura] (1–114).
  int ayahCount(int sura) {
    if (sura < 1 || sura > 114) {
      throw ArgumentError.value(sura, 'sura', 'must be between 1 and 114');
    }
    return data.suraAyahCounts[sura - 1];
  }

  /// The 1-based mushaf page (1–604) that [ayah] appears on.
  int pageOf(Ayah ayah) => _pageOfIndex(_index(ayah)) + 1;

  /// Validates [ayah] and returns its 0-based global index in mushaf order.
  int _index(Ayah ayah, [String name = 'ayah']) {
    if (ayah.sura < 1 || ayah.sura > 114) {
      throw ArgumentError.value(
          ayah.sura, name, 'sura must be between 1 and 114');
    }
    final count = data.suraAyahCounts[ayah.sura - 1];
    if (ayah.aya < 1 || ayah.aya > count) {
      throw ArgumentError.value(ayah.aya, name,
          'aya must be between 1 and $count for sura ${ayah.sura}');
    }
    return _suraOffsets[ayah.sura - 1] + ayah.aya - 1;
  }

  /// 0-based page containing global ayah index [i].
  int _pageOfIndex(int i) {
    var lo = 0, hi = 603;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (data.pageFirstAyahIndex[mid] <= i) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// Global index of the last ayah on 0-based page [p].
  static int _pageEnd(int p) => p == 603
      ? data.ayahWeights.length - 1
      : data.pageFirstAyahIndex[p + 1] - 1;

  /// Sum of effective weights of global indices [i]..[j], inclusive.
  double _weightBetween(int i, int j) => _cumWeights[j + 1] - _cumWeights[i];

  /// Page weight of the inclusive range [start]..[end].
  ///
  /// Full pages inside the range count exactly 1.0; the partial first and
  /// last pages count as (weight read on page / total weight of page).
  double pages({required Ayah start, required Ayah end}) {
    final si = _index(start, 'start');
    final ei = _index(end, 'end');
    if (si > ei) {
      throw ArgumentError('start $start comes after end $end in mushaf order');
    }
    return _pagesByIndex(si, ei);
  }

  double _pagesByIndex(int si, int ei) {
    final ps = _pageOfIndex(si);
    final pe = _pageOfIndex(ei);
    if (ps == pe) return _weightBetween(si, ei) / _pageTotals[ps];
    final startFrac = _weightBetween(si, _pageEnd(ps)) / _pageTotals[ps];
    final endFrac =
        _weightBetween(data.pageFirstAyahIndex[pe], ei) / _pageTotals[pe];
    return startFrac + (pe - ps - 1) + endFrac;
  }

  /// Weight of a single [ayah] as a fraction of its page.
  double ayahWeight(Ayah ayah) {
    final i = _index(ayah);
    return _weightBetween(i, i) / _pageTotals[_pageOfIndex(i)];
  }

  /// The ayah at which a portion of [pages] pages, starting at [start]
  /// (inclusive), ends: the earliest ayah `end` such that
  /// `pages(start: start, end: end) >= pages`.
  ///
  /// Clamped to the last ayah of the Quran (114:6) if the portion runs
  /// past the end.
  Ayah endOfPortion({required Ayah start, required double pages}) {
    if (pages <= 0) {
      throw ArgumentError.value(pages, 'pages', 'must be greater than zero');
    }
    final si = _index(start, 'start');
    final last = data.ayahWeights.length - 1;
    if (_pagesByIndex(si, last) <= pages) return const Ayah(114, 6);
    // pages(si..ei) grows monotonically in ei, so binary search works.
    var lo = si, hi = last;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_pagesByIndex(si, mid) >= pages) {
        hi = mid;
      } else {
        lo = mid + 1;
      }
    }
    return _ayahFromIndex(lo);
  }

  /// Converts a 0-based global ayah index back to an [Ayah].
  Ayah _ayahFromIndex(int i) {
    var lo = 0, hi = 113;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_suraOffsets[mid] <= i) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return Ayah(lo + 1, i - _suraOffsets[lo] + 1);
  }
}
