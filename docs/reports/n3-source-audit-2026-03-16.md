# N3 data audit and bootstrap notes (2026-03-16)

## What was missing

- `assets/data/vocab/n3/` and `assets/data/kanji/n3/` were empty.
- `ContentDatabase` still seeded only `N5` and `N4`.
- `AppDatabase` only pre-created lessons `1-50`, so `N3` lesson meta could stay empty on existing installs.
- Canonical asset bundle declarations did not include `assets/data/canonical/vocab/n3/` and `assets/data/canonical/kanji/n3/` explicitly.

## Source policy used

There is no official JLPT vocabulary/kanji list published for the post-2010 test, so the safe approach is:

1. Use open/licensed lexical datasets for coverage and validation.
2. Keep a small, reviewed starter lesson instead of bulk-copying from copyrighted commercial lists.
3. Expand gradually with reproducible tooling.

## Online sources checked

- Official JLPT FAQ: https://www.jlpt.jp/e/faq/
- JMdict / EDRDG: https://www.edrdg.org/jmdict/j_jmdict.html
- KANJIDIC Project / EDRDG: https://www.edrdg.org/wiki/index.php/KANJIDIC_Project
- Open Anki JLPT decks (MIT): https://github.com/jamsinclair/open-anki-jlpt-decks

## Current N3 bootstrap scope

- Added canonical starter lesson `51` for vocab.
- Added canonical starter lesson `51` for kanji.
- Added tooling script `tooling/bootstrap_n3_starter.py` so the lesson can be regenerated.
- Updated canonical index after generation.

## Remaining gaps

- N3 grammar is still empty.
- N3 immersion content is still empty.
- N3 legacy lesson assets are still not populated; current app path works from canonical assets.
- The first N3 lesson is a starter pack, not a full 25-lesson curriculum yet.
