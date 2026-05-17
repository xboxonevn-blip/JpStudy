# Full App Audit - 2026-05-17

Timestamp: `2026-05-17T13:45+07:00`

Scope: Phase 0 only. No source-code fixes in this pass. Hypothesis: the live failures are not independent feature bugs; they come from three shared seams: route identity, async content loading without timeouts, and shell branch navigation state.

## Live Verification

Method: Playwright headless against `https://jpstudy.web.app`, seeded with:

```js
localStorage.setItem('flutter.app.locale', JSON.stringify('vi'));
localStorage.setItem('flutter.onboarding.completed', 'true');
localStorage.setItem('flutter.onboarding.level', JSON.stringify('n5'));
localStorage.setItem('flutter.onboarding.goal', JSON.stringify('jlpt'));
localStorage.setItem('flutter.analytics.consent', 'false');
```

Results:

| Reported bug | Verified result | Evidence |
| --- | --- | --- |
| `/#/lesson/1`: Vocab `Tổng 0`, Grammar empty | Confirmed. After 9s, lesson header is `N5 / Minna No Nihongo 1`, Vocab shows `Tổng 0`, card spinner still active. | Screenshot `output-lesson-1-live.png` (local verification artifact, not committed). |
| `/#/lesson/26`: Vocab `Tổng 0`, Grammar empty | Confirmed for seeded N5. Route renders `N5 / Minna No Nihongo 26`, which is an invalid N5 lesson identity; `Tổng 0`, spinner active. | Screenshot `output-lesson-26-live.png`. |
| `/#/vocab` -> `Mở track` infinite loading | Partially confirmed. `/#/vocab` showed a blocking Kana soft-suggest modal first. Existing code has multiple unbounded loading states; companion/catalog surfaces still need timeout/error guarantees. | `vocab_screen.dart:341-369`, `minna_lesson_catalog_screen.dart:123-130`, `vocab_screen_parts.dart:1572-1581`. |
| `/#/premium` renders Leaderboard | Corrected on current live with seeded prefs. `/#/premium` rendered the Upgrade screen. | Screenshot `output-premium-live.png`. |
| `Nâng cấp` sidebar changes URL/content incorrectly; direct `/#/search` shows Community | Not reproduced by text locator, but source confirms a real desync hazard: `_goToBranch` calls both `navigationShell.goBranch()` and `GoRouter.go()`. | `app_shell_scaffold.dart:199-202`. |
| Level inconsistent across screens | Source confirms drift paths. There is one global `studyLevelProvider`, but several screens mutate it without persisting and some keep local mirrors. | `level_provider.dart:4`, `onboarding_provider.dart:42-45`, `kanji_hub_screen.dart:45,165-181,443-496`, `vocab_screen_parts.dart:157-164`, `me_screen.dart:182-187`. |
| `/#/search` has 200 kanji but 0 vocab/kana | Corrected on current live with seeded N5. Search showed `Từ vựng 988`, `Kanji 185`, `Hiragana/Kana 339`. Source still only uses `minna` by default, so it misses canonical ShinKanzen/Hajimete coverage for upper levels. | `search_screen.dart:21-27`, `lesson_repository.dart:658-660`. |

## Root Cause Trace

### Lesson Detail Shows Zero While Content Is Loading

`LessonDetailScreen` watches `lessonTermsProvider` and immediately collapses a loading Future into an empty list:

- `lesson_detail_screen.dart:100-110`: `termsAsync.asData?.value ?? const []`
- `lesson_detail_screen.dart:121-130`: totals are computed from that empty fallback

`lessonTermsProvider` itself blocks until both vocab and grammar seeders finish:

- `lesson_repository.dart:43-59`: `Future.wait([seedTermsIfEmpty, seedGrammarIfEmpty])`

That means any slow/hanging seeding path produces the exact live symptom: `Tổng 0` plus a spinner, not a useful loading or error state.

### Lesson Identity Is Not Level-Scoped

Routes are `/lesson/:id`; the active level comes from `studyLevelProvider`, not the route:

- `lesson_detail_screen.dart:95-103`: lesson ID from route, level from provider
- `home_routes.dart:54-59`: route only carries `id`

This breaks direct routes:

- `/lesson/26` while current level is N5 becomes `N5 / Minna No Nihongo 26`
- N4 lesson 26 only works if global level already equals N4
- N3/N2/N1 all reuse lesson IDs 1-25, so progress and seeded terms can collide

