# Support data

`assets/data/support/` contains technical assets used by the app engine rather than lesson content.

## Structure

- `kanji/decomposition.json`
- `kanji/stroke_templates.json`
- `kanji/stroke_template_overrides.json`
- `kanji/kanjivg_stroke_paths_n5n4.json`

## `kanji/decomposition.json`

Purpose:
- Compatibility export for kanji decomposition/radical breakdown.
- Used when the app or tooling needs a shared decomposition lookup independent of lesson files.

Typical shape:
- object keyed by kanji character, or array converted by tooling depending on generator version
- each value includes decomposition parts and optional labels

Common content:
- radicals or graphical parts
- semantic/structural grouping
- localized labels if generated

## `kanji/stroke_templates.json`

Purpose:
- Primary handwriting template dataset used by stroke rendering/scoring.

Top-level shape:
- array of template objects

Each template commonly contains:
- `character`: kanji character
- `level`: JLPT level such as `N5` or `N4`
- `quality`: template source quality such as `manual`, `curated`, `generated`
- `strokes`: array of stroke definitions

Typical stroke fields:
- stroke path points or vector segments
- normalized coordinates
- optional direction/start-end metadata

This file is runtime-critical for handwriting mode.

## `kanji/stroke_template_overrides.json`

Purpose:
- Manual corrections layered on top of the base stroke template generation pipeline.

Typical usage:
- replace bad generated strokes
- correct ordering issues
- refine difficult characters without rebuilding everything manually

Top-level shape:
- object or array keyed by character depending on generator version
- override payload usually targets one character at a time

## `kanji/kanjivg_stroke_paths_n5n4.json`

Purpose:
- Vector stroke path dataset derived from KanjiVG-style geometry for N5/N4 coverage.
- Used for stroke guide rendering and geometry-aware handwriting support.

Top-level shape:
- collection keyed by kanji character or array of character entries

Typical fields per character:
- `character`
- stroke path list
- SVG/path-like vector commands or normalized segment data
- optional source/version metadata

## Relationship between support files

- `stroke_templates.json` is the app-facing template set used directly for scoring/rendering.
- `stroke_template_overrides.json` refines or replaces parts of that template set.
- `kanjivg_stroke_paths_n5n4.json` is the richer geometry source used to derive or inspect stroke data.
- `decomposition.json` is separate from stroke data and supports structural kanji analysis.

## Editing rules

- Do not put lesson vocab/kanji payloads in `support/`.
- Keep support files stable because runtime handwriting features depend on them directly.
- If you regenerate a support file, validate the related tests after the change.
- Preserve backwards compatibility for field names unless loaders are updated in the same change.
