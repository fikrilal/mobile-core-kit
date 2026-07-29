# Engineering Proposal: Consolidate Repository Tools Into A Local Installable `mobilekit` CLI

Date: 2026-08-01
Status: Implemented

## Decision Summary

Create a repo-local Dart CLI package that exposes the existing tool harness through a short installed command:

```bash
mobilekit verify --env dev
mobilekit lint
mobilekit fix --apply
mobilekit config generate --env dev
mobilekit scaffold feature auth
mobilekit duplication check
mobilekit doctor
```

The CLI package should live in the repository, be installable locally with `dart pub global activate --source path`, and remain usable in pinned form through `dart run`.

Recommended package shape:

```text
packages/mobile_core_kit_cli/
  pubspec.yaml
  bin/mobilekit.dart
  lib/src/commands/
  lib/src/process/
```

The executable name should be `mobilekit`.

CI should initially keep using pinned repo-local execution:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Local developer setup may install the command:

```bash
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit verify --env dev
```

## Context And Problem

The repository had a mature tooling harness whose public command surface was
previously scattered across legacy scripts. The current public surface is the
repo-local `mobilekit` CLI:

- `packages/mobile_core_kit_cli/` owns command routing and workflow orchestration;
- `packages/mobile_core_kit_lints/` owns executable custom lint rules;
- `lint/` and `duplication/` contain repository-owned policy;
- `.jscpd*.json` contains duplication profile configuration.

The current docs and CI use pinned CLI commands, with the complete reference in
`docs/engineering/mobilekit_cli_reference.md`.

This works, but it has avoidable costs:

- Developers should use stable workflow commands instead of implementation paths.
- Some scripts duplicate process-running logic, including FVM-aware Dart/Flutter resolution.
- The duplication harness previously depended on POSIX shell wrappers, which made Windows behavior uneven.
- The old script layout did not clearly separate public commands from internal implementation files and config.
- Documentation must repeat low-level script paths across engineering guides, CI notes, and PR templates.

The goal is not to invent a new harness. The goal is to make the existing harness easier to run, easier to document, and less likely to drift.

## Goals

- Provide a short local command: `mobilekit`.
- Preserve repo-pinned behavior for CI and repeatable automation.
- Consolidate public tool workflows behind stable subcommands.
- Keep implementation changes small and reversible.
- Preserve existing verification semantics during migration.
- Reduce duplicate process-runner logic across Dart scripts.
- Make duplication profiles invocable through Dart so the public command surface is less shell-dependent.
- Provide `mobilekit doctor` for deterministic local tooling diagnostics.

## Non-Goals

- Do not publish the CLI to pub.dev as part of the first migration.
- Do not combine the CLI package with `packages/mobile_core_kit_lints`.
- Do not move architecture policy such as `lint/architecture_lints.yaml` into the CLI package.
- Do not change verification behavior while creating the CLI.
- Do not add new checks just because a CLI now exists.

## Proposed Command Surface

The first version should expose workflows, not every internal script.