Phase 1 fix must make curriculum identity explicit: route or storage key must include level/series, not only integer `lessonId`.

### Content Assets Are Present; Runtime Loading Is The Weak Link

Current source manifest is no longer stale:

- `assets/data/content/index.json`: vocab `16,712`, kanji `929`, grammar `754`, grammar examples `4,924`, immersion `125`
- vocab series totals: `ShinKanzen 5,573`, `hajimete 8,334`, `minna 2,805`

Current repository code is source-aware for lesson vocab:

- `lesson_repository.dart:1178-1191`: queries `series + level + lessonTag`
- `lesson_repository.dart:1238-1247`: direct asset fallback if content DB is stale

So the P0 lesson bug is not "no authored content"; it is route identity + async seeding/lifecycle + no timeout/error UI.

### Vocab Track Loading Has No Global Timeout Contract

Several content surfaces render bare progress indicators while awaiting repository/asset work:

- `vocab_screen.dart:341-369`: catalog/home loading
- `minna_lesson_catalog_screen.dart:123-130`: Minna catalog loading
- `hajimete_chapter_catalog_screen.dart:150-152`: Hajimete catalog loading
- `hajimete_chapter_detail_screen.dart:253,1405`: chapter/detail loading
- `vocab_screen_parts.dart:1572-1581`: inline search FutureBuilder loading

Phase 1 fix: wrap all content-loading providers/futures with bounded timeout + retryable error UI. No surface should stay spinner-only after the timeout.

### Shell Navigation Can Desync URL And Branch

The app currently has 11 shell branches:

- `app_router.dart:51-62`: kanji, foundations, vocab, grammar, home, memory, practice, exam, leaderboard, premium, profile

Sidebar item indexes map directly to those branches:

- `app_shell_scaffold.dart:207-283`: item `branchIndex`

Tap handler performs two navigations:

- `app_shell_scaffold.dart:199-202`: `navigationShell.goBranch(index, initialLocation: true)` then `GoRouter.of(context).go(location)`

This can mutate branch stack and URL in separate steps. Phase 1 fix should use one navigation mechanism only; for shell branch taps, `goBranch` with correct branch initial locations is enough, or direct `go()` must be paired with a deterministic branch selected by GoRouter, not both.

### Level State Has One Provider But Multiple Writers And Local Mirrors

The nominal store is:

- `level_provider.dart:4`: `StateProvider<StudyLevel?>`
- `onboarding_provider.dart:18-39`: bootstrap from `SharedPreferences`
- `onboarding_provider.dart:42-45`: only `setPersistedStudyLevel` updates provider + prefs together

But several screens bypass the canonical setter:

- `kanji_hub_screen.dart:165-181`: maintains `_selectedLevel` and mutates provider directly
- `kanji_hub_screen.dart:443-496`: modal utility actions mutate provider directly
- `vocab_screen_parts.dart:157-164`: track open mutates provider directly

That explains transient drift: current branch local state, global provider, and persisted prefs can disagree until a rebuild/reload. Phase 2 should require every level change to go through `setPersistedStudyLevel` or a single controller.

## Phase 1 Fix Plan

1. Add failing tests for lesson identity and non-empty textbook lessons:
   - `/lesson/1` N5 has vocab + grammar
   - `/lesson/26` N4 has vocab + grammar
   - N3/N2/N1 lesson 1 have vocab + grammar
   - direct lesson route must include/resolve level, or refuse ambiguous IDs with a redirect/error
2. Replace lesson loading empty fallback with explicit loading/error states. Do not show `Tổng 0` while provider is loading.
3. Add timeout + retry UI to lesson terms, grammar seeding, vocab catalog, Minna/Hajimete catalog/detail, and inline vocab search.
4. Fix `_goToBranch` to use one navigation path. Add route smoke test for sidebar items and direct `/#/premium`, `/#/search`.
5. Search P0/Phase 6 carry-over: change `searchIndexProvider` away from `getVocabByLevel(... -> minna)` so upper-level vocab/kana use canonical source too.

## Corrections To Owner Report

- `/#/premium` currently renders Upgrade in a clean seeded live session.
- `/#/search` currently shows non-zero N5 vocab/kana in a clean seeded live session.
- Lesson routes remain P0 broken on live.
- Branch desync remains credible from source and should be fixed before more IA consolidation.

## Surprise

The content inventory is mostly present and current `main` has a regenerated manifest, but live lesson detail can still show zero because route identity and loading state are wrong. Mental model update: "content exists" is not enough; curriculum identity must be level-scoped and loading must fail closed with a learner-readable error instead of pretending zero content.

