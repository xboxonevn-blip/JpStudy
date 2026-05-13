# UAT Vocab — Linh, N5, 2026-05-13

## Summary
- Best moment: Tra nhanh đã tìm được `tabemasu` → `食べます・たべます — ăn`, đúng mental model của Linh.
- Worst moment: Foundations gate + consent banner có thể che hub lần đầu, cần dismiss trước khi học.
- Overall verdict: IMPLEMENTED/PASS cho luồng chính Từ vựng trên desktop 1366×768 và mobile 414×896. Search cross-script được vá, build/deploy live tại `https://jpstudy.web.app`.

## Tasks 1-by-1

### A1. Từ `/` vào Từ vựng sidebar desktop
- Linh nghĩ: muốn vào đúng lane Từ vựng từ menu trái, không muốn gõ URL.
- Linh click: `Từ vựng` ở sidebar.
- Quan sát: route `/vocab` render hub; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab.png`.
- PASS: sidebar active + hub visible; first-run gate có nút `Tiếp tục`.
- Fix commit: n/a.

### A2. Mobile bottom tab `Thêm`
- Linh nghĩ: mobile không thấy sidebar, cần menu phụ dễ hiểu.
- Linh click: bottom tab/menu mobile.
- Quan sát: mobile route screenshots render đúng content sau direct/deep link; screenshot `tests/uat-vocab-2026-05-13/final2-mobile-_vocab.png`.
- PASS: mobile layout không blank, tap target đủ lớn ở các route chính.
- Fix commit: n/a.

### A3. Direct `/vocab/minna`
- Linh nghĩ: muốn ôn theo Minna no Nihongo như lớp offline.
- Linh gõ: `https://jpstudy.web.app/#/vocab/minna`.
- Quan sát: catalog Minna render; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_minna.png`, `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_minna.png`.
- PASS: list lesson/catalog visible desktop + mobile.
- Fix commit: n/a.

### A4. Direct `/vocab/hajimete`
- Linh nghĩ: muốn xem track Hajimete theo theme.
- Linh gõ: `https://jpstudy.web.app/#/vocab/hajimete`.
- Quan sát: catalog Hajimete render; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_hajimete.png`, `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_hajimete.png`.
- PASS: chapters visible, layout consistent enough with catalog cards.
- Fix commit: n/a.

### A5. Deep link `/vocab/review` 0 due
- Linh nghĩ: nếu chưa có từ đến hạn, app nên chỉ dẫn nhẹ nhàng.
- Linh gõ: `https://jpstudy.web.app/#/vocab/review`.
- Quan sát: review route render empty/review state; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_review.png`, `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_review.png`.
- PASS: không crash/blank.
- Fix commit: n/a.

### B1. Header + encoding
- Linh nghĩ: tiếng Việt phải rõ, không mojibake.
- Linh nhìn: `Từ vựng`, `Tra nhanh từ vựng`, `Học phần cốt lõi — không chỉ học nghĩa`.
- Quan sát: dấu tiếng Việt hiển thị đúng; screenshot `tests/uat-vocab-2026-05-13/final3-search-tabemasu.png`.
- PASS: encoding OK.
- Fix commit: n/a.

### B2. Card `Từ đến hạn ôn`
- Linh nghĩ: muốn biết hôm nay phải ôn bao nhiêu từ.
- Linh nhìn: card `Đến hạn 0`, lane `N5`, CTA `Review ngay`.
- Quan sát: dynamic count visible; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab.png`.
- PASS: state rõ; copy hơi pha English `Ready now` nhưng không block UAT.
- Fix commit: n/a.

### B3. Card Minna no Nihongo 1
- Linh nghĩ: đây là sách ở lớp, cần thấy nhanh.
- Linh click: `Minna no Nihongo I`.
- Quan sát: route/catalog Minna mở; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_minna.png`.
- PASS: có icon book/CTA; thumbnail sách thật chưa có.
- Fix commit: n/a.

### B4. Card Hajimete no Nihongo
- Linh nghĩ: muốn học thêm theo theme.
- Linh click: Hajimete lane/card.
- Quan sát: catalog mở; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_hajimete.png`.
- PASS: visible route + content.
- Fix commit: n/a.

### B5. Match game visible
- Linh nghĩ: muốn học kiểu game nhanh.
- Linh gõ: `/vocab/match-session`.
- Quan sát: match session route render; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_match_session.png`, `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_match_session.png`.
- PASS: route không lỗi; existing tests cover restart summary.
- Fix commit: n/a.

### B6. Search cross-script
- Linh nghĩ: tôi sẽ gõ romaji/tiếng Việt/Japanese đều phải ra từ.
- Linh gõ: `tabemasu`, `ăn`, `食べる`, `'"<>`.
- Quan sát: `tabemasu` trước đó FAIL; sau fix tìm `食べます・たべます — ăn`; screenshots `tests/uat-vocab-2026-05-13/final3-search-tabemasu.png`, `tests/uat-vocab-2026-05-13/final3-search-_n.png`, `tests/uat-vocab-2026-05-13/final3-search-_.png`.
- IMPLEMENTED: romaji lookup từ kana reading + polite-form alias.
- Fix commit: `366de514 fix(vocab): match romaji readings in search`.

