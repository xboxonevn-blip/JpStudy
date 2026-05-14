# UAT - Mai, N2, 2026-05-14

## Summary

- Best moment: Root home shows N2 and Vietnamese cleanly in a readable desktop layout.
- Worst moment: Direct grammar/vocab/kanji/coach/reading routes fall to N5 on live; exam center is blank/stale.
- Verdict: FAIL for 100-user beta P3 readiness. Current live channel is not trustworthy for N2 cramming.

## Tasks 1-by-1

### A1. Cold start as N2
- Mai nghĩ: "Mình mở app là phải thấy đúng N2."
- Click/gõ: Seed N2/JLPT/VI prefs, open `/#/`.
- Quan sát: Home shows N2 chips and Vietnamese UI, with `~14 phút` plan.
- PASS for root state; FAIL for cramming length. Screenshot: `tests/uat-p3-2026-05-14/p3-root-n2-vi-reload.png`.

### A2. Direct grammar
- Mai nghĩ: "Mình vào thẳng ngữ pháp N2 để ôn."
- Click/gõ: Hard reload `/#/grammar`.
- Quan sát: Screen shows `Lane N5`, `Xây nền ngữ pháp N5 thật vững`, `114` items, plus a foundations modal.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-grammar-modal.png`.

### B1. Direct vocab
- Mai nghĩ: "Mình cần học từ vựng N2 nhanh."
- Click/gõ: Hard reload `/#/vocab`.
- Quan sát: Screen shows `Lane hiện tại N5`, `Hajimete N5 (0 mục từ)`, `Ready now`, and only catalog overview.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-vocab-after-continue.png`.

### B2. Direct kanji
- Mai nghĩ: "Kanji N2 phải là lane chính."
- Click/gõ: Hard reload `/#/kanji`.
- Quan sát: Copy says `Dùng N5 làm lane chính`; N5 tab selected after continuing.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-kanji-after-continue.png`.

### C1. JLPT coach
- Mai nghĩ: "Mình cần kế hoạch ôn N2 trước kỳ thi tháng 7."
- Click/gõ: Hard reload `/#/jlpt/coach`.
- Quan sát: `Hub ôn thi N5`, full mock `13Q • 28m`, bank `0Q • 25 bài`.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-coach.png`.

### C2. Exam center
- Mai nghĩ: "Mình muốn làm đề thử hoặc baseline."
- Click/gõ: Hard reload `/#/exam-center`.
- Quan sát: Legacy/empty `Thi thử` page with only `Chọn cấp JLPT`.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-exam-center.png`.

### D1. Reading drill
- Mai nghĩ: "Đọc hiểu N2 là phần cần luyện mỗi ngày."
- Click/gõ: Hard reload `/#/jlpt/reading`.
- Quan sát: Route shows `Lộ trình N5`, `Mục tiêu 5 phút`, first passage tagged N5.
- FAIL. Screenshot: `tests/uat-p3-2026-05-14/p3-reading.png`.

### E1. Group/social
- Mai nghĩ: "Mình học cùng nhóm, cần chia sẻ tiến độ."
- Click/gõ: Open `/#/community` and `/#/leaderboard`.
- Quan sát: Leaderboard has `Chia sẻ snapshot`; community has `Mời bạn bè` as `Sớm` and `Phòng cộng đồng` as `Kế hoạch`.
- PARTIAL. Screenshots: `tests/uat-p3-2026-05-14/p3-community-scroll.png`, `tests/uat-p3-2026-05-14/p3-leaderboard.png`.

## Issues Found

- [HIGH] [LIVE-DEEPLINK-N2] Direct live routes fall back from N2 to N5.
- [HIGH] [EXAM-LIVE-DRIFT] Live exam center is stale/empty.
- [HIGH] [NO-CRAM-MODE] No 3-hour/day or July-JLPT cramming plan is visible.
- [MEDIUM] [GROUP-STUDY-ROADMAP] Share exists, but invites/community rooms are not active.
- [MEDIUM] [FOUNDATIONS-MODAL] Direct study routes show a foundations gate before the user can work.

## Changes Made Locally

No P3 code changes. The direct-route N5 fallback maps to known live-channel drift; current local app init already has a regression test from P2.

Verification for this docs-only P3 pass:

```powershell
git diff --check
```

## Deferred

- Redeploy/channel verify live app, then rerun P2/P3 deep-link route probes.
- Decide whether long-session N2 cramming is a beta persona requirement.
- Decide whether group study means share-only beta or active friend/community loops.
