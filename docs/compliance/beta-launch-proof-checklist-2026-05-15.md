# Beta Launch Proof Checklist - 2026-05-15

Status: manual/operator handoff. These items are required before claiming the
mission stopping condition is complete. Do not commit secrets, screenshots with
secret values, or private user data.

Primary app URL: `https://jpstudy.web.app`

Aggregate status command:

```powershell
npm run report:launch-readiness -- --json
```

Structured manual proof state:

```powershell
npm run report:launch-readiness -- --json --proof-state docs/compliance/launch-proof-state.json
```

The proof state file may close only manual gates: legal approval, Sentry
first-issue proof, deletion execution, GA4 retention UI proof, and App Check
enforcement. Each gate still requires explicit metadata. Date fields must
parse as dates, legal approval must reference an existing git commit, and
Sentry proof must include both the workflow run URL and the first issue URL.
GA4 learning-event export remains source-verified and cannot be closed by the
proof state file. Firebase Storage is intentionally descoped for beta and
recorded as deferred metadata because the app is local-first and the project
remains on Spark.

Latest post-descope run on `2026-05-17T09:12+07:00` returned
`complete=false` with blockers: `legal-approval-missing`,
`sentry-dsn-missing`, `deletion-proof-missing`,
`ga4-retention-proof-missing`, and `app-check-enforcement-deferred`.
Storage reports as `deferred` with reason
`storage-descoped-for-beta`; `storage-not-provisioned` is no longer a beta
blocker.

Operator URLs are now printed directly by:

- `npm run report:launch-readiness -- --json --proof-state docs/compliance/launch-proof-state.json`
- `npm run report:storage-readiness -- --json --skip-emulator`
- `npm run report:deletion-readiness -- --uid "<firebase-uid>" --json`
- `npm run report:ga4-export -- --json`

## Remaining Owner Gate Quick Actions

Use the project owner account `chung.phukiengiabuon@gmail.com`
(`authuser=1`) for Firebase/GCP/GA actions.

1. Legal approval:
   - Review live `/privacy` and `/terms`.
   - Use `docs/compliance/legal-approval-checklist.md` to check the specific
     privacy/terms claims before approving.
   - Fill `docs/compliance/launch-proof-state.json`:
     `legal.approved=true`, `legal.reviewer`, `legal.approvedAt`,
     `legal.commit`, and `legal.evidence`.
2. Sentry proof:
   - Add GitHub Actions secret `JPSTUDY_SENTRY_DSN`.
   - Run GitHub Actions `CI` manually with `sentry_smoke=true`.
   - Fill `docs/compliance/launch-proof-state.json`:
     `sentry.eventSent=true`, `sentry.sentAt`, `sentry.issueUrl`,
     `sentry.workflowRun`, and `sentry.evidence`.
3. Firebase Storage:
   - Descoped for beta by owner decision on `2026-05-17`.
   - Rationale: new Cloud Storage for Firebase buckets require Blaze, while
     `jpstudy-v2` stays on Spark and the app is local-first.
   - Beta backup path is local file export/import in Data controls.
   - Keep Storage scaffolding, rules, and CORS files for a future cloud-sync
     rebuild, but do not require bucket provisioning for beta.
4. Deletion proof:
   - Use only the dedicated test UID/support ID.
   - Run `npm run report:deletion-readiness -- --uid "<uid>"`.
   - After GA4 Admin/deletion access is ready, execute the beta runbook and
     set `deletion.executed=true`, `deletion.executedAt`,
     `deletion.supportId`, and `deletion.evidence`.
5. GA4 retention proof:
   - Open GA4 Admin for property `536663906`.
   - Record retention value and set `ga4Retention.verified=true`,
     `ga4Retention.verifiedAt`, `ga4Retention.retention`, and
     `ga4Retention.evidence`.
6. GA4 learning export:
   - Closed on `2026-05-17T08:28+07`: BigQuery export contains
     `srs_review_completed`, `n5_micro_quiz_completed`, and
     `session_quality_rated`.
7. App Check enforcement:
   - Wait 1-2 weeks of beta monitoring.
   - Enforce App Check, smoke Auth/Analytics, then set
     `appCheck.enforced=true`, `appCheck.enforcedAt`, and
     `appCheck.evidence`.

## 1. GitHub Actions Secret-Backed Deploy

