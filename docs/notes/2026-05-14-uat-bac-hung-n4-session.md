# UAT - Bác Hùng, N4, 2026-05-14

## Summary

- Best moment: Tablet root shows N4 cleanly, and a slow tap opens a readable N4 learning plan with a `~15p` lesson step.
- Worst moment: Direct kanji/vocab/grammar/reading/study hub routes fall to N5 on live.
- Verdict: FAIL for 100-user beta P4 readiness. Good root readability is not enough without N4 route trust and a travel/fun goal.

## Tasks 1-by-1

### A1. Tablet cold start
- Bác Hùng nghĩ: "Chữ phải dễ đọc, và app phải nhớ mình đang học N4."
- Click/gõ: Seed N4/reading/VI prefs, set tablet `834x1194`, browser zoom about 125%, open `/#/`.
- Quan sát: N4 chips visible; root uses large stacked cards and bottom nav.
- PASS for readability and root state; PARTIAL for plan detail. Screenshot: `tests/uat-p4-2026-05-14/p4-root-tablet-125.png`.

### A2. Slow tap on plan
- Bác Hùng nghĩ: "Tôi bấm chậm một nút học, đừng đưa nhầm."
- Click/gõ: Slow tap `Học ngay`.
- Quan sát: Opens `Học` surface with `Đào sâu thêm vào N4`, `Bắt đầu Minna No Nihongo 26`, `Mở bài học`, and `~15p`.
- PASS. Screenshot: `tests/uat-p4-2026-05-14/p4-root-after-slow-tap.png`.

### B1. Kanji N4
- Bác Hùng nghĩ: "Tôi muốn xem Hán tự N4."
- Click/gõ: Hard reload `/#/kanji`.
- Quan sát: Route falls to N5 and shows foundations modal; N4 tab is visible but not selected.
- FAIL. Screenshot: `tests/uat-p4-2026-05-14/p4-kanji-tablet-125.png`.

### B2. Vocab N4
- Bác Hùng nghĩ: "Tôi muốn học từ vừa sức N4."
- Click/gõ: Hard reload `/#/vocab`.
- Quan sát: `Lane hiện tại N5`, `Ready now`, `Hajimete N5 (0 mục từ)`, foundations modal.
- FAIL. Screenshot: `tests/uat-p4-2026-05-14/p4-vocab-tablet-125.png`.

### B3. Grammar N4
- Bác Hùng nghĩ: "Tôi muốn ôn mẫu câu N4."
- Click/gõ: Hard reload `/#/grammar`.
- Quan sát: `Lane N5`, `Xây nền ngữ pháp N5 thật vững`, `114` items, modal.
- FAIL. Screenshot: `tests/uat-p4-2026-05-14/p4-grammar-tablet-125.png`.

### C1. Reading/travel
- Bác Hùng nghĩ: "Tôi học để đi du lịch, không nhất thiết thi."
- Click/gõ: Hard reload `/#/jlpt/reading`, then `/#/study-hub`.
- Quan sát: Reading falls to N5. Study hub falls to N5/JLPT but has filters like `Đọc hiểu`, `Tự học`, `Công cụ`. Root plan after tap has `Mở immersion`.
- PARTIAL. Screenshots: `tests/uat-p4-2026-05-14/p4-reading-tablet-125.png`, `tests/uat-p4-2026-05-14/p4-study-hub-tablet-125.png`.

### D1. Community/settings
- Bác Hùng nghĩ: "Tôi cần tìm cài đặt hoặc trợ giúp."
- Click/gõ: Open `/#/community`.
- Quan sát: Large cards readable; `Dữ liệu và reset` and `Phòng thí nghiệm UI` visible. No font-size setting visible.
- PARTIAL. Screenshot: `tests/uat-p4-2026-05-14/p4-community-tablet-125.png`.

## Issues Found

- [HIGH] [LIVE-DEEPLINK-N4] Direct live routes fall back from N4 to N5.
- [HIGH] [NO-TRAVEL-GOAL] No travel/fun onboarding goal exists.
- [MEDIUM] [TABLET-MOBILE-SHELL] Tablet portrait at 125% uses mobile card shell and hides detailed plan context.
- [MEDIUM] [NO-FONT-SETTING] No visible text-size/accessibility preference.
- [MEDIUM] [N4-SOFT-GATE] Foundations modal blocks direct N4 routes.

## Changes Made Locally

No P4 code changes. This was a docs/evidence pass.

Verification for this docs-only P4 pass:

```powershell
git diff --check
```

## Deferred

- Hosting deploy/channel verification.
- Tablet/large-font regression test.
- Travel/fun goal scope decision.
- Accessibility settings scope decision.
