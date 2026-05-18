# Autonomous Loop Status

## 2026-05-17

- Track A P0/P1 seed backlog created in `docs/research/quality-backlog.md`.
- Verified locally: Profile shell click routes to `/me`; selected branch is derived from URL path; stale branch index no longer drives selection.
- Verified locally: VI copy guards cover the reported vocab/review leaks and review-page metaphors.
- Verified locally: Vietnamese vocab catalog status badges no longer render `Companion` or duplicate `Bổ trợ`.
- Verified locally: upper-level generated/prefixed Minna lesson titles fall back to Shin Kanzen curriculum titles.
- Verified locally: the Home/Review next-lesson action maps level-scoped storage IDs such as `200001` back to Shin Kanzen source lesson titles.
- Still unverified: live deployed proof on `https://jpstudy.web.app` after deploy/cache-clear.
- Still pending: Track B `vi-source-verified` content verification loop. No `vi-human-approved` tags added.

## 2026-05-17 Continued

- Verified + pushed: `624ac24c fix(vocab): wire Shin Kanzen catalog tracks`.
- Verified locally: `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, and full `flutter test` passed with 2298 tests.
- Deployed: Firebase Hosting `jpstudy` from `624ac24c`.
- Verified live after deploy: `/#/vocab/shinkanzen?level=N3` shows 25 lessons / 404 terms and non-zero rows; N2 shows 25 lessons / 1797 terms; N1 shows 25 lessons / 3476 terms.
- Added pending backlog: roadmap honesty gate (P0), grammar practice gate (P1), quiz answer-selection redesign (P1).
- Still pending: Track A roadmap honesty gate next; Track B `vi-source-verified` loop not started in this continuation.

## 2026-05-17 Roadmap Gate

- Verified locally: QA-A-007 roadmap is no longer a decorative list. Resource chips now carry real destinations; upper levels sequence Shin Kanzen vocab before grammar; Hajimete is optional; listening is not rendered without audio inventory; fixed month promises are replaced by adaptive hour labels.
- Verified locally: `flutter test test/features/home/models/textbook_roadmap_test.dart test/features/home/learning_path_foundations_gate_test.dart`, `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, and full `flutter test` passed with 2299 tests.
- Verified live after deploy with cache disabled: N3 roadmap no longer shows fixed month/listening stages, and visible chips opened non-empty routes for Shin Kanzen vocab, Hajimete optional vocab, grammar, kanji, immersion, and exam.
- Still unverified: full chip-by-chip live sweep at N5/N4/N2/N1. A long N2/N1 batch timed out before returning a complete result, so it is not counted as verified.
- Added pending backlog: Kanji Hán-Việt route/language gating (P0), per-language kanji UX (P1), and JLPT-complete kanji expansion (P2).

## 2026-05-17 Han-Viet Route Gate

- Verified locally: QA-A-010 no longer routes Hán-Việt rules through the N5-only Kana gate. `/foundations/han-viet` renders at N4, and Kanji hub exposes a new `/kanji/han-viet` action only for Vietnamese UI.
- Verified locally: EN UI hides the Kanji Hán-Việt rules action. Focused tests, `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, taxonomy guard, and full `flutter test` passed with 2301 tests.
- Verified live after deploy with cache disabled: N3 `/kanji/han-viet` renders Hán-Việt rules, legacy `/foundations/han-viet` also renders rules without the Kana lock, and EN Kanji hides the Hán-Việt action.

## 2026-05-17 Quiz Answer Selection Slice

- Verified locally: grammar multiple-choice questions now require select -> confirm; tapping an option no longer commits immediately.
- Verified locally: four-answer grammar multiple-choice uses a 2x2 grid on wide layouts and a compact one-column mobile layout with all options plus the confirm button hit-testable inside a 390x640 viewport.
- Verified locally: grammar practice no longer repeats the full mode/config card on every question; the top row is reduced to question count, progress, and question type.
- Verified live after deploy `4622e4c5`: desktop `/#/grammar-practice` shows one slim top row, four answers in a 2x2 grid, and disabled `Answer` until selection; mobile 390x640 shows question, four compact answer rows, and `Answer` in one viewport.
- Verified live after deploy `4622e4c5`: tapping a mobile answer then `Answer` advances from question 1 to question 2, proving select -> confirm is active.
- Still pending: one shared quiz component across lesson test, grammar gate, and JLPT mock/exam.

