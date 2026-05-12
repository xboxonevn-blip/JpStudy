# UAT Kanji — Linh, N5, 2026-05-13

## Summary
- Best moment: Vào `/#/kanji` nhanh; grid N5 render rõ, chữ 学 nổi bật, mobile dùng được.
- Worst moment: Một số flow học sâu/chữ viết tay chưa đủ discoverable qua CanvasKit/headless; cần instrumentation test riêng.
- Overall verdict: Kanji Hub đạt smoke UAT cho navigation, overview, level/filter/detail entry trên desktop + mobile. Các hạng mục advanced (handwriting scoring, FSRS batch summary, offline/cloud sync) được ghi deferred vì cần test thủ công/account state sâu hơn.

## Tasks 1-by-1

### A1. Vào Hán tự
- Linh nghĩ: “Mình muốn bấm Hán tự từ màn chính, không muốn gõ URL.”
- Linh click: Desktop sidebar `Hán tự`.
- Quan sát: URL đổi sang `/#/kanji`, content Kanji Hub render. Screenshot `tests/uat-kanji-2026-05-13/final-A1-desktop-kanji.png` và `tests/uat-kanji-2026-05-13/A1-desktop-after-kanji.png`.
- PASS — visible canvas sidebar navigate đúng sau hotfix.
- Fix commit: `385e90c1`, `2983fa46`.

### A2. Direct URL Kanji
- Linh nghĩ: “Nếu app gửi link thẳng, mình muốn mở được ngay.”
- Linh click/gõ: Mở `https://jpstudy-v2.web.app/#/kanji`.
- Quan sát: Desktop + mobile render Kanji Hub; không có CSP console error. Screenshot `tests/uat-kanji-2026-05-13/A2-desktop-direct.png`, `tests/uat-kanji-2026-05-13/A2-mobile-direct.png`.
- PASS — TTI smoke trong ngưỡng quan sát (<10s headless); cần lab 4G riêng cho số chuẩn.
- Fix commit: n/a.

### A3. Mobile bottom nav
- Linh nghĩ: “Trên iPhone mình chỉ dùng bottom tabs.”
- Linh click: Bottom tab `Hán tự` tại viewport 414×896.
- Quan sát: URL đổi `/#/kanji`, mobile Kanji Hub render. Screenshot `tests/uat-kanji-2026-05-13/final-A3-mobile-kanji-mcp.png`.
- PASS — 1 tap, không thấy CSP/fatal console error.
- Fix commit: `385e90c1`.

### B1. Header Kho Hán Tự
- Linh nghĩ: “Mình hiểu đây là kho học kanji.”
- Linh click/gõ: Quan sát overview desktop/mobile.
- Quan sát: Header/tagline hierarchy rõ, mobile không wrap hỏng. Screenshot `tests/uat-kanji-2026-05-13/B1-desktop-overview.png`, `tests/uat-kanji-2026-05-13/B1-mobile-overview.png`.
- PASS — spacing ổn.
- Fix commit: n/a.

### B2. Consent font tiếng Việt
- Linh nghĩ: “Chữ Việt phải có dấu, không được thành dấu hỏi.”
- Linh click/gõ: Reload app, quan sát consent banner.
- Quan sát: Copy đã khôi phục UTF-8: `Giúp cải thiện JpStudy`, `Không, cảm ơn`. Screenshot coverage qua overview/mobile.
- PASS — mojibake fixed.
- Fix commit: `7e78bc24`, test `e96b24bd`.

### B3. Cards Hôm nay / Học mới / Khám phá
- Linh nghĩ: “Mình muốn biết nên học gì tiếp.”
- Linh click/gõ: Quan sát 3 card overview; click `Học mới` smoke.
- Quan sát: `Học mới` mở flow/surface liên quan; empty due card có copy nhưng CTA mạnh hơn vẫn nên cải thiện. Screenshot `tests/uat-kanji-2026-05-13/F1-new-batch-after.png`.
- PASS với UX note — nên thêm CTA “Học 5 kanji mới…” sau này.
- Fix commit: n/a.