## Phase 1 P0 Live Recheck

Timestamp: `2026-05-17T14:13+07:00`

Commit/deploy: `096e913a fix(app): repair lesson loading and navigation P0`, deployed to `https://jpstudy.web.app`.

Live Playwright results after deploy:

| Route | Seeded level | Result |
| --- | --- | --- |
| `/#/lesson/1` | N5 | Vocab tab rendered `Tổng 51`; first term `私` with Vietnamese meaning `tôi`. |
| `/#/lesson/26?level=N4` | N4 | Vocab tab rendered `Tổng 68`; first term `見ます`. |
| `/#/lesson/1?level=N3` | N3 | Vocab tab rendered `Tổng 7`; first term `愛`. |
| `/#/lesson/1?level=N2` | N2 | Vocab tab rendered `Tổng 73`; first term `あいかわらず`. |
| `/#/lesson/1?level=N1` | N1 | Vocab tab rendered `Tổng 140`; first term `嗚呼`. |
| `/#/vocab` | N5 | Catalog resolved without spinner-only state after 9s. |
| `/#/premium` | N5 | Rendered Upgrade content, not Leaderboard. |
| `/#/search` | N5 | Rendered Search content with `Xem tất cả (988)` vocab entries, not Community. |

Remaining caveat: this verifies the P0 learner-loop blockers, not the later Phase 2 level-store unification or Phase 3 IA consolidation.

## Phase 3 IA Consolidation Update

Timestamp: `2026-05-17T15:47+07:00`

Source commits through `0494c0f9 refactor(nav): keep progress on canonical home branch`.

Verified source changes:

- `app_router.dart` now has five shell branches: Home, Learn, Review, Exam, Profile.
- `/roadmap` and `/today` redirect to `/`.
- `/memory` redirects to `/review`; `/community` redirects to `/me`.
- Old enhanced lesson mode URLs redirect to canonical `/lesson/:id/practice/:mode`:
  `learn-enhanced`, `flashcards-enhanced`, `test-enhanced`, `write-mode`, and `match-mode`.
- New navigation calls for lesson learn/write/match/flashcards/test use canonical practice routes.
- Home no longer mounts a second inline onboarding system or mobile-only fallback path.
- `CommunityScreen` was removed because Community was not a real community surface and now resolves to Profile.
- Review screen title now matches the shell label.
- `/progress` is owned by the Home branch only; Profile links call that canonical route.

Verification run before docs update:

```text
flutter analyze lib test -> passed
flutter test -> 2299 passed
python tooling/audit_ui_string_literals.py --check -> 0 remaining candidates
```

Remaining caveat: Phase 3 IA source cleanup is not the same as Phase 4 lesson-screen/product-identity cleanup. `lesson_detail_screen.dart` is still monolithic, curriculum lesson edit/copy/create affordances still need hard-gating or isolation, and practice-mode copy still needs learner-language polish.

## Phase 4 Lesson/Product Identity Update

Timestamp: `2026-05-17T16:38+07:00`

Source commits through `8a7952ee refactor(srs): stop updating legacy SM2 fields`.

Verified source changes:

- Lesson detail first tab is now `Vocab` / `Từ vựng` / `語彙`, not the reused Flashcards label.
- Curriculum lesson detail no longer exposes copy-set, add-term, combine-set, or inline edit controls.
- Curriculum `/lesson/:id/edit` redirects back to `/lesson/:id`, so the Quizlet-style editor is not reachable from fixed curriculum lessons.
- Lesson practice CTAs are reduced to Flashcards, Test, and Write. Legacy `match-mode` and `/lesson/:id/practice/match` redirect to Test.
- `lesson_detail_screen.dart` was split into focused `lesson_detail_controls.dart` and `lesson_detail_card.dart`; the main screen is now `883` lines.
- The Kanji study-flow card now returns users from the 214-radicals view to the level kanji grid instead of being a dead tap target.
- Home achievement notifications no longer use blocking dialogs on load; pending achievements surface as non-blocking SnackBars.
- Vocab/grammar SRS update APIs no longer accept or write legacy SM-2 `box` / `ease` values. The generated DB columns remain for backward-compatible schema/export shape, but the live scheduler path is FSRS-only (`stability`, `difficulty`, `fsrs_state`, `fsrs_step`).

Verification run for Phase 4 chunks:

