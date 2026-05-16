# D2 Launch-Readiness Synthesis 2026-05-15

## Status

The D2 pass moved N5/N4 from unauditable to launch-tier for a 5-10 learner pilot. User follow-up on 2026-05-15 confirmed the N5-N1 editorial batch was reviewed, so `vi-human-approved` is applied across all scanned N5-N1 content. User confirmation on 2026-05-16 additionally authorized direct item-level tagging for remaining N1-N5 editorial-batch entries. The content-status auditor now treats `vi-human-approved` as closing stale machine/open-review tags; those tags remain only as provenance.

## Before / After

| Metric | Baseline | After pass |
|---|---:|---:|
| Files scanned | 781 | 781 |
| Items scanned | 23,444 | 23,444 |
| Files with machine VI | 150 | 0 |
| Files with open review tags | 105 | 0 |
| Files with approval signals | 150 | 775 |

| Level | Baseline approved | After approved | Open review after |
|---|---:|---:|---:|
| N5 | 0 | 3,497 | 0 |
| N4 | 0 | 3,376 | 0 |
| N3 | 0 | 3,412 | 0 |
| N2 | 367 | 4,770 | 0 |
| N1 | 417 | 8,389 | 0 |

| Dataset | Baseline approved | After approved |
|---|---:|---:|
| grammar | 436 | 754 |
| grammar_examples | 0 | 4,924 |
| vocab | 0 | 16,712 |
| kanji | 298 | 929 |

## Launch Tier

N5/N4 are launch-tier for pilot use:

- Grammar explanations: N5 `118/118`, N4 `100/100` approved.
- Grammar examples: N5 `1,180`, N4 `1,000` approved through accepted spot-check batch.
- Vocab: N5 `1,327`, N4 `1,478` Minna entries approved through accepted spot-check batch.
- Kanji: N5 `185`, N4 `141` entries approved through accepted spot-check batch.
- Mojibake integrity test covers content JSON and passes on the checked suite.

## Upper-Level Scope

N3/N2/N1 now carry user approval. Remaining caveats are scope/routing, not Vietnamese review status:

- Local Minna vocab route stops at N4; N3-N1 use JLPT-focused `ShinKanzen`/`hajimete` routes.
- N1 kanji scope is still `889 / 2,000`; do not market full N1 kanji coverage.
- N3+ grammar/vocab surfaces keep an upper-level scope note, not a draft-quality warning.

## Verification

Commands run during this pass:

```bash
flutter test test\data\repositories\grammar_repository_test.dart test\data\content_mojibake_integrity_test.dart test\core\research\content_vi_status_audit_test.dart
flutter test test\features\grammar\grammar_screen_test.dart test\features\vocab\vocab_screen_test.dart
flutter test test\core\app_language_copy_test.dart test\data\content_mojibake_integrity_test.dart
dart run tool\research\content_vi_status_report.dart
```

Latest audit:

```text
N5 approved 3497, open 0
N4 approved 3376, open 0
N3 approved 3412, open 0
N2 approved 4770, open 0
N1 approved 8389, open 0
```

## Deferred

- N1 kanji scope expansion from current app scope toward 2,000 target.
