# External Content Scope Audit

Date: 2026-03-16

## Scope Checked

- Official 3A Network / 3A Corporation pages for Minna no Nihongo scope
- jpdb lesson vocabulary reference for Minna no Nihongo I
- Existing repo web-backed tooling:
  - `tooling/ensure_n4n5_kanji_vocab_coverage.py --dry-run`
  - `tooling/link_kanji_examples_to_vocab.py --dry-run`

## Confirmed Findings

### 1. Lesson coverage matches the official 25 + 25 lesson structure

Official 3A pages show:

- Elementary I has 25 lessons
- Elementary II has 25 lessons
- Elementary I corresponds roughly to JLPT N5
- Elementary II corresponds roughly to JLPT N4

Repo status:

- `assets/data/vocab/n5/lesson_01..25`
- `assets/data/vocab/n4/lesson_26..50`
- `assets/data/kanji/n5/kanji_n5_1..25.json`
- `assets/data/kanji/n4/kanji_n4_26..50.json`

Conclusion:

- Lesson structure is complete for the current N5/N4 Minna scope.

### 2. Current lesson-linked kanji data is complete for app coverage, but not for the full official Kanji supplementary books

Official 3A pages for the Kanji books state:

- Book I studies 220 kanji
- Book II studies 316 kanji
- Total across both books: 536 kanji

Repo status:

- `326` kanji rows
- `295` unique kanji characters

Conclusion:

- Your repo is complete for the current lesson-linked app experience.
- It does **not** yet cover the full supplementary Minna Kanji book scope (`536` total).
- If your product goal is only lesson + vocab-linked kanji for N5/N4 study, current coverage is acceptable.
- If your goal expands to full Minna Kanji workbook parity, there is still a sizable expansion backlog.

### 3. Web-backed coverage audit found no missing lesson-linked kanji coverage

Local dry-run result from `tooling/ensure_n4n5_kanji_vocab_coverage.py --dry-run`:

- `missingSingleBefore: 0`
- `missingCompoundBefore: 0`
- `missingSingleAfter: 0`
- `missingCompoundAfter: 0`

Conclusion:

- Relative to the repo's current kanji set, vocab support is saturated.
- There is no immediate missing single-kanji / compound-kanji support left to auto-backfill.

### 4. Kanji example linking is fully resolved

Local dry-run result from `tooling/link_kanji_examples_to_vocab.py --dry-run`:

- `total_examples: 953`
- `unmatched: 0`

Conclusion:

- Current kanji example references resolve cleanly into normalized vocab rows.

### 5. Your N5 vocab is broader than a textbook-only deck

jpdb's Minna no Nihongo I reference deck reports:

- `979` unique words across Minna no Nihongo I

Repo status:

- N5 canonical vocab entries: `1327`

Interpretation:

- The repo is not merely mirroring textbook core vocabulary.
- It also includes expanded support rows such as lesson web-check additions,
  kanji coverage rows, and example-driven inserts.
- This is not a defect, but it means the dataset should be treated as an
  **expanded curriculum**, not a strict textbook transcript.

### 6. There are upstream 2026 edition differences you may want to track later

From the official 3A Third Edition announcement page:

- Elementary II notation change: `（道が）込みます` -> `（道が）混みます`
- Elementary I pronunciation placement change: `何<なに>` moved from Lesson 6 to Lesson 5
- Elementary I notation changes include `兄弟` -> hiragana, `君` -> hiragana, `牛どん` -> `牛丼`

Conclusion:

- Your current repo aligns better with **Second Edition**.
- If you later migrate to **Third Edition**, some vocab placement / notation updates will be needed.

## Recommendation

Treat the current repo as:

- complete for `Minna no Nihongo Second Edition` lesson-linked N5/N4 study flow
- internally complete for current kanji/vocab/example linking
- incomplete only if you want full parity with the official supplementary Kanji books
- version-sensitive if you plan to follow Third Edition updates

## Sources

- https://www.3anet.co.jp/en/minnanonihongo_dai3pan.html
- https://www.3anet.co.jp/np/en/books/2302/
- https://www.3anet.co.jp/np/en/books/2402/
- https://www.3anet.co.jp/np/en/books/2358/
- https://www.3anet.co.jp/np/en/books/2458/
- https://jpdb.io/textbook/9/minna-no-nihongo-i
- https://jpdb.io/textbook/9/minna-no-nihongo-i/1/lesson-1/vocabulary-list
- https://jpdb.io/textbook/9/minna-no-nihongo-i/25/lesson-25/vocabulary-list
