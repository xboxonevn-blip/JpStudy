# UAT — Anh Tuấn, N3, 2026-05-14

## Summary

- Best moment: Root home in Vietnamese shows N3 and a `~14 phút` plan; JLPT coach and reading drill are credible for a busy N3 learner.
- Worst moment: Direct links and exam entry are not trustworthy; mobile reading CTA can be hidden by bottom nav; live Vietnamese still has `?` mojibake.
- Verdict: FAIL for 100-user beta P2 readiness. Usable after careful root-start workaround, but not robust enough for real N3 learners.

## Tasks 1-by-1

### A1. Cold start as N3
- Anh Tuấn nghĩ: “Mình muốn mở app và thấy đúng N3, không phải N5.”
- Click/gõ: Seed prefs, open `/#/`.
- Quan sát: Home shows `N3`, Vietnamese UI, plan `~14 phút`.
- PASS with setup caveat. Screenshot: `tests/uat-p2-2026-05-14/home-n3-vi.png`.

### A2. Direct grammar link
- Anh Tuấn nghĩ: “Đồng nghiệp gửi thẳng link ngữ pháp N3 thì phải đúng N3.”
- Click/gõ: Hard reload `/#/grammar`.
- Quan sát: UI Vietnamese but level fell back to N5 (`Lane N5`, `Build N5...`).
- FAIL. Screenshot: `tests/uat-p2-2026-05-14/direct-grammar-hard-reload-n5-bug.png`.

### B1. 15-minute plan
- Anh Tuấn nghĩ: “Tối nay mình có 15 phút.”
- Click/gõ: Root home.
- Quan sát: Desktop home shows `~14 phút`, `Bắt đầu học`, `Ôn thi JLPT`.
- PASS desktop; mobile hides detailed plan behind simplified cards.

### C1. N3 grammar hub
- Anh Tuấn nghĩ: “Mình cần ngữ pháp N3, không ôn N5.”
- Click/gõ: Root first, then grammar nav.
- Quan sát: `Ngữ pháp (N3)`, `100` total items, light drill CTA.
- PASS with deep-link caveat. Screenshot: `tests/uat-p2-2026-05-14/desktop-grammar-n3-vi.png`.

### D1. JLPT coach
- Anh Tuấn nghĩ: “Còn 3 tháng đi Nhật, mình cần biết điểm yếu.”
- Click/gõ: `/#/jlpt/coach`.
- Quan sát: `Hub ôn thi N3`, baseline needed, full mock 13Q/31m, quick bank 0Q, reading 25 bài.
- PASS for orientation, FAIL for quick check bank. Screenshot: `tests/uat-p2-2026-05-14/jlpt-coach-n3.png`.

### D2. Full mock
- Anh Tuấn nghĩ: “Cuối tuần mình làm baseline dài hơn.”
- Click/gõ: Start full mock.
- Quan sát: `Đề thi thử JLPT Pro`, sections `Bunpo`, `KanJI`, `Dokkai`, 31 minutes.
- PASS smoke; copy/capitalization rough. Screenshot: `tests/uat-p2-2026-05-14/jlpt-full-mock-n3.png`.

### D3. Exam sidebar
- Anh Tuấn nghĩ: “Nút Đề thi phải mở trung tâm thi.”
- Click/gõ: Sidebar `Đề thi`; hard reload `/#/exam-center`.
- Quan sát: Live route shows legacy/empty exam surfaces, not local rich hub.
- FAIL. Screenshot: `tests/uat-p2-2026-05-14/exam-center-hard-reload-legacy.png`.

### E1. Mobile reading commute
- Anh Tuấn nghĩ: “Trên xe bus mình làm một bài đọc 9 phút.”
- Click/gõ: Mobile `/#/jlpt/reading`.
- Quan sát: 25 N3 sets, target 9 minutes, but chips show `3 c?u`, `9 ph?t`.
- FAIL editorial. Screenshot: `tests/uat-p2-2026-05-14/mobile-reading-n3-mojibake.png`.

### E2. Mobile CTA tap
- Anh Tuấn nghĩ: “Mình bấm bắt đầu bài đọc.”
- Click/gõ: Tap where start button is partially visible near bottom.
- Quan sát: Tap hit bottom nav and navigated to Kanji.
- FAIL touch safety. Screenshot: `tests/uat-p2-2026-05-14/mobile-reading-cta-occluded-wrong-nav.png`.

### F1. Kanji N3
- Anh Tuấn nghĩ: “Kanji N3 phải có lane riêng.”
- Click/gõ: Mobile Kanji.
- Quan sát: Modal suggests foundations first; after continuing, N3 shows 203 items and 12 new kanji.
- PASS content, MEDIUM friction. Screenshot: `tests/uat-p2-2026-05-14/mobile-kanji-n3.png`.

### F2. Vocab N3
- Anh Tuấn nghĩ: “Mình muốn học từ mới N3.”
- Click/gõ: Mobile Vocab.
- Quan sát: Modal suggests foundations first; then `Ready now`, `Hajimete N3 (0 mục từ)`.
- FAIL for N3 confidence. Screenshot: `tests/uat-p2-2026-05-14/mobile-vocab-n3.png`.

## Issues Found

- [HIGH] [INIT-DEEPLINK] Deep links skip `appInitProvider`, so persisted N3 falls back to N5.
- [HIGH] [MOBILE-CTA] JLPT reading start CTA can be occluded by bottom nav.
- [HIGH] [EXAM-LIVE-DRIFT] Live `/#/exam-center` does not match local rich exam hub expectation.
- [MEDIUM] [READING-MOJIBAKE] Live N3 reading chips show `3 c?u`, `9 ph?t`.
- [MEDIUM] [VOCAB-N3] Vocab page reports `Hajimete N3 (0 mục từ)` and leaks `Ready now`.
- [MEDIUM] [N3-SOFT-GATE] N3 vocab/kanji interrupted by foundations modal.

## Changes Made Locally

- Fixed study-goal Vietnamese/Japanese mojibake.
- Fixed JLPT reading meta pill labels (`câu`, `phút`, `問`, `分`).
- Moved app initialization trigger to app bootstrap so deep-link routes load persisted level/goal without visiting home first.
- Moved the JLPT reading card CTA above preview on compact mobile, removed the redundant picker notice on compact width, compacted the mobile hero, and removed delayed per-card animations.
- Rechecked live `/exam-center` with clean JSON-encoded N3/VI prefs. It still renders the old `Đề thi thử JLPT N3` empty lesson screen; deployed JS maps `/exam-center` to the same widget as `/practice/mock-exam`, so this is a stale deploy/channel issue rather than current local route code.
- Added focused tests.

Verification:

```powershell
flutter test --concurrency=1 test\core\study_goal_test.dart test\features\jlpt\jlpt_reading_screen_test.dart
flutter test --concurrency=1 test\features\jlpt\jlpt_reading_screen_test.dart test\features\jlpt\jlpt_reading_mobile_layout_test.dart
flutter test --concurrency=1 test\app\app_init_deep_link_test.dart test\features\home\home_screen_test.dart test\features\ui\exam_and_coach_route_smoke_test.dart test\core\study_goal_test.dart test\features\jlpt\jlpt_reading_screen_test.dart
```

## Deferred

- Live redeploy/re-test of global app init deep-link fix.
- Live redeploy/re-test of mobile CTA layout fix.
- Redeploy or channel-check `jpstudy-v2` hosting for exam route parity.
- Vocab N3 data/copy investigation.
