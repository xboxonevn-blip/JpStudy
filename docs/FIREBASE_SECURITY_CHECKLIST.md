# Firebase Security Checklist

## Storage Rules

- Deploy `storage.rules` before enabling cloud backup in production.
- User backups are restricted to `users/{uid}/backup.json`.
- Reads, writes, and deletes require Firebase Auth and matching `request.auth.uid`.
- Writes are limited to JSON payloads up to 5 MiB.
- All other Storage paths are denied by default.

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
- Cloud backup upload/download is blocked until `emailVerified` is true.
- Users can delete their Firebase Storage cloud backup from Data controls.
- Enable Firebase Auth password policy.
- Review Google sign-in authorized domains and OAuth clients.
- In the production Firebase project, remove `localhost` from Auth authorized domains unless a time-boxed dev exception is documented.
- Production Auth authorized domains should include only the deployed app origins and Firebase-required project domains, for example:
  - `jpstudy-v2.firebaseapp.com`
  - `jpstudy-v2.web.app`
  - `jpstudy.web.app`
- If local Auth testing is needed, prefer a separate dev Firebase project instead of re-adding `localhost` to production.
- Monitor failed sign-in spikes and Firebase quota errors.

## API Key Restrictions

- Keep the web Firebase API key restricted by HTTP referrer in Google Cloud Console.
- Allowed web referrers should include production Firebase Hosting origins only:
  - `https://jpstudy-v2.web.app/*`
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

- Firebase Hosting sets baseline browser hardening headers: `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, and `Permissions-Policy` for both Hosting targets in `firebase.json`.
- The current CSP allows Flutter web, Firebase/Auth/API calls, Google Analytics/Tag Manager, Google sign-in, and font/image sources needed by the app. Keep `frame-ancestors 'none'`.
- When adding a new external API, font, CDN, model endpoint, or auth provider, update `firebase.json` CSP explicitly and verify against both Hosting targets.
- Verify after deploy with:

```sh
curl -I https://jpstudy-v2.web.app
curl -I https://jpstudy.web.app
```

## Deploy

```sh
npm run test:storage-rules
firebase deploy --only storage
firebase deploy --only hosting
```

## CI

- GitHub Actions runs UI string guard, `flutter analyze`, `flutter test`, a release-like web build, the D7 web performance budget report, `npm ci`, and `npm run test:storage-rules`.
- Live post-deploy smoke, Lighthouse, branch protection, and failure notifications are not yet proven from repository files.
