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
