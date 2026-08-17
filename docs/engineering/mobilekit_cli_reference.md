# Mobilekit CLI Reference

`mobilekit` is the repository-local, internal command surface for development,
verification, scaffolding, duplication checks, and runtime evidence.

Use the pinned form in CI and reproducible documentation:

```bash
dart run mobile_core_kit_cli:mobilekit <command> [options]
```

For local convenience, activate the checkout-local package explicitly:

```bash
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit <command> [options]
```

The CLI is private to this repository and is not published to pub.dev.

## Command overview

| Command | Purpose |
| --- | --- |
| `mobilekit init` | Initialize template lifecycle state and enter customization. |
| `mobilekit customize` | Review or update template lifecycle state. |
| `mobilekit doctor` | Read-only tooling, template-policy, and external-setup diagnostics. |
| `mobilekit lint` | Run Flutter analyzer and custom lint rules. |
| `mobilekit verify` | Run a typed fast, full, runtime, or CI verification profile. |
| `mobilekit fix` | Preview or apply safe Dart fixes and formatting. |
| `mobilekit config generate` | Generate build configuration from `.env/*.yaml`. |
| `mobilekit env verify` | Validate environment schema files. |
| `mobilekit codegen verify` | Verify generated-code freshness. |
| `mobilekit l10n verify` | Verify the generated untranslated-message report. |
| `mobilekit project-map verify` | Check AGENTS project-map drift. |
| `mobilekit knowledge verify` | Check project-map, normative links, and plan lifecycle. |
| `mobilekit scaffold feature` | Generate a feature slice. |
| `mobilekit duplication check` | Run duplication detection and filtering. |
| `mobilekit runtime logs` | Manage background Flutter log sessions. |
| `mobilekit runtime evidence` | Run device integration tests and collect evidence. |

Show the current top-level or command-specific help with:

```bash
dart run mobile_core_kit_cli:mobilekit --help
dart run mobile_core_kit_cli:mobilekit <command> --help
```

## Template lifecycle

The template lifecycle commands are intended for the first use of a copied
mobile-core-kit repository. They require the checked-in
`.mobilekit/template.yaml` marker and write the non-secret customization state
to `.mobilekit/project.yaml`.

### `init`

```bash
mobilekit init
mobilekit init --config path/to/project.yaml --yes
mobilekit init --dry-run
```

`init` validates the template marker, collects the customization inputs, and
enters the same customization workflow as `customize`. Use `--config` for a
non-interactive input file, `--dry-run` to print the normalized plan without
writing, and `--yes` to apply without the confirmation prompt.

### `customize`

```bash
mobilekit customize
mobilekit customize --config path/to/project.yaml --yes
mobilekit customize --dry-run
```

`customize` reads the existing manifest when present and allows the same
identity and integration-policy values to be reviewed or replaced. It fails
when no manifest exists unless a config file is supplied. Applying the plan
updates the allowlisted application package, Android namespace/application IDs,
flavor suffixes, Kotlin package path, Android label, localized branding, root
metadata, README, iOS application and test bundle IDs, and iOS display/name
values in `Runner/Info.plist`. The iOS transformation keeps the `Runner` and
`RunnerTests` target names and only edits their target-owned bundle settings.
Deep-link policy updates the tracked examples, Android intent filters, iOS
associated domains, parser fixtures, and the current deep-link guide. Disabled
deep links clear platform claims and runtime example hosts. Firebase mode is
persisted and reported; `configure` prints a `flutterfire configure` handoff,
`keep-demo` reports a production blocker, and `disabled` preserves the Firebase
code without deleting configuration files. Ignored runtime environment and
native Firebase files are never overwritten.

Both commands reject unsupported schema versions and secret-like or runtime
environment values in tracked configuration. API endpoints, OIDC client IDs,
Firebase credentials, signing material, Git remotes, and external hosting
state remain user-owned configuration.

After a successful apply, `init` and `customize` run the existing generation
owners in this order: `flutter pub get`, `flutter gen-l10n` when ARB inputs
exist, environment validation and `config generate` when a non-empty local
environment file exists, and `build_runner` when it is declared. Missing
inputs are reported as skips; a failed generation step returns non-zero and
does not claim that setup is complete. A second apply with the same manifest
is a no-op.

`mobilekit doctor` adds a residual-default report after initialization. Known
application/package/platform defaults are `blocking`, placeholders in example
environment files are `review-required`, and matches in harness or historical
documentation are `historical`. Blocking findings make the doctor report
fail; the report includes a short path preview for each category.

## Verification and quality commands

### `lint`

```bash
mobilekit lint
```

Runs the Flutter analyzer followed by the repository's custom lint rules. It
accepts no workflow-specific options.

### `verify`

```bash
mobilekit verify --profile fast --env dev
mobilekit verify --profile full --env dev
mobilekit verify --profile runtime --env dev --device emulator-5554
mobilekit verify --profile ci --env prod
```

