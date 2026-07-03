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
}
