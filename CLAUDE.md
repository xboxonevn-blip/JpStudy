# JpStudy v2 — Project Context for Claude / Codex agents

> Source of truth for project infrastructure. Read this FIRST before any
> task that touches deployment, auth, billing, or external services.

## Hosting sites (primary + disabled default)

JpStudy-v2 deploys only to the primary Firebase Hosting site:

| Site target | URL | Purpose |
|---|---|---|
| **`hosting:jpstudy`** | `https://jpstudy.web.app` | **PRIMARY** — only active web Hosting target |
| `hosting:jpstudy-v2` | `https://jpstudy-v2.web.app` | Disabled legacy default site; do not deploy |

Only `hosting:jpstudy` should serve `build/web` artifacts. The legacy default
site `hosting:jpstudy-v2` is disabled and should stay disabled.

Deploy command:
```bash
firebase deploy --only hosting:jpstudy
```

When verifying live behaviour, check `https://jpstudy.web.app` as production.
For hosting or security work, also confirm the disabled legacy URL still
returns `404`. See `SHIPPING.md` for full release flow.

## Firebase / GCP identities

- **Firebase project ID**: `jpstudy-v2`
- **Project number**: `129949648924`
- **GA4 property ID**: `536663906` (account `393943579` "Default Account for Firebase")
- **GCP organization**: `chung-phukiengiabuon-org`
- **Plan**: Spark (no-cost). BigQuery Sandbox 10 GB linked.
- **Web API key** (public, restricted to referrers): `AIzaSyCgerXOA8C9qtjB1yP3oAbsvMAjpFHPSmc`

## Owner / admin accounts

Multiple Google accounts can sign in to the browser. The project owner is
**not** the default `/u/0/` account:

| Google account | Role on `jpstudy-v2` | Chrome `/u/N/` path |
|---|---|---|
| `chung.phukiengiabuon@gmail.com` | **Owner** | `/u/1/` |
| `xboxonevn@gmail.com` | No access | `/u/0/` |
| `chuchanistore@gmail.com` | Unknown | `/u/2/` (likely) |
| `xboxonevn.photo@gmail.com` | Unknown | `/u/3/` (likely) |

Always navigate Firebase / GCP console URLs with `?authuser=1` (or `/u/1/`)
to land on the correct account automatically.

## Test account (manual QA login on web)

- Email: `admin@jpstudy.test`
- Password: `adminadmin`  ← leaked in chat, rotate before launch
- Firebase UID: `iE3tNLHW7tTvTAL7WmSG2JyIovI2`
- Role: normal user, no admin claims.

Do not grant elevated privileges without explicit user request.

## Service accounts

| Service account | Project | Purpose | Roles |
|---|---|---|---|
| `ga4-data-reader@jpstudy-v2.iam.gserviceaccount.com` | `jpstudy-v2` | Read GA4 events from BigQuery for research notebook | BigQuery Data Viewer, BigQuery Job User |
| `firebase-adminsdk-fbsvc@jpstudy-v2.iam.gserviceaccount.com` | `jpstudy-v2` | Default Firebase Admin SDK | (Firebase managed) |

### `ga4-data-reader` key

- JSON key path: `C:\Users\xboxo\.config\gcp\jpstudy-v2-591716a5e835.json`
- Env var: `GOOGLE_APPLICATION_CREDENTIALS` (set permanently for User scope)
- Key ID prefix: `591716a5...`

If key is lost or leaked, rotate at:
https://console.cloud.google.com/iam-admin/serviceaccounts/details/100263708149546336398/keys?authuser=1&project=jpstudy-v2

## Authorized domains (for App Check / Auth)

When configuring reCAPTCHA, Firebase Auth authorized domains, API key
HTTP referrers, etc., always include all four:

1. `jpstudy.web.app` ← PRIMARY production
2. `jpstudy-v2.firebaseapp.com` ← Firebase default Auth domain
3. `localhost` ← local development (consider removing for production
   when separate dev Firebase project is set up)

## Local development

- Codebase root: `C:\Users\xboxo\Documents\GitHub\JpStudy-v2`
- Flutter framework configured for web + android + ios + windows.
- Drift/SQLite local DB for content + SRS.
- Riverpod for state management.
- `shared_preferences` persists user choice across reloads.

### Git workflow policy (mandatory)

**Commit directly to `main`. DO NOT create feature branches.**

This is a solo-dev project. Branching (e.g. `codex/jpstudy-2026-05-15-sprint1`)
adds merge overhead with zero review benefit. Workflow:

```
git checkout main         # ALWAYS work on main
git add <files>           # stage specific files (NOT git add -A)
git commit -m "type(scope): subject"  # Conventional Commits
git push origin main      # push directly
```

