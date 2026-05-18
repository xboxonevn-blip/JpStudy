# Surprise Journal

## 2026-05-13T22:14:11+07:00 - Firebase analytics is much thinner than expected

- Prior belief: 60% chance that current Firebase + Drift signals could compute a rough NS after minor query work.
- Actual observation: Firebase only exposes broad learn-session/auth/sync events; vocab/grammar SRS review completion is local-only; session quality is absent.
- Delta: about -40 percentage points on real-user NS measurability.
- Updated belief: real-user NS is not measurable until event contract + quality rating are added.
- New hypothesis: a pure synthetic eval harness is the fastest first artifact because product optimization before telemetry would be blind.

## 2026-05-14T02:20:00+07:00 - Approved grammar tags overstate readiness

- Prior belief: after Q2.1, N1/N2 grammar explanations tagged `approved-by-user` were likely safer than open-review examples.
- Actual observation: `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5` and contained placeholder review language.
- Delta: about -50 percentage points on trust in approval status as a quality proxy.
- Updated belief: approval metadata must be audited against human-readable rubric before launch claims.
- New hypothesis: status taxonomy must separate "machine-origin approved by tag" from "learner-ready after rubric pass."

## 2026-05-14T02:25:00+07:00 - Open-review taxonomy was incomplete

- Prior belief: `needs-vi-editorial` and `needs-human-review` covered explicit open-review grammar debt.
- Actual observation: random grammar sampling found `manual-review-needed` tags in N3/N4, adding `142` open-review grammar explanations.
- Delta: explicit open-review count increased from `1,744` to `1,886` items.
- Updated belief: review-status aliases must be normalized before using counts for prioritization.
- New hypothesis: more legacy aliases may exist outside the first scan and should be enumerated before content editing.

## 2026-05-14T03:10:00+07:00 - Vocab-kanji links are weaker than expected

- Prior belief: canonical kanji/vocab assets probably had enough cross-link structure for prerequisite suggestions after light cleanup.
- Actual observation: same-level fully covered kanji-bearing vocab entries are only `780/6379` N1, `504/2991` N2, `188/1786` N3, `393/1719` N4, and `549/1470` N5.
- Delta: about -50 percentage points on readiness for prerequisite gating.
- Updated belief: cross-link graph is useful for diagnostics, but prerequisite logic needs cumulative kanji modeling first.
- New hypothesis: cumulative lower-level kanji coverage may explain part of the same-level gap.

## 2026-05-14T03:45:00+07:00 - Upper kanji scope is thinner than vocab scope

- Prior belief: if upper-level vocab volume was broad, kanji scope might be broadly acceptable too.
- Actual observation: cumulative N1 vocab is `10,424 / 10,000` rough target, but cumulative N1 kanji is `889 / 2,000`.
- Delta: about -55 percentage points on N1 kanji scope confidence.
- Updated belief: vocab and kanji readiness must be tracked separately.
- New hypothesis: present upper-level kanji may be accurate but under-complete; D2.6 should verify quality before expansion planning.

## 2026-05-14T04:30:00+07:00 - Upper Han-Viet metadata is incomplete

- Prior belief: existing Unihan importer and credits made upper kanji metadata mostly safe where rows existed.
- Actual observation: seeded N3/N2/N1 sample found `23 / 50` missing local Han-Viet values and one mismatch (`行`: local `Hành`, Unihan `hàng`).
- Delta: about -45 percentage points on confidence that current upper Han-Viet can be learner-facing without caveat.
- Updated belief: Unihan source trail is useful QA evidence, not completion evidence.
- New hypothesis: a full-corpus completeness audit should be run before any upper-kanji expansion or learner-facing Han-Viet emphasis.

## 2026-05-14T05:20:00+07:00 - Vietnamese copy is far less centralized than expected

- Prior belief: most UI Vietnamese likely lived in `app_language.dart`, with a few local helper exceptions.
- Actual observation: `app_language.dart` is balanced (`680` returns per locale), but D3 found `1,888` Vietnamese lines outside it.
- Delta: about -60 percentage points on confidence that one-file editorial review is enough.
- Updated belief: D3 must classify copy ownership before editing wording.
- New hypothesis: top-file clustering means a small set of feature copy modules can reduce most editorial fragmentation.

## 2026-05-14T10:19:17+07:00 - N3 state is route-entry fragile

- Prior belief: once SharedPreferences had `onboarding.level=n3`, level-sensitive routes would load N3 regardless of entry path.
- Actual observation: root cold start shows N3, but direct `/#/grammar` hard reload shows N5 because app init is watched by `HomeScreen`, not globally. Live `/#/exam-center` also does not match the local rich exam hub.
- Delta: about -50 percentage points on confidence that mixed-level users can safely use deep links.
- Updated belief: D4 readiness depends on app bootstrap architecture, not just per-screen content.
- New hypothesis: moving init to app/shell bootstrap and adding deep-link tests will remove a class of N5 fallback bugs across grammar/exam/vocab.

## 2026-05-14T11:58:00+07:00 - N2 cramming is live-channel and product-scope blocked

- Prior belief: after the P2 local init patch, P3 might mainly expose advanced-content depth or laptop workflow issues.
- Actual observation: live root shows N2, but direct grammar/vocab/kanji/coach/reading still fall to N5, `/exam-center` is stale/empty, and the root plan is only `~14 phút` for a 3-hour/day cramming persona.
- Delta: about -40 percentage points on confidence that P2's fix can be evaluated from current production without redeploy/channel verification.
- Updated belief: deployed-channel parity is now a prerequisite experiment; cramming intensity is also an explicit product decision, not a copy tweak.
- New hypothesis: after redeploy/channel verification, remaining P3 blockers will shift from level persistence to long-session JLPT planning and active group-study scope.

## 2026-05-14T12:35:00+07:00 - Retiree/travel persona has no first-class goal

- Prior belief: P4 would mainly test large text and slow-tap layout, while the existing goal model could approximate a fun/travel learner.
- Actual observation: `StudyGoal` has only `jlpt`, `reading`, and `writing`; P4 had to use `reading` as a proxy. Tablet root is readable and N4-aware, but direct routes still fall to N5 and no font-size setting is visible.
- Delta: about -35 percentage points on confidence that current onboarding can honestly represent non-exam learners.
- Updated belief: older/travel learners are a positioning decision, not only an accessibility/layout task.
- New hypothesis: adding a travel/fun goal or narrowing beta positioning will matter more for P4 trust than adding another generic content card.

## 2026-05-14T13:05:00+07:00 - N1 reading exists but is hidden

