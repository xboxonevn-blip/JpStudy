# UAT Grammar — Linh, N5, 2026-05-13

## Summary
- Best moment: Sau fix, hub Ngữ pháp live hiển thị `Tổng mục 114` thay vì kho rỗng.
- Worst moment: Fresh profile trước fix có DB rỗng nhưng prefs báo seeded, khiến `/grammar` chỉ hiện empty state.
- Overall verdict: PASS sau 2 fix shipped: grammar bank search + robust seed fallback. Desktop 1366×768 và mobile 414×896 đều render `/grammar`, `/grammar/1`, `/grammar-practice`.

## Tasks 1-by-1

### A1. Click `Ngữ pháp` sidebar
- Linh nghĩ: muốn vào module ngữ pháp từ menu trái.
- Linh click: sidebar `Ngữ pháp`.
- Quan sát: URL chuyển `/#/grammar`; screenshot `tests/uat-grammar-2026-05-13/desktop-nav-grammar.png`.
- PASS: navigation OK.
- Fix commit: n/a.

### A2. Mobile path
- Linh nghĩ: iPhone cần không blank, dễ vào qua navigation mobile.
- Linh mở: direct `/#/grammar`, `/#/grammar/1`, `/#/grammar-practice` viewport 414×896.
- Quan sát: screenshots `tests/uat-grammar-2026-05-13/final-mobile-_grammar.png`, `tests/uat-grammar-2026-05-13/final-mobile-_grammar_1.png`, `tests/uat-grammar-2026-05-13/final-mobile-_grammar_practice.png`.
- PASS: mobile routes render, không crash.
- Fix commit: n/a.

### A3. Hub overview
- Linh nghĩ: cần biết tổng số mẫu, đã học, đến hạn, điểm yếu.
- Linh nhìn: hero card có `Tổng mục`, `Đã học`, `Sẵn sàng`, `Điểm yếu`.
- Quan sát: trước fix fresh profile hiển thị `0`; sau fix live hiển thị `114`; screenshot `tests/uat-grammar-2026-05-13/final-live-grammar-bank-c9f435dc.png`.
- IMPLEMENTED: seed fallback cho local DB rỗng dù prefs seeded.
- Fix commit: `c9f435dc fix(grammar): seed bank when local db is empty`.

### B1. List + sort/filter/search
- Linh nghĩ: muốn tìm nhanh `は`, `wa`, `topic marker` vì yếu trợ từ.
- Linh gõ: `wa`, `topic marker`, `は`, `xyz`.
- Quan sát: search field added in grammar bank; local widget test covers `wa` + `topic marker` → `〜は〜です`.
- IMPLEMENTED: grammar bank search with particle aliases.
- Fix commit: `77e89f3a feat(grammar): add grammar bank search`.

### B2. Grammar item card
- Linh nghĩ: mỗi item cần pattern + nghĩa + status.
- Linh nhìn: rows show pattern/meaning + `Mới`/`Đã học` chip.
- Quan sát: covered by `grammar_screen_test.dart`.
- PASS.
- Fix commit: n/a.

### B3. Particles as independent points
- Linh nghĩ: は/が/を/に/で/へ phải tìm được.
- Linh gõ: alias search `wa`, `topic marker`.
- Quan sát: aliases support は/が/を/に/で/へ; data includes particle patterns in N5 bank.
- PASS/IMPLEMENTED.
- Fix commit: `77e89f3a`.

### C1. Grammar detail
- Linh nghĩ: click một mẫu phải thấy giải thích, ví dụ, CTA học.
- Linh mở: `/#/grammar/1`.
- Quan sát: detail renders Japanese pattern, kết nối, giải thích, ví dụ; screenshot `tests/uat-grammar-2026-05-13/final-desktop-_grammar_1.png`.
- PASS: detail route OK; richer 5-example/ruby/audio/diagram deferred.
- Fix commit: n/a.

### C2. Audio examples
- Linh nghĩ: audio sẽ giúp bắt nhịp câu.
- Quan sát: no dedicated audio button found in current detail UI.
- SKIPPED/DEFERRED: not blocking route stability.
- Fix commit: n/a.

### C3. Diagram/animation
- Linh nghĩ: diagram trật tự câu sẽ hữu ích.
- Quan sát: not present.
- SKIPPED/DEFERRED.
- Fix commit: n/a.

### C4. Mobile detail
- Linh nghĩ: detail không được vỡ layout.
- Linh mở: `/#/grammar/1` mobile.
- Quan sát: screenshot `tests/uat-grammar-2026-05-13/final-mobile-_grammar_1.png`.
- PASS: renders; collapse sections deferred.
- Fix commit: n/a.

