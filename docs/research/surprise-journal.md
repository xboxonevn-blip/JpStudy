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