Rules:
- One commit = one logical change (still applies)
- Conventional Commits subject ≤ 72 chars
- KHÔNG `git checkout -b <branch>` — Codex/agents must NOT create
  branches without explicit user request
- KHÔNG mega-commit ("update" / "Big Update" / "WIP")
- KHÔNG `git push --force` on main unless rollback explicitly requested
- KHÔNG skip hooks (`--no-verify`)

If sprint contains many commits, push each commit individually OR
push in batch after sprint cluster — both fine, as long as branch
stays `main`.

Rollback strategy without branches: use `git revert <hash>` to
back out a bad commit. Faster than branch-based rollback.

### GitHub Actions log policy

For CI logs/status, use GitHub CLI only:

```bash
gh run view <run-id> --log
gh run view --job <job-id> --log
gh api repos/xboxonevn-blip/JpStudy/actions/runs/<run-id>/...
```

Do not use `git credential fill` to extract a GitHub token into shell variables.
Do not build raw `Invoke-WebRequest`/Bearer-token calls for Actions logs. If
`gh` is missing on a machine, install GitHub CLI first (`winget install
GitHub.cli`) and authenticate with `gh auth login`.

### Required env vars for full build

| Variable | Source | Purpose |
|---|---|---|
| `GOOGLE_APPLICATION_CREDENTIALS` | Set permanently | Codex / tool scripts query BigQuery |
| `JPSTUDY_RECAPTCHA_SITE_KEY` | Set permanently (User scope) | Web App Check via `--dart-define` at build |
| `FIREBASE_TOKEN` | GitHub Actions secret from `firebase login:ci` | CI deploy automation for `hosting:jpstudy` |
| `JPSTUDY_SENTRY_DSN` | Sentry project | Optional web error monitoring via `--dart-define` |
| `JPSTUDY_SENTRY_ENVIRONMENT` | Optional | Sentry environment label, defaults to `production` |
| `JPSTUDY_RELEASE` | Optional | Sentry release label for deploy correlation |
| `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION` | Optional | Set `true` only after Firebase Storage is provisioned and CORS-verified |

## Research notebook + Auto Research mission

Active Karpathy-style Auto Research mission. See `docs/research/`:
- `README.md` — open questions + dimension status
- `north-star-metric.md` — NS definition
- `surprise-journal.md` — belief shifts log
- `mental-models.md` — appended-only "why it works"
- `synthesis-2026-05-15.md` — latest phase synthesis
- `mission-completion-audit-2026-05-15.md` — sprint/stop-condition
  evidence map and remaining blockers

Active dimensions:
- D1 (measurement), D2 (content), D3 (Vietnamese), D4 (personas), D5
  (pedagogy), D6 (UI/UX), D7 (performance), D8 (compliance) +
  D8-release-risk.

Active workstream status (as of 2026-05-17):
- Curriculum-gating onboarding Phase 1-13 source work is complete,
  including anonymous Auth bootstrap and legacy migration gating.
- Sprint 1-7 implementation/docs are substantially complete. Do not restart
  completed work without checking `mission-completion-audit-2026-05-15.md`.
- Latest exact source/CI/deploy proof changes with each main commit. Check
  `docs/compliance/beta-launch-proof-checklist-2026-05-15.md` or the current
  GitHub Actions run for the newest run ID. The tracked deploy gate must show
  `ui-string-guard`, `firebase-security-rules`, and secret-backed
  `deploy-hosting` all completed with `success`, including production build,
  primary deploy, primary/legacy smoke, live resource smoke, and Lighthouse
  live gate.
- Latest live route-matrix proof: `558fc151` fixed Flutter web hash-route
  bootstrap by seeding persisted providers before `runApp`. `17100cb1` adds
  `npm run report:live-route-matrix`, and the latest run passed `36/36` N4/N3/N2/N1
  live direct-route checks with no N5 fallback markers across audited hash routes.
- Latest D2 content integrity correction: `f5ff772b` plus
  `D2-spot-check-N3-2026-05-16.md` and
  `D2-spot-check-N1-2026-05-16.md`.
  Current audit reports N5/N4 launch-tier and N3/N2/N1 launch-tier quality
  with user spot-check still pending for the upper-level samples. The latest
  owner spot-check defects fixed duplicated N3 vocab glosses and N1 kanji
  compound-sourced meanings such as `稲`. Machine-draft and open-review counts
  are `0` across all levels. Codex must not add `vi-human-approved`; only the
  user can add that after item-level review.
