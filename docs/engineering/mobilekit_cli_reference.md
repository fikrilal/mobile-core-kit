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
| `mobilekit verify` | Run the canonical repository quality gate. |
| `mobilekit fix` | Preview or apply safe Dart fixes and formatting. |
| `mobilekit config generate` | Generate build configuration from `.env/*.yaml`. |
| `mobilekit env verify` | Validate environment schema files. |
| `mobilekit codegen verify` | Verify generated-code freshness. |
| `mobilekit l10n verify` | Verify the generated untranslated-message report. |
| `mobilekit project-map verify` | Check AGENTS project-map drift. |
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

## Verification and quality commands

### `lint`

```bash
mobilekit lint
```

Runs the Flutter analyzer followed by the repository's custom lint rules. It
accepts no workflow-specific options.

### `verify`

```bash
mobilekit verify --env dev
```

Options:

- `--env, -e <dev|staging|prod>` — environment; defaults to `dev`.
- `--apply-fixes` — apply the supported `directives_ordering` fix before the
  remaining checks.
- `--check-codegen` — verify generated-code freshness.
- `--skip-duplication` — skip core and small-helper duplication profiles.
- `--skip-format` — skip the final formatting check.
- `--skip-tests` — skip Flutter tests.

The gate also generates build configuration and localization output, validates
environment and project-map state, runs lint/guardrail checks, and returns on
the first failing step.

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
```

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
