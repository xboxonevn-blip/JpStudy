# Upper JLPT Content Editorial Backlog

Status: code/data plumbing is complete and validated. Remaining work is editorial, not safe to auto-complete without JLPT review.

## Current Seed Coverage

- N3: local lesson ids 1-25 for grammar, examples, kanji, immersion.
- N2: local lesson ids 1-25 for grammar, examples, kanji, immersion; 191 grammar explanations are user-approved Vietnamese drafts; 1797 vocab items remain internal Vietnamese drafts tagged `needs-human-review`; 200 derived kanji have user-approved Unihan stroke/Hán Việt metadata where available; 25 original reading passages are user-approved.
- N1: local lesson ids 1-25 for grammar, examples, kanji, immersion; 245 grammar explanations are user-approved Vietnamese drafts; 3476 vocab items remain internal Vietnamese drafts tagged `needs-human-review`; 200 derived kanji have user-approved Unihan stroke/Hán Việt metadata where available; 25 original reading passages are user-approved.

## Editorial Exit Criteria

- Improve approved N2/N1 grammar explanations with example-level Vietnamese translations when editorial time is available.
- Review `docs/reports/upper-jlpt-vocab-vi-review.csv`, replacing `[VI cần duyệt]` fallback glosses with natural Vietnamese.
- Review `docs/reports/upper-jlpt-kanji-unihan-review.csv` for kanji missing Unihan Hán Việt values, then replace derived kanji lists with a reviewed N2/N1 syllabus when available.
- Add comprehension questions for approved N2/N1 immersion passages.
- Remove `manual-review-needed` / `needs-vi-editorial` tags only after review passes.

## Guardrails

- `test/data/upper_jlpt_content_integrity_test.dart` protects lesson id ranges, minimum payload, JSON parseability, and mojibake regressions.
- Keep upper levels using local lesson ids 1-25; do not reintroduce N3 global ids 51-75.
