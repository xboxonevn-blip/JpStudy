# Tooling

`tooling/` contains local scripts and helper assets for content generation, validation, migration, and quality maintenance.

## Folder structure

- `reports/`: tooling-specific runtime or workflow reports
- `_tmpcache/`: local caches for heavy source datasets and intermediate artifacts
- `*.py`: executable maintenance scripts
- `*.json`: helper inputs such as manual overrides or theme maps

## Script groups

### Content export and validation

- `build_canonical_content_v2.py`: exports lesson data into the runtime `assets/data/content/` layout
- `validate_content_assets_v2.py`: validates content integrity across vocab/kanji datasets
- `audit_content_completeness.py`: runs broader repo-level completeness and self-heal checks

### Grammar quality audit

- `audit_grammar_example_quality.dart`: audits grammar example readiness for `contextChoice`, `errorCorrection`, and `transformation`, and writes `docs/reports/grammar-example-quality-report.json`

### Archive migration and backfill

- `backfill_vocab_from_kanji_examples.py`: pushes archived kanji example content back into archived vocab lesson structures
- `link_kanji_examples_to_vocab.py`: links archived kanji examples to archived vocab identifiers
- `fix_vocab_kanjimeaning_hanviet.py`: repairs archived vocab Han-Viet labels using local/manual/open sources
- `refine_coverage_meaningvi_manual.py`: manual refinement pass for archived coverage gaps
- `ensure_n4n5_kanji_vocab_coverage.py`: audits and repairs N4/N5 archive coverage relationships

### Grammar generation and normalization

- `generate_n3_grammar_scaffold.py`: scaffolds N3 grammar lesson data
- `normalize_grammar_examples.py`: standardizes grammar example wording/shape
- `normalize_n3_grammar_semantics.py`: normalizes N3 grammar semantics and labels
- `upgrade_grammar_quality.py`: improves grammar payload quality and example richness
- `score_n3_lesson_coherence.py`: scores lesson coherence for N3 grammar/grouping work

### Lesson/theme drafting

- `generate_n3_quartet_drafts.py`: drafts N3 lesson/theme structures using the QUARTET mapping approach
- `bootstrap_n3_starter.py`: creates a starter N3 lesson from open-source references
- `quartet1_theme_map.json`: lesson/theme grouping input used by drafting scripts

### Kanji support assets

- `sync_kanji_decomposition_labels.py`: syncs decomposition labels from content kanji files into support exports
- `generate_kanjivg_stroke_paths.py`: generates `assets/data/support/kanji/kanjivg_stroke_paths_n5n4.json`
- `generate_stroke_templates.py`: builds handwriting stroke templates
- `audit_handwriting_measurement.dart`: runs the deterministic handwriting measurement audit sample set (default `tooling/handwriting_audit_cases.v3.json`) and writes both `docs/reports/handwriting-measurement-audit-report.json` and `docs/reports/handwriting-measurement-audit-report.md`
- `promote_n4_curated_from_mistakes.py`: promotes curated template improvements from mistake-driven review

### Source cache / external source prep

- `build_jmdict_kanjidic_cache.py`: downloads and parses JMdict + KANJIDIC2 local caches
- `hanviet_manual_overrides.json`: manual Han-Viet override table used by repair scripts

### Operational workflow

- `run_promotion_workflow.py`: scheduled/forced promotion workflow entrypoint

## Conventions

- Runtime-facing app data should end up under `assets/data/content/` or `assets/data/support/`.
- Historical import sources belong under `assets/data/archive/`.
- Generated reports should go under `docs/reports/` unless they are workflow-local and temporary.
- Large or remote-source caches belong in `tooling/_tmpcache/` and should remain ignored locally.

## Recommended usage order

For content work, the most common sequence is:
- build source cache if needed
- generate or normalize content
- validate content
- review `docs/reports/` outputs

For grammar hardening work, the common sequence is:
- edit only grammar blocks that the audit marks as `real-quality-gap`
- run `dart run tooling/audit_grammar_example_quality.dart --locale en`
- run `python tooling/validate_content_assets_v2.py`
- review `docs/reports/grammar-example-quality-report.json` before treating the pass as done

For handwriting measurement work, the common sequence is:
- review `tooling/handwriting_audit_cases.v1.json` for synthetic baseline cases and `tooling/handwriting_audit_cases.v2.json` for initial lesson/example-derived cases and `tooling/handwriting_audit_cases.v3.json` for expanded real-data defect coverage
- run `flutter test test/tooling/handwriting_measurement_audit_runner_test.dart`
- review `docs/reports/handwriting-measurement-audit-report.json` and the paired `docs/reports/handwriting-measurement-audit-report.md` summary
