# Grammar Hardening Execution Plan - 2026-03-24

## Status

- This file is the canonical working-memory plan for the `2026-03-24` grammar hardening pass.
- It supersedes `docs/plans/next-execution-plan-2026-03-19.md`, which should now be treated as historical context only.
- Scope for this execution cycle stays data-first grammar hardening. Cloud sync and dependency refresh remain out of scope for this branch.
- Canonical grammar quality status after the pass: `0` real quality gaps across `N5`, `N4`, and `N3` in `docs/reports/grammar-example-quality-report.json`.

## Completed In This Pass

- tightened `GrammarExampleQualityAssessor` and `GrammarQuestionGenerator` together so transformation support matches real runtime behavior for plain-form negatives and `〜ている`
- reclassified formula-style, request-like, and dialogue-style grammar blocks as `expected-missing` when the app should not generate those question types from them
- repaired the actual `N5` context-choice-ready example gaps in the flagged grammar example assets
- regenerated `docs/reports/grammar-example-quality-report.json`
- kept public grammar models, question enums, and Grammar Practice screen inputs stable
- replaced the skipped legacy mock-exam walkthrough with a smaller submit/results regression that is intended to stay stable in the full suite

## Worktree Hygiene Notes

- Keep `.claude/settings.local.json` out of the work commit.
- The existing five unrelated test-cleanup edits should be landed separately as a baseline-green change if they are intended to stay.
- Do not reopen `expected-missing` grammar blocks unless runtime question requirements change.

## Canonical Commands

```bash
flutter test test/features/grammar/grammar_question_generator_test.dart
flutter test test/features/grammar/grammar_practice_screen_test.dart
flutter test test/data/utils/grammar_example_quality_test.dart

dart run tooling/audit_grammar_example_quality.dart --locale en
python tooling/validate_content_assets_v2.py

flutter analyze
flutter test
flutter build web
```

## Truth Artifacts

- Grammar quality report: `docs/reports/grammar-example-quality-report.json`
- Active execution plan: `docs/plans/2026-03-24-grammar-hardening-execution-plan.md`
- Release-truth docs: `README.md`, `ROADMAP.md`, `tooling/README.md`

## What Next

- Keep the grammar report green and treat future grammar changes as regressions unless the report semantics intentionally change.
- Move the next hardening slice to handwriting reliability and route / release stability.
- Continue replacing flaky walkthroughs with stable focused regressions on high-value user flows.
- Schedule dependency refresh in a separate plan rather than mixing it into grammar hardening.
