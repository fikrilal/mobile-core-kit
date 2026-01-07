# Google Sign-In (Firebase ID token → backend exchange)

This template’s Google login flow is:

1. Google Sign-In (device) → FirebaseAuth
2. Obtain a **Firebase ID token**
3. Exchange it with the backend: `POST /v1/auth/google` `{ "idToken": "..." }`

The backend is the source of truth for sessions/tokens.

---

## Android requirement: `serverClientId` (google_sign_in v7)

`google_sign_in` v7 on Android uses Credential Manager and **requires** a server client ID.

This template uses **only** `android/app/google-services.json` as the source of truth.

Verify `android/app/google-services.json` includes an OAuth client with `client_type: 3` (Web).
The Google Services Gradle plugin will generate `default_web_client_id`, and the plugin auto-reads it.

Important: rebuild the app after replacing `google-services.json` (hot reload is not enough).

---

## Getting the Web client ID

Use the **Web OAuth client ID** from the same Firebase project the backend verifies (`FIREBASE_PROJECT_ID`).

Common places to find it:

- Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration
- Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client IDs (Web client)

---

## Firebase project prerequisites (high level)

- Enable Google as a Sign-in provider in Firebase Authentication.
- Android: register your package names (including flavor suffixes) and add SHA-1/SHA-256 fingerprints.
- iOS: run `flutterfire configure` and ensure `GoogleService-Info.plist` + URL schemes are correct.

See `docs/engineering/firebase_setup.md` for the full Firebase wiring guide.
