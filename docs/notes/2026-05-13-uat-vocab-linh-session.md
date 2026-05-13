# UAT Vocab — Linh, N5, 2026-05-13

## Summary
- Best moment: Vocab hub vào nhanh, Minna/Hajimete rõ 2 track, mobile đọc được.
- Worst moment: Hajimete detail có mojibake ở nút lưu từ trước hotfix; đã sửa `c6e6a130`.
- Overall verdict: PASS có điều kiện cho browse/catalog/review-empty/match-empty. Các flow cần dữ liệu tiến độ thật (due cards, offline sync, XP/session summary) vẫn deferred vì live account hiện 0 due/0 active session data.

## Tasks 1-by-1

### A1. Từ `/` vào Từ vựng desktop
- Linh nghĩ: muốn vào nhanh từ sidebar, không muốn đoán route.
- Linh click: sidebar `Từ vựng`.
- Quan sát: hub render đúng, URL `/#/vocab`; screenshot `tests/uat-vocab-2026-05-13/A1-vocab-desktop-after-continue.png`.
- PASS — sidebar route hoạt động.
- Fix commit: none.

### A2. Mobile bottom `Thêm`
- Linh nghĩ: iPhone cần tìm `Từ vựng` trong nav phụ.
- Linh click: mobile nav, route trực tiếp `/vocab`.
- Quan sát: mobile hub render, cards xếp dọc; screenshot `tests/uat-vocab-2026-05-13/mobile-__vocab.png`.
- PASS — mobile layout usable; bottom menu full interaction not fully accessible under CanvasKit automation.
- Fix commit: none.

### A3. Direct `/vocab/minna`
- Linh nghĩ: muốn ôn theo Minna đang học ở lớp.
- Linh gõ: `https://jpstudy.web.app/#/vocab/minna`.
- Quan sát: `Minna N5`, 25 bài, 1327 mục từ, progress 0%; screenshot `tests/uat-vocab-2026-05-13/desktop-__vocab_minna.png`.
- PASS.
- Fix commit: none.

### A4. Direct `/vocab/hajimete`
- Linh nghĩ: muốn track theo chủ đề.
- Linh gõ: `/#/vocab/hajimete`.
- Quan sát: 14 chapter, 662 từ, quick entry Chương 01-03; screenshot `tests/uat-vocab-2026-05-13/desktop-__vocab_hajimete.png`.
- PASS.
- Fix commit: none.

### A5. Direct `/vocab/review` khi 0 due
- Linh nghĩ: nếu chưa có gì ôn, app phải nói rõ.
- Linh gõ: `/#/vocab/review`.
- Quan sát: empty state `Hiện không có từ đến hạn`, CTA `Quay lại`; screenshot `tests/uat-vocab-2026-05-13/desktop-__vocab_review.png`.
- PASS.
- Fix commit: none.

### B1. Header + encoding
- Linh nghĩ: tiếng Việt phải tự nhiên, không lỗi dấu.
- Linh nhìn: `Hôm nay`, `Học phần cốt lõi — không chỉ học nghĩa`.
- Quan sát: dấu tiếng Việt OK; screenshot `tests/uat-vocab-2026-05-13/vocab-vi.png`.
- PASS.
- Fix commit: none.

### B2. Due card dynamic count
- Linh nghĩ: muốn biết hôm nay cần ôn bao nhiêu.
- Linh nhìn: `Đến hạn 0`, `Lane hiện tại N5`.
- Quan sát: count khớp review-empty state 0.
- PASS.
- Fix commit: none.

### B3. Minna card
- Linh nghĩ: muốn thấy giáo trình quen thuộc.
- Linh click: `Minna no Nihongo I`.
- Quan sát: vào catalog Minna; icon sách có, không có thumbnail bìa thật.
- PASS with UX note — book-cover thumbnail deferred.
- Fix commit: none.

### B4. Hajimete card
- Linh nghĩ: muốn mở track chủ đề.
- Linh nhìn/click: recommended `Hajimete N5 (662 mục từ)` và route Hajimete.
- Quan sát: catalog render ổn; thumbnail riêng chưa có.
- PASS with UX note — thumbnail deferred.
- Fix commit: none.

