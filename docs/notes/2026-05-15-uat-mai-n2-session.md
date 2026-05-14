# UAT - Mai, N2, 2026-05-15

## Summary

- Best moment: Clean onboarding persists Vietnamese + N2 correctly, and the home shell no longer exposes Kana for an upper-level learner.
- Worst moment: N2 vocab is still locked. The page says `Hajimete N2 (0 mục từ)`, catalog summary shows `0 Đang mở`, and both N2 tracks remain preview-only.
- Verdict: PARTIAL for onboarding/Kana/foundations gates; FAIL for N2 vocab unlock.

## Tasks 1-by-1

### A1. Cold onboarding as N2
- Click/gõ: Clear storage, open production root, decline analytics, choose Vietnamese, choose N2, start.
- Quan sát: Stored `flutter.app.locale = "vi"`, `flutter.onboarding.level = "n2"`, `flutter.onboarding.completed = true`.
- PASS. Evidence: `tests/uat-p3-2026-05-15/evidence.json`, screenshot `tests/uat-p3-2026-05-15/03-home-after-onboarding.png`.

### A2. Home N2 + no Kana
- Quan sát: Home shows N2 chip and Vietnamese UI. Desktop sidebar omits Kana while keeping Hán tự, Từ vựng, Ngữ pháp, Lộ trình, Ghi nhớ, Chủ động, Đề thi, Xếp hạng.
- PASS. Screenshot: `tests/uat-p3-2026-05-15/03-home-after-onboarding.png`.

### A3. Foundations route for non-N5
- Click/gõ: Open `/#/foundations`.
- Quan sát: Locked screen says `Bảng chữ là cấp N5 — bạn đang ở N2`.
- PASS. Screenshot: `tests/uat-p3-2026-05-15/04-foundations-locked.png`.

### A4. Vocab N2 unlock
- Click/gõ: Open `/#/vocab`, continue past modal, wait, scroll to N2 catalog.
- Quan sát: `Hajimete N2 (0 mục từ)`, `0 Đang mở`; `Hajimete no Nihongo Tango` and `Shin Kanzen Master` N2 cards are `Sắp ra mắt` / `Xem trước`.
- FAIL. Screenshots: `tests/uat-p3-2026-05-15/06-vocab-top-after-continue.png`, `tests/uat-p3-2026-05-15/07-vocab-current-level-catalog.png`.

## Issues Found

- [HIGH] [VOCAB-N2-STILL-LOCKED] N2 vocab remains preview-only on live after the unlock work.
- [MEDIUM] [VOCAB-COUNT-ZERO] Next-step copy reports `0 mục từ`, which destroys confidence for a cramming persona.

## Verification

- Live URL: `https://jpstudy.web.app`
- Retest date: `2026-05-15`
- Browser automation: Playwright Chromium, clean storage per persona.