- Prior belief: P5 would likely fail because N1 advanced reading/news content was absent.
- Actual observation: after root init, `/#/immersion` shows 25 N1 decks and an advanced passage with annotations. However direct immersion/reading/study hub fall to N5, study hub advanced filter shows N3/listening resources, and no news/current-world route appears.
- Delta: +35 percentage points on confidence that N1 reading content exists; -40 percentage points on confidence that advanced users can discover it reliably.
- Updated belief: P5 is a discovery/channel problem plus a news-scope problem, not pure content absence.
- New hypothesis: promoting initialized N1 immersion into study hub/root will help advanced readers more than creating another generic N1 drill, unless news is explicitly promised.

## 2026-05-14T13:40:00+07:00 - FSRS is legacy and skips learning steps

- Prior belief: FSRS risk was likely calibration quality; the implementation probably satisfied broad FSRS invariants because existing tests passed.
- Actual observation: local scheduler has `17` parameters versus current FSRS-6 `21`, persists no learning/relearning state or step, and schedules a new-card `Good` after `3,456` minutes versus the reference scheduler's `10` minutes.
- Delta: about -70 percentage points on confidence that current SRS scheduling can be called FSRS-6-ready.
- Updated belief: SRS correctness must be fixed at the state-machine level before learner retention metrics can be trusted.
- New hypothesis: adding FSRS learning/relearning state and pinned reference tests will change early review density more than tuning retention from `0.9`.

## 2026-05-14T14:25:00+07:00 - Global streak credit is uneven across skills

- Prior belief: streak policy might be simple but probably counted all meaningful study activities through shared progress code.
- Actual observation: vocab SRS and generic XP paths update `user_progress`, but grammar SRS review updates only `grammar_srs_state.streak`. There is also no streak freeze/grace/timezone policy and no unique day guard.
- Delta: about -45 percentage points on confidence that streak can be interpreted as a cross-skill retention signal.
- Updated belief: streak is currently a UI habit counter, not a clean metric.
- New hypothesis: normalizing one global study-activity recorder will change streak fairness more than adding milestone rewards.

## 2026-05-14T15:10:00+07:00 - XP is not one account currency yet

- Prior belief: XP was probably fragmented by formula but still flowed into one account-level progress counter.
- Actual observation: tests/games/challenges write global XP, but Learn and Flashcards can show `+XP` without a discovered global `user_progress` write; achievements expose `bonusXP` labels without consistent account-credit evidence. No daily cap, burnout guard, diminishing returns, or XP throttle was found.
- Delta: about -50 percentage points on confidence that `todayXp` can be interpreted as normalized study effort.
- Updated belief: XP is motivational UI first, analytics signal second.
- New hypothesis: centralizing visible XP sources will reduce product confusion more than tuning individual reward amounts.

## 2026-05-14T14:20:00+07:00 - BigQuery auth works before event tables exist

- Prior belief: once the service account existed, an existing Firebase dataset table would immediately confirm read access.
- Actual observation: OAuth token mint and `SELECT 1 AS ok` BigQuery job succeeded, but `firebase_sessions.sessions_*` had no matching tables and the Firebase export datasets currently listed `0` tables.
- Delta: about -35 percentage points on confidence that D1 can produce real current funnel counts before the GA4 export table lands.
- Updated belief: D1 is unblocked at the credentials/job layer, not yet at the real-event layer.
- New hypothesis: the first useful real NS run will depend on `analytics_536663906.events_*` appearing, not on the pre-existing Firebase datasets.

## 2026-05-14T14:21:00+07:00 - Onboarding goals do not fork most paths

- Prior belief: broad goals probably shaped at least the first session and daily plan.
- Actual observation: onboarding persists only level/goal; first-win is always vocab; daily plan ignores `studyGoalProvider`; only `StudyGoal.writing` triggers a special post-onboarding route.
- Delta: about -55 percentage points on confidence that current onboarding can serve D4 persona-specific needs.
- Updated belief: onboarding is a short setup flow, not personalization.
- New hypothesis: a small `OnboardingProfile` policy will improve first-session fit more than adding more generic home cards.

## 2026-05-14T14:22:00+07:00 - Grammar ghost practice may not clear ghosts

- Prior belief: completing ghost practice probably updated the same state that powers the ghost badge/list.
- Actual observation: `grammarGhostsProvider` reads `grammar_srs_state.ghostReviewsDue`, but `GhostPracticeScreen` answers only update local score. Its "mark mastered" action calls `LessonRepository.markGrammarAsMastered()`, which deletes old `AttemptAnswer` rows instead of clearing `ghostReviewsDue`.
- Delta: about -65 percentage points on confidence that grammar ghost practice is a reliable remediation loop.
- Updated belief: grammar ghost state is split and can go stale.
- New hypothesis: unifying grammar ghosts on one state path will reduce repeated "already fixed" frustration more than tuning ghost UI copy.

## 2026-05-14T15:45:00+07:00 - Cumulative kanji still does not rescue prerequisite gating

- Prior belief: same-level vocab-kanji coverage was probably too harsh, and cumulative lower-level kanji might make prerequisite routing nearly usable.
- Actual observation: cumulative full coverage is still only N1 `2483/6379`, N2 `1098/2991`, N3 `545/1786`, N4 `672/1719`, and N5 `549/1470` kanji-bearing vocab entries.
- Delta: about -35 percentage points on confidence that hard cross-skill prerequisite gates are near-term viable.
- Updated belief: prerequisite logic should be advisory and telemetry-backed, not a hard gate.
- New hypothesis: scoped "review these kanji first" suggestions on vocab details and repeated vocab mistakes will create safer learning gains than route-level locks.

## 2026-05-14T15:16:00+07:00 - Good loading patterns exist but are not default

- Prior belief: loading state risk was probably simple spinner overuse with no strong local counterexample.
- Actual observation: Kanji Hub, JLPT, and Progress Coach have good localized/loading-card examples, but `CircularProgressIndicator` still appears `69` times across `53` files and six home/me loading branches collapse.
- Delta: +20 percentage points on confidence that the solution can copy local patterns; -30 percentage points on confidence that current loading UX is consistent.
- Updated belief: the blocker is policy adoption, not missing design capability.
- New hypothesis: converting one primary route family plus home dashboard panels will improve trust more than creating a generic shimmer library.

## 2026-05-14T15:26:00+07:00 - Error UI has better primitives than usage

- Prior belief: error states likely had the same problem as loading states: mostly bare labels with no shared primitive.
- Actual observation: `ErrorStateWidget` has semantics, friendly messages, compact mode, and optional retry, and several feature cards already implement good retry. The gaps are older raw exception branches and silent optional-panel errors.
- Delta: +30 percentage points on confidence that error cleanup can be incremental; -25 percentage points on confidence that current beta error UX is safe.
- Updated belief: severity rules plus targeted conversions beat a broad widget migration.
- New hypothesis: converting Foundations/Grammar/Recall Sprint raw errors will reduce learner distrust faster than polishing lower-priority snackbar copy.

## 2026-05-14T15:38:00+07:00 - Contrast risk is localized to small helper/status tokens

