# Android CI/CD — mobile-core-kit

This document describes the recommended Android release pipeline for `mobile-core-kit` when using
GitHub Actions and Google Play. The reference workflow lives at
`.github/workflows/android.yml`.

The goal is to have a repeatable, environment‑aware build that:

- Runs tests on every push to `main`.
- Builds a production app bundle for the `prod` flavor.
- Uploads the `.aab` as an artifact.
- Optionally pushes the bundle to Google Play **as a draft** so you can review and roll out from
  the Play Console.

---

## 1. Workflow Overview

- **Runner**: `ubuntu-latest`.
- **Tooling**:
  - `subosito/flutter-action` (Flutter stable).
  - `actions/setup-java` (Temurin 21).
  - Gradle + Android tooling (no Mac required).
- **Flavors**:
  - `dev`, `staging`, `prod` defined in `android/app/build.gradle.kts` (dimension `env`).
- **Entry point**:
  - `lib/main_prod.dart` for the production flavor.
  - `ENV` is set via `--dart-define=ENV=prod` and wired into `BuildConfig`.

High‑level steps in `android.yml`:

1. Checkout repository.
2. Restore `.env/dev|staging|prod.yaml` from secrets with lane-aware behavior:
   - `pull_request`: missing secret falls back to committed file (warning).
   - non-PR lanes (`push` to `main`, `workflow_dispatch`): missing secret fails the job.
3. Restore `android/app/google-services.json` from secret (or fail if missing).
4. Run environment schema validation (`tool/verify_env_schema.dart`) as part of canonical verify.
5. Setup Flutter + Java (Temurin 21) and cache pub/Gradle.
6. Run `flutter pub get`.
7. Generate `build_config_values.dart` for `prod` via `dart run tool/gen_config.dart --env prod`.
8. Run `flutter test`.
9. Optionally materialize the upload keystore and Play service-account credentials.
10. Build the prod app bundle:
   ```bash
   flutter build appbundle \
     --release \
     --flavor prod \
     -t lib/main_prod.dart \
     --dart-define=ENV=prod
   ```
11. Upload the `app-prod-release.aab` as a GitHub Actions artifact.
12. (Optional, commented out) Publish to the Play internal track using Gradle Play Publisher (GPP).

> Template author note: In my Orymu project I pushed builds to Google Play as **draft** and always
> did the final review/rollout manually from the Play Console. The publish step in this template is
> intentionally commented out so you get the same behavior by default.

---

## 2. Required Secrets

Configure repository secrets under **Settings ▸ Secrets and variables ▸ Actions**.

**Keystore & signing**

- `ANDROID_KEYSTORE_BASE64`  
  Base64‑encoded upload keystore. Example (Linux/macOS):
  ```bash
  base64 -w0 upload-key.jks > upload-key.b64
  ```
  Copy the single‑line contents into the secret.

- `ANDROID_KEYSTORE_PASSWORD`  
  Keystore password (`-storepass` when creating the keystore).

- `ANDROID_KEY_ALIAS`  
  Alias used when generating the key (`-alias`).

- `ANDROID_KEY_PASSWORD`  
  Key password (`-keypass`). Often the same as the store password.

> Note: The template Gradle config still uses the debug signing config. Once you’re ready, wire the
> keystore into `android/app/build.gradle.kts` and use the secrets above.

**Firebase / Google services**

- `ANDROID_GOOGLE_SERVICES_JSON`  
  Full contents of `android/app/google-services.json` for your Firebase project. Paste the raw JSON
  into the secret (multi‑line supported). If you prefer to keep the file in Git, leave this secret
  empty and commit the JSON instead.

**Env YAML overrides**

The template reads environment config from `.env/*.yaml`. To keep secrets out of Git you can
override those files at runtime:

- `ENV_DEV_YAML` → writes `.env/dev.yaml`
- `ENV_STAGING_YAML` → writes `.env/staging.yaml`
- `ENV_PROD_YAML` → writes `.env/prod.yaml`
Behavior is lane-aware:

- `pull_request`: missing secret falls back to committed `.env/*.yaml` with a warning.
- non-PR lanes (`push` to `main`, `workflow_dispatch`): missing secret fails in strict mode.

In all lanes, resolved `.env/*.yaml` files must exist and be non-empty after restore.

## 2.1 Env Config Integrity Policy

| Lane | Missing `ENV_*_YAML` secret | Outcome |
|---|---|---|
| `pull_request` | Allowed | Warning + fallback to committed `.env/*.yaml` |
| `push` to `main` | Not allowed | Job fails (`strict env mode`) |
| `workflow_dispatch` | Not allowed | Job fails (`strict env mode`) |