| Command | Purpose | Current source |
| --- | --- | --- |
| `mobilekit verify --env dev` | Canonical local quality gate | `packages/mobile_core_kit_cli/lib/src/workflows/verify_workflow.dart` |
| `mobilekit lint` | Run Flutter analyzer and custom lint rules | `packages/mobile_core_kit_cli/lib/src/workflows/lint_workflow.dart` |
| `mobilekit fix --apply` | Safe formatting/import fix workflow | `packages/mobile_core_kit_cli/lib/src/workflows/fix_workflow.dart` |
| `mobilekit config generate --env dev` | Generate build config from `.env/<env>.yaml` | `packages/mobile_core_kit_cli/lib/src/workflows/build_config_workflow.dart` |
| `mobilekit scaffold feature <name>` | Generate feature scaffolding | `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart` |
| `mobilekit duplication check` | Run default duplication checks | `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart` |
| `mobilekit duplication check --profile core` | Run core duplication profile | `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart` |
| `mobilekit duplication check --profile small-helpers` | Run small-helper duplication profile | `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart` |
| `mobilekit duplication check --profile presentation` | Run presentation duplication profile | `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart` |
| `mobilekit env verify --env dev` | Validate one environment file | `packages/mobile_core_kit_cli/lib/src/workflows/environment_schema_workflow.dart` |
| `mobilekit env verify --all --strict` | Validate all env files with production invariants | `packages/mobile_core_kit_cli/lib/src/workflows/environment_schema_workflow.dart` |
| `mobilekit codegen verify` | Verify generated code freshness | `packages/mobile_core_kit_cli/lib/src/workflows/codegen_workflow.dart` |
| `mobilekit l10n verify` | Verify untranslated messages | `packages/mobile_core_kit_cli/lib/src/workflows/l10n_workflow.dart` |
| `mobilekit project-map verify` | Verify AGENTS project-map drift | `packages/mobile_core_kit_cli/lib/src/workflows/project_map_workflow.dart` |
| `mobilekit doctor` | Diagnose local toolchain requirements for this repo | `packages/mobile_core_kit_cli/lib/src/doctor/doctor.dart` |
| `mobilekit runtime evidence --device <id>` | Run device integration tests and collect runtime evidence | `packages/mobile_core_kit_cli/lib/src/runtime/runtime_evidence_workflow.dart` |

Commands that are implementation details should remain internal. For example,
`duplication_report_filter.dart` stays behind `mobilekit duplication check`.

## Package And Installation Model

Add a new package:

```text
packages/mobile_core_kit_cli/
```

Its `pubspec.yaml` should expose:

```yaml
name: mobile_core_kit_cli
publish_to: "none"

executables:
  mobilekit: mobilekit
```

The root `pubspec.yaml` should add a path dev dependency:

```yaml
dev_dependencies:
  mobile_core_kit_cli:
    path: packages/mobile_core_kit_cli
```

This supports two modes.

Pinned mode:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Installed local mode:

```bash
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit verify --env dev
```

Pinned mode should remain the default for CI because it ties execution to the checked-out repository version. Installed mode is a developer convenience.

## Ownership And Boundaries

The CLI should own orchestration:

- parsing command names and options;
- resolving the repository root;
- invoking Dart, Flutter, FVM-backed Flutter/Dart, `npx`, and other subprocesses;
- printing consistent step output;
- returning correct process exit codes.

The CLI should not own repository policy:

- architecture import boundaries stay in `lint/architecture_lints.yaml`;
- custom lint AST rules stay in `packages/mobile_core_kit_lints`;
- duplication allowlists stay in `duplication/*.json`;
- jscpd profile config stays in `.jscpd*.json`;
- engineering workflow expectations stay in `docs/engineering/*`.

This separation matters because policy should be reviewed as repo data. The CLI should make policy easier to execute, not hide it inside package code.

## Proposed Migration

### Phase 1: Add The CLI Package Without Behavior Changes (complete)

The repository now contains `packages/mobile_core_kit_cli` with:

- `bin/mobilekit.dart`;
- command routing using `package:args`;
- a shared process runner with current FVM-aware behavior;
- `mobilekit doctor` diagnostics for required local tools;
- command implementations that own the public workflows.

### Phase 2: Move Shared Dart Logic Behind Commands (complete)

The duplicated runner logic from verification, fixing, config generation,
codegen, and related workflows now lives in the CLI package.

### Phase 3: Convert Shell Public Surface To Dart Commands (complete)

Implement duplication profiles directly as Dart orchestration around:

- `npx --yes jscpd`;
- `packages/mobile_core_kit_cli/lib/src/duplication/duplication_report_filter.dart`;
- existing `.jscpd*.json`;
- existing allowlist files.

The CLI duplication profiles are now the supported public surface.

### Phase 4: Update Documentation And CI (complete)