- Prior belief: if contrast failed, sidebar/nav or the overall beige palette would probably be the main issue.
- Actual observation: sidebar inactive labels pass `6.35`-`6.43:1`, mobile nav inactive passes `4.97:1`, and body text passes. Failures cluster in input hints (`2.57:1`), `ink 0.45` helpers (`2.79:1`), and warning/status chips (`2.55:1` for `AppStatusChip.warning`).
- Delta: +35 percentage points on confidence that nav is safe; -45 percentage points on confidence that small helper/status copy is WCAG-safe.
- Updated belief: contrast can be fixed by token policy and chip foregrounds before broad theme redesign.
- New hypothesis: a tiny contrast unit test for theme pairs will prevent more regressions than screenshot-only review.

## 2026-05-14T15:46:00+07:00 - Touch target failures cluster around compact overrides

- Prior belief: the Discover Practice reorder button was likely the main touch-target outlier.
- Actual observation: primary nav/quiz/grid controls mostly pass, but compact overrides recur across top bar, mistake delete, library/practice action CTAs, home handwriting, lesson inline icons, and `StarRating`.
- Delta: -45 percentage points on confidence that touch target risk is isolated to one panel.
- Updated belief: a shared `44x44` hitbox rule is higher leverage than per-screen visual redesign.
- New hypothesis: render-box widget tests for compact controls will catch more accessibility regressions than manual visual review.

## 2026-05-14T15:58:00+07:00 - Dark mode is functional but not parity-ready

- Prior belief: dark mode might be a shallow toggle with little verification.
- Actual observation: shell/provider/settings wiring exists, `AppThemePalette.dark` is exposed, and focused dark/theme tests pass; parity gaps remain in dark `ThemeData`, hardcoded light surfaces, and route coverage.
- Delta: +30 percentage points on confidence that dark mode is usable; -35 percentage points on confidence that it is polished across routes.
- Updated belief: dark mode should stay available, but parity requires route probes and component-theme mirroring.
- New hypothesis: fixing dark component themes will remove more parity defects than chasing every hardcoded `Colors.white` hit.

## 2026-05-14T16:12:00+07:00 - Startup resource count matters more than app-shell gzip

- Prior belief: the first D7 concern would be whether Flutter web build or `main.dart.js` size was too large.
- Actual observation: build passed and `main.dart.js` is `1.77 MB` gzip, but local first-route load observed `250` resources and many grammar JSON fetches.
- Delta: -45 percentage points on confidence that shell bundle size is the dominant SM5 risk; +50 percentage points on confidence that content-loading policy is the bottleneck.
- Updated belief: route-specific lazy loading and a resource-count budget should precede low-level bundle tuning.
- New hypothesis: stopping all-level grammar/example prefetch will improve real mobile startup more than shaving small code paths.

## 2026-05-14T16:45:00+07:00 - Release risk is doc/channel drift, not build failure

- Prior belief: after a passing web build, the next release risk would mostly be product polish.
- Actual observation: focused smoke tests pass after a stale route assertion update, but both live sites lag current `HEAD`, `SHIPPING.md` omits the web App Check dart-define, and CSP docs disagree with active config.
- Delta: +45 percentage points on confidence that beta deploy needs a release-hygiene gate before more live UAT.
- Updated belief: deployment proof must include channel freshness, exact build flags, docs/config parity, and post-deploy route/perf probes.
- New hypothesis: aligning release docs and deploy target choice will remove more beta confusion than another local-only persona pass.

## 2026-05-14T17:05:00+07:00 - Legal consent surface is absent, not merely incomplete

- Prior belief: Privacy/Terms might exist as docs or buried settings copy but need route/link polish.
- Actual observation: no `/privacy` or `/terms` constants/routes, no VI+EN legal copy, and no Settings/Onboarding/Login links were found.
- Delta: -70 percentage points on confidence that D8.Q8.1 is a content-polish task; +70 percentage points that it is missing product surface.
- Updated belief: compliance work needs route/link/test scaffolding before legal wording quality can be evaluated.
- New hypothesis: a small `LegalDocumentScreen` route slice will unlock more launch readiness than another general security checklist edit.

## 2026-05-14T17:14:00+07:00 - Web Firebase API key is already referrer-restricted

- Prior belief: Q8.2 would likely expose an unverified manual GCP Console task.
- Actual observation: fake `https://evil.example/probe` referrer returned `403 API_KEY_HTTP_REFERRER_BLOCKED` for Identity Toolkit, while expected Firebase Hosting referrers reached normal endpoint validation.
- Delta: +55 percentage points on confidence that web Auth key referrer restriction is already active; -35 percentage points on confidence that Q8.2 is a current blocker.
- Updated belief: keep API-key restriction as a launch verification gate, but shift D8 attention to Auth authorized domains, App Check build flags, and release-doc parity.
- New hypothesis: launch risk is now more likely in docs/process drift than in the web API-key restriction itself.

## 2026-05-14T17:33:00+07:00 - CI exists but live-release automation is missing

- Prior belief: D8.Q8.5 might reveal almost no GitHub Actions coverage.
- Actual observation: the only workflow was named `UI String Guard`, but it already ran UI string guard, `flutter analyze`, `flutter test`, web build, and Firebase Storage rules tests.
- Delta: +45 percentage points on confidence that local-source regressions are CI-covered; +50 percentage points on confidence that release risk is specifically live/deploy/perf automation, not total CI absence.
- Updated belief: rename and tune the existing CI, then add Lighthouse/live smoke only after deploy target and budget policy are explicit.
- New hypothesis: branch protection and post-deploy probes will improve beta safety more than adding another generic PR test job.

## 2026-05-14T18:16:00+07:00 - Grammar startup prefetch had two seeders

- Prior belief: scoping content DB grammar seeding would likely remove the first-load grammar JSON spike.
- Actual observation: app startup also fired `GrammarSeeder.seedGrammarData()` and loaded N1-N5 into the app DB.
- Delta: +30 percentage points on confidence that level-scoped seed APIs are required before browser resource-count budgets can be meaningful.
- Updated belief: every startup/on-demand seeder needs a level contract; fixing only one DB copy leaves performance risk in the other copy.
- New hypothesis: after rebuild, first-route browser resource count should drop materially from the `250` baseline if grammar JSON was the dominant eager-fetch source.

## 2026-05-14T18:29:00+07:00 - Lazy grammar seed cut first-route requests by more than half

- Prior belief: resource count should drop materially if all-level grammar was the dominant eager-fetch source.
- Actual observation: first-route resource count dropped `250 -> 108`; grammar resources are now `50` N5-only files.
- Delta: +35 percentage points on confidence that grammar seeding was the main measured first-load request spike.
- Updated belief: next D7 leverage is route-minimal active-level grammar loading and automated resource-count budgets, not generic bundle shaving.
- New hypothesis: moving grammar seeding from app startup to grammar/lesson demand will remove most of the remaining `50` grammar JSON resources from root load.

