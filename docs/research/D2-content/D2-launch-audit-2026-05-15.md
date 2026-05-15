# D2 Launch Audit 2026-05-15

## Scope

This is the launch-readiness baseline before the D2 editorial pass.

User update 2026-05-15: spot-check samples are accepted. For batches that are actually editorial-reviewed in this pass, Codex may add `vi-human-approved` together with the audit trail tag. This does not authorize blanket approval for untouched content.

## Fresh Status

Command:

```bash
dart run tool/research/content_vi_status_report.dart
```

Result:

| Metric | Count |
|---|---:|
| Files scanned | 781 |
| Items scanned | 23,444 |
| Files with machine VI | 150 |
| Files with open review tags | 105 |
| Files with approval signals | 150 |

## By JLPT Level

| Level | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| N1 | 8,389 | 4,701 | 980 | 417 |
| N2 | 4,770 | 2,752 | 764 | 367 |
| N3 | 3,412 | 0 | 100 | 0 |
| N4 | 3,376 | 0 | 35 | 0 |
| N5 | 3,497 | 0 | 7 | 0 |

## By Dataset

| Dataset | Items | Machine | Open review | Approved |
|---|---:|---:|---:|---:|
| grammar | 754 | 436 | 142 | 436 |
| grammar_examples | 4,924 | 1,744 | 1,744 | 0 |
| immersion | 125 | 0 | 0 | 50 |
| kanji | 929 | 0 | 0 | 298 |
| vocab | 16,712 | 5,273 | 0 | 0 |

## Encoding Sweep Baseline

UTF-8 parse check:

| Check | Result |
|---|---|
| JSON files parsed | 781 |
| Invalid JSON / invalid UTF-8 | 0 |
| Double-encoded UTF-8 marker families (Latin-A continuation, broken smart-punctuation bytes, escaped replacement code points) | 0 |
| Probable `?` replacement artifacts | 442 matches in 62 files |

The `?` queue is not the same as normal question punctuation. It is focused on patterns such as `xu?t hi?n`, `trong t?`, `Ng??i`, `Nh?n`, and `b?n d?ch`.

Top affected areas:

| Area | Finding |
|---|---|
| `assets/data/content/kanji/n1` | repeated scaffold text `Kanji xu?t hi?n trong t? JLPT N1...` |
| `assets/data/content/kanji/n2` | repeated scaffold text `Kanji xu?t hi?n trong t? JLPT N2...` |
| `assets/data/content/kanji/n4/lesson_39.json` | mnemonic text has multiple replacement artifacts |
| `assets/data/content/kanji/n4/lesson_45.json` | mnemonic text has multiple replacement artifacts |
| `assets/data/content/vocab/n3/ShinKanzen` | several Vietnamese gloss and Han-Viet fields still contain replacement artifacts |

## Literal-Template Patterns

Observed priority patterns:

| Pattern | Risk | Priority |
|---|---|---|
| `[VI cần duyệt] ...` in upper vocab | User-facing draft marker leaks into content | N2/N1 draft-tier cleanup |
| `Kanji xuất hiện trong từ JLPT ... (English gloss)` | Grammatically okay after mojibake fix, but still template-heavy | N1/N2 kanji draft-tier |
| Grammar examples with literal Vietnamese | Beginner comprehension issue | N5/N4 launch-tier |
| Untagged N5/N4 grammar files | Audit cannot distinguish reviewed vs untouched | N5/N4 launch-tier |

## Priority Queue

1. D2-2: fix probable `?` replacement artifacts, starting with N4/N5 launch scope and safe repeated N1/N2 kanji scaffold text.
2. D2-3: N5 grammar editorial pass; tag reviewed files with `vi-editorial-codex-pass` and `vi-human-approved`.
3. D2-4: N4 grammar editorial pass; same tag discipline.
4. D2-5/D2-6: N5/N4 vocab and kanji Han-Viet checks.
5. D2-7/D2-8: normalize taxonomy and add N3+ draft-quality disclaimer.

## Launch Decision

N5/N4 are not yet auditable as launch-ready because approval coverage is currently `0` by level, despite many files appearing readable. The next commits must create an audit trail tied to actual editorial review.

N3+ remains draft-tier. It can stay available only with a visible editorial-review disclaimer.
