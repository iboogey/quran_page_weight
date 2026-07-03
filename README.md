# quran_page_weight

Compute the page weight of any Quran ayah range in the standard 604-page
Madani mushaf (Hafs). Pure Dart, fully offline, zero dependencies — works
in Flutter, on servers, and in CLI tools.

## What it does

- **Range → pages**: how many physical mushaf pages a range covers,
  including fractions (`15:5 → 18:100` ≈ `41.9` pages).
- **Reverse lookup**: where does a portion of N pages end?
- **Sura info**: a sura's total pages and its starting page.

Full pages are counted exactly from the real mushaf page boundaries;
partial first/last pages are weighted by word count, with sura headers
and basmala lines accounted for. Accuracy is within a fraction of a page.

## Usage

```dart
import 'package:quran_page_weight/quran_page_weight.dart';

final quran = await QuranPageWeight.load();

quran.pages(start: Ayah(2, 1), end: Ayah(2, 15));    // ~1.6
quran.pages(start: Ayah(15, 5), end: Ayah(18, 100)); // ~41.9
quran.ayahWeight(Ayah(2, 282));                      // ~1.0 (fills its page)
quran.endOfPortion(start: Ayah(15, 5), pages: 2.0);  // Ayah where 2 pages end
quran.suraPages(18);                                 // ~11.4
quran.suraStartPage(18);                             // 293
quran.pageOf(Ayah(36, 1));                           // 440
quran.ayahCount(2);                                  // 286
```

Ranges are inclusive on both ends. Invalid input (sura outside 1–114,
aya beyond the sura, start after end) throws `ArgumentError`.

## Using the data outside Dart

The same numbers ship as plain JSON in `data/` (`page_map.json`,
`ayah_weights.json`) so a server in any language can reproduce the
calculation. See `tool/generate_data.dart` for how they are built.

## Mushaf edition

v1 covers the standard 604-page Madani mushaf (Hafs). Other layouts
(Warsh, 13-line Indo-Pak) may be added later without API changes.