## 2026-05-14T18:38:00+07:00 - Root does not need grammar seed

- Prior belief: some startup grammar seed might be needed for first-session readiness.
- Actual observation: removing app DB startup grammar seed dropped root grammar resources `50 -> 0`; focused grammar screens still passed on-demand tests.
- Delta: +45 percentage points on confidence that grammar should be entirely route-demanded.
- Updated belief: provider initialization should avoid content seeding unless the root route immediately needs that content.
- New hypothesis: a checked-in route resource smoke will catch more launch perf regressions than another static bundle-size threshold.

## 2026-05-14T18:54:00+07:00 - Clean Chromium is stricter than manual browser smoke

- Prior belief: the checked-in Playwright smoke would reproduce the manual `69` resource count closely.
- Actual observation: clean Chromium reports `38` resources with `jsonCount=1`, because it avoids local extension noise and some cached/browser-side requests.
- Delta: +20 percentage points on confidence that CI-local resource smoke is less noisy than ad hoc manual browser sessions.
- Updated belief: use the checked-in smoke for regression gates; use manual browser/MCP sessions for investigation only.
- New hypothesis: live Firebase Hosting resource count will differ again because compression/CDN/App Check/referrer behavior changes the request graph.

## 2026-05-14T19:16:34+07:00 - Renderer payload dominates raw web build

- Prior belief: D7 bundle work would mostly center on `main.dart.js` and content JSON.
- Actual observation: raw `build/web` is CanvasKit/Skwasm `52.6%`, content/support JSON `30.8%`, and top-level app JS only `10.6%`; no deferred route chunks are emitted.
- Delta: +35 percentage points on confidence that renderer choice/CDN behavior is a first-class D7 question, not a footnote.
- Updated belief: optimize startup through separate renderer/runtime, content-request, and app-code-splitting tracks.
- New hypothesis: D7.Q7.3 renderer comparison will change performance strategy more than small Dart UI code shaving.

## 2026-05-14T19:31:00+07:00 - Wasm build is viable but not an obvious beta default

- Prior belief: if `--wasm` worked, it might be an easy performance upgrade over the default renderer.
- Actual observation: `--wasm` builds pass but emit Skwasm primary plus CanvasKit fallback, increasing raw output `62.48 MB -> 68.34 MB` (`+9.4%`); local smoke looked faster but had security-software injection noise.
- Delta: -30 percentage points on confidence that switching to Wasm before live traces is low risk.
- Updated belief: Wasm belongs on a preview channel until Firebase Hosting headers, browser matrix, and live perf are proven.
- New hypothesis: release-channel stability matters more than renderer experimentation for the first controlled beta.

## 2026-05-14T19:59:00+07:00 - Crashlytics dataset is not crash telemetry

- Prior belief: the existing `firebase_crashlytics` BigQuery dataset might mean production crash monitoring was mostly Firebase-console setup.
- Actual observation: the app has no `firebase_crashlytics` or `sentry_flutter` package, no `FlutterError.onError` / `PlatformDispatcher.instance.onError` hook, no source-map/symbol upload path, and no first-crash verification.
- Delta: -60 percentage points on confidence that beta runtime failures will be visible automatically.
- Updated belief: product analytics and Firebase-side datasets do not equal runtime error monitoring.
- New hypothesis: adding a web-capable error sink before broad beta will catch more release regressions than another local-only smoke test.

## 2026-05-15T00:46:00+07:00 - Radicals Han-Viet drift is systemic, not a 5-15% cleanup

- Prior belief: 214 Kangxi radicals likely had a small Vietnamese display cleanup, roughly 5-15% bad rows from tone marks, duplicate glosses, or conversion leftovers.
- Actual observation: full Q2.7 audit checked `214` rows against Unicode Unihan `kVietnamese`: `85` leading-label mismatches, `78` missing Unihan/local compare rows, `51` near-matches, and `0` exact display matches because every row carries a local gloss. Duplicate-gloss pattern appeared in `29` rows.
- Delta: mismatch plus missing compare rows hit `163 / 214` (`76.2%`), far beyond the prior 5-15% expectation.
- Updated belief: the radical table came from an ASCII/raw-gloss normalization pipeline, not from reviewed Vietnamese editorial data. Unihan is good for checking the leading Han-Viet label, but glosses need a separate human/editorial source.
- New hypothesis: a top-30 correction pass will remove the most visible wrong Han-Viet labels, but full learner-ready status needs a separate editorial source for radical glosses.

## 2026-05-15T01:20:00+07:00 - GA4 BigQuery export still absent after auth was proven

- Prior belief: after the first export window, `analytics_536663906.events_*` would likely exist and produce the first real 48h event-count baseline.
- Actual observation: Node REST BigQuery auth passed with `SELECT 1 AS ok`, `asia-southeast1` listed only `firebase_crashlytics`, `firebase_messaging`, and `firebase_sessions`, `US` listed zero datasets, and `analytics_536663906` returned `404` in both locations.
- Delta: confidence in producing a real NS datapoint during Sprint 1 drops from likely to blocked; the blocker is GA4 export provisioning or linking, not local credentials.
- Updated belief: BigQuery readiness needs an explicit dataset-existence gate before any NS/funnel run. `firebase_sessions` presence is not evidence that Firebase Analytics export is live.

## 2026-05-15T01:55:00+07:00 - Mojibake bug was isolated to one UI header path

- Prior belief: radical Vietnamese display problems were mostly data-layer `radicals_214.json` issues.
- Actual observation: the stroke filter chips rendered `nét` correctly through `KanjiCopy`, while the radical group headers used separate hardcoded literals: `$strokeCount n?t` and `$count b? th?`.
- Delta: same screen had two text paths with different quality; data cleanup alone would not touch the header mojibake.
- Updated belief: dual render paths create dual bug surfaces. User-visible Vietnamese strings should route through `AppLanguage` or a feature copy layer, not local hardcoded literals.

## 2026-05-15T03:31:00+07:00 - Vocab unlock has separate data and availability gates

- Prior belief: after the T3 vocab-unlock work, data-backed N3/N2/N1 tracks would be open enough for P2/P3/P5 live UAT.
- Actual observation: clean live onboarding shows N4 open (`Hajimete` 632 terms, `Minna II` 1,478 terms), but N3/N2/N1 still report `0 mục từ`, `0 Đang mở`, and cards remain `Sắp ra mắt` / `Xem trước`.
- Delta: -50 percentage points on confidence that content seeding alone controls vocab readiness.
- Updated belief: vocab readiness has at least four gates: seeded content, catalog visibility, availability/CTA state, and review queue counts.
- New hypothesis: the availability registry or level whitelist was only opened for N4, while upper-level data remains visible but disabled.

## 2026-05-15T06:08:00+07:00 - Anonymous Auth can be identity without a login wall