- Remaining blockers are operational/legal proofs: legal approval,
  Sentry DSN + first issue, first executed deletion proof, GA4 UI retention
  proof, and later App Check enforcement proof. GA4 BigQuery learning-event
  export proof closed on 2026-05-17T08:28+07 with all three learning-event
  families present. Firebase Storage is descoped for beta by owner decision on 2026-05-17
  because new buckets require Blaze and the beta stays Spark/local-first with
  file export/import backup. Keep Storage scaffolding gated for future cloud
  sync; do not require bucket provisioning for beta launch. The local
  `firebase-admin` tooling blocker for Auth deletion is resolved by
  `tool/research/firebase_admin_delete_user.js`; live deletion proof still
  requires GA4/operator gates.
  Latest completion audit: `docs/research/mission-completion-audit-2026-05-17.md`.
  Operator handoff checklist:
  `docs/compliance/beta-launch-proof-checklist-2026-05-15.md`.
  Current readiness reports now include direct operator URLs for launch proof,
  Storage, deletion, GA4 Admin, App Check, and GitHub Actions; these URLs do not
  close proof gates by themselves. Storage reports as
  `storage-descoped-for-beta`, not as a beta blocker.
- Owner-provided study source folders from
  `C:\Users\xboxo\Desktop\PC\Tai lieu N5 den N1 tham khao.txt` are recorded in
  `docs/credits/upper-jlpt-sources.md` as manual QA/reference-only material.
  Do not bulk-copy those materials without explicit licensing/ownership
  clearance, and do not access `https://nhaikanji.com/` per owner note.

## App Check (reCAPTCHA v3)

- Provider: reCAPTCHA v3 (free, ~10k assessments/month).
- Web app `jpstudy (web)`: registered with reCAPTCHA badge ✓ (status
  "Registered").
- reCAPTCHA admin label: `JpStudy Web App Check`
- reCAPTCHA admin URL:
  https://www.google.com/recaptcha/admin/site/753526489/setup
- Domains whitelisted on reCAPTCHA: jpstudy.web.app,
  jpstudy-v2.firebaseapp.com, localhost
- Site key (public): set in `JPSTUDY_RECAPTCHA_SITE_KEY` env var
  (prefix `6LfZ5uks...`)
- Secret key: stored in Firebase App Check config only. NEVER commit or
  log. If leaked, rotate via reCAPTCHA admin → Settings → Generate new.

Build with App Check enabled:
```bash
flutter build web --release \
  --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=$JPSTUDY_RECAPTCHA_SITE_KEY
```

PowerShell:
```powershell
flutter build web --release `
  --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=$env:JPSTUDY_RECAPTCHA_SITE_KEY
```

## Outstanding ops debt (user must do manually)

```
□ Rotate password admin@jpstudy.test (was leaked in chat).
□ Verify "localhost" removed from production Firebase Auth authorized
  domains (per SECURITY.md). Currently kept for dev convenience.
□ Decide whether to migrate to dedicated `jpstudy-v2-dev` Firebase
  project for local dev to retire localhost domain.
□ Register App Check for jpstudy (android), jpstudy (ios), jpstudy
  (windows) — currently only jpstudy (web) registered.
□ Future-only: set up Firebase Storage for `jpstudy-v2` only if cloud backup
  or legacy migration is reintroduced after beta. Current Spark/new-bucket
  state blocks Storage setup from CLI, and Firebase currently requires the
  pay-as-you-go Blaze plan to use Cloud Storage for Firebase. Keep
  `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION` unset/false until billing/location,
  bucket, rules deploy, and CORS preflight are verified.
□ After 1-2 weeks monitoring, switch App Check from monitoring to
  enforce mode for applicable beta Firebase APIs. Storage enforcement is
  future-only unless cloud backup/migration returns.
✓ GitHub Actions secrets `FIREBASE_TOKEN` and
  `JPSTUDY_RECAPTCHA_SITE_KEY` are set; secret-backed deploy is proven.
  Optional: set `JPSTUDY_SENTRY_DSN` for beta error monitoring.
□ Provide/verify Sentry DSN and record a first deployed issue URL before
  claiming production observability.
□ Finalize legal review for `/privacy` and `/terms`; current copy remains
  a review-needed beta draft.
□ Execute one real deletion runbook case and record proof before public launch.
  Auth deletion helper exists at `tool/research/firebase_admin_delete_user.js`;
  it is dry-run by default and requires explicit `--execute` against a
  dedicated test UID.
□ Capture GA4 UI retention proof in Console; BigQuery TTL is source-proven,
  but GA4 UI retention remains manual.
```

## Communication

Primary user is Vietnamese; respond in Vietnamese unless asked otherwise.
Codex commits in English (Conventional Commits format), but UAT docs
and surprise-journal entries are bilingual where helpful.