## 2026-05-17 Learn Multiple-Choice Confirm Slice

- Verified locally: lesson learn multiple-choice no longer submits on option tap; option tap only selects and the `learn_mc_confirm` button submits.
- Verified locally: `flutter test test/features/learn/learn_screen_test.dart test/features/test/test_screen_submit_test.dart test/features/test/test_screen_feedback_test.dart` passed.
- Verified locally: `flutter test test/features/learn/widgets/learn_widgets_test.dart` passed.
- Still unverified: deployed/live proof for lesson learn multiple-choice after this commit.
- Still pending: one shared quiz component across lesson test, grammar gate, and JLPT mock/exam.

## 2026-05-17 Lesson Test Mobile Layout Slice

- Live check after deploy `12283ccc` found lesson test mobile still broken: the header text wrapped vertically and the answer area did not fit.
- Verified locally with new guard: `flutter test test/features/test/test_screen_mobile_layout_test.dart` passes and catches the former mobile overflow under a 390x540 shell-height viewport.
- Verified locally: focused learn/test/grammar regression suites passed after compacting the shared learn multiple-choice/true-false primitives and TestScreen mobile header.
- Follow-up live check after `bcf3052a` still failed for lesson-test MC: only A/B were visible. Fixed with commits `59b16a2b`, `5d72d991`, and `cd93753f`.
- Verified locally after `cd93753f`: `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, focused learn/test/mock suites, and full `flutter test` passed with 2306 tests.
- Deployed `cd93753f` to Firebase Hosting.
- Verified live after cache clear at `https://jpstudy.web.app/?codexFresh=cd93753f#/lesson/1` with 390x640 viewport: lesson-test true/false choices fit; lesson-test MC shows question, all four choices, and `Kiểm tra` in one viewport; tapping an option only selects and enables `Kiểm tra`.
- Still pending: one shared quiz component across lesson test, grammar gate, and JLPT mock/exam.
- Added/confirmed pending Kanji backlog: per-language kanji UX (Vietnamese Hán-Việt-centric; English hides Hán-Việt; Japanese immersion) and phased KANJIDIC2/Unihan kanji expansion with reachability guards.

## 2026-05-18 Kanji Per-Language Detail Slice

- Verified locally: Vietnamese Kanji detail shows a Hán-Việt row, Vietnamese mnemonic, and the inline Hán-Việt panel.
- Verified locally: English and Japanese Kanji detail hide Hán-Việt rows/panels; English shows the English mnemonic.
- Verified locally: Kanji card semantics now use language-specific labels instead of Vietnamese-only `Học/onyomi/kunyomi` copy.
- Verified locally: `flutter test test/features/kanji_hub/kanji_hub_screen_test.dart`, `flutter test test/features/kanji_hub/kanji_hub_semantics_test.dart`, `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, and full `flutter test` passed with 2309 tests.
- Still pending: live proof after deploy; kanji lesson/practice/search consumers; Japanese definition data completeness; phased KANJIDIC2/Unihan expansion.

## 2026-05-18 Kanji Han-Viet Seed Backfill

- Live check after `9471f273` found the detail labels updated, but the Hán-Việt row was still absent for seeded production kanji because `labels.hanViet` was not copied into `decomposition_json`.
- Verified locally: content DB schema v33 reseeds kanji, and the new DB regression confirms `人` carries `decomposition.hanViet = Nhân`.
- Verified locally: `flutter test test/data/db/content_database_lazy_seed_test.dart`, kanji hub tests, kanji semantics tests, `flutter analyze lib test`, string guard, taxonomy guard, and full `flutter test` passed with 2310 tests.
- Deployed `edcfa4ff` to Firebase Hosting.
- Verified live with cache-disabled/new-page checks: Vietnamese `人` detail shows `Hán-Việt Nhân`; English `人` detail hides Hán-Việt UI and shows English mnemonic; Japanese `作` detail hides Hán-Việt UI. Japanese definition data is still incomplete and falls back to English meaning, so that remains pending.

## 2026-05-18 Kanji Search Language Gate

- Verified locally: English Search no longer matches hidden Hán-Việt keywords; Vietnamese Search still matches Hán-Việt queries.
- Verified locally: `flutter test test/features/search/search_screen_test.dart`, `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, taxonomy guard, and full `flutter test` passed with 2311 tests.
- Still pending: live proof of Search Hán-Việt keyword gating; kanji lesson/practice consumers.

