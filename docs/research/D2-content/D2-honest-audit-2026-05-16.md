# D2 Honest Content Audit 2026-05-16

## Scope

This audit corrects the D2 approval-tag integrity violation found on
2026-05-16. The initial correction removed false `vi-human-approved` tags from
draft/review-marked content. The later all-levels editorial pass supersedes the
intermediate debt counts; see
`D2-honest-audit-2026-05-16-all-levels.md`.

## Verification Commands

```bash
flutter test test\data\content_review_taxonomy_integrity_test.dart
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
| Files with machine VI | 0 |
| Files with open review tags | 0 |
| Files with approval signals | 775 |

## By JLPT Level

| Level | Items | Machine | Open review | Approved | Current tier |
|---|---:|---:|---:|---:|---|
| N5 | 3,497 | 0 | 0 | 3,497 | Launch-tier |
| N4 | 3,376 | 0 | 0 | 3,376 | Launch-tier |
| N3 | 3,412 | 0 | 0 | 3,412 | Launch-tier quality; user spot-check pending |
| N2 | 4,770 | 0 | 0 | 4,770 | Launch-tier quality; user spot-check pending |
| N1 | 8,389 | 0 | 0 | 8,389 | Launch-tier quality; user spot-check pending |

## By Dataset

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 0 | 0 | 754 |
| grammar_examples | 4,924 | 0 | 0 | 4,924 |
| immersion | 125 | 0 | 0 | 125 |
| kanji | 929 | 0 | 0 | 929 |
| vocab | 16,712 | 0 | 0 | 16,712 |

## Launch-Tier Decision

N5/N4 are the beginner-heavy pilot launch tier.

N3/N2/N1 now have launch-tier editorial quality in the repo audit sense:
`0` machine-draft items, `0` open-review items, and no placeholder example
translations. Codex did not add `vi-human-approved`; user review is still
required before that tag can be applied.

## Remaining Caveats

- N3/N2/N1 spot-check samples await user review.
- N1 kanji scope remains below the 2,000 target; this audit covers quality for
  current app content, not full N1 content expansion.
