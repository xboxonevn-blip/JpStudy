# Shipping JpStudy

## Web (Firebase Hosting)

Prerequisites: `firebase login` already done.
Required launch secret: `JPSTUDY_RECAPTCHA_SITE_KEY` for web App Check.

1. One-time init (skip if firebase.json already has "hosting" section):
   firebase init hosting
   - Select existing project: jpstudy-v2
   - Public directory: build/web
   - Single-page app: Yes
   - Set up automatic builds with GitHub: No

2. Preflight:
   flutter analyze
   flutter test
   npm run test:storage-rules

3. Build with web App Check enabled:
   flutter build web --release --base-href=/ --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=$JPSTUDY_RECAPTCHA_SITE_KEY

   PowerShell:
   flutter build web --release --base-href=/ --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=$env:JPSTUDY_RECAPTCHA_SITE_KEY

4. Deploy the primary Hosting target:
   firebase deploy --only hosting:jpstudy

Result: app available at https://jpstudy.web.app

Post-deploy checks:
- curl -I https://jpstudy.web.app
- Confirm Content-Security-Policy, X-Frame-Options, Referrer-Policy, and Permissions-Policy headers.
- Re-run route smoke and performance smoke against the deployed URL.
- Confirm Firebase Auth, Storage backup, App Check telemetry, and Analytics DebugView.

## Android APK (direct distribution)

Prerequisites: signing keystore at android/app/release.keystore
with password configured in android/key.properties (gitignored).

1. Build:
   flutter build apk --release --split-per-abi

2. APKs land at build/app/outputs/flutter-apk/.
   Upload to GitHub Releases via:
   gh release create v1.0.0 build/app/outputs/flutter-apk/*.apk \
     --title "v1.0.0" --notes "First public release"

## Smoke test before sharing the URL

- Sign in with Google works
- Sign in with email/password works
- Learn session completes -> auto-upload writes to Firebase Storage
- Backup downloads on a different browser session