### B4. Search box
- Linh nghĩ: “Mình sẽ tìm 学 bằng kanji, gaku, học/hoc để không phải nhớ chính xác.”
- Linh click/gõ: Test widget nhập `学`, `hoc`, `gaku`, `manabu`; live smoke mở search panel.
- Quan sát: Search hiện 学 qua kanji, Hán Việt không dấu, onyomi romaji, kunyomi romaji. Screenshot `tests/uat-kanji-2026-05-13/B4-search-panel-desktop.png`.
- IMPLEMENTED/PASS — search đã match `character`, meaning, examples, readings, Hán Việt, component names; normalize tiếng Việt không dấu.
- Fix commit: `dd56c535`.
### B5. Handwriting Auto-Find
- Linh nghĩ: “Mình muốn vẽ 一 để app đoán.”
- Linh click/gõ: Smoke mở vùng vẽ/toggle/nút tìm.
- Quan sát: Headless không đánh giá được stroke scoring/gesture fidelity tin cậy.
- DEFERRED — cần manual QA hoặc Playwright pointer-trace test chuyên biệt.
- Fix commit: n/a.

### C1. Tabs Flashcard / Luyện viết / Quy tắc Hán Việt
- Linh nghĩ: “Mình muốn chọn cách học.”
- Linh click: `Flashcard (N5)`, `Luyện viết (N5)`, `Quy tắc Hán Việt`.
- Quan sát: Các tab/entry phản hồi, không crash. Screenshot `tests/uat-kanji-2026-05-13/C1-writing-after.png`, `tests/uat-kanji-2026-05-13/C1-hanviet-after.png`.
- PASS smoke.
- Fix commit: n/a.

### C2. Level + 214 Bộ thủ
- Linh nghĩ: “Sau N5 mình sẽ thử N4, còn bộ thủ giúp nhớ nghĩa.”
- Linh click: N4/N3/radicals smoke, `214 Bộ thủ`.
- Quan sát: UI phản hồi; radical surface mở/không crash. Screenshot `tests/uat-kanji-2026-05-13/C2-radicals-after.png`.
- PASS smoke; count/lag cần metric test riêng.
- Fix commit: n/a.

### C3. Filter chips
- Linh nghĩ: “Mình muốn lọc mới/đã học/đến hạn.”
- Linh click: `Tất cả`, `Mới`, `Đã học` smoke.
- Quan sát: Filter UI clickable; count học thật cần seeded progress test.
- PASS smoke / DEFER count mutation.
- Fix commit: n/a.

### C4. Stroke filter
- Linh nghĩ: “Chữ ít nét dễ học hơn.”
- Linh click: Stroke chips smoke.
- Quan sát: Filter controls hiện và clickable; multi-select/reset cần spec rõ hơn.
- PASS smoke / UX note.
- Fix commit: n/a.

### C5. Kanji grid
- Linh nghĩ: “Mình cần tap được từng chữ trên điện thoại.”
- Linh click: Grid item `学`.
- Quan sát: Grid 185 item scroll/render ổn trong smoke; mobile card đủ lớn trực quan. Screenshot `tests/uat-kanji-2026-05-13/D1-detail-gaku.png`.
- PASS smoke.
- Fix commit: n/a.

### D1. Detail 学
- Linh nghĩ: “Chữ này mình đang học, cần nghĩa + âm đọc.”
- Linh click: Card `学`.
- Quan sát: Detail mở; screenshot `tests/uat-kanji-2026-05-13/D1-detail-gaku-after.png`.
- PASS smoke — examples/stroke order/TTS chưa được assert bằng automation.
- Fix commit: n/a.

### D2. Mẹo Hán Việt
- Linh nghĩ: “Mẹo Hán Việt là điểm làm mình nhớ nhanh.”
- Linh click: Section/link Hán Việt smoke.
- Quan sát: Hán Việt page/surface mở, không crash. Screenshot `tests/uat-kanji-2026-05-13/C1-hanviet-after.png`.
- PASS smoke; modal stacking cần manual visual pass.
- Fix commit: n/a.

### D3. CTA học chữ này
- Linh nghĩ: “Nếu thích 学, mình muốn thêm vào lộ trình.”
- Linh click: CTA/detail action smoke.
- Quan sát: Action surface phản hồi; progress count cần seeded auth DB test.
- PASS smoke / DEFER persistence assertion.
- Fix commit: n/a.

### D4. Luyện viết 学
- Linh nghĩ: “Mình muốn tập viết đúng 8 nét.”
- Linh click: `Luyện viết (N5)`.
- Quan sát: Writing entry mở; scoring fairness không thể kết luận headless. Screenshot `tests/uat-kanji-2026-05-13/C1-writing-after.png`.
- PASS entry / DEFER scoring.
- Fix commit: n/a.

