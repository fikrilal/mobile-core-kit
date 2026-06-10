# Maestro Testing

Maestro provides black-box proof against a compiled application. It complements
unit, widget, and Flutter integration tests; it does not replace them.

## Supported Baseline

- Android Pixel 8 emulator
- Android API 34, Google APIs, x86_64
- Maestro CLI version from `tool/agent/maestro_version.txt`
- Repo-pinned Flutter SDK through FVM

Install the pinned Maestro version before running the harness. Normal test
execution never downloads or upgrades the CLI.

## Run Evidence

With a connected emulator or device:

```bash
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device emulator-5554 \
  --flavor dev \
  --include-tags smoke
```

Reuse an existing APK when build evidence is not required:

```bash
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device emulator-5554 \
  --flavor dev \
  --app-file build/app/outputs/flutter-apk/app-dev-debug.apk \
  --skip-build
```

The Maestro lane validates Java, Maestro, FVM, ADB, the selected device, environment
configuration, Firebase configuration, and selected flows. It inspects the APK
manifest for the application ID, installs that APK, verifies the installed
package, captures device logs, and passes the inspected ID to Maestro.

Production execution requires `--allow-prod`. The runner always excludes flows
tagged `destructive` or `requires_backend` for production.

## Authenticated Local Journey

The login/logout journey uses a generated backend identity and must run through
its fixture-aware wrapper:

```bash
tool/agent/auth_fixture_evidence_check.sh \
  --flow .maestro/flows/auth/login_logout.yaml \
  --device <medium-phone-device> \
  --flavor dev \
  --app-file build/app/outputs/flutter-apk/app-dev-debug.apk \
  --skip-build
```

The wrapper registers a unique synthetic account, completes its profile,
passes disposable credentials through `MAESTRO_` shell variables, and revokes
all active sessions after success, assertion failure, or interruption. Setup
and cleanup failures are hard failures. Generated secrets are removed from
retained text artifacts before the command returns.

`tool/agent/login_logout_evidence_check.sh` is a convenience wrapper for the
same command with the login/logout flow preselected.

The security and active-sessions journey uses the same fixture lifecycle to
prove authenticated account navigation and API-backed session rendering:

```bash
./mobtrace verify security-sessions \
  --device <medium-phone-device> \
  --flavor dev
```

The Android camera journey captures a frame, accepts it, verifies the complete
profile-image upload, then removes the image:

```bash
./mobtrace verify camera-launch \
  --device <medium-phone-device> \
  --flavor dev
```

Android `image_picker` delegates capture to the system camera intent and does
not require this app to declare CAMERA permission. iOS still requires
`NSCameraUsageDescription` and retains its native permission-denial handling.
The fixture trap also clears and verifies profile-image state if the flow fails
after upload but before UI cleanup.

This journey currently uses the Medium Phone API 35 emulator as secondary
authenticated evidence. It does not replace the API 34 baseline above.

## Artifacts

Evidence is written under `_artifacts/mobile/<timestamp>/`:

```text
metadata.txt
status.env
summary.md
maestro/
  artifacts/
  command.txt
  device.log
  junit.xml
  maestro.log
  runner.log
```

Artifacts are retained on success and failure. They are ignored by Git. Review
screenshots and logs for credentials or personal data before sharing them.

## Authoring Rules

- Add or update a flow only for a critical cross-screen user journey.
- Implement lower-level behavior tests first.
- Use stable semantic identifiers while preserving screen-reader labels.
- Inspect selectors on the compiled app's accessibility tree.
- Do not use coordinates, fixed sleeps, broad retries, or retry loops that hide
  regressions.
- Keep reusable setup in `.maestro/subflows/` and top-level journeys in
  `.maestro/flows/`.

## Verification

```bash
bash -n tool/agent/maestro_evidence_check.sh
tool/agent/test_maestro_evidence_check.sh
tool/agent/test_mobile_evidence_check.sh
```

A runtime-sensitive change is not proven until the evidence runner succeeds on
a real device or emulator and the artifact path is recorded in the PR.