- Prior belief: a durable UID probably required a visible login/upgrade moment before cloud identity could be trusted.
- Actual observation: Firebase anonymous Auth can run before `runApp` with a 5-second timeout, reuse an existing user, fall back to local-only if offline, and still give Storage rules a real `request.auth.uid` for migration paths.
- Delta: +45 percentage points on confidence that Phase 13 can ship without adding onboarding friction.
- Updated belief: identity foundation and account-upgrade UX are separate phases. The app can establish a private UID now, then add soft upgrade/linking later.
- New hypothesis: once live App Check + anonymous Auth are verified, Storage-backed safety nets can cover more beta data without forcing sign-in.

## 2026-05-15T08:20:00+07:00 - Live Auth proof depends on server-side provider state

- Prior belief: after source wiring and an App Check-keyed deploy, anonymous Auth would likely work unless network/App Check failed.
- Actual observation: live `accounts:signUp` reaches Identity Toolkit with the allowed referrer but returns `400 ADMIN_ONLY_OPERATION`; browser network and REST probes agree, so Firebase Anonymous provider is disabled server-side.
- Delta: -60 percentage points on confidence that SP7 is operational from source changes alone; +60 percentage points that Firebase Console provider state must be an explicit release gate.
- Updated belief: "auth source wired" and "Auth provider enabled" are separate launch proofs. The app's local-only fallback protects boot, but it does not prove identity/migration readiness.
- New hypothesis: enabling Anonymous provider in Firebase Console should remove the live console error and allow Storage migration verification without any code change.

## 2026-05-15T08:38:00+07:00 - Anonymous Auth unmasked missing Storage setup

- Prior belief: once Anonymous provider was enabled, the Phase 13 migration path would likely verify end to end.
- Actual observation: `accounts:signUp` now returns `200`, but live migration upload fails at Firebase Storage CORS/preflight, and `firebase deploy --only storage --project jpstudy-v2` reports Firebase Storage has not been set up.
- Delta: +55 percentage points on confidence that identity and storage setup are separate operational gates.
- Updated belief: keep anonymous sign-in active, but do not auto-run Storage migration until bucket/rules/CORS are proven.
- New hypothesis: a build-time migration flag will preserve zero-friction identity while avoiding noisy live Storage failures on Spark/new-bucket projects.

## 2026-05-15T09:35:00+07:00 - Analytics reset is not a web-complete deletion control

- Prior belief: adding `FirebaseAnalytics.resetAnalyticsData()` to Data controls would close the in-app telemetry reset gap for the web beta.
- Actual observation: the Flutter Firebase Analytics wrapper can expose the reset action, but `firebase_analytics_web 0.6.1+5` throws `UnimplementedError('resetAnalyticsData() is not supported on Web.')`.
- Delta: -50 percentage points on confidence that device reset alone satisfies the D8 deletion requirement for the Firebase Hosting product.
- Updated belief: Analytics reset is a useful device-side control where supported, but web beta compliance still needs a GA4 deletion runbook and retention proof.
- New hypothesis: the next highest-value compliance task is a support runbook that maps Auth UID, Storage backup, GA user deletion, and BigQuery export cleanup into one operator flow.

## 2026-05-15T11:25:00+07:00 - GA4 export landed before learning events did

- Prior belief: after the earlier `404`, the next blocker was likely export provisioning itself.
- Actual observation: `analytics_536663906` now exists in `asia-southeast1`, but the first sample has only `page_view`, `user_engagement`, `session_start`, `first_visit`, and `onboarding_completed`; funnel is `4` opened / `1` onboarded / `0` first SRS, and real NS is `0.00%`.
- Delta: +70 percentage points on confidence that BigQuery plumbing is operational; -40 percentage points on confidence that first export automatically yields learning-outcome signal.
- Updated belief: dataset existence is necessary but not sufficient. The next measurement gate is event diversity and learner behavior after onboarding.
- New hypothesis: a small beta seeding script or guided smoke flow should intentionally trigger SRS, micro-quiz, and quality-rating events before interpreting NS.

## 2026-05-15T19:58:00+07:00 - FSRS correctness required state, not just formulas

- Prior belief: replacing the legacy interval math with FSRS-6 formulas would be the main fix.
- Actual observation: formulas alone were insufficient. Correct new-card and relearning behavior required persisted card `state` and `step` across vocab, grammar, kanji, and kana tables, plus a schema migration for existing rows.
- Delta: +60 percentage points on confidence that the SRS loop now behaves like a learning scheduler instead of a day-scale interval calculator.
- Updated belief: SRS correctness is a state-machine problem first and a parameter/formula problem second.
- New hypothesis: early beta retention shifts will come more from minute-scale learning/relearning loops than from changing the default retention target.

## 2026-05-15T20:35:00+07:00 - Learning metrics also needed FSRS state

- Prior belief: after persisting `fsrs_state`, the remaining SRS UI metrics would mostly stay valid.
- Actual observation: daily-plan critical counts and retention stage breakdown still used the legacy `stability < 1.0` proxy. FSRS-6 learning cards can have stability above `1.0`, so the proxy hid due learning steps from planning.
- Delta: +25 percentage points on confidence that state-machine persistence must flow into analytics/query code, not only review writes.
- Updated belief: any SRS query named "learning", "critical", or "stage" must read explicit FSRS state before using stability brackets.

## 2026-05-15T21:10:00+07:00 - Launch readiness needed auditable tiering, not only nicer Vietnamese

- Prior belief: the D2 pass would mostly be a rewrite exercise over N5/N4 text.
- Actual observation: many N5/N4 strings were already readable, but the audit could not distinguish reviewed launch-tier content from untouched data until tags were normalized and user-approved batches were recorded. N3+ also needed visible draft-tier UX instead of silent availability.
- Delta: +55 percentage points on confidence that content launch readiness depends on provenance and UI tiering as much as prose quality.
- Updated belief: beginner-heavy pilot content needs two artifacts for trust: fluent Vietnamese and an explicit review signal. Upper levels can remain available only when the app labels them as editorial draft.

## 2026-05-16T03:36:00+07:00 - Event names were not enough for NS scoring

- Prior belief: once `n5_micro_quiz_completed` appeared in GA4 export, the export report could score the quiz gate.
- Actual observation: the app emits `correct_count`, `total_count`, and `accuracy`, while the BigQuery report queried a nonexistent `score` parameter. The event family could arrive and still produce `quizGatePasses=0`.
- Delta: -45 percentage points on confidence that event-name coverage alone proves measurement readiness.
- Updated belief: telemetry contracts need parameter-level parity between app emitters, network proof, BigQuery SQL, and the NS scorer. Event presence is only the first gate.

## 2026-05-16T04:20:00+07:00 - D2 fake-approval incident compromised taxonomy integrity