Update canonical commands in:

- `AGENTS.md`;
- `README.md`;
- `docs/engineering/guardrails.md`;
- `docs/engineering/agent_pr_loop.md`;
- `docs/engineering/duplication_harness.md`;
- `.github/pull_request_template.md`;
- `.github/workflows/android.yml`;
- `.github/actions/flutter-bootstrap/action.yml` where relevant.

CI should use pinned execution:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env prod --check-codegen
```

Developer docs can show installed local usage:

```bash
mobilekit verify --env dev
```

### Phase 5: Remove Old Public Entry Points (complete)

The retired script entry points and wrappers have been removed. `mobilekit` is
the supported public command surface, while repository policy remains in
`lint/`, `duplication/`, and the root `.jscpd*.json` files.

## Compatibility And Rollback

Compatibility is now explicit through pinned and installed CLI modes:

- CI uses `dart run mobile_core_kit_cli:mobilekit ...`.
- Developers may activate the checkout-local package and use `mobilekit ...`.
- No application runtime behavior is involved in the tooling migration.

The main compatibility risk is developer global activation drift. A globally activated `mobilekit` may point at stale local package code.

Mitigation:

- CI uses `dart run mobile_core_kit_cli:mobilekit`.
- Bootstrap docs tell developers to rerun local activation after pulling CLI changes.
- `mobilekit doctor` reports the local toolchain state and can call out likely stale activation symptoms where detectable.

Do not add self-updating or automatic reactivation machinery in the first pass. `mobilekit doctor` should diagnose; installation remains explicit.

## Risks And Tradeoffs

| Risk | Impact | Mitigation |
| --- | --- | --- |
| CLI becomes a dumping ground | The command surface becomes as scattered as the legacy scripts | Expose workflow commands only; keep internal helpers private |
| Global activation drift | Developers may run stale command code | Keep CI pinned; document reactivation |
| Behavior changes during migration | Existing verification guarantees weaken accidentally | Port by delegation first, then refactor internals |
| Shell-to-Dart duplication conversion changes results | Duplication findings may differ | Compare profile output during migration and keep the CLI profile behavior stable |
| More package structure than today | Slightly more files and indirection | Justified because verification and scaffolding are public repo workflows |
| Doctor command scope creeps into environment management | CLI starts mutating developer machines unexpectedly | Keep `doctor` read-only by default; provide explicit commands for remediation |

## Acceptance Criteria

The proposal should be considered implemented when:

- `mobilekit verify --env dev` runs the canonical repository quality gate.
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` works without global activation.
- `dart pub global activate --source path packages/mobile_core_kit_cli` exposes `mobilekit`.
- The retired script entry points are removed after parity is established.
- CI uses pinned CLI execution.
- Documentation points developers to `mobilekit` for normal workflows.
- Duplication profiles remain available through `mobilekit duplication check`.
- `mobilekit doctor` reports required local tooling status without modifying the machine by default.
- No architecture lint policy, duplication allowlist data, or jscpd profile config is hidden inside CLI code.

## Verification Expectations

Implementation should be treated as a medium-risk tooling change because it touches repository verification and CI ergonomics.

Required mechanical checks after implementation:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit doctor
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit verify --env dev --skip-tests
mobilekit doctor
```

For final verification, run the full gate through the pinned command:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Command output and evidence belong in the execution plan or PR, not in this proposal.

## Settled Decisions

1. Old public script wrappers are deleted after migration.

   Compatibility wrappers are temporary migration aids, not permanent aliases.

2. `mobilekit install` will not be included in the first version.

   Local activation remains explicit:

   ```bash
   dart pub global activate --source path packages/mobile_core_kit_cli
   ```

3. `mobilekit doctor` is included in the first CLI scope.

   It should diagnose required local tools and environment readiness. It should not mutate the developer machine by default.

4. The executable name is `mobilekit`.

   The name is accepted as the stable public command name for this repository tooling.
