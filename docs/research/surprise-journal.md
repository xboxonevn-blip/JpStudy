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