- Prior belief: a user approval instruction could safely convert the remaining D2 batch to `vi-human-approved` if no immediate UI failure appeared.
- Actual observation: bulk `vi-human-approved` was applied to 23,444 items including 50 untranslated N1/N2 grammar-example placeholder files. Those files still contained `Bản dịch ví dụ cần biên tập từ: [English]` and draft/review tags.
- Delta: -80 percentage points on confidence that approval tags can be trusted without content-state guards.
- Updated belief: `approved` must mean content verified, not user-said-go. Tag taxonomy integrity requires automatic contradiction checks, and machine/open-review debt must stay visible until content is actually rewritten or reviewed.

## 2026-05-16T04:55:00+07:00 - Item-level guards missed mixed-debt files

- Prior belief: checking approval and review debt at the same item level was enough to protect the D2 taxonomy.
- Actual observation: 48 N1/N2 kanji lesson files still had `vi-human-approved` on checked entries while the same file also contained `vi-needs-review` entries. The item-level guard passed, but the user-requested file-level grep failed.
- Delta: -35 percentage points on confidence that nested content audits can ignore file-level provenance.
- Updated belief: human approval tags need both item-level and file-level contradiction guards when a content file mixes reviewed and draft entries.

## 2026-05-16T06:10:00+07:00 - Upper-level launch tier needed reuse, not only translation

- Prior belief: finishing N1/N2/N3 launch-tier status would mostly be direct translation of remaining machine-draft fields.
- Actual observation: N1 Tanos vocab had 3,463 exact matches in the already reviewed N1 Hajimete set, leaving only 13 unmatched terms for manual translation. Reusing reviewed internal content reduced risk versus re-translating every gloss from English.
- Delta: +50 percentage points on confidence that internal reviewed-source alignment is the safest path for large content batches.
- Updated belief: D2 editorial work should first search for trusted in-repo equivalents, then translate only unmatched content. Launch-tier evidence still requires audit counts plus spot-check samples; Codex must not add `vi-human-approved`.

## 2026-05-16T23:51:35+07:00 - Direct-route trust needed a real bootstrap gate

- Prior belief: watching `appInitProvider` at the app level was probably enough, because reactive screens would update after persisted level loaded.
- Actual observation: screens with internal init-time state can still read null and default to N5 before app init resolves. Kanji Hub also had a second stale path because it copied the level into local state after first frame.
- Delta: -35 percentage points on confidence that provider watch alone closes deep-link fallback; +45 percentage points on confidence after adding a router bootstrap gate and a Kanji late-level sync regression.
- Updated belief: route trust requires preventing route widgets from mounting until persisted state is ready, plus tests for any screen that mirrors provider state internally.

## 2026-05-17T00:44:00+07:00 - Bootstrap loading can destroy hash deep links

- Prior belief: a temporary non-router loading `MaterialApp` would be a safe way to prevent direct-route widgets from mounting before persisted level state loaded.
- Actual observation: on live web, that loading app stripped direct `/#/grammar` hash routes back to `/` before `MaterialApp.router` mounted. The first fix removed N5 fallback but introduced route loss. Seeding persisted providers before `runApp` let the router mount on the first frame and preserved direct hash URLs.
- Delta: -50 percentage points on confidence that swapping root app types during bootstrap is harmless on Flutter web; +40 percentage points on confidence after live N4/N3/N2/N1 direct-route checks showed no N5 fallback markers.
- Updated belief: web deep-link safety requires one router identity from the first frame. Bootstrap should preload provider state, not temporarily replace the router with a separate `MaterialApp`.

## 2026-05-17T03:20:00+07:00 - Storage blocker was a product-scope mismatch

- Prior belief: beta launch needed Firebase Storage provisioning proof because legacy migration and cloud backup scaffolding existed.
- Actual observation: the product decision is local-first beta on Spark. New Firebase Storage buckets require Blaze, so cloud backup and legacy Storage migration are optional future work, not beta requirements.
- Delta: -70 percentage points on confidence that missing Storage provisioning should block beta launch.
- Updated belief: launch readiness tooling must distinguish "required but failing" from "intentionally descoped." Keep Storage scaffolding gated for future rebuilds, but local file export/import is the beta backup path.

## 2026-05-17T03:25:00+07:00 - Content counters missed semantic gloss defects

- Prior belief: N3/N1 machine/open-review counters near zero were a strong proxy for spot-check quality.
- Actual observation: owner spot-check found duplicated N3 glosses, wrong N3 meanings such as `合わせる`, and N1 kanji meanings copied from compound examples such as `稲光` into `稲`.
- Delta: -45 percentage points on confidence that taxonomy counters alone prove content quality.
- Updated belief: D2 evidence needs semantic spot-checks over representative vocab and kanji display glosses, not only tag-state integrity.

## 2026-05-17T08:55:00+07:00 - Duplicate-gloss guard needed canonical text

- Prior belief: the existing N3 duplicate-gloss regression would catch repeated semicolon fragments.
- Actual observation: labels like `(1) hoàn toàn` and `(sl) ôm` made duplicate fragments look distinct, so 35 repeated N3 Hajimete glosses still passed until the test canonicalized numbered/parenthetical prefixes.
- Delta: -30 percentage points on confidence that separator-only checks catch editorial debt.
- Updated belief: content QA tests must normalize editorial wrappers before comparing meanings; otherwise real duplicate glosses hide behind dictionary labels.
## 2026-05-17 - App Coherence Phase 0 Vocab Pipeline

Audit expected N2/N1 lesson vocab to be absent from the runtime path. Actual: N2/N1 ShinKanzen lesson assets and indexes exist, and `/lesson/:id` can load them through a direct asset fallback. The real coherence defect is stale `index.json` plus a `minna_*`-only content DB lookup that misses seeded ShinKanzen rows. Mental model update: asset availability is not equivalent to canonical runtime wiring; fallback success can hide a broken primary pipeline.

## 2026-05-17 - Lesson Identity Collision

While verifying all-level lesson vocab seeding, a new coherence risk surfaced: lesson progress and terms are keyed by integer `lessonId`, but N5, N3, N2, and N1 all use route lesson IDs 1-25. The Phase 1 source-aware fix makes a clean active-level lesson load correctly, but a user who switches levels after seeding another level can still collide with existing rows. Mental model update: source-aware data loading is necessary but not sufficient; curriculum identity must include level or a stable level-scoped route ID.

## 2026-05-17 - Live Lesson Zero Was Not Missing Content

Live `/lesson/1` and `/lesson/26` still showed `Tổng 0` with a spinner after the content manifest and source-aware query were fixed. Actual root cause is stronger than "missing vocab": route identity omits level, pending async providers are rendered as empty lists, and content seeding has no timeout/error contract. Mental model update: authored assets plus repository tests do not prove the learner loop works; direct route identity and loading-state semantics are part of the content pipeline.