Status: completed on `main`. Use the current GitHub Actions run for the newest
exact commit/run ID; the run must show all source and deploy gates green.

Goal: prove `deploy-hosting` performs a real build/deploy/live-smoke/Lighthouse
run on `main`, not only the skip-safe wrapper.

Current secret state:

- Repository secret `FIREBASE_TOKEN`.
- Repository secret `JPSTUDY_RECAPTCHA_SITE_KEY`.
- Optional repository secret `JPSTUDY_SENTRY_DSN` is not set.

Operator note:

- `JPSTUDY_RECAPTCHA_SITE_KEY` and `FIREBASE_TOKEN` are set as repository
  secrets without exposing values in logs.
- `JPSTUDY_SENTRY_DSN` remains optional for deploy and required only for
  Sentry first-issue proof.

Evidence recorded:

- GitHub Actions workflow:
  `https://github.com/xboxonevn-blip/JpStudy/actions/workflows/ui-string-guard.yml`
- `deploy-hosting` job step list shows these steps `success`, not
  `skipped`:
  - `Build web for production`
  - `Deploy primary Firebase Hosting target`
  - `Smoke primary and legacy hosting`
  - `Check live web resource smoke`
  - `Lighthouse live gate`
- Primary URL status: `https://jpstudy.web.app` returns `200`.
- Legacy URL status: `https://jpstudy-v2.web.app` returns `404`.
- Local live resource smoke after deploy remains covered by CI. Additional
  Playwright visual smoke on `2026-05-16T08:05+07:00` checked Kanji radical
  headers, Han-Viet rules, and Review Forecast labels on
  `https://jpstudy.web.app`.
- Latest checked run at handoff time must complete `ui-string-guard`,
  `firebase-security-rules`, and `deploy-hosting` with `success`.

## 2. Sentry First-Issue Proof

Goal: prove source-wired Sentry is operational in a deployed web build.

Current status: source-ready, live proof missing.

- Source wiring and the disabled-by-default smoke trigger are deployed on
  `main`; use the current GitHub Actions run for exact CI/deploy proof.
- Manual CI smoke path is available through GitHub Actions `workflow_dispatch`
  input `sentry_smoke=true`. When `JPSTUDY_SENTRY_DSN` is present, the workflow
  builds with `JPSTUDY_SENTRY_SMOKE_EVENT=true`, deploys, and opens
  `https://jpstudy.web.app/?sentry-smoke=1` in Chromium.
- Repository Actions secrets rechecked on `2026-05-17T09:13+07:00` include
  `FIREBASE_TOKEN` and `JPSTUDY_RECAPTCHA_SITE_KEY`, but not
  `JPSTUDY_SENTRY_DSN`.
- Sentry readiness CLI rechecked on `2026-05-17T09:13+07:00` with
  `npm run report:sentry-readiness -- --json`: source wiring and workflow smoke
  gate are present, repo secrets metadata is readable, no event was sent, and
  readiness remains `false` with reason `sentry-dsn-missing`.

Required setup:

- Create/choose a Sentry Flutter or JavaScript project.
- Set `JPSTUDY_SENTRY_DSN` as a GitHub Actions secret, or pass it only through
  a local `--dart-define` for a non-public test build.
- Keep `sendDefaultPii=false` and consent/sign-in gate behavior unchanged.
- For an intentional smoke event, build with
  `--dart-define=JPSTUDY_SENTRY_SMOKE_EVENT=true`, then open
  `https://jpstudy.web.app/?sentry-smoke=1`. The smoke trigger is disabled
  unless both the build flag and URL query parameter are present.

Evidence to record:

- Build or CI run URL showing `JPSTUDY_SENTRY_DSN` was supplied without
  revealing the value.
- Sentry issue URL for the intentional `JpStudy Sentry smoke event` exception.
- Confirmation the event includes release/environment context and no learner
  prompt, answer, name, or free-text content.

## 3. Firebase Storage Migration Proof

Goal: deferred for beta. Firebase Storage remains scaffolded but disabled.
Do not enable automatic migration during the Spark/local-first beta.

Current status:

- Owner decision on `2026-05-17`: beta will not use Firebase Storage because
  new Storage buckets require Blaze and `jpstudy-v2` stays on Spark.
- Cloud backup UI is gated off by default; local file export/import remains
  the beta backup story.
- Legacy Storage migration stays gated by
  `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=false` / unset.

Future setup, only if cloud sync returns:

