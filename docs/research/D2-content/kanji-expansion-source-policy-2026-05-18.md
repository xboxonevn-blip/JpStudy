# Kanji Expansion Source Policy

Generated: `2026-05-18T07:34:21+07:00`

## Finding

JLPT does not publish modern vocabulary/kanji/grammar item lists. The official FAQ says publishing Test Content Specifications with vocabulary, kanji, and grammar lists is not appropriate because JLPT measures communicative task competence, not list memorization: <https://www.jlpt.jp/e/faq/>

KANJIDIC2 is a valid open source for kanji facts, but not a modern N5-N1 level split. EDRDG states KANJIDIC project files are released under Creative Commons Attribution-ShareAlike 4.0: <https://www.edrdg.org/wiki/KANJIDIC_Project.html>

Unihan is a valid source for Hán-Việt readings and related Unicode data. Unicode states most data files and software are released under the Unicode License: <https://unicode.org/faq/unicode_license.html>

Third-party JLPT Kanji level pages can explain the no-official-list problem and can be used as cross-checks, but unclear licensing means they must not be copied into app data. Example reference only: <https://www.japanese-kanji.com/levels-jlpt.htm>

## Policy

- Use KANJIDIC2 for kanji character facts: readings, stroke count, old JLPT tier, English gloss seeds, and reference IDs.
- Use Unihan `kVietnamese` for Hán-Việt readings.
- Do not copy modern JLPT level lists from unclear-license websites.
- Do not claim an official modern JLPT Kanji list exists.
- Before generating N3/N2/N1 expansion batches, choose a modern level-mapping source with one of:
  - explicit open license compatible with app redistribution, or
  - owner-provided/approved curriculum mapping created from textbook scope, with provenance logged.
- Treat any unclear-license website as verification/cross-check only.

## Impact On QA-B-002

QA-B-002 cannot safely proceed as a bulk N5-N1 generation from KANJIDIC2 alone. The safe order is:

1. Fix completeness debt for current authored kanji.
2. Use KANJIDIC2 + Unihan to enrich known characters.
3. Add missing N5/N4 from old-JLPT KANJIDIC2 first, because their mapping is straightforward.
4. For N3/N2/N1, select and document a redistribution-safe modern mapping before adding new characters.
5. Keep reachability guard mandatory for every batch.
