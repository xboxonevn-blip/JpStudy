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

## 2026-05-14 - Q5.6 / E5.6

- Cumulative lower-or-same-level kanji coverage still does not support hard prerequisite gating: only N1 `2483/6379`, N2 `1098/2991`, N3 `545/1786`, N4 `672/1719`, and N5 `549/1470` kanji-bearing vocab entries are fully covered.
- Scoped kanji practice exists, but no discovered code path maps weak vocab/grammar items to prerequisite review.
- The existing foundations gate is a one-time soft suggestion, not a per-item dependency engine.

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

## 2026-05-14 - Q6.3 / E6.3

- Existing loaders are not consistent enough to claim a polished first-run experience: `CircularProgressIndicator` appears `69` times across `53` files, usually without copy.
- Skeleton/shimmer is effectively absent; the only discovered structured skeleton is the progress coach board.
- Six home/me loading branches collapse with `SizedBox.shrink()`, so optional-panel loading can be visually indistinguishable from positive absence.

## 2026-05-14 - Q6.4 / E6.4

- `ErrorStateWidget` exists, but shared error UI is not the default: only `13` feature usages were found after excluding self/test.
- Several learner-facing routes can show raw exception text, including Foundations, Grammar, and Recall Sprint.
- At least eight sampled error branches collapse with `SizedBox.shrink()`, so optional-panel failures can be indistinguishable from absent content.

## 2026-05-14 - Q6.5 / E6.5

- Current sampled UI cannot claim WCAG 2.1 AA: input hint text is `2.57:1`, below the `4.5:1` normal-text threshold.
- `AppStatusChip.warning` is `2.55:1`; warning-colored small text is not contrast-safe on light surfaces.
- `ink 0.45` helper text is `2.79:1`, and `ink 0.50`-`0.55` captions are large-only, not safe for small body/caption text.

## 2026-05-14 - Q6.6 / E6.6

- The UI cannot claim consistent `44x44` touch targets yet: several active controls intentionally shrink below the floor.
- Discover Practice reorder is explicitly `28/34` with `MaterialTapTargetSize.shrinkWrap`, and the focus chip is a small custom `GestureDetector`.
- Secondary controls repeat the pattern: top-bar notification `36/40`, mistake delete `36`, lesson inline zero-constraint icons, library/practice `minimumSize: Size(0, 0)` CTAs, and interactive `StarRating`.

## 2026-05-14 - Q6.7 / E6.7

- Dark mode is wired, but current evidence does not support a polished parity claim.
- `AppTheme.dark` does not mirror several light-theme component families, including navigation bar, filled/outlined buttons, input decoration, and icon theme.
- Hardcoded light surfaces remain in feature code, including Grammar repair prompts and Design Lab, and route-level dark visual coverage is currently narrow.

## 2026-05-14 - Q7.1 / E7.1

- No Lighthouse score was produced because local Lighthouse CLI and Chrome/Edge CLI availability were missing.
- Release build passes, but current evidence does not support SM5 performance readiness.
- First local release smoke observed `250` resources and broad grammar JSON fetching; JSON assets total `19.35 MB`.
- Local Firebase analytics/installations produced localhost referer `403` errors, so console health is noisy outside approved hosting origins.

## 2026-05-14 - Q8.1 / E8.1

- Passing release web build is not enough evidence for beta deploy readiness: both live Firebase sites are older than current `HEAD`.
- The basic `SHIPPING.md` web build command omits `JPSTUDY_RECAPTCHA_SITE_KEY`, so following it leaves web App Check inactive.
- D7.Q7.2 found no route-level deferred JS chunks in the current release build. `main.dart.js` is one app bundle; route-level code splitting is not currently happening automatically.
- D7.Q7.3 did not justify switching beta to Flutter `--wasm`: build passes, but raw output increases by `9.4%` because Skwasm and CanvasKit fallback are both emitted, and live compatibility/perf is still unproven.
- Security docs are stale about CSP: they say strict CSP is not enabled, while `firebase.json` and live channels configure CSP.
- GA4 measurement was table-blocked during this check: `analytics_536663906` was absent and Firebase-side datasets exposed zero event tables. Later 2026-05-15 evidence shows the dataset appeared, but the first sample still lacks learning-outcome events.

