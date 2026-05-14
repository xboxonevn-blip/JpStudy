# UAT - Bác Hùng, N4, 2026-05-15

## Summary

- Best moment: Tablet onboarding to Vietnamese + N4 works, the bottom nav hides Kana, and N4 vocab is genuinely open.
- Worst moment: The foundations suggestion still interrupts first vocab entry, and older persona gaps remain: no travel/fun goal and no visible font-size setting.
- Verdict: PASS for the targeted SP2 re-test scope: onboarding gate, Kana hiding, foundations lock, and N4 vocab unlock.

## Tasks 1-by-1

### A1. Tablet onboarding as N4
- Click/gõ: Clear storage, open production root at `834x1194`, decline analytics, choose Vietnamese, choose N4, start.
- Quan sát: Stored `flutter.app.locale = "vi"`, `flutter.onboarding.level = "n4"`, `flutter.onboarding.completed = true`.
- PASS. Evidence: `tests/uat-p4-2026-05-15/evidence.json`, screenshot `tests/uat-p4-2026-05-15/03-home-after-onboarding.png`.

### A2. Home N4 + no Kana
- Quan sát: Home shows N4 chip and tablet/mobile shell with Lộ trình, Hán tự, Đề thi, Thêm. Kana is not a primary nav item.
- PASS. Screenshot: `tests/uat-p4-2026-05-15/03-home-after-onboarding.png`.

### A3. Foundations route for non-N5
- Click/gõ: Open `/#/foundations`.
- Quan sát: Locked screen says `Bảng chữ là cấp N5 — bạn đang ở N4`.
- PASS. Screenshot: `tests/uat-p4-2026-05-15/04-foundations-locked.png`.

### A4. Vocab N4 unlock
- Click/gõ: Open `/#/vocab`, continue past modal, wait, scroll to N4 catalog.
- Quan sát: N4 section is `Đã mở`; `Hajimete no Nihongo Tango N4` shows `632 mục từ`, `Ready now`, and `Mở lane`; `Minna no Nihongo II` shows `1,478 mục từ` and `Mở track`.
- PASS. Screenshots: `tests/uat-p4-2026-05-15/07-vocab-current-level-catalog.png`, `tests/uat-p4-2026-05-15/08-vocab-n4-open-tracks.png`.

## Issues Found

- [MEDIUM] [VOCAB-FOUNDATIONS-MODAL] Even the passing N4 path still starts with a foundations suggestion modal.
- [MEDIUM] [P4-PERSONA-GAPS] Travel/fun motivation and font-size preference remain out of scope in this re-test.

## Verification

- Live URL: `https://jpstudy.web.app`
- Retest date: `2026-05-15`
- Browser automation: Playwright Chromium, clean storage per persona.
