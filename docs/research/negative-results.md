# Negative Results

## 2026-05-13 - Q1 / E1.1

- Existing Firebase Analytics could not compute the North Star.
- No durable 1-5 session-quality rating was found.
- No one-command North Star report existed.
- Local Drift cannot answer 50-user beta NS without a stable cohort/user export path.

## 2026-05-13 - Q1 / E1.2

- Synthetic NS 4.00% is not evidence about real learners.
- Lesson 1-25 test completion is only a proxy for an embedded N5 micro-quiz, not a validated quiz identity.

## 2026-05-13 - Q1 / E1.3

- Normalized event JSON support is not proof that raw GA4 BigQuery export is ready.
- The event fixture has only 2 observed users, so its 2.00% NS is a harness check, not beta evidence.

## 2026-05-13 - Q1 / E1.4

- GA4-shaped fixture support is not proof that BigQuery export is enabled or that real beta events preserve stable user continuity.
- The adapter validates documented schema mechanics only; it does not validate production data availability.

## 2026-05-13 - Q1 / E1.5

- Firebase CLI project/app visibility is not proof of GA4 BigQuery export readiness.
- `gcloud` and `bq` are unavailable locally, so dataset/table checks cannot be run from this workstation yet.

## 2026-05-14 - Q1.3 / E1.7

- HomeScreen widget-level verification for onboarding telemetry is blocked by Flutter Windows native-assets/sqlite copy crash and timeout in this environment.
- `onboarding_completed` service tests do not prove Firebase DebugView/export delivery.

## 2026-05-14 - Q1.3 / E1.8

- Existing normalized NS fixture cannot answer SM1 funnel because it lacks open/session and onboarding events.
- Funnel report readiness is not real funnel evidence without a real GA4 export sample.

## 2026-05-14 - Q1.4 / E1.9

- `tool/research/ga4_ns_export.sql` is a handoff query, not evidence about current users.
- Pseudonymous event rows are lower-risk than PII, but should still stay out of git.

## 2026-05-14 - Q2.1 / E2.1

- March 16 Vietnamese audits scanned `351` files, but current content scope has `781` JSON files; old audit totals are stale for launch readiness.
- The first Q2.1 scanner undercounted lower-level open review until `manual-review-needed` was folded into the status taxonomy.
- `vocab` has `5,273` machine-origin items but no approval/open-review status, so current tags cannot distinguish reviewed from unreviewed imported vocabulary.

## 2026-05-14 - Q2.2 / E2.2

- `approved-by-user` is not enough evidence of learner-ready Vietnamese: `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5`.
- The 10-item sample is not enough to estimate corpus-wide defect rate; it only falsifies the stronger assumption that approval status can be trusted by itself.

## 2026-05-14 - Q2.3 / E2.3

- Google Trends term comparison for VN could not be retrieved through the available web tooling, so no trend ranking is used.
- Vietnamese course pages are weak evidence, not user-survey evidence; Q2.3 cannot prove N3+ route preference.
- "Minna stops at N4" is false for the official series because Minna Chukyu exists with Vietnamese support; it is only true for the current local app assets.

## 2026-05-14 - Q2.4 / E2.4

- Same-level vocab-to-kanji coverage is too shallow for prerequisite gating: N1 has only `780 / 6,379` kanji-bearing vocab entries fully covered by same-level kanji.
- N4/N5 kanji example `sourceVocabId` refs are not fully resolved (`353 / 381`, `401 / 452`).
- Same-level coverage may understate true learner coverage because lower-level kanji should be cumulative, so Q2.4 does not prove exact prerequisite gaps yet.

## 2026-05-14 - Q2.5 / E2.5

- Current JLPT does not publish official vocabulary/kanji/grammar item lists, so "official scope" cannot be verified as an exact checklist.
- Cumulative N1 kanji scope is only `889 / 2,000` rough target; JpStudy should not claim full N1 kanji coverage.
- Broad vocab count does not offset quality risk from machine-origin/approved-but-unclear content.

## 2026-05-14 - Q2.6 / E2.6

- Unicode Unihan credit/source trail does not prove upper-kanji Han-Viet completeness.
- The seeded 50-row N3/N2/N1 spot check found `23 / 50` missing local Han-Viet values.
- One sampled row with both values mismatched (`行`: local `Hành`, Unihan `hàng`), so ambiguous readings need human review rather than blind replacement.

## 2026-05-14 - Q3.1-Q3.3 / E3.1-E3.3

- Balanced `app_language.dart` switch coverage (`680` returns per locale) is not enough to claim editorial readiness because terminology is still inconsistent.
- `app_language.dart` is not the sole copy surface: `1,888` Vietnamese lines exist outside it.
- Source/content encoding was not fully clean: Dart source had `7` mojibake hits before the D3 fix, and `3` docs files remain not UTF-8 decodable.
