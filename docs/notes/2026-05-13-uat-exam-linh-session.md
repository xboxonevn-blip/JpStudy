# UAT Đề thi JLPT — Linh, N5, 2026-05-13

## Summary
- Best moment: Các route JLPT chính đều mount được trên desktop + mobile; test suite exam/JLPT pass 84/84.
- Worst moment: `/#/exam-center` không có level mặc định nên live chỉ hiện “Chọn cấp JLPT”; đã ship fix default N5.
- Overall verdict: PASS sau hotfix cho route/render/deploy. Còn deferred perf: lần cold-load đầu `/#/exam-center` mất ~25s mới qua spinner, cần task tối ưu data/bootstrap riêng.

## Tasks 1-by-1

### A1. Click “Đề thi” sidebar
- Linh nghĩ: muốn vào thi thử N5 nhanh, không muốn chọn lại cấp.
- Linh click: sidebar “Đề thi”.
- Quan sát: trước fix kẹt prompt chọn cấp; sau fix render “Kiểm tra: Đề thi thử JLPT N5”. Screenshot: `tests/uat-exam-2026-05-13/desktop-exam-center-25s.png`.
- PASS — route tới `/#/exam-center`, content N5 render.
- Fix commit: `29c4436c`.

### A2. Hub overview
- Linh nghĩ: muốn thấy mock, đọc hiểu, coach, lịch sử.
- Linh click: direct `/#/exam-center`.
- Quan sát: Test config mock N5 render; hub card-level exam center chưa đầy đủ như spec marketing 4-card.
- PASS functional / DEFER UX — config flow usable, hub overview richer nên roadmap.
- Fix commit: `29c4436c`.

### A3. Đếm ngược ngày thi JLPT
- Linh nghĩ: muốn biết còn bao lâu tới kỳ thi.
- Linh click: xem hub.
- Quan sát: chưa thấy countdown 12/7 hoặc 12/12.
- DEFERRED — feature copy/logic chưa có trên exam center.

### A4. Mobile layout
- Linh nghĩ: iPhone cần thấy CTA rõ, không blank.
- Linh click: mở mobile `414×896`.
- Quan sát: route render sau load; screenshot `tests/uat-exam-2026-05-13/mobile-exam-center-25s.png`.
- PASS functional / DEFER perf — cold-load vượt mục tiêu 5s.

### B1. Test config
- Linh nghĩ: muốn mock N5 mặc định.
- Linh click: `/#/exam-center`, `/#/practice/mock-exam`.
- Quan sát: “Đề thi thử JLPT N5”, 1327 câu, 25 phút, 50 câu.
- PASS — config available once level defaults N5.
- Fix commit: `29c4436c`.

### B2. Config invalid
- Linh nghĩ: không muốn bấm nhầm bài 0 câu.
- Linh click: widget tests validate config/session behavior.
- Quan sát: targeted tests pass.
- PASS — covered by `test_config_test.dart`, `test_session_test.dart`.

### B3. Save preset config
- Linh nghĩ: muốn lần sau dùng cấu hình cũ.
- Linh click: tìm preset option.
- Quan sát: chưa thấy preset save explicit.
- DEFERRED — product enhancement.

### C1. Timer
- Linh nghĩ: cần timer dễ thấy.
- Linh click: mock walkthrough tests.
- Quan sát: test screen submit/walkthrough pass; timer behavior covered.
- PASS — `test_screen_submit_test.dart`, `mock_exam_walkthrough_test.dart`.

### C2. Question UI
- Linh nghĩ: cần câu hỏi + A/B/C/D dễ chạm.
- Linh click: run widget tests.
- Quan sát: test screen tests pass; mobile route screenshot captured.
- PASS — no overflow failure in test suite.

### C3. Navigation controls
- Linh nghĩ: cần câu trước/sau, flag, nộp bài.
- Linh click: submit flow tests.
- Quan sát: last question submit confirmation test pass.
- PASS.

### C4. Submit confirm
- Linh nghĩ: sợ nộp thiếu câu.
- Linh click: submit early in tests.
- Quan sát: confirmation dialog covered; tests pass.
- PASS.

### C5. Timer hết auto-submit
- Linh nghĩ: hết giờ phải tự nộp.
- Linh click: session tests.
- Quan sát: no live forced-timeout run; unit coverage exists.
- PASS unit / DEFER live long-duration.

### D1. Results
- Linh nghĩ: muốn biết đỗ/rớt N5.
- Linh click: results tests.
- Quan sát: `test_results_screen_test.dart` pass.
- PASS.

### D2. Review
- Linh nghĩ: muốn xem câu sai + học lại.
- Linh click: review tests.
- Quan sát: `test_review_screen_test.dart` pass.
- PASS.

### D3. History
- Linh nghĩ: muốn xem lần làm trước.
- Linh click: `/#/lesson/test/history` desktop/mobile.
- Quan sát: route mounts; screenshot `tests/uat-exam-2026-05-13/desktop-test-history.png`.
- PASS.

### E1. JLPT Coach
- Linh nghĩ: muốn app chỉ ra điểm yếu.
- Linh click: `/#/jlpt/coach`.
- Quan sát: route mounts desktop/mobile; tests pass.
- PASS.

### E2. Recommendations
- Linh nghĩ: muốn bài luyện cụ thể.
- Linh click: coach screen.
- Quan sát: coach tests pass; screenshots captured.
- PASS functional.

