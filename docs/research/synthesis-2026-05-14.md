# Synthesis 2026-05-14

## Phase 0 Status

Measurement harnesses now cover synthetic NS, event replay, GA4-shaped exports, SM1 funnel scoring, and current Vietnamese content-status scanning. Real beta telemetry and content readiness remain unproven.

## Top Findings

1. Real NS/SM1 counts remain blocked by missing GA4/Firebase event tables, not by BigQuery identity. Service-account auth and BigQuery Job User access work, but `analytics_536663906` is absent and Firebase-side datasets currently expose zero tables. Confidence: high.
2. Current content scope is much larger than the March Vietnamese audits: `781` JSON files now vs `351` scanned then. Confidence: high.
3. N1/N2 content carries major machine-origin metadata: `7,453` machine-origin items across N1/N2. Confidence: high for tag count, medium for quality inference.
4. Explicit open-review debt is concentrated in grammar examples: `1,744 / 1,886` open-review items are in `grammar_examples`, with another `142` in grammar explanations. Confidence: high.
5. Vocabulary review status is ambiguous: `5,273` machine-origin vocab items have no matching approval/open-review status. Confidence: high.
6. N3-N5 have `142` open-review grammar explanations but no approval signals in the scanner; absence of tags elsewhere is not equivalent to being reviewed. Confidence: high.
7. N1/N2 approved grammar explanations are not reliably learner-ready: `4 / 4` sampled approved items scored clarity `2/5`. Confidence: medium because sample size is small but falsifier is strong.
8. Missing local Minna N3+ is not a hard blocker if routes are JLPT-labeled, but the official Minna series does continue into intermediate levels with Vietnamese support. Confidence: medium.
9. Grammar examples are mostly linked to grammar points, but vocab-to-kanji coverage is too shallow for hard prerequisite gating. Even cumulative lower-or-same-level kanji fully covers only N1 `2483 / 6379`, N2 `1098 / 2991`, N3 `545 / 1786`, N4 `672 / 1719`, and N5 `549 / 1470` kanji-bearing vocab entries. Confidence: high for graph counts, medium for pedagogic inference.
10. Cumulative vocab count reaches rough JLPT targets, but cumulative upper-level kanji does not: N1 has `889 / 2,000`, N2 has `689 / 1,000`. Confidence: medium because current JLPT has no official item lists.
11. Upper-kanji Han-Viet values are incomplete: Q2.6 sampled N3/N2/N1 found `22 / 50` exact Unihan matches, `23 / 50` missing local values, `4 / 50` missing Unihan values, and `1 / 50` mismatch. Confidence: medium because this is a seeded sample.
12. App-language switch coverage is balanced, but copy is not centralized: `app_language.dart` has `680` returns per locale and no blank/TODO returns, while `1,893` Vietnamese lines exist elsewhere in Dart after excluding research helper code. Confidence: high for counts, medium for severity.
13. Encoding cleanup landed for scanned paths: `7` Dart-source mojibake hits were found and fixed, and `3` UTF-16 LE docs were converted to UTF-8. Content JSON had no marker hits in the precise scan. Confidence: high for scanned marker set.
14. Vietnamese typography sample is mostly clean at the character/punctuation layer: fixed-seed Q3.4 sampled `100` strings from `2,196` candidates, average `4.84/5`, with `8` raw-English-term warnings and `0` mojibake/punctuation/tone-variant warnings. Confidence: medium; this is heuristic triage, not human editorial approval.
15. Full ARB migration before beta is not worth the risk: `AppLanguage` appears in `140` lib files, `appLanguageProvider` in `111`, and `AppLanguage.en/vi/ja` references occur `5,219` times. There are `0` `.arb` files and no `l10n.yaml`, though `flutter_localizations` and `MaterialApp.locale` already exist. Confidence: high for surface count, medium for effort estimate.
16. Q3.6 found `0` ICU/plural API usage, `5` relevant manual singular guards, and `41` raw English count-plural strings across `18` files. A TDD patch fixed central `AppLanguage` count helpers, reducing remaining grep matches to `31`; Vietnamese is less affected. Confidence: medium from regex triage.
17. Top hardcoded-copy files split into three ownership types: domain data, feature copy modules, and local UI/helper copy. Confidence: high after direct inspection of the top ten files.
18. D6 UI surfaces need policy before broad polish: card families are implicit, `EmptyStateWidget` is unused, loaders are mostly bare spinners (`69` circular indicators across `53` files), and shared error UI has only `13` feature usages. Confidence: high for grep counts, medium for UX severity.
19. Optional dashboard panels can hide state: empty/loading/error branches often collapse with `SizedBox.shrink()`, including six loading branches and at least eight sampled error branches. Confidence: high for sampled code, medium for user impact until telemetry.
20. Raw exception text can reach learner-facing UI in Foundations, Grammar, and Recall Sprint; friendly error primitives exist but are not consistently adopted. Confidence: high for sampled code, medium for frequency.
21. Contrast is not globally broken, but small helper/status text is not WCAG-safe: nav inactive labels pass, while input hints are `2.57:1`, `ink 0.45` helper text is `2.79:1`, and `AppStatusChip.warning` is `2.55:1`. Confidence: high for sampled token math, medium for visual coverage.
22. Touch targets are not consistently safe in compact/inline controls: primary nav, quiz controls, and Kanji grids mostly pass, but discover reorder/focus controls, top-bar notification, mistake delete, lesson inline icons, library/practice action CTAs, handwriting free-practice CTA, and `StarRating` shrink below `44x44`. Confidence: high for explicit constraints, medium for runtime hitbox coverage.
23. Dark mode works at the shell/token layer but is not parity-ready: focused dark/theme tests pass, while dark `ThemeData` lacks several light-theme component families, hardcoded light surfaces remain in Grammar repair prompts and Design Lab, and route-level dark visual coverage is narrow. Confidence: high for wiring/test evidence, medium for route impact.
24. Web release build passes, but SM5 performance readiness is unproven: no Lighthouse score was produced, `main.dart.js` is `1.76 MB` gzip, total JSON assets are `19.35 MB`, and local first-route smoke observed `250` resources with broad grammar JSON loading. E7.2 added a reproducible build-artifact budget gate that passes current `build/web`. Confidence: high for build/size counts, medium for runtime impact because localhost is not Firebase Hosting.
25. Release readiness is gated by hygiene and parity, not compilation. Focused route/layout smoke tests pass after a stale `/exam-center` assertion update, but both Firebase live sites are older than current `HEAD`. E8.6 patched `SHIPPING.md` App Check build flags and CSP checklist drift, but no fresh deploy or live route/perf probe has run. Confidence: high for CLI/config/doc evidence.
26. Privacy/Terms launch surface was absent at E8.2, but E8.3 added `/privacy` and `/terms` routes, VI+EN review-needed draft copy, and links from Settings/Data controls, Onboarding, and Login. Confidence: high for route/widget test evidence; legal sufficiency remains unapproved.
27. Web Firebase API-key referrer restriction is active for Identity Toolkit: fake `https://evil.example/probe` referrer returns `403 API_KEY_HTTP_REFERRER_BLOCKED`, while Firebase Hosting referrers reach endpoint validation. Confidence: high for live Google API response; GCP Console allowed-referrer list still needs manual launch review.
28. Firebase Auth authorized-domain final proof is console-blocked from source. Source/CLI confirm intended hosts (`jpstudy-v2.firebaseapp.com`, `jpstudy-v2.web.app`, `jpstudy.web.app`), but not whether `localhost` is removed from production Auth authorized domains. Confidence: high for source/CLI limitation.
29. CI is not absent: GitHub Actions already runs string guard, analyze, tests, web build, and Storage rules tests. E8.7 made the web build release-like and added the D7 artifact budget gate, but deploy/live smoke/Lighthouse/notification gates remain absent. Confidence: high for workflow-file evidence.

