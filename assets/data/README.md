# Data layout

`assets/data/` is organized by purpose instead of historical schema.

## Runtime content

- `assets/data/content/index.json`
- `assets/data/content/vocab/`
- `assets/data/content/kana/`
- `assets/data/content/kanji/`
- `assets/data/content/grammar/`
- `assets/data/content/grammar_examples/`
- `assets/data/content/immersion/`

These directories contain the learning content that the app loads at runtime.
`content/kanji/han_viet_on_rules.json` is a sourced heuristic reference for Han-Viet to On-yomi study hints.

## Support assets

- `assets/data/support/kanji/decomposition.json`
- `assets/data/support/kanji/kanjivg_stroke_paths_n5n4.json`
- `assets/data/support/kanji/stroke_templates.json`
- `assets/data/support/kanji/stroke_template_overrides.json`

These files support handwriting, stroke rendering, and kanji decomposition.
They are technical assets, not lesson content.

## Archive

- `assets/data/archive/vocab/`
- `assets/data/archive/kanji/`

These folders keep older lesson schemas for migration history, audits, and import tooling.
Runtime lesson loading and DB seeding do not read from this archive.

## Policy

- Edit new lesson content under `assets/data/content/`.
- Edit handwriting/decomposition assets under `assets/data/support/kanji/`.
- Treat `assets/data/archive/` as import/archive storage only.