### E3. Progress to N5 goal
- Linh nghĩ: muốn thanh tiến độ tới N5.
- Linh click: coach screen.
- Quan sát: no live text extraction reliable under CanvasKit; route screenshot saved.
- PASS route / DEFER copy audit.

### F1. Reading passage
- Linh nghĩ: muốn đoạn đọc N5 dễ đọc.
- Linh click: `/#/jlpt/reading`.
- Quan sát: route mounts desktop/mobile; screenshots captured.
- PASS.

### F2. Furigana toggle
- Linh nghĩ: muốn bật/tắt furigana.
- Linh click: reading screen.
- Quan sát: not fully interactive-audited in headless CanvasKit.
- DEFERRED — manual/semantic audit needed.

### F3. Tap kanji tooltip
- Linh nghĩ: muốn nghĩa nhanh khi chạm chữ Hán.
- Linh click: reading route.
- Quan sát: no automated assertion added.
- DEFERRED — product QA follow-up.

### F4. Desktop split layout
- Linh nghĩ: laptop nên đọc trái, hỏi phải.
- Linh click: desktop reading.
- Quan sát: screenshot `tests/uat-exam-2026-05-13/desktop-reading.png`.
- PASS route/render.

### F5. Mobile stack
- Linh nghĩ: iPhone nên stack dọc.
- Linh click: mobile reading.
- Quan sát: screenshot `tests/uat-exam-2026-05-13/mobile-reading.png`.
- PASS route/render.

### G1. Mock Pro 105 phút
- Linh nghĩ: muốn mô phỏng đề thật.
- Linh click: `/#/jlpt/mock-pro`.
- Quan sát: route mounts; CSP analytics error fixed.
- PASS.
- Fix commit: `134b729e`.

### G2. Listening audio
- Linh nghĩ: cần audio thật.
- Linh click: mock pro route.
- Quan sát: no Firebase Storage audio assertion in this pass.
- DEFERRED — requires audio inventory audit.

### G3. Block back button
- Linh nghĩ: thi thật không nên thoát nhầm.
- Linh click: mock pro route.
- Quan sát: not verified live.
- DEFERRED.

### G4. Pause/strict timer
- Linh nghĩ: cần biết có pause không.
- Linh click: mock pro route.
- Quan sát: not verified live.
- DEFERRED.

### H1. Network drop
- Linh nghĩ: mất mạng giữa bài không được mất đáp án.
- Linh click: unit suite only.
- Quan sát: session storage tests pass; offline live not simulated.
- PASS unit / DEFER live offline harness.

### H2. Two tabs conflict
- Linh nghĩ: không muốn 2 tab ghi đè.
- Linh click: not executed.
- Quan sát: no conflict harness.
- DEFERRED.

### H3. Mobile lock screen timer
- Linh nghĩ: khóa máy rồi mở lại timer xử lý đúng.
- Linh click: not executable in headless.
- Quan sát: not verified.
- DEFERRED.

### H4. Data/tests
- Linh nghĩ: muốn test suite xanh.
- Linh click: run targeted exam/JLPT tests.
- Quan sát: 84/84 pass, then 16/16 targeted pass after fix.
- PASS.

## Issues found
- [HIGH] [EXAM-LEVEL-DEFAULT]: `/#/exam-center` rendered only “Chọn cấp JLPT” for users without in-memory `studyLevelProvider`.
  - Repro: open `https://jpstudy.web.app/#/exam-center` with seeded localStorage only.
  - File: `lib/features/test/screens/home_mock_exam_screen.dart`.
  - Fix: fallback to `StudyLevel.n5`.
  - Verify: `home_mock_exam_screen_test.dart` updated; live screenshots show N5 config.
  - Fix commit: `29c4436c`.
- [MEDIUM] [CSP-GTM-CONNECT]: Analytics transport to `www.googletagmanager.com/td` blocked by `connect-src`.
  - Repro: live console on `/#/jlpt/mock-pro` desktop.
  - File: `firebase.json`.
  - Fix: add `https://www.googletagmanager.com` to `connect-src` for both hosting targets.
  - Verify: rerun live route sweep, CSP GTM error gone.
  - Fix commit: `134b729e`.
- [MEDIUM] [EXAM-COLD-LOAD]: `/#/exam-center` cold-load can show spinner ~25s before config appears.
  - Repro: headless Chrome live wait 8s still spinner, 25s renders.
  - File: likely `lib/features/test/screens/home_mock_exam_screen.dart` + `lessonRepositoryProvider.getVocabByLevel` path.
  - Fix: deferred; needs async skeleton/cache/index optimization.
  - Verify artifact: `desktop-exam-center.png` vs `desktop-exam-center-25s.png`.

## Delights
- Vietnamese consent banner renders dấu correctly.
- Sidebar shell remains stable on desktop screenshots.
- Test config clearly shows current config summary.
- Exam/JLPT route suite already has useful smoke/walkthrough coverage.

## Top changes shipped
- `29c4436c fix(exam): default mock exam level to N5`
- `134b729e fix(csp): allow analytics transport endpoint`

## Top changes deferred
- Perf: optimize exam-center cold-load to meet <3s desktop / <5s mobile.
- UX: replace config-first exam center with richer 4-card hub: Mock Pro, Reading, Coach, History.
- Product: JLPT countdown, preset save, live offline/two-tab/timer-lock harness.
- Content: verify listening audio inventory for Mock Pro.
