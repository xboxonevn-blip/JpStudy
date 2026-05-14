# UAT - Sora, N1, 2026-05-14

## Summary

- Best moment: After root init, immersion shows `Track N1`, 25 N1 decks, and an advanced Japanese passage with annotations.
- Worst moment: Direct immersion/reading/study/vocab/grammar routes fall to N5; study hub advanced filter does not show N1 reading/news.
- Verdict: FAIL for 100-user beta P5 readiness. N1 content exists, but routing and discovery are not trustworthy.

## Tasks 1-by-1

### A1. N1 root
- Sora nghĩ: "Mình đã có N1, app phải mở thẳng vào đọc nâng cao."
- Click/gõ: Seed N1/reading/VI prefs, open `/#/`.
- Quan sát: N1 chips visible; home suggests `Đọc một bài đắm mình`.
- PASS root. Screenshot: `tests/uat-p5-2026-05-14/p5-root-n1-vi.png`.

### A2. Direct immersion
- Sora nghĩ: "Mình mở link đọc mở rộng."
- Click/gõ: Hard reload `/#/immersion`.
- Quan sát: Route falls to `Track N5`, `Deck đọc N5`, and beginner cards.
- FAIL. Screenshot: `tests/uat-p5-2026-05-14/p5-immersion.png`.

### A3. Immersion after root init
- Sora nghĩ: "Nếu app đã biết N1 thì đọc nâng cao có tồn tại không?"
- Click/gõ: Root first, then hash route to `/#/immersion`.
- Quan sát: `Track N1`, `Deck đọc N1`, `25` decks.
- PASS with entry-path caveat. Screenshot: `tests/uat-p5-2026-05-14/p5-immersion-hash-after-init.png`.

### A4. Open N1 deck
- Sora nghĩ: "Bài có đủ khó không?"
- Click/gõ: Open first N1 deck.
- Quan sát: `便利さの裏側にある依存`, `Ước lượng N1`, abstract Japanese paragraphs and annotation chips.
- PASS content sample. Screenshot: `tests/uat-p5-2026-05-14/p5-immersion-n1-deck.png`.

### B1. JLPT reading
- Sora nghĩ: "Đọc hiểu N1 phải khó hơn tự giới thiệu."
- Click/gõ: Hard reload `/#/jlpt/reading`.
- Quan sát: `Lộ trình N5`, `Mục tiêu 5 phút`, cards `自己紹介`, `私の家族`.
- FAIL. Screenshot: `tests/uat-p5-2026-05-14/p5-reading.png`.

### B2. Study hub advanced
- Sora nghĩ: "Mình muốn tìm tài nguyên nâng cao hoặc tin tức."
- Click/gõ: Open `/#/study-hub`, then after root init select `Nâng cao`.
- Quan sát: Direct route falls N5. After init, hero is N1, but advanced filter shows `N3 Grammar Contrast Set` and `Deep Listening Loop`; no N1/news reading.
- FAIL advanced discovery. Screenshots: `tests/uat-p5-2026-05-14/p5-study-hub.png`, `tests/uat-p5-2026-05-14/p5-study-hub-advanced-filter.png`.

### C1. Core maintenance
- Sora nghĩ: "Mình chỉ cần giữ phong độ."
- Click/gõ: Open `/#/progress` and `/#/active`.
- Quan sát: Progress has `Chạy một block tổng hợp ngắn`; active workspace has `Nhồi tối`, `18 phút`, `Recall`, queue preview.
- PARTIAL. Screenshots: `tests/uat-p5-2026-05-14/p5-progress.png`, `tests/uat-p5-2026-05-14/p5-active-after-root-nav.png`.

## Issues Found

- [HIGH] [LIVE-DEEPLINK-N1] Direct live routes fall back from N1 to N5.
- [HIGH] [NO-NEWS-READING] No news/current-world advanced reading surfaced.
- [HIGH] [ADVANCED-HUB-GAP] Study hub advanced filter does not expose N1 reading.
- [MEDIUM] [N1-DISCOVERY] N1 immersion exists but requires initialized state/indirect navigation.
- [MEDIUM] [CERTIFIED-REVIEW] Maintenance routes are generic and not tuned for N1-certified users.

## Changes Made Locally

No P5 code changes. This was a docs/evidence pass.

Verification for this docs-only P5 pass:

```powershell
git diff --check
```

## Deferred

- Hosting deploy/channel verification.
- D4 cross-persona synthesis.
- N1 immersion/study-hub discovery patch.
- News/current-world scope decision.
