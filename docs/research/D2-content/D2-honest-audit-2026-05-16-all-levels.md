# D2 Honest Content Audit 2026-05-16 All Levels

## Verification

```bash
flutter test test\data\content_review_taxonomy_integrity_test.dart
dart run tool\research\content_vi_status_report.dart
```

## Current Status

| Level | Items | Machine | Open review | Approved | Tier |
|---|---:|---:|---:|---:|---|
| N5 | 3,497 | 0 | 0 | 3,497 | Launch-tier |
| N4 | 3,376 | 0 | 0 | 3,376 | Launch-tier |
| N3 | 3,412 | 0 | 0 | 3,412 | Launch-tier quality; user spot-check pending |
| N2 | 4,770 | 0 | 0 | 4,770 | Launch-tier quality; user spot-check pending |
| N1 | 8,389 | 0 | 0 | 8,389 | Launch-tier quality; user spot-check pending |

## Dataset Status

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 0 | 0 | 754 |
| grammar_examples | 4,924 | 0 | 0 | 4,924 |
| immersion | 125 | 0 | 0 | 125 |
| kanji | 929 | 0 | 0 | 929 |
| vocab | 16,712 | 0 | 0 | 16,712 |

## Notes

- No `vi-human-approved` tag was added by Codex.
- N1/N2 placeholder grammar examples were translated earlier; current grep finds no `Bản dịch ví dụ cần biên tập từ:`.
- N1 grammar explanations were rewritten from placeholder text to fluent Vietnamese.
- N1 kanji open-review entries now have Han-Viet readings and Vietnamese display glosses.
- N1 Tanos vocab was aligned to the reviewed N1 Hajimete vocabulary set where possible; 13 unmatched terms were manually translated, then separator/duplicate glosses were polished.
- N1 kanji scope caveat remains: this is editorial quality for current app content, not expansion to the full 2,000-kanji N1 target.

## Remaining Gate

User review of spot-check files is still required before any `vi-human-approved` tagging:

- `D2-spot-check-N3-2026-05-16.md`
- `D2-spot-check-N2-2026-05-16.md`
- `D2-spot-check-N1-2026-05-16.md`