This policy removes silent fallback risk in release-capable lanes.

## 2.2 Environment Schema Validation

Canonical verification now runs:

```bash
dart run tool/verify_env_schema.dart --all
```

When running production verification (`tool/verify.dart --env prod`), strict production invariants are enforced:

```bash
dart run tool/verify_env_schema.dart --all --strict
```

Validator location: `tool/verify_env_schema.dart`.

Required keys validated for each environment:

- URLs: `core`, `auth`, `profile` (absolute `http/https` URLs)
- Booleans: `enableLogging`, `reminderExperiment`, `analyticsEnabledDefault`, `analyticsDebugLoggingEnabled`, `netLogRedact`
- Integers: `netLogBodyLimitBytes`, `netLogLargeThresholdBytes`, `netLogSlowMs` (must be `> 0`)
- Enum-like string: `netLogMode` (`off | summary | smallBodies | full`)
- String: `googleOidcServerClientId`
- Host list: `deepLinkAllowedHosts` (non-empty, hostnames only)

Strict production invariants (`--strict`, prod):

- `enableLogging: false`
- `analyticsDebugLoggingEnabled: false`
- `netLogRedact: true`
- `netLogMode: off`

**Play Console (optional, for publishing)**

- `PLAY_STORE_JSON`  
  Raw contents of the Play Developer API service‑account JSON. Create a service account with at
  least the **Release Manager** role, grant it access to your app in Play Console ▸ **Setup ▸ API
  access**, then create a JSON key and paste its contents into this secret.

The workflow writes this JSON to `PLAY_CONFIG_PATH` (`/tmp/play-credentials.json` by default) if
the secret is present.

---

## 3. Gradle Play Publisher (Optional)

The template workflow includes a commented‑out step that calls:

```bash
./gradlew :app:publishProdReleaseBundle \
  -Ptarget=lib/main_prod.dart \
  -Pdart-defines=$DART_DEFINES \
  --release-status $PLAY_RELEASE_STATUS
```

To use it:

1. Add the Gradle Play Publisher plugin to your Android build (top‑level `build.gradle` and
   `android/app/build.gradle.kts`).
2. Configure the `play {}` block to point to `PLAY_CONFIG_PATH` and the `prod` flavor.
3. Set:
   ```yaml
   env:
     PLAY_TRACK: internal
     PLAY_RELEASE_STATUS: draft
   ```
4. Uncomment the publish step in `.github/workflows/android.yml`.

Recommended settings:

- Keep `PLAY_RELEASE_STATUS=draft` so every CI upload lands as a draft in Play.
- Promote/release manually from the Play Console once you’ve reviewed the build.

---

## 4. First Upload Requirement

For a brand‑new package name, Google Play still requires the very first `.aab` to be uploaded
manually via the Play Console. After that:

- CI can upload new versions to the internal (or other) track.
- You can promote from internal → closed → production within Play without re‑uploading.

---

## 5. Operational Tips

- **Manual review first**  
  Even after enabling GPP, it’s usually safer to keep CI uploads as draft and manually control when
  a version goes live.

- **Managed publishing**  
  Enabling Managed publishing in Play Console gives you another layer of control over when releases
  are visible to users.

- **Feature branches**  
  Use the `workflow_dispatch` trigger from feature branches to test changes to the workflow itself
  without impacting `main`.

- **Artifacts as build output**  
  Each run uploads the prod AAB as `appbundle-prod-release`. You can download it from the Actions
  UI for manual sideloading or for QA before Play submission.

- **Secret rotation**  
  Rotate the upload key only if compromised. If you do rotate it, update the Play Console and the
  GitHub secrets in sync.

This pipeline is deliberately conservative: it guarantees a reproducible prod build and an artifact
on every run, but leaves the final “push to users” step in your hands. Enable the publish step only
when you’re confident in the process and comfortable with CI owning uploads. 

## 6. Troubleshooting Env Validation Failures

- **Missing secret in strict mode**
  - Symptom: `Secret for .env/<env>.yaml not provided and strict env mode is enabled.`
  - Fix: add/update the corresponding `ENV_<ENV>_YAML` secret.

- **Resolved env file empty**
  - Symptom: `.env/<env>.yaml is missing or empty after restore.`
  - Fix: ensure the secret payload is valid YAML and non-empty.

- **Schema error**
  - Symptom: `Environment schema validation failed` with key/type details.
  - Fix: update `.env/*.yaml` or secret payload to satisfy required keys/types.

- **Strict prod invariant violation**
  - Symptom: strict-mode failure for logging/analytics/network logging settings.
  - Fix: align `.env/prod.yaml` values with production policy.