## 2026-05-17 - P0 Lesson Fix Needed Storage Identity Too

The first P0 hypothesis focused on UI loading semantics, but repository tests exposed a second failure mode: N5 and N3 lesson `1` could share the same persisted lesson row. Fixing only `/lesson/:id` links would still leave progress rows vulnerable after level switches. Mental model update: curriculum identity must be storage-level scoped, not just route-level scoped; user-visible source lesson numbers and persisted lesson IDs are separate concepts.

## 2026-05-17 - Exam Navigation Uses Exam Center, Not Exam Route

Phase 2 first fixed the selected-level copy in `ExamScreen`, but the sidebar branch actually lands on `/exam-center`. Live checks still showed stale N5 cards until `ExamCenterHubScreen` was updated too. Mental model update: route labels and branch targets are the product surface; fixing a similarly named route is insufficient unless the shell wiring proves it is the live destination.

## 2026-05-17 - IA Cleanup Needed Legacy Route Ownership

Phase 3 reduced the visible shell to five branches, but old route paths still mattered: `/memory`, `/community`, enhanced lesson-mode URLs, and duplicate `/progress` ownership could keep stale mental models alive even after the sidebar looked clean. Mental model update: IA consolidation is not complete when navigation labels change; every legacy path must either redirect to a canonical owner or be removed with tests.
## 2026-05-17T16:38+07:00 - Product identity leaks were mostly route affordances

Phase 4 audit expected deep lesson data-model surgery, but the learner-facing Quizlet-style leakage was mostly reachable UI and route affordances: edit/copy/add/combine controls, `/lesson/:id/edit`, and match-mode aliases. Hard-gating routes plus hiding curriculum controls removed the beta-facing confusion while keeping old editor/schema pieces isolated for possible future "My sets". Mental model update: beta product identity can be enforced at navigation and action boundaries before deleting compatibility schema.

## 2026-05-17T17:35+07:00 - Copy debt lived outside central language helpers

- Prior belief: most learner-copy cleanup would be concentrated in `app_language.dart` and a few route labels.
- Actual observation: stale learner-hostile wording was spread across feature-local helpers and widgets: grammar lesson actions, custom practice, premium plan copy, mini-dashboard labels, roadmap fallback titles, and the Profile link to Design Lab.
- Delta: -30 percentage points on confidence that central i18n tests alone catch copy quality regressions.
- Updated belief: copy QA needs both centralized string tests and a feature-local literal sweep. Internal/dev surfaces should not have learner navigation entry points unless they have learner-ready language.

## 2026-05-17T18:58+07:00 - Live verification can be stale after deploy

- Prior belief: a cache-busted `https://jpstudy.web.app/?fresh=...#/route` load in an existing Playwright context was enough to prove the latest Firebase Hosting release.
- Actual observation: the page kept running the previous Flutter bundle and still showed `Nhánh học hiện tại` plus the N3 Kana soft-suggest modal after deploy, while a fresh `fetch('/main.dart.js', {cache: 'reload'})` already returned the new bundle with `Hướng học hiện tại`.
- Delta: -35 percentage points on confidence that query-string reload alone defeats Flutter web service-worker/browser cache state.
- Updated belief: post-deploy live evidence must clear service-worker/cache state or use a fresh cache-disabled browser context before judging source changes.

## 2026-05-17T20:20+07:00 - Shell selection needed URL truth, not branch memory

- Prior belief: replacing `navigationShell.goBranch()` with `GoRouter.go()` was enough to keep shell navigation and URL aligned.
- Actual observation: live retest still showed Profile landing on the Learn/Vocab branch. The safer model is to give every visible shell item its canonical location and derive selected state from the active URL path.
- Delta: -40 percentage points on confidence that shell currentIndex is trustworthy after mixed SPA navigation.
- Updated belief: shell branch state is a cache; route path is the source of truth for both navigation target and selected UI state.

## 2026-05-17T21:05+07:00 - Lesson title fixes need every action surface

- Prior belief: fixing lesson detail/repository fallback would remove the visible Minna title leak for N2/N3/N1.
- Actual observation: live Review/Home next-lesson actions used `language.lessonTitle(storageLessonId)` directly, so scoped IDs such as `200001` rendered as `Minna No Nihongo 200001` even after lesson detail was correct.
- Delta: -25 percentage points on confidence that lesson title correctness can be verified from `/lesson/:id` alone.
- Updated belief: curriculum identity must be checked on every CTA surface that formats lesson IDs, especially Home/Review continuation providers.

## 2026-05-17T21:30+07:00 - Copy leaks can hide in secondary badges

- Prior belief: the vocab copy guard over central helpers covered the owner-reported `Companion` leak.
- Actual observation: live semantics still exposed `Bổ trợ Companion Minna no Nihongo I` because a status badge used a private hardcoded `_programBadge()` path instead of the localized helper.
- Delta: -20 percentage points on confidence that helper-level copy tests cover composite cards.
- Updated belief: copy QA must include rendered widget text for dense catalog cards, not only string helper samples.

## 2026-05-17T22:20+07:00 - Shin Kanzen data existed but had no catalog owner

- Prior belief: empty Shin Kanzen tracks were likely another data-manifest or seeding gap.
- Actual observation: N3/N2/N1 `ShinKanzen/index.json` files and lesson assets were present, but the catalog card used the generic review fallback instead of a source-specific catalog/detail route.
- Delta: -30 percentage points on confidence that non-empty content inventory implies a reachable learner path.
- Updated belief: every content source needs a route owner and a rendered non-zero catalog test; source data plus aggregate counts can still produce a hollow track.

## 2026-05-17T23:05+07:00 - Roadmap honesty needed route-owned chips

- Prior belief: the textbook roadmap could stay as static guidance once the underlying catalogs loaded.
- Actual observation: the roadmap copy claimed "content actually shipped" but its tags were inert strings, included unavailable listening tracks, and implied fixed month pacing for upper levels.
- Delta: -25 percentage points on confidence that content-backed hubs make roadmap stages trustworthy automatically.
- Updated belief: curriculum roadmaps need the same route ownership as catalogs: every visible chip should know its destination, and unavailable modalities should be absent or explicitly deferred.

## 2026-05-17T23:45+07:00 - Hán-Việt rules were a kanji feature behind a kana gate

- Prior belief: Hán-Việt rules could remain under Foundations because the data lived near kana/foundations services.
- Actual observation: the route was wrapped by the N5-only Kana guard, so higher-level learners hit a Kana unavailable message from a Kanji aid.
- Delta: -30 percentage points on confidence that module folder ownership matches product ownership.
- Updated belief: language-specific learning aids should be routed by learner task ownership; Hán-Việt belongs to Kanji UX even if it reuses Foundations data services.

## 2026-05-17T23:58+07:00 - Quiz chrome needed layout proof, not just copy removal

