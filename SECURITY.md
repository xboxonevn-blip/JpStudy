# Security

## Firebase Web API key restrictions

The Firebase Web API key is safe to ship in the web bundle only when Google Cloud API key restrictions are enabled.

For production, restrict the Web API key in Google Cloud Console:

1. Open Google Cloud Console > APIs & Services > Credentials.
2. Select the Browser/Web API key used by `lib/firebase_options.dart` for project `jpstudy-v2`.
3. Under Application restrictions, choose HTTP referrers.
4. Allow only these referrers:
   - `https://jpstudy-v2.web.app/*`
   - `https://jpstudy-v2.firebaseapp.com/*`
5. Under API restrictions, restrict the key to the Firebase/Google APIs used by the app.
6. Save, then verify sign-in and cloud sync on both hosting domains.

Do not allow wildcard domains beyond the Firebase Hosting origins above for production.

## Firebase Auth authorized domains

Production Firebase Auth authorized domains should include only deployed production/staging domains. Remove `localhost` from the production project before broad sharing; use a separate development Firebase project for local web auth testing.

Production checklist:

1. Open Firebase Console > Authentication > Settings > Authorized domains for project `jpstudy-v2`.
2. Keep only deployed app domains needed for production sign-in:
   - `jpstudy-v2.web.app`
   - `jpstudy-v2.firebaseapp.com`
3. Remove `localhost` and any temporary preview domains from the production Firebase project.
4. Save changes.
5. Verify Google/email sign-in on:
   - `https://jpstudy-v2.web.app`
   - `https://jpstudy-v2.firebaseapp.com`
6. For local development, use a separate Firebase project that still allows `localhost`.

Do not re-add `localhost` to the production project for debugging; switch the local build to the development Firebase config instead.

