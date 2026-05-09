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
- Monitor failed sign-in spikes and Firebase quota errors.

## Abuse / DDOS Boundary

- Client code cannot provide true DDOS protection.
- Use Firebase quotas, App Check enforcement, and Google Cloud/Firebase monitoring.
- Put any future custom API behind server-side auth checks and per-user/IP rate limits.

## Hosting Headers

- Firebase Hosting sets baseline browser hardening headers: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, and `Permissions-Policy`.
- A strict Content-Security-Policy is intentionally not enabled yet because Flutter web, Firebase Auth, App Check, and future model/CDN endpoints need explicit allowlists.
- Verify after deploy with:

```sh
curl -I https://jpstudy-v2.web.app
```

## Deploy

```sh
npm run test:storage-rules
firebase deploy --only storage
firebase deploy --only hosting
```

## CI

- GitHub Actions runs `npm ci` and `npm run test:storage-rules` in the `firebase-security-rules` job.
