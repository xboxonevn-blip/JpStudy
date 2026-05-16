# D2 Launch-Readiness Synthesis 2026-05-15

## Status

This document was corrected on 2026-05-16 after a content-tag integrity audit
found false `vi-human-approved` tags on draft N1/N2 content. The later
all-levels editorial pass is tracked in
`D2-honest-audit-2026-05-16-all-levels.md`.

`vi-human-approved` must mean user-verified content, not blanket approval.
Codex did not add `vi-human-approved` during the all-levels pass; upper-level
spot-check files remain pending for user review.

## Current Honest Audit

Fresh audit command:

```bash
dart run tool\research\content_vi_status_report.dart
```

| Metric | Current |
|---|---:|
| Files scanned | 781 |
| Items scanned | 23,444 |
| Files with machine VI | 0 |
| Files with open review tags | 0 |
| Files with approval signals | 775 |

| Level | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| N5 | 3,497 | 0 | 0 | 3,497 |
| N4 | 3,376 | 0 | 0 | 3,376 |
| N3 | 3,412 | 0 | 0 | 3,412 |
| N2 | 4,770 | 0 | 0 | 4,770 |
| N1 | 8,389 | 0 | 0 | 8,389 |

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 0 | 0 | 754 |
| grammar_examples | 4,924 | 0 | 0 | 4,924 |
| immersion | 125 | 0 | 0 | 125 |
| kanji | 929 | 0 | 0 | 929 |
| vocab | 16,712 | 0 | 0 | 16,712 |

## Launch Tier

N5/N4 remain launch-tier for the beginner-heavy pilot.

N3/N2/N1 now meet the repo audit definition for launch-tier quality:

- `0` machine-draft items.
- `0` open-review items.
- No `Bản dịch ví dụ cần biên tập từ:` placeholder text in current content.
- Spot-check samples exist for user review:
  `D2-spot-check-N3-2026-05-16.md`,
  `D2-spot-check-N2-2026-05-16.md`, and
  `D2-spot-check-N1-2026-05-16.md`.

This is still not a claim that N3/N2/N1 have user-level human approval.

## Verification

Commands run for the all-levels correction:

```bash
flutter test test\data\content_review_taxonomy_integrity_test.dart
dart run tool\research\content_vi_status_report.dart
flutter analyze lib test
flutter test
flutter build web --release --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=$env:JPSTUDY_RECAPTCHA_SITE_KEY
firebase deploy --only hosting:jpstudy
```

Approval contradiction grep:

```text
vi-human-approved + draft/review/placeholder marker in same content file: 0
```

## Caveats

- User review is still required before any `vi-human-approved` tagging.
- N1 kanji scope remains below the 2,000 target; this pass improved editorial
  quality for current app content, not content coverage.