### D5. Flashcard 学
- Linh nghĩ: “Flashcard cần 4 mức Sai/Khó/Đúng/Dễ.”
- Linh click: `Flashcard (N5)` smoke.
- Quan sát: Entry không crash; FSRS 4-button đã được xử lý ở backlog trước nhưng không reassert sâu trong Kanji session.
- PASS smoke / DEFER session summary.
- Fix commit: n/a.

### D6. Quy tắc Hán Việt full
- Linh nghĩ: “Mình muốn bảng quy tắc dễ scan.”
- Linh click: `Quy tắc Hán Việt`.
- Quan sát: Page/surface mở. Screenshot `tests/uat-kanji-2026-05-13/C1-hanviet-after.png`.
- PASS smoke; TOC/search/clickable examples cần UX spec pass.
- Fix commit: n/a.

### E1. 214 Bộ thủ
- Linh nghĩ: “Bộ thủ mộc/thủy giúp mình đoán nghĩa.”
- Linh click: `214 Bộ thủ`.
- Quan sát: Radical surface mở, không crash. Screenshot `tests/uat-kanji-2026-05-13/C2-radicals-after.png`.
- PASS smoke.
- Fix commit: n/a.

### F1. Học mới batch
- Linh nghĩ: “Tối nay mình học 12 chữ mới.”
- Linh click: Card `Học mới`.
- Quan sát: Flow entry phản hồi. Screenshot `tests/uat-kanji-2026-05-13/F1-new-batch-after.png`.
- PASS entry / DEFER full FSRS scoring script.
- Fix commit: n/a.

### F2. Counts after session
- Linh nghĩ: “Sau học, số đã học phải tăng.”
- Linh click/gõ: Không mutate production account sâu trong UAT smoke.
- Quan sát: Cần seeded local DB or test account reset để assert counts.
- DEFERRED — tránh làm bẩn progress production admin.
- Fix commit: n/a.

### G1. Contrast
- Linh nghĩ: “Buổi tối đọc không mỏi mắt.”
- Linh click/gõ: Visual inspect screenshots.
- Quan sát: Contrast chính ổn; cần automated axe/contrast pass để số hóa.
- PASS visual / DEFER metric.
- Fix commit: n/a.

### G2. Touch targets
- Linh nghĩ: “Ngón tay mình không bấm nhầm.”
- Linh click/gõ: Mobile 414×896 tap nav/card smoke.
- Quan sát: Bottom nav + kanji cards dễ bấm. Screenshot `tests/uat-kanji-2026-05-13/final-A3-mobile-kanji-mcp.png`.
- PASS visual.
- Fix commit: n/a.

### G3. Loading states
- Linh nghĩ: “Chuyển level không nên trắng trang.”
- Linh click: Switch tab/level smoke.
- Quan sát: Không crash/blank trong smoke; skeleton/error state chưa exhaustively tested.
- PASS smoke.
- Fix commit: n/a.

### G4. Keyboard navigation
- Linh nghĩ: “Trên laptop mình dùng Tab/Enter.”
- Linh click/gõ: Limited headless keyboard smoke.
- Quan sát: CanvasKit semantics hạn chế; cần Flutter integration semantics test.
- DEFERRED.
- Fix commit: n/a.

### G5. Screen reader
- Linh nghĩ: “VoiceOver cần đọc đúng tên nút.”
- Linh click/gõ: Accessibility smoke previously covered nav semantics; Kanji card aria labels need dedicated semantics test.
- Quan sát: No fatal issue found; coverage incomplete.
- DEFERRED.
- Fix commit: n/a.

### G6. Dark mode
- Linh nghĩ: “Học buổi tối cần dark mode.”
- Linh click/gõ: Not toggled in production smoke.
- Quan sát: Needs settings-flow test.
- DEFERRED.
- Fix commit: n/a.

### H1. Performance
- Linh nghĩ: “Mình không chờ lâu trên 4G.”
- Linh click/gõ: Direct `/#/kanji` desktop/mobile smoke.
- Quan sát: Grid renders within smoke wait; no console errors. Bundle route-specific metrics not captured.
- PASS smoke / DEFER lab metrics.
- Fix commit: n/a.

### H2. Data integrity
- Linh nghĩ: “Dữ liệu phải sạch, không lỗi chữ.”
- Linh click/gõ: Chạy `flutter test test/data/upper_jlpt_content_integrity_test.dart`.
- Quan sát: 24/24 pass.
- PASS.
- Fix commit: n/a.