```text
flutter analyze lib test -> passed before/after scoped chunks
flutter test -> passed 2297 before Phase 4 chunking
kanji_hub_screen_test.dart -> passed 9/9
home_screen_test.dart -> passed 12/12
SRS DAO/repository/ghost focused tests -> passed 40/40
ui string guard -> 0 candidates before Phase 4 commits
```

Remaining caveat: the old `LessonEditScreen` file and generated `box/ease` schema fields still exist for compatibility and possible future "My sets" isolation. They are no longer reachable or updated from the fixed curriculum learner path.

## Phase 5 Learner Copy Update

Timestamp: `2026-05-17T17:35+07:00`

Source scope: learner-facing copy cleanup across Home, Learn, Review, Exam,
Kanji, Vocab, Grammar, Profile, Premium, Progress, Search, Library, and
practice surfaces.

Verified source changes:

- Removed developer/product jargon from visible labels and subtitles where it
  leaked to learners: `workspace`, `control center`, `lane`, `track`, `flow`,
  `queue`, `deck`, `bank`, `analytics`, `snapshot`, `Starter sets`, and similar
  phrasing were rewritten to concrete learner-language equivalents.
- Updated tests that intentionally assert learner copy so they track the new
  Vietnamese/English wording instead of stale implementation jargon.
- Removed the Design Lab dev surface from learner routing instead of keeping a
  hidden direct route.
- Roadmap title fallback no longer returns raw phase IDs; unknown phases render
  a generic localized study-step label instead of leaking slugs such as
  `n1_vocab_grammar`.
- Premium/privacy-adjacent learner copy no longer describes beta value in terms
  of analytics jargon; it uses study stats, reading depth, exam practice, and
  local learner outcomes.

Verification run after Phase 5:

```text
flutter analyze lib test -> No issues found
python tooling/audit_ui_string_literals.py --check -> 0 remaining candidates
flutter test test/data/content_review_taxonomy_integrity_test.dart -> 2/2 passed
node --test test/tool/research/*.js -> 53/53 passed
flutter test -> 2299 passed
learn_screen_test.dart -> passed 11/11; caught Firebase auto-upload warning is non-fatal
```

Remaining caveat: Phase 6 polish and the new 2026-05-17 full-app P0 audit
remain separate workstreams. Search/vocab/kana completeness, "Mở track" live
behavior, and level-state live consistency still need their own verification
after the copy cleanup commit.

## Phase 6 Polish Update

Timestamp: `2026-05-17T18:05+07:00`

Hypothesis: the remaining polish issues were small copy/state guards, not a new
data-pipeline rewrite.

Verification and changes:

- Search source already builds a mixed index from current-level vocab and kanji,
  classifying kana-only vocab as Kana (`search_screen.dart`); existing search
  tests cover vocab, kanji, kana filter behavior, and romaji matching.
- Foundations soft-suggest was level-blind. Added a N5-only guard so the "study
  Kana first" prompt does not appear for N4/N3/N2/N1 learners.
- Vocab CTA labels were already unified in Vietnamese as `Mở hướng học`; the
  remaining visible lane/track wording was cleaned in Japanese and shared vocab
  copy so CTA language points to "study/path" consistently.

Focused verification:

```text
flutter test test/features/foundations/foundations_soft_suggest_gate_test.dart test/features/search/search_screen_test.dart test/features/vocab/vocab_screen_test.dart test/features/vocab/hajimete_chapter_catalog_screen_test.dart -> 44/44 passed
```

Post-deploy live verification:

```text
commit 812b4e0 -> built with JPSTUDY_RECAPTCHA_SITE_KEY and deployed to hosting:jpstudy
https://jpstudy.web.app/?primary-check=phase6 -> 200
https://jpstudy-v2.web.app/?legacy-check=phase6 -> 404
/#/lesson/1 seeded N5 -> Vocab total 51, first card 私 / tôi
/#/lesson/26?level=N4 seeded N4 -> Vocab total 68, first card 見ます
/#/search seeded N5 -> vocab 988, kanji 185, Hiragana/Kana 339
/#/premium seeded N5 -> Upgrade screen, not Leaderboard
/#/vocab seeded N3 after browser cache disabled -> no Kana soft-suggest modal, label reads Hướng học hiện tại
```

Surprise during live verification: an already-open Playwright browser context
kept running the previous Flutter bundle after deploy, even though a fresh
`fetch('/main.dart.js', {cache: 'reload'})` returned the new bundle with
`Hướng học hiện tại`. Disabling browser cache/clearing service-worker state was
required before using that context as live evidence.