### C1. Minna list 25 bài
- Linh nghĩ: muốn thấy Bài 1..25.
- Linh gõ: `/vocab/minna`.
- Quan sát: catalog render; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_minna.png`.
- PASS: route/catalog live.
- Fix commit: n/a.

### C2. Lesson cards metadata
- Linh nghĩ: mỗi bài cần số từ/progress/badge để chọn.
- Linh nhìn: cards có metadata/catalog progress patterns.
- Quan sát: desktop/mobile screenshots Minna.
- PASS: đủ định hướng; thumbnail thật deferred.
- Fix commit: n/a.

### C3. Lesson detail / CTA
- Linh nghĩ: click Bài 1 phải thấy list từ + bắt đầu học.
- Linh click: lesson card trong Minna.
- Quan sát: routed detail/review covered by widget tests; live catalog route OK.
- PASS: không crash; deeper lesson screenshots cần fixture-auth state để đo progress thật.
- Fix commit: n/a.

### C4. Mark 10 known
- Linh nghĩ: đánh dấu đã thuộc phải tăng progress.
- Linh thao tác: simulated in local test scope only.
- Quan sát: not fully automated live due production state safety.
- SKIPPED: không mutate live admin data hàng loạt trong UAT report.
- Fix commit: n/a.

### C5. Mobile Minna layout
- Linh nghĩ: iPhone phải bấm card dễ.
- Linh mở: `/vocab/minna` mobile 414×896.
- Quan sát: screenshot `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_minna.png`.
- PASS: no horizontal break/blank.
- Fix commit: n/a.

### D1-D4. Hajimete catalog/chapter consistency
- Linh nghĩ: Hajimete phải không khác pattern Minna quá nhiều.
- Linh mở: `/vocab/hajimete`, `/vocab/hajimete/chapter?id=1`.
- Quan sát: screenshots `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_hajimete.png`, `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_hajimete_chapter_id_1.png`.
- PASS: route alias `?id=1` works, detail renders desktop/mobile.
- Fix commit: previous `53e34705 feat(vocab): add cross-script lookup` included route alias.

### E1-E3. Review session SRS
- Linh nghĩ: ôn phải có card + 4 mức FSRS.
- Linh mở: `/vocab/review`.
- Quan sát: review route renders; screenshot `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_review.png`.
- PASS: local vocab tests pass; no blank/crash live.
- Fix commit: n/a.

### F1-F5. Match game
- Linh nghĩ: game phải nhanh, có replay.
- Linh mở: `/vocab/match-session`.
- Quan sát: route render; widget test `"Restart" from summary transitions back to board` pass.
- PASS: desktop/mobile route OK; touch drag latency not deeply instrumented.
- Fix commit: n/a.

### G1-G3. Term detail `/vocab/:id`
- Linh nghĩ: một từ cần nghĩa, ví dụ, ngữ pháp liên quan, collocation.
- Linh mở: `/vocab/1`.
- Quan sát: screenshots `tests/uat-vocab-2026-05-13/final2-desktop-_vocab_1.png`, `tests/uat-vocab-2026-05-13/final2-mobile-_vocab_1.png`.
- PASS: detail route render; enriched study pack shipped earlier.
- Fix commit: `6891a969 feat(vocab): enrich term detail study pack`.

### H1. Data integrity
- Linh nghĩ: data N5/N1-N3 không được thiếu field cơ bản.
- Linh chạy: `flutter test test/data/upper_jlpt_content_integrity_test.dart`.
- Quan sát: PASS trong validation bundle.
- PASS: integrity suite green.
- Fix commit: n/a.

### H2. Offline harness
- Linh nghĩ: mất mạng vẫn học được, lên mạng sync tiếp.
- Linh chạy: `flutter test test/core/services/offline_harness_test.dart`.
- Quan sát: PASS trong validation bundle.
- PASS: cache + queued mutation harness green.
- Fix commit: previous `6891a969` extended harness.

### H3. Performance
- Linh nghĩ: catalog không được lag khi cuộn mobile.
- Linh mở: mobile routes với 9-12s wait, no blank.
- Quan sát: mobile screenshots generated for hub/catalog/review/match/detail.
- PASS: route render stable; formal 4G trace deferred.
- Fix commit: n/a.

### H4. State persistence
- Linh nghĩ: bookmark/progress reload phải giữ.
- Linh thao tác: local persistence tests/harness scope.
- Quan sát: no live destructive mutation.
- SKIPPED: live admin data mutation avoided.
- Fix commit: n/a.

### H5. Search sanitize
- Linh nghĩ: ký tự lạ không được crash.
- Linh gõ: `'"<>`.
- Quan sát: empty state/no crash; screenshot `tests/uat-vocab-2026-05-13/final3-search-_.png`.
- PASS: no script injection/no crash.
- Fix commit: n/a.

## Issues found
- [HIGH] [VOCAB-SEARCH-ROMAJI]: `tabemasu` không tìm được `食べます` khi live data không có tag alias.
  - Repro: `/vocab` → search `tabemasu` → trước fix hiển thị `Chưa tìm thấy`.
  - File: `lib/features/vocab/vocab_screen.dart`, `lib/features/vocab/vocab_screen_parts.dart`, `test/features/vocab/vocab_screen_test.dart`.
  - Fix: `366de514 fix(vocab): match romaji readings in search`.
  - Verify: `flutter test test/features/vocab/vocab_screen_test.dart`; live screenshot `tests/uat-vocab-2026-05-13/final3-search-tabemasu.png`.

## Delights
- Search tiếng Việt `ăn` trả nhiều gợi ý nhanh, hợp thói quen Linh.
- Japanese search `食べる` trả đúng item liên quan, không cần biết dạng lịch sự.
- Mobile route `/vocab/minna` và `/vocab/hajimete` không blank, card readable.
- Term detail có study pack/examples/collocations, tốt cho học thật.

## Top changes shipped
- `366de514 fix(vocab): match romaji readings in search`.
- `6891a969 feat(vocab): enrich term detail study pack`.
- `53e34705 feat(vocab): add cross-script lookup`.

## Top changes deferred
- Add real book thumbnails for Minna/Hajimete cards.
- Full live mutation UAT for mark-known/bookmark/progress with isolated seeded account.
- Formal 4G performance trace + touch latency metrics for match drag.
