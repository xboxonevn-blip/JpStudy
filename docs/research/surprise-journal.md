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