## Ruled Out

1. "The March 16 audit is enough for launch readiness" - false for current scope.
2. "Open review tags cover all machine-translated content" - false for vocabulary.
3. "No tag means reviewed" - unsupported.
4. "`approved-by-user` means learner-ready" - false for sampled N1/N2 grammar explanations.
5. "Minna has no N3+ continuation" - false for the official series; true only for local app assets.
6. "Kanji/vocab cross-links are ready for prerequisite logic" - false for same-level graph.
7. "JpStudy has full N1/N2 kanji scope" - false against rough count targets.
8. "Unihan-sourced kanji metadata means upper Han-Viet is complete" - false in the Q2.6 sample.
9. "`app_language.dart` is the only Vietnamese UI-copy surface" - false; D3 found `1,893` Vietnamese lines outside it.
10. "Loading polish just needs a shimmer component" - false; good local loading examples already exist, but adoption/policy is inconsistent.
11. "Error handling lacks primitives" - false; primitives exist, but severity rules and retry adoption are uneven.
12. "The beige/light palette makes navigation unreadable" - false in the sampled tokens; nav contrast passes. The risk is muted helper/status text.
13. "Touch target risk is only in the Discover Practice panel" - false; the same compacting pattern appears in top bar, lesson, mistake, library/practice, handwriting, and shared rating controls.
14. "Dark mode is just an unwired toggle" - false; it is wired and tested. "Dark mode is polished parity" is also unsupported.
15. "Web build failure is the current performance blocker" - false; release build passes. The blocker is measurement/tooling plus startup resource loading.
16. "A passing web build proves live beta readiness" - false; live channel freshness, App Check telemetry, explicit deploy target selection, and post-deploy probes are still required.
17. "Privacy/Terms only need copy polish" - false at E8.2; the route/link surface itself was absent. E8.3 added the minimal tested surface, but final legal approval remains open.
18. "The web Firebase API key is probably still unrestricted" - false for Identity Toolkit fake-referrer probes; the remaining risk is process/docs coverage and other key/platform restrictions.
19. "Auth authorized domains can be fully audited from repo config" - false; repo config exposes intended domains, not Firebase Console allowlist state.
20. "D8.Q8.5 needs a baseline CI from zero" - false; the baseline exists but needs release/live automation.

