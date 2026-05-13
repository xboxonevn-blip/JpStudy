# UAT De thi JLPT — Linh, N5, 2026-05-13

## Summary
- Best moment: Exam Center now opens as a real JLPT hub, not a slow config-first screen.
- Worst moment: Sidebar exam item is below fold on 768px desktop when consent banner is visible; direct route and CTA flows pass.
- Overall verdict: PASS for live route render, N5 hub, mock/reading/coach/history entry points, build, deploy, CSP. DEFER only deep exam behaviors that need longer/manual harness (audio inventory, lock-screen timer, two-tab conflict).

## Tasks 1-by-1

### A1. Click "De thi" sidebar
- Linh nghĩ: muốn vào khu luyện đề từ màn chính.
- Linh click: sidebar desktop; item may be below fold on short 768px viewport with consent banner.
- Quan sát: direct `/#/exam-center` PASS; sidebar screenshot `tests/uat-exam-2026-05-13/desktop-home-nav.png` shows rail visible but exam item below fold.
- PASS route / DEFER minor nav discoverability.
- Fix commit: `f8b3705b`.

### A2. Hub overview
- Linh nghĩ: muốn thấy 4 lối vào chính.
- Linh click: mở `/#/exam-center`.
- Quan sát: có cards "Thi thử N5 (105 phút)", "Luyện đọc N5", "Coach JLPT", "Lịch sử thi".
- PASS. Screenshot: `tests/uat-exam-2026-05-13/desktop-exam-center.png`, `tests/uat-exam-2026-05-13/mobile-exam-center.png`.
- Fix commit: `f8b3705b`.

### A3. Countdown JLPT
- Linh nghĩ: muốn biết còn bao lâu tới kỳ thi.
- Linh click: xem hero hub.
- Quan sát: chip "Còn 60 ngày tới JLPT" hiển thị theo mốc 12/7 hoặc 12/12.
- PASS.
- Fix commit: `f8b3705b`.

### A4. Mobile layout
- Linh nghĩ: iPhone phải stack dọc, CTA dễ bấm.
- Linh click: mobile 414x896.
- Quan sát: cards stack vertical, CTA rõ; screenshot `tests/uat-exam-2026-05-13/mobile-exam-center.png`.
- PASS.

### B1. Test config
- Linh nghĩ: muốn N5 default rồi chỉnh số câu/timer.
- Linh click: card "Đề luyện tuỳ chỉnh nhanh" / direct `/#/practice/mock-exam`.
- Quan sát: TestConfigScreen mount pass; N5 fallback fixed.
- PASS.
- Fix commit: `29c4436c`.

### B2. Config invalid
- Linh nghĩ: không muốn bắt đầu bài 0 câu.
- Linh click: covered by `test_config_test.dart`, `test_session_test.dart`.
- Quan sát: tests pass.
- PASS.

### B3. Save preset config
- Linh nghĩ: muốn lần sau dùng cấu hình cũ.
- Linh click: không thấy explicit preset save.
- DEFERRED product enhancement.

### C1-C5. Test screen
- Linh nghĩ: cần timer, câu hỏi, prev/next, flag, submit confirm, auto-submit.
- Linh click: widget flows + mock walkthrough.
- Quan sát: `test_screen_submit_test.dart`, `mock_exam_walkthrough_test.dart` pass; submit confirm covered.
- PASS unit/widget; timer-expiry live long-run DEFERRED.

### D1-D3. Results, review, history
- Linh nghĩ: cần điểm, breakdown, xem câu sai, lịch sử.
- Linh click: results/review/history tests + live route `/#/lesson/test/history`.
- Quan sát: tests pass; live screenshots captured.
- PASS.

### E1-E3. JLPT Coach
- Linh nghĩ: muốn thấy điểm yếu tuần này + bài luyện gợi ý.
- Linh click: `/#/jlpt/coach`.
- Quan sát: route mounts desktop/mobile, tests pass.
- PASS route/widget.

### F1-F5. JLPT Reading
- Linh nghĩ: đọc đoạn N5 trên laptop/mobile.
- Linh click: `/#/jlpt/reading`.
- Quan sát: route mounts desktop/mobile, screenshots captured.
- PASS route/render; furigana toggle + kanji tooltip deep interaction DEFERRED.

### G1. Mock Pro 105 phút
- Linh nghĩ: muốn đề thật 105 phút.
- Linh click: "Bắt đầu thi thử" CTA.
- Quan sát: CTA navigates to `/#/jlpt/mock-pro`; click verify PASS.
- PASS.
- Fix commit: `f8b3705b`.

### G2-G4. Listening/audio/back/pause
- Linh nghĩ: mock pro phải giống thi thật.
- Linh click: route mount verified.
- Quan sát: audio Storage inventory, back-button block, strict timer not fully automated in this pass.
- DEFERRED.

### H1-H4. Edge cases
- Linh nghĩ: mất mạng/2 tab/lock screen/test data phải ổn.
- Linh click: targeted exam/JLPT suite.
- Quan sát: 84/84 pass; live route sweep all PASS; CSP header PASS.
- PASS tests; offline/two-tab/lock-screen live harness DEFERRED.

## Issues found
- [HIGH] [EXAM-LEVEL-DEFAULT]: exam config screen previously stuck at level prompt without in-memory study level — fixed by N5 fallback.
  - File: `lib/features/test/screens/home_mock_exam_screen.dart`
  - Fix commit: `29c4436c`
  - Verify: targeted tests + live screenshots.
- [MEDIUM] [CSP-GTM-CONNECT]: GTM analytics endpoint blocked by `connect-src` — fixed.
  - File: `firebase.json`
  - Fix commit: `134b729e`
  - Verify: live route sweep no CSP failure.
- [HIGH] [EXAM-HUB-MISSING]: `/#/exam-center` was config-first, not a product hub with mock/reading/coach/history — fixed.
  - File: `lib/features/test/screens/home_mock_exam_screen.dart`, `lib/app/navigation/routes/exam_routes.dart`
  - Fix commit: `f8b3705b`
  - Verify: desktop/mobile live screenshots.
- [LOW] [RAIL-DISCOVERABILITY]: on 1366x768 with consent banner, lower sidebar items like Exam can sit below fold.
  - File: `lib/app/navigation/app_shell_scaffold.dart`
  - Fix: deferred; needs rail scroll/compact prioritization pass.

## Delights
- Hub copy is Vietnamese-first and N5-specific.
- 105-minute mock is visible immediately as primary CTA.
- Mobile cards stack cleanly at 414x896.
- Consent banner Vietnamese font renders correctly.

## Top changes shipped
- `29c4436c fix(exam): default mock exam level to N5`
- `134b729e fix(csp): allow analytics transport endpoint`
- `f8b3705b feat(exam): add JLPT exam center hub`

## Top changes deferred
- Listening audio inventory + playback verification.
- Strict timer/back-button/lock-screen harness.
- Two-tab conflict/offline exam mutation harness.
- Sidebar lower-item discoverability on short desktop heights.
