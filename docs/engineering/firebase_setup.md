# Firebase Setup & Project Swapping Guide

This template is **Firebase‑ready** but not tied to a permanent project. This guide explains:

- how to wire it to a Firebase project for local/dev testing, and  
- how to swap to a different Firebase project when starting a new app.

The goal is: you can prove Crashlytics / Messaging etc. work once, and every future app can
re‑point the template to its own Firebase project with a few commands.

## Important (template demo Firebase)

This repo currently includes Firebase configuration (`lib/firebase_options.dart` and
`android/app/google-services.json`) for a **demo Firebase project used only for this template**.

- This is not production configuration.
- When you clone this repo for a real app, you should run `flutterfire configure` and replace these
  files so your app points to your own Firebase project.

---

## 1. Prerequisites

- Flutter installed (managed via FVM in this repo).
- Firebase CLI + FlutterFire CLI:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Make sure `flutterfire` is on your PATH (or call it via `dart pub global run flutterfire_cli`).

---

## 2. Flavor‑aware Android IDs

Android flavors are defined in `android/app/build.gradle.kts`:

- Application IDs (recommended mapping):
  - `dev`     → `com.yourcompany.yourapp.dev`
  - `staging` → `com.yourcompany.yourapp.staging`
  - `prod`    → `com.yourcompany.yourapp`

For **minimal setup**, you can start by wiring only the `dev` flavor. Real apps can later configure
`staging` and `prod` as separate Firebase apps if needed.

---

## 3. One‑time Firebase wiring for this template

These steps make the template talk to *some* Firebase project so you can verify the integration.
Later apps will repeat the same steps with their own projects.

### 3.1 Create a Firebase project

1. Go to Firebase Console and create a project, e.g. `mobile-core-kit-template-dev`.
2. Enable:
   - Crashlytics (optional but recommended)
   - Cloud Messaging (optional)

### 3.2 Configure Android (dev flavor)

1. In Firebase Console, add an **Android app** with:
   - Package name: `com.yourcompany.yourapp.dev`
   - App nickname: e.g. `corekit_dev`
2. Download the generated `google-services.json` and place it at:
   - `android/app/google-services.json` (the default spot works with flavors).
3. Add the Google services Gradle plugin if you haven’t already (follow FlutterFire docs). In most
   Flutter projects, `flutterfire configure` will handle this.

### 3.3 Run FlutterFire configure

From the project root (`mobile-core-kit/`):

```bash
flutterfire configure
```

and follow the prompts (select your Firebase project and platforms).  
If you want to skip the prompts, you can use the explicit form:

```bash
flutterfire configure \
  --project <your-firebase-project-id> \
  --android-package-name com.yourcompany.yourapp.dev
```

Both do the same thing; the flags just make the command non‑interactive.

`flutterfire configure` will:

- Generate `lib/firebase_options.dart` with `DefaultFirebaseOptions.currentPlatform`.
- Update Android/iOS projects as needed.

### 3.4 Wire entrypoints to `firebase_options.dart`

This template initializes Firebase in `bootstrapLocator()` (`lib/core/di/service_locator.dart`)
using the generated options:

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

In other words, you typically **do not** need to touch `main_{env}.dart` for Firebase initialization
unless your app requires multi-app initialization or non-default naming.

---

## 4. Swapping to a different Firebase project (per‑app)

When you spin up a **new product app** from this template, you should point it to a different
Firebase project.

For each new app:

1. **Create a project** in Firebase Console (e.g. `my-product-dev`).
2. Decide your application IDs / bundle IDs (ideally update them from `com.example.*` to your org).
3. From the app’s cloned repo, run (from project root):

   ```bash
   flutterfire configure \
     --project <new-firebase-project-id> \
     --android-package-name <your.dev.applicationId> \
     --ios-bundle-id <your.dev.bundleId>
   ```

4. This will overwrite:
   - `lib/firebase_options.dart`
   - platform config (Gradle/Xcode) and link to the new project.
5. Commit the updated `firebase_options.dart` and any platform config changes you want to keep.

If you want **separate Firebase apps per flavor** (`dev`, `staging`, `prod`), you can:

- Register three apps in Firebase (one per `applicationId`), and
- Either:
  - Use multi‑app initialization in code (`Firebase.initializeApp(name: ..., options: ...)` and
    pick by `BuildConfig.env`), or
  - Keep using a single app for all flavors during development and only split in production.

For this template, a **single dev app** is sufficient to prove out the wiring.

---

## 5. What is committed vs ignored

Recommended pattern for this repo:

- **Committed**:
  - `lib/firebase_options.dart` (generated by `flutterfire configure`).
  - Any Gradle/Xcode changes required by FlutterFire.
- **Ignored** (depending on your policy; adjust `.gitignore` as needed):
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

Each team can adapt this to their security/compliance rules. The template code itself does not
assume those files are committed.

---

## 6. Running with flavors

Once wired, you can run:

```bash
fvm flutter run \
  -t lib/main_dev.dart \
  --flavor dev \
  --dart-define=ENV=dev
```

Crashlytics collection is enabled only when:

- `BuildConfig.env == BuildEnv.prod`, **and**
- `Firebase.initializeApp()` succeeded.

For local dev, you can still see non‑fatal logs in the Firebase Console after forcing a crash when
Crashlytics is enabled.
