# Tooling Workflows

## Scheduled N4 Promotion

Use `run_promotion_workflow.py` as the release/tooling entrypoint.

### Run every app start (but gate to weekly)

```bash
python tooling/run_promotion_workflow.py --schedule app-start --interval-days 7
```

### Run from a weekly job (CI / Task Scheduler)

```bash
python tooling/run_promotion_workflow.py --schedule weekly --interval-days 7
```

### Force run now

```bash
python tooling/run_promotion_workflow.py --force
```

## Reports

- Promotion history JSON: `tooling/reports/n4_promotion_history.json`
- Scheduler state JSON: `tooling/reports/n4_promotion_schedule_state.json`

Each promotion run appends one entry to the history file, including:
- run time, mode, promoted count
- list of promoted characters (lesson/stroke/score)

## Canonical Content v2

Use the canonical content workflow when you want vocab / kanji data to stay
normalized, reproducible, and aligned with lesson assets.

### Sync embedded decomposition

```bash
python tooling/sync_kanji_decomposition_labels.py
```

This updates `decomposition` inside lesson kanji JSON files and rewrites
`assets/data/kanji/decomposition.json` as a derived compatibility export.

### Build canonical exports

```bash
python tooling/build_canonical_content_v2.py
```

Outputs:
- `assets/data/canonical/index.json`
- `assets/data/canonical/vocab/n5/lesson_XX.json`
- `assets/data/canonical/vocab/n4/lesson_XX.json`
- `assets/data/canonical/kanji/n5/lesson_XX.json`
- `assets/data/canonical/kanji/n4/lesson_XX.json`
- `docs/reports/canonical-content-v2-report.json`

### Validate content integrity

```bash
python tooling/validate_content_assets_v2.py
```

Validation report:
- `docs/reports/content-validation-v2.json`

Schema guide:
- `docs/DATA_SCHEMA_V2.md`

## N3 starter bootstrap

Use this when you want to begin populating `N3` with a reviewed canonical lesson
instead of bulk-importing an unverified list.

```bash
python tooling/bootstrap_n3_starter.py
```

References:
- `docs/reports/n3-source-audit-2026-03-16.md`
- `assets/data/canonical/vocab/n3/lesson_51.json`
- `assets/data/canonical/kanji/n3/lesson_51.json`

## JMdict + KANJIDIC2 pipeline

Build local parsed caches from the official EDRDG source archives:

```bash
python tooling/build_jmdict_kanjidic_cache.py
```

Quick validation mode:

```bash
python tooling/build_jmdict_kanjidic_cache.py --limit 100
```

Outputs:
- `tooling/_tmpcache/jmdict_kanjidic/raw/JMdict_e.gz`
- `tooling/_tmpcache/jmdict_kanjidic/raw/kanjidic2.xml.gz`
- `tooling/_tmpcache/jmdict_kanjidic/parsed/jmdict_e_min.json`
- `tooling/_tmpcache/jmdict_kanjidic/parsed/kanjidic2_min.json`
- `docs/reports/jmdict-kanjidic-cache-report.json`

Supporting theme map:
- `tooling/quartet1_theme_map.json`

## Full content audit

Run a repo-wide data completeness audit and local self-heal passes:

```bash
python tooling/audit_content_completeness.py --apply-fixes
```

Output:
- `docs/reports/full-content-audit.json`