## 2026-05-14 - Q8.1 / E8.2

- No `/privacy` or `/terms` route constants/routes were found in source.
- No VI+EN Privacy Policy or Terms of Service copy was found; `terms` hits are vocabulary term-count labels.
- Settings/Data controls, Onboarding, and Login do not link to legal documents.
- Data controls exist, but they are not a substitute for policy/terms routes or consent-surface links.

## 2026-05-14 - Q8.1 / E8.3

- The route/link absence above has been cleared by a minimal implementation, but this is not legal clearance.
- Privacy/Terms copy remains explicitly marked `review-needed draft`.
- Public launch still lacks final support/contact wording and approved data-deletion policy language.

## 2026-05-14 - Q8.2 / E8.4

- The expected "web API key is currently unrestricted" risk did not reproduce: fake referrer probes were blocked with `API_KEY_HTTP_REFERRER_BLOCKED`.
- The security checklist still lacked an explicit API-key restriction verification gate before E8.4.
- This probe does not verify Android/iOS key package restrictions or the exact GCP Console allowed-referrer list.

## 2026-05-14 - Q8.3 / E8.5

- Firebase Auth authorized-domain allowlist is not verifiable from repository source or `firebase hosting:sites:list`.
- `localhost` removal from production Auth authorized domains remains unverified until Firebase Console inspection.
- Before E8.5, the security checklist had only a generic authorized-domain review line, not a production allowlist or explicit `localhost` removal gate.

## 2026-05-14 - Q8.1 / E8.6

- Release doc/config drift was reduced, but not converted into live release proof.
- No deploy was attempted after adding the App Check build flag and CSP checklist updates.
- Live channel freshness, App Check telemetry, and live route/perf probes remain unverified.

## 2026-05-14 - Q8.5 / E8.7

- The expected "CI is mostly absent" risk did not reproduce; the existing workflow already ran analyze/test/web build and Storage rules tests.
- No workflow provides deploy automation, post-deploy live route smoke, Lighthouse/performance budgets, or explicit notification.
- Branch protection cannot be verified from repository files.

## 2026-05-14 - Q7.1 / E7.2

- Build-artifact budgets now exist and pass, but they do not measure route resource count, Lighthouse score, TTI, or live Firebase Hosting compression/CDN behavior.
- The largest JSON budget still permits `19.35 MB`; it is a regression gate, not proof that startup content loading is efficient.

## 2026-05-14 - Q7.1 / E7.3

- All-level grammar startup seeding is fixed locally, but no fresh browser resource-count smoke has proved the `250` first-load resource baseline improved.
- The fix covers discovered grammar app/content DB seeders only; other content families still need browser-level request instrumentation.

## 2026-05-14 - Q7.1 / E7.4

- Post-fix resource count improved `250 -> 108`, but this is still manual Playwright evidence, not a checked-in CI gate.
- Startup still fetches `50` active-level grammar JSON resources; the app is level-scoped but not route-minimal.
- Firebase localhost referrer `403` noise remains in local browser perf smoke.

## 2026-05-14 - Q7.1 / E7.5

- Root grammar prefetch is removed locally, but no checked-in browser resource-count test prevents regression yet.
- `69` first-route resources is localhost evidence only; Firebase Hosting compression/CDN and live auth/App Check behavior remain unmeasured after this patch.

## 2026-05-14 - Q7.1 / E7.6

- Local resource-count CI gate now exists, but it still serves `build/web`; it does not prove live Firebase Hosting headers, CDN behavior, App Check, or Auth/referrer behavior.
- Lighthouse remains absent; the Playwright resource smoke is a request-count gate, not a full SM5 performance score.
