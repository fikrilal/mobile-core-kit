# First-Use Checklist

Use this checklist when copying `mobile-core-kit` into a new mobile app.

## Recommended backend

For the fastest path, pair the mobile template with
[backend-core-kit](https://github.com/fikrilal/backend-core-kit). The API,
auth, session, and current-user contracts are already aligned. Set the backend
URL in `.env/dev.yaml` and continue with the steps below.

## 1. Bootstrap the repository-local CLI

From the copied repository:

```bash
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit init --dry-run
mobilekit init
```

The template marker lets `mobilekit` locate the project even before `git init`.
For CI or another reproducible setup, use a non-secret YAML input file:

```bash
dart run mobile_core_kit_cli:mobilekit init \
  --config path/to/project-input.yaml --yes
```

The interactive wizard and YAML mode normalize the same repository slug,
display name, Dart package, Android IDs, iOS IDs, deep-link policy, and
Firebase mode. API endpoints and OIDC client IDs are deliberately not part of
the wizard.

## 2. Review the generated plan

Confirm that the plan contains the intended values before applying it. The
operation is allowlisted and transactional:

- `--dry-run` writes nothing;
- a managed-file conflict stops the operation before writing;
- a failed write restores the pre-apply files; and
- repeating the same initialization is idempotent.

The CLI/lint package identities remain `mobile_core_kit_cli` and
`mobile_core_kit_lints`; they are part of the repository harness and are not
renamed with the application.

## 3. Complete user-owned setup

After initialization, inspect the external items in the plan and configure
only the values owned by the new project:

- copy or create `.env/dev.yaml`, `.env/staging.yaml`, and `.env/prod.yaml`
  from the tracked examples;
- provide real API endpoints and OIDC client IDs in those ignored files;
- when Firebase is selected, run `flutterfire configure` and review the
  generated options and native files;
- register deep-link domains and publish the Android/iOS verification files;
- configure signing, CI secrets, store metadata, and release identifiers;
- replace product icons, splash assets, and any remaining product copy.

The CLI never accepts credentials, writes ignored runtime environment files,
or overwrites `google-services.json` and `GoogleService-Info.plist`.

## 4. Generate and verify

`mobilekit init` runs `flutter pub get`, localization generation, build-config
generation, and `build_runner` when their inputs are present and valid. It
reports skipped work when a required input is absent. Run the full gate after
user-owned setup is available:

```bash
dart run mobile_core_kit_cli:mobilekit doctor
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Use `--profile ci --env prod` for the production CI verification lane.
Collect Android emulator and iOS simulator/device evidence for customized
identities, startup behavior, and the selected deep-link mode before release.