### B5. Match game visible
- Linh nghĩ: muốn chơi nhanh để nhớ nghĩa.
- Linh gõ: `/#/vocab/match-session`.
- Quan sát: start screen `Ghép đúng term và nghĩa`; screenshot `tests/uat-vocab-2026-05-13/desktop-__vocab_match-session.png`.
- PASS.
- Fix commit: none.

### B6. Search terms
- Linh nghĩ: muốn gõ `tabemasu`, `ăn`, `食べる`.
- Linh click/gõ: search box không thấy trên visible hub/catalog.
- Quan sát: route direct term works for ids, but global vocab search not visible in tested viewport.
- DEFERRED — product gap: add visible vocab search across kana/VI/kanji.
- Fix commit: none.

### C1. Minna 25 bài
- Linh nghĩ: muốn đúng Minna I bài 1-25.
- Linh nhìn: stat `25 bài học`, cards `Bài 1`, `Bài 2`.
- Quan sát: PASS.
- Fix commit: none.

### C2. Lesson card metadata
- Linh nghĩ: cần biết bài nào, bao nhiêu từ, tiến độ.
- Linh nhìn: title, subtitle, word count, ready badge; progress summary top-level.
- Quan sát: lesson card lacks per-card progress bar in screenshot.
- PASS with UX note — per-card progress bar deferred.
- Fix commit: none.

### C3. Lesson detail
- Linh click: Bài 1 expected detail/list.
- Quan sát: route patterns/test suite cover lesson open; live deep click under CanvasKit not fully scripted.
- DEFERRED — add DOM-independent integration test for lesson detail list.
- Fix commit: none.

### C4. Mark-known session counts
- Linh nghĩ: muốn đánh dấu 10 từ đã thuộc.
- Linh thao tác: not executed live because no deterministic seeded user data/session harness.
- DEFERRED — requires seeded local DB/session test.
- Fix commit: none.

### C5. Mobile catalog
- Linh nhìn: mobile hub/catalog screenshots.
- Quan sát: cards/chips readable, tap targets visually >44px; screenshot `tests/uat-vocab-2026-05-13/mobile-__vocab_minna.png`.
- PASS.
- Fix commit: none.

### D1. Hajimete chapter list
- Linh nghĩ: muốn chapter N5 01-14.
- Linh nhìn: 14 chapter, 662 terms.
- Quan sát: PASS.
- Fix commit: none.

### D2. Chapter preview
- Linh nhìn: quick chips `Chương 01 • 48 từ`.
- Quan sát: cards show chapter + count; 3-4 lemma preview not visible above fold.
- PASS with UX note — preview terms lower/fold-dependent.
- Fix commit: none.

### D3. Chapter detail
- Linh gõ: `/#/vocab/hajimete/chapter?id=1`.
- Quan sát: detail renders flashcards, stats, actions; pre-fix save label mojibake, fixed and redeployed.
- IMPLEMENTED — screenshot before `desktop-__vocab_hajimete_chapter_id_1.png`, after cache-fresh EN `verify-c6e6a130-hajimete-detail-fresh.png`.
- Fix commit: `c6e6a130`.

### D4. Layout consistency
- Linh nghĩ: Minna và Hajimete nên cùng mental model.
- Linh so sánh: both use cream card, stats chips, back path; Hajimete has more study actions.
- PASS.
- Fix commit: none.

### E1. Review session with 10 due
- Linh nghĩ: muốn 4 nút FSRS.
- Linh gõ: `/vocab/review`.
- Quan sát: account has 0 due, so only empty state verified.
- DEFERRED — seeded due cards required.
- Fix commit: none.

### E2. Rating summary
- Linh thao tác: not executed; no due session.
- Quan sát: not verifiable live.
- DEFERRED.
- Fix commit: none.

### E3. Refresh interrupt
- Linh thao tác: not executed; no active session.
- Quan sát: not verifiable live.
- DEFERRED.
- Fix commit: none.

