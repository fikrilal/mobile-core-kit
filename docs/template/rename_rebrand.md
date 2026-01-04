# Rename & Rebrand (Template Customization)

When cloning this template into a real app, you should update identifiers and branding early to avoid:
- mismatched Android `namespace` vs `applicationId`,
- wrong iOS bundle identifiers,
- Firebase/app links/auth redirect misconfiguration.

## 1) Choose Your Identifiers

Pick a base identifier for your app, for example:

- Android `applicationId`: `com.yourcompany.yourapp`
- iOS bundle id: `com.yourcompany.yourapp`

Then decide flavor identifiers:

- `dev`: `com.yourcompany.yourapp.dev`
- `staging`: `com.yourcompany.yourapp.staging`
- `prod`: `com.yourcompany.yourapp`

## 2) Android (Gradle + Manifest)

1. Update `applicationId` + flavor suffixes:
   - `android/app/build.gradle.kts`
     - `defaultConfig.applicationId`
     - `productFlavors.*.applicationIdSuffix` (dev/staging)

2. Update the Kotlin/Java package namespace:
   - `android/app/build.gradle.kts` → `android.namespace`
   - Then move code under:
     - `android/app/src/main/kotlin/<your/package>/...` or `android/app/src/main/java/<your/package>/...`

3. Update the app label (launcher name):
   - `android/app/src/main/AndroidManifest.xml` → `android:label`

## 3) iOS (Bundle Identifier + Display Name)

1. Update bundle identifiers:
   - `ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`

2. Update display name:
   - `ios/Runner/Info.plist` (typically `CFBundleDisplayName`)

If you maintain separate iOS flavors/schemes, ensure each scheme has its own bundle id and Firebase config.

## 4) Firebase (Required if you use Firebase)

After changing app identifiers, reconfigure Firebase:

- Run `flutterfire configure` (see `docs/engineering/firebase_setup.md`).
- Replace:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist` (if used)

## 5) Deep Links / Universal Links

If you use deep links:

- Update the allowlist and domains as documented in `docs/template/deep_linking.md`.
- If you change domains, update Android intent filters and iOS associated domains accordingly.

## 6) Branding Assets

- Native splash: `flutter_native_splash` config in `pubspec.yaml`
- App icons: update launcher icons per platform
- In-app title: `lib/app.dart` → `MaterialApp.router(title: ...)`

