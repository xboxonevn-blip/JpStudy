# Content data

`assets/data/content/` contains the learning content that the app loads at runtime.

## Structure

- `index.json`
- `kana/kana_chart.json`
- `kanji/han_viet_on_rules.json`
- `vocab/<level>/lesson_XX.json`
- `kanji/<level>/lesson_XX.json`
- `grammar/<level>/grammar_<level>_<lesson>.json`
- `grammar_examples/<level>/lesson_<lesson>.json`
- `immersion/`

Levels currently follow JLPT naming such as `n5`, `n4`, `n3`.

## `index.json`

Purpose:
- Lightweight manifest for available lesson exports.
- Used by tooling and audits to understand coverage.

Typical fields:
- schema or version metadata
- available datasets
- lesson counts or level summaries

## `kana/kana_chart.json`

- Canonical beginner kana chart payload imported from the Drive scan.
- Contains hiragana and katakana base rows, dakuten/handakuten variants, stroke counts, and compound kana.
- Does not depend on publisher web pages.

## `kanji/han_viet_on_rules.json`

- Online-source-backed learner heuristics for guessing common On readings from Vietnamese Han-Viet labels.
- Contains source URLs, blocked-domain policy, confidence scores, rule categories, and examples.
- Rules are study hints only; lesson kanji readings remain the canonical runtime answer source.

## `vocab/<level>/lesson_XX.json`

Purpose:
- Canonical lesson vocab payload used by runtime lesson loading and DB seeding.

Top-level shape:
- object
- `lessonId`: integer
- `level`: string
- `title`: optional object/string depending on generator phase
- `theme`: optional theme metadata
- `entries`: array

Each entry typically contains:
- `order`: display order inside lesson
- `lemma`: base term data
- `sense`: lesson-specific meaning data
- `links`: source identifiers if present
- `tags`: array of tags

Typical `lemma` fields:
- `term`: Japanese surface form
- `reading`: kana reading or null
- `labels`: nested labels such as Han-Viet or search helpers

Typical `sense` fields:
- `meaningVi`: Vietnamese meaning
- `meaningEn`: English meaning
- optional notes/register/context metadata

## `kanji/<level>/lesson_XX.json`

Purpose:
- Canonical kanji lesson payload used by runtime kanji loading and DB seeding.

Top-level shape:
- object
- `lessonId`: integer
- `level`: string
- `theme`: optional theme metadata
- `entries`: array

Each entry typically contains:
- `character`: kanji character
- `strokeCount`: integer
- `readings`: object
- `labels`: object with localized meanings
- `mnemonic`: object with localized mnemonics
- `decomposition`: structured decomposition payload
- `examples`: array of words/examples linked to the kanji
- `order`: optional lesson ordering

Typical `readings` fields:
- `onyomi`: array
- `kunyomi`: array

Typical `labels` fields:
- `meaningVi`
- `meaningEn`
- `hanViet`

## `grammar/<level>/grammar_<level>_<lesson>.json`

Purpose:
- Grammar point definitions per lesson.

Top-level shape:
- array of grammar point objects

Each grammar point commonly contains:
- `grammarPoint` or equivalent title key
- `title`
- `titleEn`
- `meaning` or `meaning_vi`
- `structure` or `connection`
- `explanation`
- `explanation_vi`
- optional nuance / usage / contrast metadata

## `grammar_examples/<level>/lesson_<lesson>.json`

Purpose:
- Example sentences for grammar points, separated from the definition file.

Top-level shape:
- array

Each item commonly contains:
- grammar point identifier or title reference
- `jp`: Japanese sentence
- `reading`: optional kana reading
- `vi`: Vietnamese translation
- `en`: English translation
- optional notes such as nuance or situational context

## `immersion/`

Purpose:
- Reading/immersion content grouped for app discovery or practice flows.

This subtree is content-facing, but structurally looser than lesson vocab/kanji.
It may contain:
- per-level lesson/article JSON
- shared manifests such as `immersion_samples.json`

## Editing rules

- Add new lesson vocab/kanji under `vocab/` and `kanji/` only.
- Keep lesson numbering consistent with the app lesson ranges.
- Prefer additive, schema-consistent updates over one-off custom fields.
- If a new field is needed, update loaders/tooling together.
