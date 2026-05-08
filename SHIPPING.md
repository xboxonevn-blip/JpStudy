# Shipping JpStudy

## Web (Firebase Hosting)

Prerequisites: `firebase login` already done.

1. One-time init (skip if firebase.json already has "hosting" section):
   firebase init hosting
   - Select existing project: jpstudy-v2
   - Public directory: build/web
   - Single-page app: Yes
   - Set up automatic builds with GitHub: No

2. Build:
   flutter build web --release --base-href=/

3. Deploy:
   firebase deploy --only hosting

Result: app available at https://jpstudy-v2.web.app

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
