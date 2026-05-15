# Beta Launch Proof Checklist - 2026-05-15

Status: manual/operator handoff. These items are required before claiming the
mission stopping condition is complete. Do not commit secrets, screenshots with
secret values, or private user data.

Primary app URL: `https://jpstudy.web.app`

## 1. GitHub Actions Secret-Backed Deploy

Goal: prove `deploy-hosting` performs a real build/deploy/live-smoke/Lighthouse
run on `main`, not only the skip-safe wrapper.

Required setup:

- Repository secret `FIREBASE_TOKEN`.
- Repository secret `JPSTUDY_RECAPTCHA_SITE_KEY`.
- Optional repository secret `JPSTUDY_SENTRY_DSN`.

Operator note:

- `firebase login:ci` must be run in an interactive user terminal. A Codex
  non-interactive attempt on 2026-05-15 returned `Cannot run login:ci in
  non-interactive mode.`
- After generating the token, set it as GitHub repository secret
  `FIREBASE_TOKEN`. Do not paste the token into chat or commit it.

Evidence to record:

- GitHub Actions run URL.
- `deploy-hosting` job step list where these steps are `success`, not
  `skipped`:
  - `Build web for production`
  - `Deploy primary Firebase Hosting target`
  - `Smoke primary and legacy hosting`
  - `Check live web resource smoke`
  - `Lighthouse live gate`
- Primary URL status: `https://jpstudy.web.app` returns `200`.
- Legacy URL status: `https://jpstudy-v2.web.app` returns `404`.

## 2. Sentry First-Issue Proof

Goal: prove source-wired Sentry is operational in a deployed web build.

Required setup:

- Create/choose a Sentry Flutter or JavaScript project.
- Set `JPSTUDY_SENTRY_DSN` as a GitHub Actions secret, or pass it only through
  a local `--dart-define` for a non-public test build.
- Keep `sendDefaultPii=false` and consent/sign-in gate behavior unchanged.

Evidence to record:

- Build or CI run URL showing `JPSTUDY_SENTRY_DSN` was supplied without
  revealing the value.
- Sentry issue URL for one intentional non-production test exception.
- Confirmation the event includes release/environment context and no learner
  prompt, answer, name, or free-text content.

## 3. Firebase Storage Migration Proof

Goal: prove anonymous Auth plus Storage rules can write the legacy migration
payload before enabling automatic migration.

Required setup:

- Create/provision Firebase Storage for project `jpstudy-v2`.
- Deploy `storage.rules`.
- Configure CORS for the web app origin.
- Keep `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=false` until proof passes.

Evidence to record:

- Storage bucket name and console URL.
- Rules deploy command output.
- CORS config command output or console proof.
- Live web run with `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=true` where:
  - anonymous sign-in succeeds,
  - `users/{uid}/legacy_migration.json` is created,
  - another UID cannot read or write that path,
  - migration does not repeat after `flutter.auth.migrated=true`.

## 4. Legal Copy Approval

Goal: convert `/privacy` and `/terms` from beta draft to approved launch copy.

Evidence to record:

- Reviewer name or approval source.
- Reviewed date.
- Approved copy commit hash.
- Confirmation contact/support, data categories, retention, deletion rights,
  anonymous UID handling, analytics consent, and Storage backup language were
  reviewed.

## 5. Deletion Runbook Execution Proof

Goal: prove the deletion runbook can delete a test user's data end to end.

Safety:

- Use only a dedicated test account/support ID.
- Do not run deletion against real learner data without explicit user request.

Evidence to record:

- Support ID copied from the app.
- Auth user deletion result.
- Storage `users/{uid}/...` deletion result.
- GA4/BigQuery deletion request or documented limitation.
- Verification that the app no longer restores that user's cloud data.

## 6. GA4 Retention UI Proof

Goal: prove GA4 UI retention settings match the privacy/analytics policy.

Evidence to record:

- GA4 Admin retention screen screenshot or written console observation.
- Retention value.
- Date and Google account used.
- Cross-check with BigQuery dataset/table TTL evidence already recorded in the
  research notebook.
- Optional source-verifiable path: enable Google Analytics Admin API
  (`analyticsadmin.googleapis.com`) for project `129949648924`, grant the
  service account Analytics read access, then probe
  `properties/536663906/dataRetentionSettings`.

## 7. App Check Enforcement Proof

Goal: enforce App Check only after legitimate web traffic has been monitored.

Timing:

- Wait 1-2 weeks of monitoring after beta traffic begins.

Evidence to record:

- App Check monitoring screenshot/summary before enforcement.
- Enforcement change date.
- Post-enforcement smoke: Auth, Storage backup/migration, and Analytics still
  work on `https://jpstudy.web.app`.

## Update Locations After Proof

After each proof, update:

- `docs/research/mission-completion-audit-2026-05-15.md`
- `docs/research/README.md`
- The relevant `docs/research/D8-compliance/Q8.*-raw-output.md`
- `docs/research/surprise-journal.md` if the result changes a belief by more
  than 20%.