## 2026-05-18 Kanji Lesson/Practice Language Slice

- Verified locally: lesson kanji list hides Hán-Việt labels and Vietnamese decomposition component names for EN/JA, while VI still shows them.
- Verified locally: Japanese lesson kanji, kanji reading home, kanji reading quiz, and handwriting practice no longer show Vietnamese meanings when an English fallback exists.
- Verified locally: `flutter test test/features/lesson/widgets/kanji_list_widget_test.dart test/features/kanji_reading/kanji_reading_quiz_screen_test.dart test/features/kanji_reading/home_kanji_reading_screen_test.dart test/features/write/handwriting_walkthrough_test.dart` passed.
- Verified locally: `flutter analyze lib test`, UI string guard, taxonomy guard, and full `flutter test` passed with `2317` tests after the lesson/practice consumer slice.
- Deployed `4747b677` to Firebase Hosting.
- Verified live after deploy: Japanese Kanji detail for `作` shows the English fallback `make, create` and no Hán-Việt row/panel; Japanese Search query `nhan` returns no matches, so hidden Vietnamese Hán-Việt keywords do not drive results.
- Verified live after deploy: Japanese lesson Kanji tab for N5 shows English fallback meanings and no Hán-Việt fields. Japanese Kanji Reading practice shows English fallback meaning `exploits, achievements` and no Hán-Việt fields.
- Still broken before follow-up fix: Japanese `書く` from Kanji Practice blanked the content area. Console showed `RangeError: max must be in range 0 < max <= 2^32, was 0`, traced to `Random().nextInt(1 << 32)` in handwriting session seed generation after web compilation.
- Fixed locally: replaced the seed max with a web-safe constant and added a regression guard that failed before the fix. `flutter analyze lib test`, UI string guard, taxonomy guard, focused handwriting tests, and full `flutter test` passed with `2318` tests.
- Deployed `b07d10f6` to Firebase Hosting.
- Verified live after deploy: Japanese `/#/kanji/practice` -> `書く` renders `手書き: N3 — 新しい漢字`, shows `leader, commander` as the fallback meaning, and no longer logs the RangeError. The only new warning was the existing manifest icon warning.
- Still pending: real Japanese definition data.

## 2026-05-17 Kanji Japanese Meaning Plumbing

- Verified inventory gap: `assets/data/content` currently has `0` `meaningJa` fields, so live Japanese Kanji cannot yet show native Japanese definitions without new source-backed data.
- Implemented locally: `KanjiItem.meaningJa`, `KanjiItem.displayMeaning(AppLanguage)`, content DB schema v34, seed/repository mapping for `labels.meaningJa`, and consumer wiring for Kanji detail/grid, Search, lesson Kanji list, Kanji Reading, and Handwriting.
- Added focused regressions using synthetic `meaningJa` values so Japanese UI prefers Japanese definitions when available, then falls back to English/Vietnamese honestly when not.
- Verified locally: focused Kanji/search/write tests passed, `flutter analyze lib test` passed, UI string guard reported `0` candidates, taxonomy guard passed, and full `flutter test` passed with `2321` tests.
- Deployed `a3648697` to Firebase Hosting. Live smoke with Japanese prefs showed the Kanji hub using Japanese chrome and English fallback meanings. This verifies the no-data fallback path only; real Japanese definitions remain unverified because the assets still have `0` `meaningJa` fields.
- Still pending: source-backed Japanese definition content and phased JLPT-complete kanji expansion; do not claim Japanese immersion data completeness yet.

## 2026-05-18 Kanji Content DB Self-Heal

