# UAT - Sora, N1, 2026-05-15

## Summary

- Best moment: Clean onboarding persists Vietnamese + N1, and the home shell hides beginner Kana entry points.
- Worst moment: N1 vocab is still locked. N1 `Hajimete`, `Shin Kanzen Master`, and `Advanced Vocabulary Lab` cards remain `Sắp ra mắt` / `Xem trước`.
- Verdict: PARTIAL for onboarding/Kana/foundations gates; FAIL for N1 vocab unlock and advanced-learner confidence.

## Tasks 1-by-1

### A1. Cold onboarding as N1
- Click/gõ: Clear storage, open production root, decline analytics, choose Vietnamese, choose N1, start.
- Quan sát: Stored `flutter.app.locale = "vi"`, `flutter.onboarding.level = "n1"`, `flutter.onboarding.completed = true`.
- PASS. Evidence: `tests/uat-p5-2026-05-15/evidence.json`, screenshot `tests/uat-p5-2026-05-15/03-home-after-onboarding.png`.

### A2. Home N1 + no Kana
- Quan sát: Home shows N1 chip and no Kana item in the desktop sidebar.
- PASS. Screenshot: `tests/uat-p5-2026-05-15/03-home-after-onboarding.png`.

### A3. Foundations route for non-N5
- Click/gõ: Open `/#/foundations`.
- Quan sát: Locked screen says `Bảng chữ là cấp N5 — bạn đang ở N1`.
- PASS. Screenshot: `tests/uat-p5-2026-05-15/04-foundations-locked.png`.

### A4. Vocab N1 unlock
- Click/gõ: Open `/#/vocab`, continue past modal, wait, scroll to N1 catalog.
- Quan sát: `Hajimete N1 (0 mục từ)`, `0 Đang mở`; N1 `Hajimete no Nihongo Tango`, `Shin Kanzen Master`, and `Advanced Vocabulary Lab N1+` remain preview/coming-soon.
- FAIL. Screenshots: `tests/uat-p5-2026-05-15/06-vocab-top-after-continue.png`, `tests/uat-p5-2026-05-15/07-vocab-current-level-catalog.png`.

## Issues Found

- [HIGH] [VOCAB-N1-STILL-LOCKED] N1 vocab tracks are visible but not open on live.
- [HIGH] [ADVANCED-VOCAB-GAP] `Advanced Vocabulary Lab N1+` exists visually but is not usable.
- [MEDIUM] [VOCAB-COUNT-ZERO] N1 next-step copy reports `0 mục từ`.

## Verification

- Live URL: `https://jpstudy.web.app`
- Retest date: `2026-05-15`
- Browser automation: Playwright Chromium, clean storage per persona.