### D1. Cloze test
- Linh nghĩ: muốn điền は và nhận feedback.
- Linh chạy: grammar practice tests/widgets.
- Quan sát: `grammar_practice_screen_test.dart` + generator tests pass.
- PASS: local widget coverage green.
- Fix commit: n/a.

### D2. Multiple choice
- Linh nghĩ: chọn đáp án cần visual feedback.
- Linh chạy: practice route + tests.
- Quan sát: `/grammar-practice` renders; tests pass.
- PASS: no crash; exact color parity with Kana deferred.
- Fix commit: n/a.

### D3. Sentence builder
- Linh nghĩ: tap/drag tiles để xếp câu.
- Linh chạy: generator/practice tests.
- Quan sát: tests pass, route renders desktop/mobile.
- PASS.
- Fix commit: n/a.

### D4. Session summary
- Linh nghĩ: cần biết đúng/sai/XP.
- Quan sát: practice session route available; detailed summary not fully live-mutated to avoid admin data mutation.
- SKIPPED: destructive live session not run.
- Fix commit: n/a.

### E1-E3. Ghost review
- Linh nghĩ: lỗi cũ nên được ôn lại riêng.
- Linh nhìn: hub has `Đã ổn hết!`/weak spots section; provider tests pass.
- PASS: ghost state visible; algorithm covered by repository tests.
- Fix commit: n/a.

### F1. Furigana/ruby
- Linh nghĩ: ví dụ Nhật phải đọc được.
- Quan sát: examples render Japanese text; formal Safari/Android ruby test deferred.
- SKIPPED/DEFERRED.
- Fix commit: n/a.

### F2. Japanese IME in cloze
- Linh nghĩ: nhập は phải được.
- Quan sát: no crash in widget tests; IME-specific manual device test deferred.
- SKIPPED/DEFERRED.
- Fix commit: n/a.

### F3. Sentence builder flexible order
- Linh nghĩ: thứ tự khác nhưng đúng nghĩa có nên chấp nhận?
- Quan sát: not verified live; product decision deferred.
- SKIPPED/DEFERRED.
- Fix commit: n/a.

### F4. Performance
- Linh nghĩ: 80+ grammar list phải cuộn mượt.
- Quan sát: live bank now has 114 items, route first render stable; screenshots captured.
- PASS baseline; formal 4G trace deferred.
- Fix commit: `c9f435dc`.

### F5. Data integrity tests
- Linh chạy: grammar quality/matching/generator tests.
- Quan sát: all selected grammar suites pass.
- PASS.
- Fix commit: n/a.

## Issues found
- [HIGH] [GRAMMAR-EMPTY-BANK]: Fresh profile showed `Kho ngữ pháp N5` = 0 because prefs `grammar_data_version` could be current while IndexedDB grammar rows were empty.
  - Repro: clear IndexedDB/localStorage → open `/#/grammar` → before fix bank empty.
  - File: `lib/data/seeds/grammar_seeder.dart`, `lib/data/repositories/grammar_repository.dart`.
  - Fix: `c9f435dc fix(grammar): seed bank when local db is empty`.
  - Verify: live screenshot `tests/uat-grammar-2026-05-13/final-live-grammar-bank-c9f435dc.png` shows `Tổng mục 114`.
- [MEDIUM] [GRAMMAR-SEARCH-MISSING]: Grammar bank had no direct search for `は`/`wa`/`topic marker`.
  - Repro: no search field in grammar bank.
  - File: `lib/features/grammar/grammar_screen.dart`, `test/features/grammar/grammar_screen_test.dart`.
  - Fix: `77e89f3a feat(grammar): add grammar bank search`.
  - Verify: `flutter test test/features/grammar/grammar_screen_test.dart`.

## Delights
- Hero metrics make progress state easy for Linh.
- Ghost review concept is visible as “điểm yếu”, understandable for mistake repair.
- Grammar detail route is readable on desktop/mobile.
- Practice route loads independently, useful for short nightly sessions.

## Top changes shipped
- `77e89f3a feat(grammar): add grammar bank search`.
- `c9f435dc fix(grammar): seed bank when local db is empty`.

## Top changes deferred
- Audio/TTS per grammar example.
- Diagram/animation for sentence order.
- Collapsible mobile detail sections.
- Formal Safari iOS/Chrome Android ruby + IME tests.
- Live destructive session summary/XP mutation with isolated seeded test account.