- Verified root cause for the owner-reported Kanji load regression: an existing content DB can have a current schema version while physically missing `kanji.meaning_ja`, causing Drift reads/seeds to fail before Kanji grid or handwriting practice can load.
- Fixed in `ed47e8ae`: content DB now self-heals `meaning_ja` in `beforeOpen` and before upper kanji reseeds during upgrade. Added regression DB fixtures for v34 and pre-v33 databases missing the column.
- Verified locally: `flutter test test/data/db/content_database_lazy_seed_test.dart`, `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, `dart run tool/research/content_vi_status_report.dart`, and full `flutter test` all passed; full suite ended at `2326`.
- Deployed to Firebase Hosting `jpstudy`.
- Verified live after deploy: VI/EN/JA across N5/N4/N3/N2/N1 loaded real Kanji grid rows and `Write/Viết/書く` handwriting practice; the 15-combo Playwright matrix had `failed=0` and `consoleErrors=0`.
- Still pending: old-browser IndexedDB migration cannot be directly proven against a production user DB without owning that browser state; the local regression fixtures cover the missing physical column path that caused the failure class.

## 2026-05-18 Kanji Expansion Audit Baseline

- Added a reproducible KANJIDIC2 old-JLPT coverage audit for QA-B-002. The local KANJIDIC2 XML remains a `.codex` cache and is ignored, not committed.
- Verified locally: `flutter test test/core/research/kanji_coverage_audit_test.dart test/tool/research/kanji_coverage_audit_report_test.dart` passed. The real-cache CLI run completed against `assets/data/content`.
- Baseline: current unique Kanji `638`; KANJIDIC2 old-JLPT unique `2230`; missing source kanji N5 `33`, N4 `157`, N2 `654`, N1 `1168`. KANJIDIC2 has no modern N3 tier, so N3 expansion still needs a separate modern JLPT source.
- Still pending: no generated Kanji were added yet; reachability guards and source-backed modern JLPT level mapping must come before expansion batches.

## 2026-05-18 Kanji Runtime Reachability Guard

- Added `test/data/content/kanji_runtime_reachability_test.dart` so every authored kanji asset entry must seed into `ContentDatabase` and return from `LessonRepository.fetchKanjiByLevel`.
- This protects the shared Kanji UI consumer path: grid, search, SRS, reading practice, and handwriting practice all depend on level fetches.
- Verified locally: `flutter test test/data/content/kanji_runtime_reachability_test.dart` passed. No new Kanji content generated yet.

## 2026-05-18 Kanji Expansion Source Policy

- Verified source boundary: official JLPT does not publish modern vocabulary/kanji/grammar lists; KANJIDIC2 and Unihan are redistribution-safe fact sources, but KANJIDIC2 only has old JLPT tiers.
- Added `docs/research/D2-content/kanji-expansion-source-policy-2026-05-18.md`.
- Decision: do not bulk-copy third-party modern JLPT kanji lists with unclear licenses. N5/N4 can start from KANJIDIC2 old tiers; N3/N2/N1 need a redistribution-safe modern mapping or owner-approved curriculum mapping before generation.

## 2026-05-18 N5 Kanji Completeness Patch

- Source-verified four N5 kanji with missing `meaningVi`: `二`, `三`, `漢`, `雪`.
- Corrected `二` Hán-Việt from native meaning `Hai` to `Nhị`; corrected `三` from `Ba` to `Tam`; added natural Vietnamese meanings/search text for all four.
- Changed these edited entries to `vi-source-verified` and updated taxonomy/content-status tooling to treat that tag as an approval signal. No `vi-human-approved` tag was added.
- Added content DB schema v35 reseed so these asset edits reach existing users, with a regression for stale v34 `二/Hai` content.
- Logged sources in `docs/research/D2-content/verification-log-2026-05-18.md`.
- Verified locally: kanji coverage audit now reports N5 incomplete current entries `0`; content status remains machine/open-review `0`; focused taxonomy/reachability/audit tests passed.

## 2026-05-18 N4 Kanji Related-Kanji Patch

- Filled empty `relatedKanji` lists for 13 N4 kanji: `色`, `予`, `静`, `危`, `以`, `文`, `死`, `飛`, `包`, `乾`, `疑`, `配`, `参`.
- No Hán-Việt, meanings, readings, or examples changed in this batch.
- Verified locally: kanji coverage audit now reports N4 incomplete current entries `0`; focused reachability/audit tests passed.

## 2026-05-18 N3 Kanji Lesson 02 Completeness Patch

- Source-verified all eight N3 lesson-02 kanji (`将`, `来`, `目`, `標`, `計`, `画`, `努`, `力`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `将`, `標`, `計`, `画`, `努`; normalized learner-facing Vietnamese display/search text; filled all lesson-02 `relatedKanji` lists.
- Added entry-level `vi-source-verified` tags for the eight edited entries. No `vi-human-approved` tag was added.
- Verified locally: JSON parses and kanji coverage audit reduced N3 incomplete current entries from `182` to `174`.
- Added content DB metadata revision `2` so post-v35 asset metadata edits reseed for existing browsers, with a regression covering a current-version stale `将` row.
- Verified live after deploying `a8ae956c` against the existing Playwright browser IndexedDB: N3 Kanji grid loaded, `将` detail showed updated Vietnamese display `tướng, tương lai`, `/kanji/practice` -> `Viết` loaded `Viết tay: N3 - Học kanji mới`, and console errors remained `0`.

## 2026-05-18 N3 Kanji Lesson 03 Completeness Patch

- Source-verified all eight N3 lesson-03 kanji (`節`, `約`, `無`, `駄`, `再`, `資`, `源`, `環`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `節`, `無`, `再`, `源`, and `環`; normalized lowercase Hán-Việt on `駄`/`資`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-03 `relatedKanji` lists.
- Replaced lesson-03 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `3` so existing browsers with revision `2` receive the new lesson-03 metadata; regression now starts from `content_meta.kanjiSeedRevision=2` and stale `節`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, and kanji coverage audit reduced N3 incomplete current entries from `174` to `168`.
- Deployed `42769e1b` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded lesson-03 row (`節`, `約`, `無`, `駄`, `再`, `資`, `源`, `環`), `節` detail showed `Tiết (tiết; đốt; giai đoạn)` plus Hán-Việt `Tiết`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 04 Completeness Patch

- Source-verified all eight N3 lesson-04 kanji (`留`, `学`, `文`, `化`, `言`, `語`, `交`, `流`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `化`, `言`, `語`, `交`, and `流`; normalized learner-facing Vietnamese display/search text for all eight entries; filled all lesson-04 `relatedKanji` lists.
- Replaced lesson-04 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `4` so existing browsers with revision `3` receive the new lesson-04 metadata; regression now starts from `content_meta.kanjiSeedRevision=3` and stale `化`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, content status stayed machine/open-review `0`, and kanji coverage audit reduced N3 incomplete current entries from `168` to `164`.
- Deployed `8516dc04` to Firebase Hosting and verified live after CDP cache-disabled reload: searching `化` opened the N3 lesson-04 detail with `Hóa (biến đổi; -hóa)` plus Hán-Việt `Hóa`; console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 05 Completeness Patch

- Source-verified all eight N3 lesson-05 kanji (`就`, `職`, `面`, `接`, `給`, `残`, `責`, `任`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `就`, `職`, `接`, `給`, `責`, and `任`; normalized lowercase Hán-Việt on `面`/`残`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-05 `relatedKanji` lists.
- Replaced lesson-05 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `5` so existing browsers with revision `4` receive the new lesson-05 metadata; regression now starts from `content_meta.kanjiSeedRevision=4` and stale `任`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, content status stayed machine/open-review `0`, and kanji coverage audit reduced N3 incomplete current entries from `164` to `156`.
- Deployed `5dc748ad` to Firebase Hosting and verified live with cache disabled: `任` detail showed `Nhậm (trách nhiệm; giao phó)` plus Hán-Việt `Nhậm`; console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 06 Completeness Patch

- Source-verified all eight N3 lesson-06 kanji (`注`, `文`, `配`, `送`, `返`, `品`, `評`, `価`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `返`, `品`, and `評`; normalized lowercase Hán-Việt on `価`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-06 `relatedKanji` lists.
- Replaced lesson-06 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `6` so existing browsers with revision `5` receive the new lesson-06 metadata; regression now starts from `content_meta.kanjiSeedRevision=5` and stale `返`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, and kanji coverage audit reduced N3 incomplete current entries from `156` to `148`.
- Deployed `9a35ca6a` to Firebase Hosting and verified live with cache disabled: search `返` opened detail showing `Phản (trả lại; quay lại)` plus Hán-Việt `Phản`; console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 07 Completeness Patch

- Source-verified all eight N3 lesson-07 kanji (`健`, `康`, `睡`, `眠`, `栄`, `養`, `治`, `療`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `健`, `康`, `睡`, `栄`, `養`, `治`, and `療`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-07 `relatedKanji` lists.
- Replaced lesson-07 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `7` so existing browsers with revision `6` receive the new lesson-07 metadata; regression now starts from `content_meta.kanjiSeedRevision=6` and stale `健`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, and kanji coverage audit reduced N3 incomplete current entries from `148` to `141`.
- Deployed `7d036448` to Firebase Hosting and verified live with cache disabled: search `健` opened detail showing `Kiện (khỏe mạnh; sức khỏe)` plus Hán-Việt `Kiện`; console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 08 Completeness Patch

- Source-verified all eight N3 lesson-08 kanji (`伝`, `統`, `祭`, `季`, `節`, `神`, `礼`, `祖`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `統`, `祭`, `季`, `節`, and `神`; normalized lowercase Hán-Việt on `祖`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-08 `relatedKanji` lists.
- Replaced lesson-08 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `8` so existing browsers with revision `7` receive the new lesson-08 metadata; regression now starts from `content_meta.kanjiSeedRevision=7` and stale `統`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, and kanji coverage audit reduced N3 incomplete current entries from `141` to `133`.
- Deployed `6019e798` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `統` returned one result, detail opened with `Thống (thống nhất; quản lý; hệ thống)` plus Hán-Việt `Thống`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 09 Completeness Patch

- Source-verified all eight N3 lesson-09 kanji (`新`, `聞`, `雑`, `誌`, `放`, `報`, `記`, `論`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `誌`, `放`, `報`, `記`, and `論`; normalized lowercase Hán-Việt on `雑`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-09 `relatedKanji` lists.
- Replaced lesson-09 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `9` so existing browsers with revision `8` receive the new lesson-09 metadata; regression now starts from `content_meta.kanjiSeedRevision=8` and stale `誌`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, content status stayed machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `133` to `125`.
- Deployed `7b22c3df` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `誌` returned one result, detail opened with `Chí (tạp chí; ghi chép)` plus Hán-Việt `Chí`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 10 Completeness Patch

- Source-verified all eight N3 lesson-10 kanji (`旅`, `観`, `交`, `通`, `予`, `約`, `宿`, `泊`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `観`, `交`, `宿`, and `泊`; kept pedagogic `Dự` for `予` despite source mismatch because Japanese `予` compounds map to `dự` for learners; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-10 `relatedKanji` lists.
- Replaced lesson-10 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `10` so existing browsers with revision `9` receive the new lesson-10 metadata; regression now starts from `content_meta.kanjiSeedRevision=9` and stale `観`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, content status stayed machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `125` to `117`.
- Deployed `5db208d6` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `観` returned one result, detail opened with `Quan (xem; quan sát; quan điểm)` plus Hán-Việt `Quan`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 11 Completeness Patch

- Source-verified all eight N3 lesson-11 kanji (`震`, `災`, `害`, `避`, `難`, `洪`, `津`, `警`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `災`, `害`, `避`, `難`, `洪`, and `警`; normalized lowercase Hán-Việt on `震` and `津`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-11 `relatedKanji` lists.
- Replaced lesson-11 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `11` so existing browsers with revision `10` receive the new lesson-11 metadata; regression now starts from `content_meta.kanjiSeedRevision=10` and stale `災`.
- Verified locally: lesson JSON parses, focused DB/reachability/taxonomy/coverage tests passed, UI string guard stayed at `0`, content status stayed machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `117` to `110`.
- Deployed `5fb47313` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `災` returned one result, detail opened with `Tai (thiên tai; tai họa)` plus Hán-Việt `Tai`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 12 Completeness Patch

- Source-verified all eight N3 lesson-12 kanji (`芸`, `術`, `演`, `劇`, `鑑`, `賞`, `奏`, `撮`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for all eight entries; kept pedagogic `Nghệ` for Japanese shinjitai `芸術` despite KANJIDIC2 listing `芸` as `Vân`; rewrote learner-facing Vietnamese display/search text; filled all lesson-12 `relatedKanji` lists.
- Replaced lesson-12 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `12` so existing browsers with revision `11` receive the new lesson-12 metadata; regression now starts from `content_meta.kanjiSeedRevision=11` and stale `芸`.
- Verified locally: `flutter analyze lib test`, UI string guard (`0` candidates), content status report (machine/open-review `0`), full `flutter test` (`2329` passed), and kanji coverage audit reduced N3 incomplete current entries from `110` to `102`.
- Deployed `6eb06479` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `芸` returned one result, detail opened with `Nghệ (nghệ thuật; tài nghệ)` plus Hán-Việt `Nghệ`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 13 Completeness Patch

- Source-verified all eight N3 lesson-13 kanji (`教`, `育`, `課`, `題`, `績`, `席`, `卒`, `導`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `課`, `績`, `卒`, and `導`; capitalized/normalized Hán-Việt on `題` and `席`; rewrote learner-facing Vietnamese display/search text; filled all lesson-13 `relatedKanji` lists.
- Replaced lesson-13 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `13` so existing browsers with revision `12` receive the new lesson-13 metadata; regression now starts from `content_meta.kanjiSeedRevision=12` and stale `課`.
- Verified locally: focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, content status report machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `102` to `95`.
- Deployed `cf404253` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `課` returned one result, detail opened with `Khóa (bài học; khóa học; phần bài)` plus Hán-Việt `Khóa`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 14 Completeness Patch

- Source-verified all eight N3 lesson-14 kanji (`族`, `戚`, `婦`, `育`, `結`, `離`, `援`, `頼`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `族`, `戚`, `婦`, `結`, `離`, and `援`; normalized `育` and `頼`; rewrote learner-facing Vietnamese display/search text; filled all lesson-14 `relatedKanji` lists.
- Replaced lesson-14 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `14` so existing browsers with revision `13` receive the new lesson-14 metadata; regression now starts from `content_meta.kanjiSeedRevision=13` and stale `族`.
- Verified locally: focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, content status report machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `95` to `87`.
- Deployed `59a896fe` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `族` returned one result, detail opened with `Tộc (gia tộc; dân tộc; dòng họ)` plus Hán-Việt `Tộc`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 15 Completeness Patch

- Source-verified all eight N3 lesson-15 kanji (`住`, `宅`, `築`, `賃`, `貸`, `設`, `備`, `民`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `築`, `設`, `備`, and `民`; normalized housing/rent/equipment learner meanings and search text for all eight entries; filled all lesson-15 `relatedKanji` lists.
- Replaced lesson-15 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `15` so existing browsers with revision `14` receive the new lesson-15 metadata; regression now starts from `content_meta.kanjiSeedRevision=14` and stale `住`.
- Verified locally: focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, content status report machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `87` to `79`.
- Deployed `38d88d85` to Firebase Hosting and verified live with cache-bypass while preserving IndexedDB: N3 Kanji grid loaded, searching `住` returned one result, detail opened with `Trú (sống ở; cư trú; nơi ở)` plus Hán-Việt `Trú`, VI write practice loaded `Viết tay: N3 - Học kanji mới`, and console errors/warnings remained `0`.

## 2026-05-18 N3 Kanji Lesson 16 Completeness Patch

- Source-verified all eight N3 lesson-16 kanji (`試`, `勝`, `負`, `選`, `練`, `優`, `決`, `審`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `試`, `勝`, `負`, `練`, and `審`; normalized `選`, `優`, and `決`; rewrote learner-facing Vietnamese display/search text; filled all lesson-16 `relatedKanji` lists.
- Replaced lesson-16 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `16` so existing browsers with revision `15` receive the new lesson-16 metadata; regression now starts from `content_meta.kanjiSeedRevision=15` and stale `試`.
- Verified locally: JSON parse passed, focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, content status report machine/open-review `0`, full `flutter test` passed with `2329` tests, and kanji coverage audit reduced N3 incomplete current entries from `79` to `71`.
- Deployed with `78febd31`; live proof included cache-disabled N3 Kanji grid and write flow loading with console warnings/errors `0`.

## 2026-05-18 QA-A-014 Kanji Content DB Partial-Coverage Repair

- Owner reported a P0 deployed regression where VI/N3 `/#/kanji` and `/#/kanji/practice` could still fail after the prior `meaning_ja` self-heal.
- Fresh-storage live check loaded N3 Kanji grid with `203` items and `Luyện viết (N3)`, so assets and fresh DB seeding are valid.
- Root cause found locally: startup self-heal only checked whether each JLPT level had any kanji rows. A current-version content DB with one stale N3 row and `content_meta.kanjiSeedRevision=16` skipped reseed and stayed partial.
- Added a RED regression for that current-version partial DB; it failed because `試` was absent. Implemented manifest-count coverage repair by comparing per-level DB counts to `assets/data/content/index.json` and reseeding only incomplete kanji levels.
- Verified locally: the new regression passes; focused native DB/reachability tests pass; `flutter test -d chrome test/data/content/kanji_runtime_reachability_test.dart` passes; UI string guard stays at `0`; content status machine/open-review stays `0`; taxonomy guard passes; `flutter analyze lib test` is clean; full `flutter test` passes with `2330`.
- Built and deployed `78febd31` to Firebase Hosting.
- Live proof with CDP cache disabled: VI Kanji grid loaded non-empty for N5, N4, N3, N2, and N1; VI write practice loaded `Viết tay: N1 — Học kanji mới`; EN grid and handwriting loaded with English copy; JA grid and handwriting loaded with Japanese copy; console warnings/errors remained `0`.

