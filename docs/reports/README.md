# Reports

`docs/reports/` contains generated audits, scorecards, migration summaries, and validation outputs.

## Typical report types

- content validation reports
- data migration reports
- quality/coherence audits
- source coverage reports
- tooling pipeline outputs

## Rules

- Prefer machine-generated or reproducible outputs here.
- Use descriptive filenames with level/scope/date where possible.
- Keep long-form human planning notes out of this folder.

## Canonical Release Reports

- `grammar-example-coverage-report.json`
  Active coverage baseline for `grammar_examples` density and missing-block checks.
- `grammar-example-quality-report.json`
  Active quality baseline for question-generation eligibility and example-block scoring.
  Missing capability flags are classified as either `expected-missing` (pattern/example shape is intentionally unsuitable for that question type) or `real-quality-gap` (the block likely needs data cleanup).
- `immersion-consistency-report.json`
  Active immersion content consistency baseline for lesson-level QA and priority fixing.
- `content-validation-v2.json`
  Active structural validation baseline for content bundle correctness.
- `canonical-content-v2-report.json`
  Active canonical content snapshot for cross-checking release readiness.
- `handwriting-measurement-audit-report.json`
  Canonical machine-readable handwriting scoring baseline across fixed audit samples.
- `handwriting-measurement-audit-report.md`
  Human-readable summary companion for the handwriting audit JSON, including pass rates, bucket splits, source-lesson splits, and failed-case highlights.

## Stale Or Legacy Reports

- `full-content-audit.json`
  Treat as a legacy snapshot until it is regenerated from the current pipeline. Do not use it as the release decision source when it disagrees with the active reports above.