Options:

- `--profile <fast|full|runtime|ci>` — explicit evidence profile; omitted means
  the legacy compatibility default, `full`.
- `--env, -e <dev|staging|prod>` — environment; defaults to `dev`.
- `--test-path <path>` — repeatable focused application test for `fast`.
- `--device`, `--target`, `--artifacts-dir`,
  `--no-example-env-fallback`, and `--google-services-json` — runtime-profile
  options delegated to the existing evidence owner.

The profiles are intentionally different:

- `fast` runs dependency/environment preflight, generated config and
  localization, knowledge validation, formatting, analyzer/custom lints, both
  harness-package test suites, and optional focused application tests;
- `full` adds generated-output freshness, advisory core/small-helper
  duplication reports, and every root application test;
- `runtime` delegates selected integration targets to the device evidence
  workflow and requires `--device`;
- `ci` has the same repository proof sequence as `full`; GitHub Actions adds
  independent platform, coverage, golden, dependency, and secret-scanning
  lanes around it.

Every profile is fail-fast and reports stable step identifiers plus remediation.
Explicit profiles reject weakening skip flags and file-mutating fixes. The old
`--apply-fixes`, `--check-codegen`, `--skip-duplication`, `--skip-format`, and
`--skip-tests` flags remain only for compatibility when `--profile` is omitted;
their output is not sufficient completion evidence.

### `fix`

```bash
mobilekit fix --dry-run
mobilekit fix --apply
```

Use exactly one mode. The dry run reports potential changes; `--apply` writes
the safe fix and formatting changes.

### `duplication check`

```bash
mobilekit duplication check
mobilekit duplication check --profile core
mobilekit duplication check --profile small-helpers
mobilekit duplication check --profile presentation
```

Without `--profile`, the core and small-helper profiles run sequentially. The
reviewed policy files live under `duplication/`; jscpd profile configuration
remains in the root `.jscpd*.json` files.

## Configuration and repository checks

```bash
mobilekit config generate --env dev
mobilekit env verify --all
mobilekit env verify --env dev
mobilekit env verify --all --strict
mobilekit codegen verify
mobilekit l10n verify
mobilekit project-map verify
mobilekit knowledge verify
```

`knowledge verify` is the normal aggregate. It requires the compact
`AGENTS.md` core map, checks normative repository-local Markdown links, and
validates active/queued execution-plan metadata against directory lifecycle.
`project-map verify` remains a focused compatibility command and now fails
when the required map is absent instead of skipping successfully.

`env verify` accepts repeatable `--env, -e <dev|staging|prod>`, `--all`, and
`--strict`. Strict checks enforce production invariants for `prod`.

`l10n verify` reads `.tmp/untranslated_messages.json` by default. A custom
report path may be supplied as its first argument:

```bash
mobilekit l10n verify path/to/report.json
```

## Scaffolding

```bash
mobilekit scaffold feature <name>
mobilekit scaffold feature <name> --slice <slice>
mobilekit scaffold feature <name> --dry-run
```

Feature names must use `snake_case`. `--slice, -s` selects an optional slice
name; `--dry-run` prints the planned output without writing files.

## Runtime commands

### Logs

```bash
mobilekit runtime logs start --session emulator --mode logs --device emulator-5554
mobilekit runtime logs start --session dev-run --mode run --device emulator-5554 --flavor dev --target lib/main_dev.dart
mobilekit runtime logs status --session emulator
mobilekit runtime logs tail --session emulator --lines 200
mobilekit runtime logs stop --session emulator
```

Useful options include `--session`, `--artifacts-dir`, `--mode logs|run`,
`--device`, `--flavor`, `--target`, `--lines`, and `--` for extra Flutter
arguments. Runtime log artifacts default to `_artifacts/runtime_logs/`.

### Evidence

```bash
mobilekit runtime evidence --device emulator-5554
mobilekit runtime evidence --device emulator-5554 --target integration_test/auth_happy_path_test.dart
mobilekit runtime evidence --device emulator-5554 --flavor dev --google-services-json /secure/google-services.json
```

Options include repeatable `--target`, `--flavor dev|staging|prod`,
`--artifacts-dir`, `--no-example-env-fallback`, and
`--google-services-json`. Evidence artifacts default to
`_artifacts/mobile/<timestamp>/`.

## Exit codes

- `0` — command completed successfully.
- `1` — the command was valid but a check, subprocess, or diagnostic failed.
- `2` — invalid command, option, argument, or command shape.

## Ownership

CLI routing and workflow orchestration live under
`packages/mobile_core_kit_cli/`. Repository policy remains visible in its
own files:

- analyzer/custom-lint policy: `lint/` and `packages/mobile_core_kit_lints/`;
- duplication policy: `duplication/` and `.jscpd*.json`;
- engineering guidance: `docs/engineering/`.

When adding a repository workflow, add or update the CLI command, update this
reference, and keep repository-specific policy outside the CLI package.
