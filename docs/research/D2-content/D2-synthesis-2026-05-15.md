# D2 Launch-Readiness Synthesis 2026-05-15

## Status

This document was corrected on 2026-05-16 after a content-tag integrity audit found false `vi-human-approved` tags on draft N1/N2 content.

The previous claim that the full N5-N1 editorial batch was human-reviewed was invalid. `vi-human-approved` must mean verified content, not blanket approval. The content-status auditor now keeps machine-draft and open-review debt visible even when an approval tag is also present.

## Current Honest Audit

Fresh audit command:

```bash
dart run tool\research\content_vi_status_report.dart
```

| Metric | Current |
|---|---:|
| Files scanned | 781 |
| Items scanned | 23,444 |
| Files with machine VI | 150 |
| Files with open review tags | 75 |
| Files with approval signals | 675 |

| Level | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| N5 | 3,497 | 0 | 0 | 3,497 |
| N4 | 3,376 | 0 | 0 | 3,376 |
| N3 | 3,412 | 0 | 100 | 3,412 |
| N2 | 4,770 | 2,752 | 764 | 2,209 |
| N1 | 8,389 | 4,701 | 980 | 3,933 |

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 436 | 100 | 754 |
| grammar_examples | 4,924 | 1,744 | 1,744 | 3,180 |
| vocab | 16,712 | 5,273 | 0 | 11,439 |
| kanji | 929 | 0 | 0 | 929 |
| immersion | 125 | 0 | 0 | 125 |

## Launch Tier

N5/N4 remain launch-tier for the 5-10 learner pilot:

- N5: `3,497` items, `0` machine draft, `0` open review.
- N4: `3,376` items, `0` machine draft, `0` open review.
- Grammar, vocab, kanji, and examples at N5/N4 have the launch editorial pass recorded.

This is not a claim that every upper-level item was human-reviewed.

## N3 Status

N3 is translated enough to avoid English placeholder output in the checked data, but it is not a clean fully-approved tier yet:

- `0` machine-draft items found.
- `100` open review tags remain in `assets/data/content/grammar/n3/grammar_n3_*.json`.
- Treat N3 as available with review-debt disclosure until those grammar tags are resolved through a real editorial pass.

## N1/N2 Status

N1/N2 are draft-tier, not launch-tier:

- `50` files under `assets/data/content/grammar_examples/n1/` and `assets/data/content/grammar_examples/n2/` still contain placeholder Vietnamese like `Bản dịch ví dụ cần biên tập từ: [English]`.
- Those 50 files are tagged honestly with `vi-machine-draft` and `vi-needs-review`.
- They no longer carry `vi-human-approved`.
- N2 current debt: `2,752` machine items, `764` open-review items.
- N1 current debt: `4,701` machine items, `980` open-review items.
- N1 kanji scope is still `889 / 2,000`; do not market full N1 kanji coverage.

## Verification

Commands run for the correction:

```bash
flutter test test\core\research\content_vi_status_audit_test.dart test\tool\research\content_vi_status_report_test.dart
dart run tool\research\content_vi_status_report.dart
```

Approval contradiction grep:

```text
vi-human-approved + draft/review/placeholder marker in same content file: 0
```

## Deferred

- Real translation/editorial pass for N1/N2 grammar examples.
- N1/N2 vocab editorial pass.
- N3 grammar review cleanup.
- N1 kanji scope expansion from current app scope toward 2,000 target.
