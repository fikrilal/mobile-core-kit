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
tool/agent/maestro_evidence_check.sh \
  --device emulator-5554 \
  --flavor dev \
  --include-tags smoke
```

Reuse an existing APK when build evidence is not required:

```bash
tool/agent/maestro_evidence_check.sh \
  --device emulator-5554 \
  --flavor dev \
  --app-file build/app/outputs/flutter-apk/app-dev-debug.apk \
  --skip-build
```

The runner validates Java, Maestro, FVM, ADB, the selected device, environment
configuration, Firebase configuration, and selected flows. It inspects the APK
manifest for the application ID, installs that APK, verifies the installed
package, captures device logs, and passes the inspected ID to Maestro.

Production execution requires `--allow-prod`. The runner always excludes flows
tagged `destructive` or `requires_backend` for production.

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
```

A runtime-sensitive change is not proven until the evidence runner succeeds on
a real device or emulator and the artifact path is recorded in the PR.
