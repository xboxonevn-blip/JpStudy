# UAT - Anh Tuấn, N3, 2026-05-15

## Summary

- Best moment: Clean onboarding lets Anh Tuấn choose Vietnamese + N3, then home shows N3 with no Kana entry in the desktop sidebar.
- Worst moment: Vocab is still not actually open for N3. The page says `Hajimete N3 (0 mục từ)`, catalog summary shows `0 Đang mở`, and N3 cards still show `Sắp ra mắt` / `Xem trước`.
- Verdict: PARTIAL for the targeted onboarding gate re-test; FAIL for the T3 vocab-unlock expectation.

## Tasks 1-by-1

### A1. Cold onboarding as N3
- Click/gõ: Clear `localStorage` + `sessionStorage`, open `https://jpstudy.web.app/#/`, decline analytics, choose `Tiếng Việt`, choose `N3`, start.
- Quan sát: Stored `flutter.app.locale = "vi"`, `flutter.onboarding.level = "n3"`, `flutter.onboarding.completed = true`.
- PASS. Evidence: `tests/uat-p2-2026-05-15/evidence.json`, screenshot `tests/uat-p2-2026-05-15/03-home-after-onboarding.png`.

### A2. Home N3 + no Kana
- Quan sát: Home shows N3 chip, Vietnamese copy, learning cards for vocab/grammar/kanji/exam. Sidebar shows Hán tự, Từ vựng, Ngữ pháp, Lộ trình, Ghi nhớ, Chủ động, Đề thi, Xếp hạng, upgrade icon; no Kana item.
- PASS. Screenshot: `tests/uat-p2-2026-05-15/03-home-after-onboarding.png`.

### A3. Foundations route for non-N5
- Click/gõ: Open `/#/foundations`.
- Quan sát: Locked screen says `Bảng chữ là cấp N5 — bạn đang ở N3`, with actions to switch to N5 or return home N3.
- PASS. Screenshot: `tests/uat-p2-2026-05-15/04-foundations-locked.png`.

### A4. Vocab N3 unlock
- Click/gõ: Open `/#/vocab`, continue past foundations suggestion, wait for live data, scroll to N3 catalog.
- Quan sát: Top summary still says `Hajimete N3 (0 mục từ)`, `0 Đang mở`; N3 `Hajimete no Nihongo Tango` and `Shin Kanzen Master` are visible but still marked `Sắp ra mắt` / `Xem trước`.
- FAIL. Screenshots: `tests/uat-p2-2026-05-15/06-vocab-top-after-continue.png`, `tests/uat-p2-2026-05-15/07-vocab-current-level-catalog.png`.

## Issues Found

- [HIGH] [VOCAB-N3-STILL-LOCKED] N3 vocab content is surfaced but not open; the live UI contradicts the expected T3 unlock.
- [MEDIUM] [VOCAB-FOUNDATIONS-MODAL] N3 vocab still starts behind a foundations suggestion modal.

## Verification

- Live URL: `https://jpstudy.web.app`
- Retest date: `2026-05-15`
- Browser automation: Playwright Chromium, clean storage per persona.