## 2026-05-18 N3 Kanji Lesson 17 Completeness Patch

- Source-verified all eight N3 lesson-17 kanji (`科`, `技`, `明`, `験`, `開`, `発`, `機`, `械`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for `技` and `械`; normalized `験`; rewrote learner-facing Vietnamese display/search text for all eight entries; filled all lesson-17 `relatedKanji` lists.
- Replaced lesson-17 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `17` so existing browsers with revision `16` receive the new lesson-17 metadata; regression now starts from `content_meta.kanjiSeedRevision=16` and stale `技`.
- Verified locally: JSON parse passed, coverage audit reduced N3 incomplete current entries from `71` to `63`, focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, content status report machine/open-review `0`, and full `flutter test` passed with `2330`.
- Live proof is pending after commit, push, build, and deploy.

## 2026-05-18 QA-A-015 Kanji Runtime Ensure Deadlock Repair

- Verified issue: `test/data/content/kanji_runtime_reachability_test.dart` hung because `LessonRepository.fetchKanjiByLevel` called public `ContentDatabase.ensureKanjiContentCurrent()` before the first content DB query.
- Root cause: that public ensure opened Drift; `beforeOpen` then awaited the same pending public ensure, causing a startup deadlock for unopened content DBs. Repository-level Kanji caches were also cleared on every Kanji read.
- Fix: `beforeOpen` now runs the private Kanji ensure path; public ensure returns whether it repaired content; `LessonRepository` ensures once per lifecycle and clears Kanji caches only on first use or actual repair.
- Verified locally: `flutter test test\data\db\content_database_lazy_seed_test.dart`, `flutter test test\data\content\kanji_runtime_reachability_test.dart`, focused Kanji/taxonomy subset, `flutter analyze lib test`, UI string guard, and node research tests all passed.
- Deployed `833ed3c8` to Firebase Hosting. Live proof: VI N3 Kanji grid loaded `203` entries, VI `Viết` opened real Kanji data (`将`); EN Kanji grid loaded; JA Kanji grid loaded; JA `214` radicals loaded. Remaining Kanji work: continue QA-B-002 source verification and expansion.

## 2026-05-18 N3 Kanji Lesson 18 Completeness Patch

- Source-verified all eight N3 lesson-18 kanji (`法`, `律`, `規`, `則`, `犯`, `罪`, `裁`, `制`) against KANJIDIC2, Unihan, and local lesson context.
- Filled missing Hán-Việt values for seven entries; rewrote learner-facing Vietnamese display/search text; filled all lesson-18 `relatedKanji` lists.
- Replaced lesson-18 file-level `vi-human-approved` with truthful `vi-source-verified` and added entry-level `vi-source-verified`. No `vi-human-approved` tag was added.
- Bumped content DB Kanji seed revision to `19` and added a lesson-18 sentinel for `裁` so existing browsers receive the new metadata even when level counts are already full.
- Verified locally: JSON parse passed, coverage audit reduced N3 incomplete current entries from `63` to `55`, focused DB/reachability/taxonomy/coverage tests passed, `flutter analyze lib test` clean, UI string guard `0`, and content status report machine/open-review `0`.
- Deployed `777a5c13` to Firebase Hosting. Live proof: search `裁` opened detail showing `Tài (xét xử; phán quyết; cắt may)` plus Hán-Việt `Tài`.