## What We Still Do Not Know

- Whether N5/N4 Vietnamese is good enough for first-week beta learners.
- Which lower-level files were human-reviewed before status metadata existed.
- Whether machine-origin N1/N2 vocab is acceptable after sampling or needs full editorial pass.
- The corpus-wide defect rate for approved N1/N2 grammar explanations.
- Whether real Vietnamese N3+ learners prefer Shin/Soumatome/Try/Mimikara over Minna Chukyu in practice.
- Whether advisory prerequisite suggestions improve recovery after vocab mistakes.
- The full-corpus defect rate for present upper-level kanji Han-Viet values.
- Which lower-ranked hardcoded Vietnamese files are legitimate domain content vs UI chrome.
- Whether the `8/100` raw-English-term typography hits are acceptable product language or must be localized before beta.
- Whether Q3.6 plural/ICU defects are severe enough to justify a small ARB pilot.
- Which central `AppLanguage` count helpers should get singular-aware English before D4 UAT.
- Whether docs should enforce UTF-8 in CI beyond the D3 audit gate.
- Whether real user telemetry will expose content-induced drop-off or quiz failures.
- Whether hidden optional-panel loading materially affects beta trust or only reduces dashboard clutter.
- Which primary route family should be converted first for loading/empty/error consistency.
- Whether raw exception text appears in production beta often enough to affect support load.
- Whether visual screenshot/axe runs find additional contrast failures beyond static token math.
- Whether widget/render-box tests find additional under-44 controls beyond static compact-override grep.
- Whether dark-mode route screenshots find severe bright islands beyond the sampled Grammar repair prompt and Design Lab cases.
- Whether live Firebase Hosting compression/CDN changes D7 conclusions materially versus local Python serving.
- Why first local load fetches many grammar assets across levels before the learner chooses a route.
- Whether browser resource-count tooling can turn the `250` local-resource observation into a CI/release gate.
- Whether the next explicit deploy should target `jpstudy-v2`, `jpstudy`, or both.
- Whether web beta requires App Check enforcement immediately or monitoring mode first.
- What exact legal copy is acceptable after human/legal review; E8.3 only proves the draft route/link surface exists.
- Whether Android/iOS Firebase API keys have correct package/bundle restrictions; E8.4 only tested the web key against Identity Toolkit.
- Whether `localhost` is still present in production Firebase Auth authorized domains; E8.5 made the manual gate explicit but did not inspect Console state.
- Whether GitHub branch protection requires the CI checks; repository files show workflows, not protection settings.

## Recommendation

Before recruiting beyond a tiny pilot, add a minimal review-status taxonomy and backfill it. Prioritize N5/N4 learner-critical paths, N1/N2 open-review examples, and approved N1/N2 grammar explanations that still contain placeholder review language. Keep N3+ route labels source-aware; do not imply a complete Minna continuation.

Prerequisite logic should stay advisory-only. Cumulative kanji coverage does not rescue hard gating, and unresolved N4/N5 refs remain a cleanup task.

Do not claim full N1/N2 kanji coverage until upper-level kanji expansion is planned and verified.

Do not present upper Han-Viet metadata as fully trusted until blank/null values and ambiguous mismatches are reviewed.

Do not start broad copy edits outside the top clusters until lower-ranked hardcoded-copy files are classified. Use the glossary seed for immediate replacements in vocab/kanji/custom-deck copy.

For D6/D7/D8 hardening, document and enforce small policies before visual refactors: three card families, visible/actionable primary empty states, visible localized primary loaders, friendly retryable primary errors, compact optional-panel loading/error handling, contrast-safe helper/status tokens, `44x44` minimum hitboxes for active controls, dark component-theme parity, first-route resource budgets, and release-doc/config parity. Avoid a broad card/shimmer/error-widget/theme rewrite until route-critical surfaces have tests and telemetry.

Before any beta deploy, keep `SHIPPING.md` and `docs/FIREBASE_SECURITY_CHECKLIST.md` aligned with actual CSP/App Check requirements, run the full local release gate, choose the Firebase target explicitly, deploy only after that decision, then rerun D4 direct-route probes and D7 perf smoke against the chosen live URL.

Before public or 100-user beta, treat the new `/privacy` and `/terms` route/link slice as beta draft only. Finalize legal copy, support/contact wording, and deletion-policy language before removing `review-needed draft` status or relying on the documents for public launch.

Keep the API-key fake-referrer probe in the release gate. The current web key passes for Identity Toolkit, but still manually verify the GCP Console allowed-referrer list and platform-key restrictions before launch.

For Auth domains, inspect Firebase Console before public beta: keep only deployed production domains and Firebase-required project domains in production, and use a separate dev Firebase project for local sign-in testing.

For D7/CI/CD, keep the release-like PR build and artifact budget gate. Add browser/live gates only after target choice: Lighthouse or Playwright resource-count budget, route smoke on the deployed URL, and explicit failure notification or branch-protection enforcement.
