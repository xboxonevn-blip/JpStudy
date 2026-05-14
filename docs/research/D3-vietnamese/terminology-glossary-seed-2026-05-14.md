# D3 Vietnamese Terminology Glossary Seed - 2026-05-14

## Purpose

Create one editorial reference before broad UI copy edits. This is a seed, not final style guide.

## Recommended Terms

| Concept | Use | Avoid / Limit | Notes |
|---|---|---|---|
| JLPT | `JLPT` | translated expansion in compact UI | Stable exam brand |
| SRS | `SRS`, first-use helper `ôn lặp lại ngắt quãng` | translating every occurrence | Learners may know SRS; keep short in badges |
| review due | `ôn tập`, `đến hạn ôn` | `review ngay`, `review queue` in VI UI | Use `phản hồi` only for answer feedback |
| answer review/feedback | `phản hồi`, `xem lại đáp án` | `ôn tập` when not scheduling | Separate from SRS review |
| quiz | `bài luyện nhanh`, `câu hỏi nhanh` | raw `quiz` in learner-facing VI | `quiz` acceptable only in internal route names |
| mock exam | `thi thử`, `đề thi thử` | `mock` in VI copy | Keep `JLPT` if exam-specific |
| vocab | `từ vựng` | `từ` for module labels | `từ` OK inside sentence if context obvious |
| grammar point | `điểm ngữ pháp` | `mẫu` alone in navigation | `mẫu` OK inside explanation text |
| kanji | `kanji` | mixed `Kanji` mid-sentence | Use lowercase `kanji` in Vietnamese sentences; title case only headings |
| Han-Viet | `Hán Việt` | `Han-Viet`, `han viet` | Keep diacritics |
| deck | `bộ thẻ` | raw `deck` in learner-facing VI | For custom-deck feature, first mention can be `bộ thẻ (deck)` |
| track/lane | `lộ trình`, `nhánh học` | raw `track`, `lane` in VI UI | Pick by context: route/course = `lộ trình`; queue/lane = `nhánh học` |
| practice | `luyện`, `luyện tập` | `practice` | `ôn` only when revisiting learned items |
| weak spot | `điểm yếu` | `weak spot` | Consistent with D3 audit |
| streak | `chuỗi ngày` | `streak` | User-facing gamification |
| progress | `tiến độ` | `progress` | Consistent app-wide |
| premium/pro | `Pro`, `Premium` | over-translating plan names | Brand/product tier can remain |

## Priority Replacements From Current Audit

| Current pattern | Proposed replacement |
|---|---|
| `Review ngay` | `Ôn ngay` |
| `Review $levelCode` | `Ôn $levelCode` |
| `Lane hiện tại` | `Nhánh học hiện tại` |
| `Mở lane đồng hành` | `Mở nhánh học đồng hành` |
| `Catalog đang mở` | `Danh mục đang mở` |
| `Preview / lộ trình` | `Xem trước / lộ trình` |
| `Luồng quiz ngữ pháp` | `Luồng luyện ngữ pháp nhanh` |
| `Chưa có deck bài đọc` | `Chưa có bộ thẻ bài đọc` |
| `Deck Kanji` | `Bộ thẻ kanji` |
| `Luyện Kanji` | `Luyện kanji` |
| `Nghĩa Kanji` | `Nghĩa kanji` |

Applied in code:

- `Review ngay` -> `Ôn ngay`
- `Review $levelCode` -> `Ôn $levelCode`
- `Lane hiện tại` -> `Nhánh học hiện tại`
- `Mở lane đồng hành` -> `Mở nhánh học đồng hành`
- `Catalog đang mở` -> `Danh mục đang mở`
- `Preview / lộ trình` -> `Xem trước / lộ trình`
- `Chưa có deck bài đọc` -> `Chưa có bộ thẻ bài đọc`
- `Deck Kanji` -> `Bộ thẻ kanji`
- `B?i ng? ph?p` -> `Bài ngữ pháp`
- `Luy?n shadowing` -> `Luyện shadowing`
- `G?i sprint` -> `Gói sprint`
- `250 th?` -> `250 thẻ`
- `12 b?` -> `12 bộ`
- `S?n ?m thanh` -> `Sẵn âm thanh`
- `Luyện Kanji` -> `Luyện kanji`
- `Nghĩa Kanji` -> `Nghĩa kanji`

Regression tests:

- `test/features/vocab/vocab_copy_test.dart`
- `test/core/app_language_copy_test.dart`
- `test/features/custom_decks/custom_decks_screen_test.dart`

## Open Editorial Questions

1. Keep `kanji` as loanword everywhere, or use `Hán tự` for navigation? Current recommendation: `kanji` in learning flows, `Hán tự` only if a formal section title already uses it.
2. Keep `SRS` visible for all learners? Current recommendation: yes, but pair with a one-time explanation.
3. Use `bộ thẻ` or `deck` for custom decks? Current recommendation: `bộ thẻ`, with `(deck)` only in advanced/custom-deck context.
