# Firebase Security Checklist

## Storage Rules

- Beta status: Firebase Storage cloud backup and legacy migration are disabled
  while `jpstudy-v2` stays on Spark. Keep this scaffolding for a future
  cloud-sync rebuild; do not enable it until a bucket is provisioned and the
  feature flag is intentionally turned on.
- Deploy `storage.rules` before enabling cloud backup in production.
- Apply `storage.cors.json` to the provisioned Firebase Storage bucket before
  browser upload/download proof.
- User backups are restricted to `users/{uid}/backup.json`.
- Anonymous bootstrap migration snapshots are restricted to
  `users/{uid}/legacy_migration.json`.
- Reads, writes, and deletes require Firebase Auth and matching `request.auth.uid`.
- Writes are limited to JSON payloads up to 5 MiB.
- All other Storage paths are denied by default.

After the bucket exists, apply and verify CORS:

```powershell
gcloud storage buckets update gs://<firebase-storage-bucket> --cors-file=storage.cors.json
gcloud storage buckets describe gs://<firebase-storage-bucket> --format="json(cors_config)"
```

Current checked-in CORS origin is the primary production app:
`https://jpstudy.web.app`.

## App Check

- Enable Firebase App Check in the Firebase Console for Storage.
- Web: register reCAPTCHA Enterprise or reCAPTCHA v3 provider.
- Android: register Play Integrity provider.
- iOS: register App Attest provider, DeviceCheck fallback if needed.
- Start in monitoring mode, verify legitimate traffic, then enforce for Storage.
- App includes `firebase_app_check`; Android uses Play Integrity and iOS uses App Attest with DeviceCheck fallback.
- Web App Check activates only when `JPSTUDY_RECAPTCHA_SITE_KEY` is provided at build time.

```sh
flutter build web --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=your_site_key
```

## Auth Hardening

- Enable email verification if email/password sign-in is public.
- The app sends a verification email after unverified email/password sign-in.
- Future cloud backup upload/download must stay blocked until `emailVerified`
  is true.
- Firebase Storage backup deletion is not a beta control because no beta
  Storage data is created.
- Enable Firebase Auth password policy.
- Review Google sign-in authorized domains and OAuth clients.
- In the production Firebase project, remove `localhost` from Auth authorized domains unless a time-boxed dev exception is documented.
- Production Auth authorized domains should include only the deployed app origins and Firebase-required project domains, for example:
  - `jpstudy-v2.firebaseapp.com`
  - `jpstudy.web.app`
- If local Auth testing is needed, prefer a separate dev Firebase project instead of re-adding `localhost` to production.
- Monitor failed sign-in spikes and Firebase quota errors.

## API Key Restrictions

- Keep the web Firebase API key restricted by HTTP referrer in Google Cloud Console.
- Allowed web referrers should include production Firebase Hosting origins only:
  - `https://jpstudy.web.app/*`
- Re-run this non-mutating probe before public launch and after key rotation:

```powershell
$apiKey = '<web-api-key>'
$headers = @{
  Origin = 'https://evil.example'
  Referer = 'https://evil.example/probe'
  'Content-Type' = 'application/json'
}
Invoke-WebRequest `
  -Uri "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$apiKey" `
  -Method Post `
  -Headers $headers `
  -Body '{}' `
  -UseBasicParsing
```

- Expected result: `403` with `API_KEY_HTTP_REFERRER_BLOCKED`.
- Do not treat API-key referrer restrictions as a substitute for App Check, Auth domain review, Storage rules, quotas, or monitoring.

## Abuse / DDOS Boundary

- Client code cannot provide true DDOS protection.
- Use Firebase quotas, App Check enforcement, and Google Cloud/Firebase monitoring.
- Put any future custom API behind server-side auth checks and per-user/IP rate limits.

## Hosting Headers

- Firebase Hosting sets baseline browser hardening headers: `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, and `Permissions-Policy` for the primary Hosting target in `firebase.json`.
- The current CSP allows Flutter web, Firebase/Auth/API calls, Google Analytics/Tag Manager, Google sign-in, and font/image sources needed by the app. Keep `frame-ancestors 'none'`.
- When adding a new external API, font, CDN, model endpoint, or auth provider, update `firebase.json` CSP explicitly and verify against the primary Hosting target.
- Verify after deploy with:

```sh
curl -I https://jpstudy.web.app
```

## Deploy

```sh
npm run test:storage-rules
firebase deploy --only storage
firebase deploy --only hosting:jpstudy
curl -I https://jpstudy.web.app
curl -I "https://jpstudy-v2.web.app/?legacy-disabled-check=1"
```

The legacy default Hosting site `jpstudy-v2` cannot be deleted because Firebase
marks it as the default site, but it must stay disabled. Do not use
`firebase deploy --only hosting`, because that can deploy every configured
Hosting target if local target drift is reintroduced.

## CI

- GitHub Actions runs UI string guard, `flutter analyze`, `flutter test`, a release-like web build, the D7 web performance budget report, `npm ci`, and `npm run test:storage-rules`.
- On push to `main`, the `deploy-hosting` job deploys only `hosting:jpstudy` when `FIREBASE_TOKEN` and `JPSTUDY_RECAPTCHA_SITE_KEY` repository secrets are present.
- The deploy job verifies primary Hosting returns `200`, the disabled legacy site returns `404`, runs live web resource smoke, and runs a Lighthouse live gate.
- If the required deploy secrets are missing, the job skips deploy with a warning so normal CI remains green.
- Branch protection and explicit failure notifications are not yet proven from repository files.
