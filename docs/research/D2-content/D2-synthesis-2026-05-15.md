# D2 Launch-Readiness Synthesis 2026-05-15

## Status

The D2 pass moved N5/N4 from unauditable to launch-tier for a 5-10 learner pilot. N3+ remains available as draft-tier with an in-app disclaimer.

## Before / After

| Metric | Baseline | After pass |
|---|---:|---:|
| Files scanned | 781 | 781 |
| Items scanned | 23,444 | 23,444 |
| Files with machine VI | 150 | 150 |
| Files with open review tags | 105 | 75 |
| Files with approval signals | 150 | 350 |

| Level | Baseline approved | After approved | Open review after |
|---|---:|---:|---:|
| N5 | 0 | 2,810 | 0 |
| N4 | 0 | 2,719 | 0 |
| N3 | 0 | 0 | 100 |
| N2 | 367 | 367 | 764 |
| N1 | 417 | 417 | 980 |

| Dataset | Baseline approved | After approved |
|---|---:|---:|
| grammar | 436 | 654 |
| grammar_examples | 0 | 2,180 |
| vocab | 0 | 2,805 |
| kanji | 298 | 624 |

## Launch Tier

N5/N4 are launch-tier for pilot use:

- Grammar explanations: N5 `118/118`, N4 `100/100` approved.
- Grammar examples: N5 `1,180`, N4 `1,000` approved through accepted spot-check batch.
- Vocab: N5 `1,327`, N4 `1,478` Minna entries approved through accepted spot-check batch.
- Kanji: N5 `185`, N4 `141` entries approved through accepted spot-check batch.
- Mojibake integrity test covers content JSON and passes on the checked suite.

## Draft Tier

N3/N2/N1 remain draft-tier:

- N3 still has `100` open grammar review items.
- N2/N1 still contain machine-origin upper-level grammar/example/vocab content.
- UI disclaimer shipped for N3+ grammar/vocab surfaces: "N3+ content is still under editorial review."

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
N5 approved 2810, open 0
N4 approved 2719, open 0
N3 approved 0, open 100
N2 approved 367, open 764
N1 approved 417, open 980
```

## Deferred

- N3/N2/N1 full editorial pass.
- N1 kanji scope expansion from current app scope toward 2,000 target.
- Upper-level grammar examples rewrite.
- Upper-level vocab machine-origin cleanup.
