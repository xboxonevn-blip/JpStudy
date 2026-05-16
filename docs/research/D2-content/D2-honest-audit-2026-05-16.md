# D2 Honest Content Audit 2026-05-16

## Scope

This audit corrects the D2 approval-tag integrity violation found on 2026-05-16. It reports current content state after removing false `vi-human-approved` tags from draft/review-marked content.

## Verification Commands

```bash
flutter test test\core\research\content_vi_status_audit_test.dart test\tool\research\content_vi_status_report_test.dart
dart run tool\research\content_vi_status_report.dart
```

Contradiction guard:

```text
vi-human-approved + draft/review/placeholder marker in same content file: 0
```

## Current Audit Totals

| Metric | Count |
|---|---:|
| Files scanned | 781 |
| Items scanned | 23,444 |
| Files with machine VI | 150 |
| Files with open review tags | 75 |
| Files with approval signals | 675 |

## By JLPT Level

| Level | Items | Machine | Open review | Approved | Current tier |
|---|---:|---:|---:|---:|---|
| N5 | 3,497 | 0 | 0 | 3,497 | Launch-tier |
| N4 | 3,376 | 0 | 0 | 3,376 | Launch-tier |
| N3 | 3,412 | 0 | 100 | 3,412 | Review debt |
| N2 | 4,770 | 2,752 | 764 | 2,209 | Draft-tier |
| N1 | 8,389 | 4,701 | 980 | 3,933 | Draft-tier |

## By Dataset

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 436 | 100 | 754 |
| grammar_examples | 4,924 | 1,744 | 1,744 | 3,180 |
| immersion | 125 | 0 | 0 | 125 |
| kanji | 929 | 0 | 0 | 929 |
| vocab | 16,712 | 5,273 | 0 | 11,439 |

## Launch-Tier Decision

N5/N4 are the launch tier for the beginner-heavy pilot:

- N5 has `0` machine-draft items and `0` open-review items.
- N4 has `0` machine-draft items and `0` open-review items.
- These levels can be used for pilot learning flows.

## N3 Reality

N3 is not machine-draft in the current audit, but it still has review debt:

- `0` machine-draft items.
- `100` open-review tags.
- Open tags are in `25` files under `assets/data/content/grammar/n3/grammar_n3_*.json`.
- N3 should keep an editorial-review note until those grammar tags are resolved.

## N1/N2 Reality

N1/N2 are not launch-ready:

- `50` files under `assets/data/content/grammar_examples/n1/` and `assets/data/content/grammar_examples/n2/` still contain placeholder Vietnamese.
- Placeholder examples: `1,744`.
- Those 50 files now have honest root tags: `vi-machine-draft` and `vi-needs-review`.
- `vi-human-approved` was removed from those files.
- N2 still has `2,752` machine items and `764` open-review items.
- N1 still has `4,701` machine items and `980` open-review items.

## Deferred Work

- Translate and editorial-review the 50 N1/N2 grammar-example placeholder files.
- Complete N1/N2 vocabulary editorial review.
- Resolve the 100 N3 grammar open-review tags.
- Expand N1 kanji scope beyond the current `889 / 2,000` app coverage.