- Confirm/upgrade billing plan first. `jpstudy-v2` is currently documented as
  Spark, while Firebase currently requires Blaze to use Cloud Storage for
  Firebase:
  `https://firebase.google.com/docs/storage/web/start`.
- Create/provision Firebase Storage for project `jpstudy-v2`.
- Deploy `storage.rules`.
- Configure CORS for the web app origin with `storage.cors.json`.
- Keep `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=false` until proof passes.

Evidence to record:

- Not required for beta.
- Current beta evidence is `storage-descoped-for-beta` from
  `npm run report:storage-readiness -- --json --skip-emulator`.
- If reintroduced later, record:
- Storage bucket name and console URL.
- Rules deploy command output.
- CORS config command output or console proof from `storage.cors.json`.
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
- Completed `docs/compliance/legal-approval-checklist.md` review.
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
- Readiness report output:
  `npm run report:deletion-readiness -- --uid "<firebase-uid>"`.
- Auth user deletion result.
- Storage deletion result is out of beta scope; no Storage user data should
  exist while cloud backup/migration are gated off.
- GA4/BigQuery deletion request or documented limitation.
- Verification that the app no longer has an Auth identity for that user and
  cannot associate future GA4 events with that UID.

Current status:

- Audited Firebase Auth deletion helper exists:
  `tool/research/firebase_admin_delete_user.js`.
- Dry-run helper defaults to `safeMode=true`; live Auth deletion requires
  explicit `--execute`.
- Recheck on `2026-05-17T09:13+07:00` removed Storage from beta scope and
  reports deletion readiness `executable=false`. Remaining proof blockers are
  missing test Support ID/Firebase UID, GA4 Admin deletion access, and
  `gcloud` or equivalent operator proof path.

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
- Codex rechecked the source-verifiable path on `2026-05-17T07:13+07:00`.
  The GA4 Admin probe still returns `403` because the Admin API is disabled,
  and the service account also receives `403 PERMISSION_DENIED` from Service
  Usage when checking that API state. Owner Console/API action is still needed.

## 7. GA4 Learning Event Export Proof

Goal: prove the three North Star learning event families are present in the
source-verifiable GA4 BigQuery export.

Current status:

- Live client emission is proven by Playwright network capture, latest recheck
  `2026-05-16T17:17+07:00`:
  - `srs_review_completed`: `22` batched vocab review rows, GA responses `204`.
  - `n5_micro_quiz_completed`: GA response `204`; latest quiz-pass params
    `correct_count=10`, `total_count=10`, `accuracy=1.0`.
  - `session_quality_rated`: GA response `204`; params `mode=test`,
    `rating=5`.
- Export ingestion landed. Recheck on `2026-05-17T08:28+07:00` found daily
  tables `analytics_536663906.events_20260514`,
  `analytics_536663906.events_20260515`, and
  `analytics_536663906.events_20260516`. Exported learning counts include
  `srs_review_completed=69`, `n5_micro_quiz_completed=3`, and
  `session_quality_rated=2`.
- North Star export sample now has `observedUsers=5`, `reviewGatePasses=1`,
  `quizGatePasses=1`, `qualityGatePasses=1`, and `qualifiedUsers=1`.
- The export report query now scores the quiz gate from the app's actual
  telemetry params: `score`, or `accuracy * 100`, or
  `correct_count / total_count * 100`.

Evidence recorded:

- `npm run report:ga4-export -- --json`.
- `eventCounts` includes all three learning-event families.
- `northStar.reviewGatePasses` can count the 20-review SRS gate.
- `northStar.qualifiedUsers=1` in the first source-verifiable sample.

## 8. App Check Enforcement Proof

Goal: enforce App Check only after legitimate web traffic has been monitored.

Timing:

- Wait 1-2 weeks of monitoring after beta traffic begins.

Evidence to record:

- App Check monitoring screenshot/summary before enforcement.
- Enforcement change date.
- Post-enforcement smoke: Auth and Analytics still work on
  `https://jpstudy.web.app`; Storage backup/migration are outside beta scope.

## Update Locations After Proof

After each proof, update:

- `docs/research/mission-completion-audit-2026-05-15.md`
- `docs/research/README.md`
- The relevant `docs/research/D8-compliance/Q8.*-raw-output.md`
- `docs/research/surprise-journal.md` if the result changes a belief by more
  than 20%.