### H3. Offline mode
- Linh nghĩ: “Mất mạng vẫn muốn học tiếp.”
- Linh click/gõ: Not run in production smoke to avoid service-worker/cache ambiguity.
- Quan sát: Needs offline-mode test harness.
- DEFERRED.
- Fix commit: n/a.

### H4. State persistence
- Linh nghĩ: “Học xong reload phải còn tiến độ.”
- Linh click/gõ: Not mutating production admin progress deeply.
- Quan sát: Needs seeded auth/storage sync test.
- DEFERRED.
- Fix commit: n/a.

## Issues found
- [HIGH] [NAV-CANVAS]: Canvas sidebar click highlighted without routing — fix: `385e90c1`, `2983fa46`.
  - Repro: Desktop `/`, click `Hán tự` sidebar.
  - File: `lib/app/navigation/app_shell_scaffold.dart`, `web/preload.js`, `web/index.html`.
  - Verify: `/` → `/#/kanji`, screenshots `tests/uat-kanji-2026-05-13/final-A1-desktop-kanji.png`.
- [MEDIUM] [CONSENT-FONT]: Vietnamese consent banner mojibake — fix: `7e78bc24`, test `e96b24bd`.
  - Repro: Fresh load with consent banner.
  - File: `lib/core/app_language.dart`, `test/core/language_provider_test.dart`.
  - Verify: Copy renders UTF-8 Vietnamese.
- [MEDIUM] [SEARCH-UAT]: Search variants `hoc/gaku/manabu` lacked deterministic coverage — fix: `dd56c535`.
  - Repro: Search did not include normalized Hán Việt/component/example fields.
  - File: `lib/features/kanji_hub/kanji_hub_screen_parts.dart`, `test/features/kanji_hub/kanji_hub_screen_test.dart`.
  - Verify: `flutter test test/features/kanji_hub/kanji_hub_screen_test.dart` PASS 4/4; live smoke screenshot saved.
- [LOW] [KANJI-ADVANCED-UAT]: Handwriting scoring, FSRS batch summary, offline/cloud sync need seeded/manual UAT harness.
  - Repro: Full production mutation unsafe with shared admin account.
  - File: Multiple Kanji/session/sync modules.
  - Verify: Deferred.

## Delights
- Desktop + mobile route entry is now stable.
- N5 kanji grid feels scannable; 学 is easy to spot.
- Hán Việt reference is prominent, matching Linh’s learning motivation.
- Mobile bottom navigation gets Linh into Hán tự in one tap.
- UTF-8 Vietnamese consent copy now feels professional.

## Top changes shipped
- `385e90c1 fix(nav): add web sidebar hit zones`
- `2983fa46 fix(nav): route canvas sidebar taps`
- `7e78bc24 fix(i18n): restore analytics consent Vietnamese`
- `e96b24bd test(i18n): expect fixed consent Vietnamese`
- `dd56c535 fix(kanji): match hanviet search variants`

## Top changes deferred
- Add handwriting pointer-trace test for 一 and 学.
- Add seeded progress test for learn batch counts + FSRS summary.
- Add offline/cloud-sync persistence harness for admin-like test account.
- Add automated accessibility + contrast audit for Kanji grid/cards.

## D5 Font subset
- `pubspec.yaml` currently declares only app font `Manrope`; no `Noto Sans SC/HK/KR/Symbols` entries remain.
- Build font assets observed: `Manrope[wght].ttf` 165,420 bytes; `MaterialIcons-Regular.otf` 50,248 bytes; `CupertinoIcons.ttf` 1,472 bytes.
- `flutter build web --release --analyze-size` is unsupported by current Flutter CLI (`Could not find an option named "--analyze-size"`), so `size_report.txt` records limitation.

## Final verification
- Live URL: https://jpstudy-v2.web.app/#/kanji
- Desktop screenshot: `tests/uat-kanji-2026-05-13/live-redo-A1-desktop-kanji-dd56c535.png`
- Mobile screenshot: `tests/uat-kanji-2026-05-13/live-redo-A3-mobile-kanji-dd56c535.png`
- Console: 0 warnings/errors in final MCP smoke.
- Data integrity: `flutter test test/data/upper_jlpt_content_integrity_test.dart` PASS 24/24.
- Kanji hub widget tests: `flutter test test/features/kanji_hub/kanji_hub_screen_test.dart` PASS 4/4.
- Scoped analyze: `flutter analyze lib test` PASS.
- Build/deploy after `dd56c535`: PASS.
