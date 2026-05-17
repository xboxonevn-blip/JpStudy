# Synthesis 2026-05-15

## Mission Summary

The 2026-05-13 to 2026-05-15 mission moved JpStudy-v2 from broad unknowns to
an evidence-backed beta posture. The research notebook now has all `62 / 62`
questions answered across D1-D8, and the user-feedback sprint converted several
live blockers into source changes: foundations gating, level propagation,
vocab catalog availability, radical header mojibake, upper kanji tabs,
Han-Viet rules localization, richer kanji detail panels, grouped navigation,
anonymous auth, Sentry wiring, CI/deploy gates, and textbook-aligned roadmap
orientation.

The product is not ready for a broad 100-user mixed N5-N1 public beta without
caveats. It is closer to a controlled pilot because the highest-risk unknowns
are now explicit: GA4 BigQuery export exists and later ingested the learning
events on 2026-05-17, upper-level scope/routing still needs caveats despite
clean machine/open-review audit counts, legal/error-monitoring/deletion/GA4
retention proof still need live operational evidence, and several
advanced-persona promises remain out of scope.

## 8 Dimension Status

| Dimension | Status | Current finding |
| --- | --- | --- |
| D1 Measurement | Complete, first real export sampled | `analytics_536663906.events_20260514` exists. Later 2026-05-17 export proof includes all three learning-event families and first source-verifiable NS `qualifiedUsers=1/5`. |
| D2 Content | Controlled pilot content clean across N5-N1 | N5-N1 now have `0` machine/open-review items. N5/N4 are launch-tier; N3/N2/N1 have launch-tier editorial quality with user spot-check pending and incomplete N1 kanji scope. |
| D3 Vietnamese | Complete, targeted cleanup active | Mojibake guards are green and key user strings moved into `AppLanguage`; copy remains decentralized. |
| D4 Personas | Complete, retested | Onboarding/level/Kana gates now pass in live re-test; upper vocab discoverability was the main residual blocker before the latest unlock work. |
| D5 Pedagogy | Complete plus roadmap shipped | FSRS, streak, XP, ghost review, and prerequisite logic are documented as policy gaps; roadmap is source-aware and advisory. |
| D6 UI/UX | Complete plus focused UX work | Compact sidebar and rich kanji panel shipped; broader loading/error/contrast/touch/dark policies remain next-cycle work. |
| D7 Performance | Complete with gates | Release build, artifact budget, and local resource smoke are guarded; live Lighthouse/trace proof still depends on deploy secrets. |
| D8 Compliance/Infra | Complete, ops proof pending | Privacy/Terms surface, Sentry source wiring, primary hosting policy, CI, and deploy job exist; public-launch legal/secret/live proofs remain open. |

## User Feedback Resolution

1. F1 radicals: full audit found radical Han-Viet drift was systemic, not a
   5-15% cleanup. Top-30 visible corrections shipped, and the remaining risk is
   now documented as editorial source quality rather than encoding alone.
2. F2 vocab catalog: the hardcoded WIP gate was removed, catalog notes explain
   publisher scope, and upper-level track availability was opened from actual
   assets. A later live retest showed availability and review-count gates are
   separate, so future checks must cover both.
3. F3 textbook coverage doubt: docs and UI copy now distinguish Minna I/II,
   Hajimete N5-N1, and Shin Kanzen N3-N1 without implying missing publisher
   coverage.
4. F4 learning path: the home learning path now has source-aware per-level
   phases: N5/N4 use Minna + Hajimete, N3/N2/N1 use Hajimete + Shin Kanzen,
   and N1 adds immersion.
5. Extra feedback from 2026-05-15 also landed: radical group mojibake fixed,
   N2/N1 Kanji Hub tabs added, Han-Viet rules localized with examples, kanji
   detail modal unified with rich study flow, and desktop sidebar compacted.

## Top 10 Findings

1. Real North Star reporting is no longer export-blocked. The first
   source-verifiable sample is still too small for outcome claims, but it now
   includes SRS/quiz/quality events and `qualifiedUsers=1/5`.
2. Content volume is high and the current N5-N1 audit is clean for
   machine/open-review debt, but upper-level spot-check/user approval and N1
   kanji scope remain caveats.
3. Cumulative vocab scope does not imply kanji scope; N1 kanji is still far
   below rough 2,000-kanji target.
4. Han-Viet and radical metadata need editorial treatment; Unihan helps with
   leading readings but not learner-facing Vietnamese glosses.
5. Level correctness must be bootstrapped at app entry, not only on the home
   route.
6. Vocab readiness has four gates: data seed, catalog display, CTA
   availability, and queue/review counts.
7. Full ARB migration is not a beta prerequisite; targeted `AppLanguage`
   cleanup has better risk/return.
8. Release risk was mostly channel/doc/flag drift, not inability to build.
9. Performance needs route-resource gates in addition to bundle-size gates.
10. Identity and login UX can be separated: anonymous Auth gives a UID without
    adding onboarding friction.

## Top 5 Surprises

1. Radical Han-Viet drift hit `163 / 214` mismatch-or-missing compare rows,
   much larger than the expected 5-15%.
2. GA4 BigQuery export appeared only after an earlier absence window; first
   useful learning-outcome rows are still missing.
3. The vocab bug was not just "data locked"; N4 could be open while N3/N2/N1
   still failed other availability gates.
4. Startup resource count fell sharply only after both grammar seed paths were
   removed from app boot.
5. Anonymous Auth can establish a private migration identity without forcing a
   visible login wall.

## Top 5 Negative Results

1. `approved-by-user` grammar tags did not guarantee learner-ready Vietnamese.
2. Vocab-kanji links are too sparse for hard prerequisite gates.
3. Real FSRS calibration still lacks beta outcome data even though the
   scheduler now conforms to FSRS-6 learning intervals.
4. Dark mode is functional but not route-level parity.
5. Existing Firebase datasets do not equal product analytics or runtime error
   observability.

## Beta Readiness Recommendation

Do not recruit 100 mixed-level Vietnamese learners yet.

Recommended next step: run a controlled 5-10 learner pilot after a fresh
secret-backed deploy proves `https://jpstudy.web.app` has the current source,
primary hosting returns `200`, legacy hosting stays `404`, CI stays green,
and live route/performance probes pass. Recruit around the paths now best
supported: N5/N4 habit learners first, then carefully scoped N3-N2 JLPT users.
Do not promise full N1/N2 kanji coverage, news/current-world reading, cramming
mode, group study, public legal clearance, or production observability until
the remaining ops and content proofs land.

## Open Questions For Next Cycle

1. When will the live export include SRS, micro-quiz, and session-quality rows
   from real beta users?
2. Which upper-level content scope gaps should be normalized first: N1 kanji
   expansion, route sequencing, or user spot-check follow-up?
3. Can upper-level vocab availability and review queues be normalized so N3-N1
   users see real unlocked work rather than preview states?
4. How should the FSRS-6 scheduler be calibrated once real beta SRS outcome
   rows exist?
5. What live Firebase Hosting Lighthouse/resource budgets should become
   blocking once deploy secrets are configured?
6. What exact legal/support/deletion wording is approved for public launch?
7. Which advanced-reader route should own N1 discovery: study hub, immersion,
   or a dedicated news/current-world lane?