### F1-F5. Match game
- Linh nghĩ: muốn ghép Nhật ↔ Việt.
- Linh gõ/click: `/vocab/match-session`, saw start screen.
- Quan sát: session created with 0 items by direct route fallback; no gameplay data.
- PASS for route/start; DEFERRED for drag/timer/summary with seeded items.
- Fix commit: none.

### G1. Term detail
- Linh gõ: `/vocab/1`.
- Quan sát: detail `私`, reading, meaning VI, SRS state; screenshot `tests/uat-vocab-2026-05-13/desktop-__vocab_1.png`.
- PASS for basic detail; DEFERRED for TTS/IPA/conjugation/3 examples/link grammar/collocation.
- Fix commit: none.

### G2. Collocation
- Linh tìm: collocation suggestion not visible.
- Quan sát: DEFERRED product enhancement.
- Fix commit: none.

### G3. Furigana/ruby
- Linh nhìn: reading above kanji (`わたし` over `私`).
- Quan sát: PASS.
- Fix commit: none.

### H1. Data integrity
- Linh/QA chạy: `flutter test test/data/upper_jlpt_content_integrity_test.dart`.
- Quan sát: 24/24 pass.
- PASS.
- Fix commit: none.

### H2. Offline
- Linh thao tác: not executed live; Firebase/local sync needs dedicated harness.
- Quan sát: DEFERRED.
- Fix commit: none.

### H3. Performance
- Linh đo: route load screenshots completed under automation; no visible scroll lag in 25/14-card catalogs.
- Quan sát: PASS basic; no 4G throttled metric captured.
- Fix commit: none.

### H4. Bookmark persist
- Linh thao tác: not executed against live user to avoid mutating admin state further.
- Quan sát: DEFERRED seeded account/harness.
- Fix commit: none.

### H5. Search sanitize
- Linh thao tác: no visible global search field found.
- Quan sát: DEFERRED with B6.
- Fix commit: none.

## Issues found
- [HIGH] [VOCAB-MOJIBAKE]: Hajimete chapter save/count labels had literal `?` placeholders — fix: `c6e6a130`.
  - Repro: open `/#/vocab/hajimete/chapter?id=1` in VI; button showed `L?u t? n?y`/catalog counts showed `L?u`, `??n h?n`.
  - File: `lib/features/vocab/screens/hajimete_chapter_detail_screen.dart`, `lib/features/vocab/screens/hajimete_chapter_catalog_screen.dart`, `lib/features/vocab/vocab_copy.dart`.
  - Verify: targeted vocab tests pass, deployed to `https://jpstudy.web.app`, cache-fresh screenshot saved.
- [MEDIUM] [VOCAB-SEARCH-MISSING]: expected global vocab search for `tabemasu`/`ăn`/`食べる` not visible in tested hub/catalog.
  - Repro: open `/vocab`, `/vocab/minna`, `/vocab/hajimete`; no above-fold search box.
  - File: likely `lib/features/vocab/vocab_screen.dart` / `vocab_screen_parts.dart`.
  - Verify: deferred.
- [MEDIUM] [SESSION-SEED-NEEDED]: due review, match gameplay, XP/count assertions need seeded due/local DB data.
  - Repro: `/vocab/review` shows 0 due; `/vocab/match-session` direct route has 0 items.
  - File: test harness/data setup.
  - Verify: deferred.

## Delights
- Vocab hub mobile is readable and not blank on 414×896.
- Minna and Hajimete tracks make N5 learning paths obvious.
- Review-empty state is friendly and not a dead end.
- Term detail already shows large Japanese term + reading + VI meaning.
- Consent/banner Vietnamese font renders correctly after previous font work.

## Top changes shipped
- `c6e6a130 fix(vocab): repair Vietnamese chapter labels`.

## Top changes deferred
- Add visible cross-script vocab search.
- Add seeded SRS/match/offline UAT harness for deterministic progress/XP/sync assertions.
- Add richer term detail: TTS, conjugations, examples, grammar links, collocations.
- Add Minna per-card progress bars and true book thumbnails.