- Prior belief: removing the repeated mode/config card would be the main quiz viewport fix.
- Actual observation: compact answer rows still failed on long repair prompts until the prompt region was made scale-down safe; otherwise tests caught render overflows before the answer layout could be trusted.
- Delta: -20 percentage points on confidence that deleting chrome alone guarantees no-scroll answer selection.
- Updated belief: quiz UX fixes need viewport-level widget guards for both ordinary and long-prompt question types before live proof.

## 2026-05-17 - Select-confirm was still fragmented by feature surface

- Prior belief: grammar practice was the dominant instant-commit quiz surface.
- Actual observation: lesson learn multiple-choice had its own widget and tests that still assumed tap-to-submit, so the safer select -> confirm pattern was not shared yet.
- Delta: -25 percentage points on confidence that fixing one quiz surface changes the product-wide quiz behavior.
- Updated belief: the final answer-selection redesign needs a shared quiz component or an explicit consumer-by-consumer parity checklist; otherwise old instant-submit behavior will persist in parallel widgets.

## 2026-05-17 - Test mode mobile needed a structural layout cut

- Prior belief: adding select -> confirm to the shared learn multiple-choice widget would be enough for lesson test mode.
- Actual observation: live mobile test mode still forced the header into vertical text because the status chips and question map consumed the answer viewport before the question rendered.
- Delta: -30 percentage points on confidence that component-level compacting solves screen-level quiz UX.
- Updated belief: quiz verification must include the whole route shell at mobile size, not just the answer widget.

## 2026-05-17 - Flutter web compact layout needed viewport fallback

- Prior belief: `LayoutBuilder` constraints and `MediaQuery.sizeOf(context).width` would reliably identify the 390px mobile shell.
- Actual observation: live Flutter web still rendered the non-compact lesson-test prompt inside a 390x640 Playwright viewport until the compact flag used the physical `View` size and separated answer compacting from navigation button visibility.
- Delta: -25 percentage points on confidence that widget-test viewport constraints match deployed Flutter web shell constraints.
- Updated belief: mobile quiz fixes need both widget guards and cache-cleared live proof; compact answer layout should be driven by the actual view size, while desktop navigation affordances should stay width-based.

## 2026-05-18 - Kanji language gating included accessibility copy

- Prior belief: hiding Hán-Việt visual rows/panels would cover the first kanji per-language slice.
- Actual observation: kanji card semantics still used Vietnamese-only `Học` labels and romanized `onyomi/kunyomi` terms, so EN/JA users would hear VI-shaped accessibility copy even after visual gating.
- Delta: -15 percentage points on confidence that visual localization covers assistive experiences.
- Updated belief: per-language UX changes need rendered accessibility labels in the same regression set as visible widgets.

## 2026-05-18 - Kanji labels existed but were not seeded into detail metadata

- Prior belief: canonical kanji `labels.hanViet` would be available to the detail dialog through the existing decomposition model.
- Actual observation: seed code copied `labels.meaningViDisplay` and mnemonics, but left `labels.hanViet` outside `decomposition_json`; live N5 `人` therefore showed Vietnamese title/mnemonic but no explicit Hán-Việt row.
- Delta: -20 percentage points on confidence that canonical asset fields reach runtime models just because they exist in JSON.
- Updated belief: every learner-facing canonical field needs a seed-path regression, especially when the runtime model stores it in a derived/nested field.

## 2026-05-18 - Hidden language-specific fields can still affect Search

- Prior belief: Search was safe once kanji subtitles/meanings switched per language.
- Actual observation: the search keyword list still indexed `decomposition.hanViet` for EN/JA, so non-Vietnamese users could match a hidden Hán-Việt reading even though the UI did not display it.
- Delta: -15 percentage points on confidence that display-only localization covers discovery behavior.
- Updated belief: per-language UX also needs query-index tests; hidden teaching aids should not silently drive results outside their intended language.

## 2026-05-17 - Handwriting seed failed only after web compilation

- Prior belief: the handwriting practice path was covered by widget tests and only needed language-copy proof.
- Actual observation: live web blanked the `書く` practice surface because `Random().nextInt(1 << 32)` compiled to a zero max on web and threw `RangeError`.
- Delta: -20 percentage points on confidence that Dart VM widget coverage catches Flutter web numeric edge cases.
- Updated belief: any random/bitwise seed logic used by learner routes needs a web-safe constant and live route proof, not only VM widget tests.

## 2026-05-17 - Japanese Kanji UX had no Japanese definition field

- Prior belief: the per-language Kanji slice mainly needed UI switching because the schema already had localized meaning fields.
- Actual observation: runtime Kanji had Vietnamese and English meanings, but no Japanese definition field in the model/DB path, and current content assets have `0` `meaningJa` entries.
- Delta: -20 percentage points on confidence that "localized schema exists" implies all target locales have data paths.
- Updated belief: per-language learning modes need two checks: rendered UI gating and asset-to-model field availability for each locale, before claiming immersion completeness.

## 2026-05-18 - Content DB schema version can lie about physical columns

- Prior belief: bumping content DB schema v34 and adding migration coverage was enough to make `meaning_ja` safe for existing installs.
- Actual observation: the deployed Kanji path could still hit an existing DB whose `user_version` was current but whose `kanji` table lacked the physical `meaning_ja` column, so Drift failed before Kanji data reached the UI.
- Delta: -25 percentage points on confidence that `user_version` alone proves content DB shape after fast-moving seed migrations.
- Updated belief: beta content DB migrations need self-healing physical-column checks for learner-critical tables, especially before startup seed/read code touches generated Drift columns.

## 2026-05-18 - KANJIDIC2 is not a modern JLPT level map

- Prior belief: KANJIDIC2 plus Unihan would be enough to drive a clean N5-N1 Kanji expansion plan.
- Actual observation: KANJIDIC2 exposes old JLPT tiers only; it can quantify large N5/N4/N2/N1 gaps, but it has no modern N3 tier and cannot safely split modern N3/N2 on its own.
- Delta: -30 percentage points on confidence that the expansion source stack is complete.
- Updated belief: expansion needs two source layers: KANJIDIC2/Unihan for open readings/meanings/Hán-Việt, plus a separate modern JLPT level mapping before generating N3/N2/N1 batches.

## 2026-05-18 - Some N5 Hán-Việt fields held native Vietnamese meanings

- Prior belief: missing `meaningVi` on a few N5 kanji was likely just a display-field omission.
- Actual observation: `二` and `三` had `hanViet` values `Hai` and `Ba`, which are native Vietnamese meanings, not Hán-Việt readings; KANJIDIC2/Unihan confirm `Nhị` and `Tam`.
- Delta: -15 percentage points on confidence that low-level kanji metadata is semantically clean when visible display text looks acceptable.
- Updated belief: Kanji completeness checks must validate field role correctness, not only non-empty strings; `hanViet` is not interchangeable with Vietnamese meaning.
