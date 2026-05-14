# D2 Synthesis 2026-05-14 - Multi-Level Content Quality

## Status

D2 measurement questions Q2.1-Q2.6 are answered with reproducible local evals. The answer is not "content ready"; it is "content risks are now measurable."

## Evidence Summary

| Question | Evidence | Decision |
|---|---|---|
| Q2.1 review status | `1,886` explicit open-review items; `5,273` machine-origin vocab rows without clear approval/open status | Need review taxonomy/backfill |
| Q2.2 grammar quality | `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5` | Approval tag not reliable |
| Q2.3 Minna gap | Local Minna vocab stops at N4; N3-N1 have `ShinKanzen`/`hajimete` routes | OK if route labels are source-aware |
| Q2.4 link graph | Grammar links strong; same-level vocab-kanji coverage shallow | No prerequisite gating yet |
| Q2.5 scope | Cumulative N1 vocab `10,424 / 10,000`; kanji `889 / 2,000` rough target | No full N1/N2 kanji scope claim |
| Q2.6 Han-Viet | 50-sample: `22` matches, `23` missing local, `4` missing Unihan, `1` mismatch | Upper Han-Viet not trusted yet |

## Strong Conclusions

1. JpStudy should not recruit 100 learners on a "complete N1-N5 content" claim.
2. The safest near-term beta story is narrow: source-aware routes, explicit beta coverage caveats, and measured learning outcomes only.
3. N5/N4 may still be viable for a tiny pilot, but D2 has not proven lower-level learner-facing quality because old audit status is stale.
4. N1/N2 content needs editorial sampling and status cleanup before being marketed as learner-ready.
5. Han-Viet and vocab-kanji features should stay diagnostic/advisory until metadata completeness improves.

## Red Team

The evals are tag/data audits and small samples, not real learner comprehension tests. A motivated learner might tolerate imperfect Vietnamese if the SRS flow is strong. However, Q2.2 directly found confusing approved grammar explanations, and Q2.6 found missing learning-aid metadata, so "good enough for 100 mixed-level users" is still unsupported.

## Next Dimension Decision

Move to D3 before D4.

Reason: D4 persona UAT would surface many content/i18n issues already visible in D2. D3 can cheaply audit app-language Vietnamese, hardcoded strings, mojibake, terminology, and typography before spending browser/UAT time across five personas.

## D3 Entry Hypotheses

1. `app_language.dart` likely has inconsistent Vietnamese terminology because it is a single large enum-extension file with thousands of strings.
2. Some hardcoded Vietnamese bypasses exist outside `app_language.dart`, especially in feature screens and docs/debug labels.
3. Mojibake is probably not limited to content JSON; source files and docs need a broader scan.
4. ARB migration may be too expensive before beta; a targeted terminology/typo patch may have better information-per-hour.

## Action

Start D3.Q3.1-Q3.3 as the next research batch:

1. Audit `lib/core/app_language.dart` string counts and terminology.
2. Search hardcoded Vietnamese in `lib/` outside the language file.
3. Run mojibake scan across `lib/`, `assets/data/content/`, and `docs/`.
4. Save D3 hypotheses/experiment/raw/analysis docs before making user-facing copy fixes.
