# Upper JLPT Content Editorial Backlog

Status: code/data plumbing is complete and validated. Remaining work is editorial, not safe to auto-complete without JLPT review.

## Current Seed Coverage

- N3: local lesson ids 1-25 for grammar, examples, kanji, immersion.
- N2: local lesson ids 1-25 for grammar, examples, kanji, immersion; grammar/vocab imported from Hanabira/Tanos and tagged `needs-vi-editorial`; kanji/immersion remain scaffold/manual-review.
- N1: local lesson ids 1-25 for grammar, examples, kanji, immersion; grammar/vocab imported from Hanabira/Tanos and tagged `needs-vi-editorial`; kanji/immersion remain scaffold/manual-review.

## Editorial Exit Criteria

- Review imported grammar explanations and add human-quality Vietnamese copy.
- Replace synthetic kanji placeholders with a reviewed N2/N1 kanji syllabus, readings, meanings, examples, and stroke counts.
- Replace immersion scaffold articles with natural graded reading passages and validated quizzes.
- Remove `manual-review-needed` / `needs-vi-editorial` tags only after review passes.

## Guardrails

- `test/data/upper_jlpt_content_integrity_test.dart` protects lesson id ranges, minimum payload, JSON parseability, and mojibake regressions.
- Keep upper levels using local lesson ids 1-25; do not reintroduce N3 global ids 51-75.
