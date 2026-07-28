# Engineering Proposal: Consolidate Repository Tools Into A Local Installable `mobilekit` CLI

Date: 2026-08-01
Status: Draft proposal

## Decision Summary

Create a repo-local Dart CLI package that exposes the existing tool harness through a short installed command:

```bash
mobilekit verify --env dev
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

The repository already has a mature tooling harness, but its command surface is scattered across `tool/`:

- `tool/verify.dart`
- `tool/fix.dart`
- `tool/gen_config.dart`
- `tool/scaffold_feature.dart`
- `tool/verify_*.dart`
- `tool/check_duplication.sh`
- `tool/filter_duplication_report.dart`
- `tool/lints/architecture_lints.yaml`

The current docs treat these as first-class workflows. Examples:

- `docs/engineering/guardrails.md` defines `dart run tool/verify.dart --env dev` as the canonical quality gate.
- `docs/engineering/agent_pr_loop.md` expects agents to run `dart run tool/verify.dart --env dev` for non-trivial work.
- `docs/engineering/duplication_harness.md` documents separate shell commands for duplication profiles.
- `.github/workflows/android.yml` calls `dart run tool/verify.dart --env prod --check-codegen`.

This works, but it has avoidable costs:

- Developers need to remember implementation paths instead of workflow commands.
- Some scripts duplicate process-running logic, including FVM-aware Dart/Flutter resolution.
- The duplication harness still depends on POSIX shell wrappers, which makes Windows behavior uneven.
- `tool/` does not clearly separate public commands from internal implementation files and config.
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
- Do not move architecture policy such as `tool/lints/architecture_lints.yaml` into the CLI package.
- Do not change verification behavior while creating the CLI.
- Do not remove existing `tool/` entry points until docs and CI have migrated.
- Do not add new checks just because a CLI now exists.

## Proposed Command Surface

The first version should expose workflows, not every internal script.

| Command | Purpose | Current source |
| --- | --- | --- |
| `mobilekit verify --env dev` | Canonical local quality gate | `tool/verify.dart` |
| `mobilekit fix --apply` | Safe formatting/import fix workflow | `tool/fix.dart` |
| `mobilekit config generate --env dev` | Generate build config from `.env/<env>.yaml` | `tool/gen_config.dart` |
| `mobilekit scaffold feature <name>` | Generate feature scaffolding | `tool/scaffold_feature.dart` |
| `mobilekit duplication check` | Run default duplication checks | `tool/check_duplication.sh`, `tool/check_small_helper_duplication.sh` |
| `mobilekit duplication check --profile core` | Run core duplication profile | `tool/check_duplication.sh` |
| `mobilekit duplication check --profile small-helpers` | Run small-helper duplication profile | `tool/check_small_helper_duplication.sh` |
| `mobilekit duplication check --profile presentation` | Run presentation duplication profile | `tool/check_presentation_duplication.sh` |
| `mobilekit env verify --env dev` | Validate one environment file | `tool/verify_env_schema.dart` |
| `mobilekit env verify --all --strict` | Validate all env files with production invariants | `tool/verify_env_schema.dart` |
| `mobilekit codegen verify` | Verify generated code freshness | `tool/verify_codegen.dart` |
| `mobilekit l10n verify` | Verify untranslated messages | `tool/verify_untranslated_messages.dart` |
| `mobilekit project-map verify` | Verify AGENTS project-map drift | `tool/verify_project_map_drift.dart` |
| `mobilekit doctor` | Diagnose local toolchain requirements for this repo | New CLI command |
| `mobilekit runtime evidence --device <id>` | Run device integration tests and collect runtime evidence | `tool/agent/mobile_evidence_check.sh` |

Commands that are implementation details should remain internal. For example, `filter_duplication_report.dart` should stay behind `mobilekit duplication check`.

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

- architecture import boundaries stay in `tool/lints/architecture_lints.yaml`;
- custom lint AST rules stay in `packages/mobile_core_kit_lints`;
- duplication allowlists stay in `tool/*.json`;
- jscpd profile config stays in `.jscpd*.json`;
- engineering workflow expectations stay in `docs/engineering/*`.

This separation matters because policy should be reviewed as repo data. The CLI should make policy easier to execute, not hide it inside package code.

## Proposed Migration

### Phase 1: Add The CLI Package Without Behavior Changes

Create `packages/mobile_core_kit_cli` with:

- `bin/mobilekit.dart`;
- command routing using `package:args`;
- a shared process runner with current FVM-aware behavior;
- `mobilekit doctor` diagnostics for required local tools;
- command implementations that call existing scripts where possible.

Keep all existing `tool/` commands working.

### Phase 2: Move Shared Dart Logic Behind Commands

Move duplicated runner logic from `tool/verify.dart`, `tool/fix.dart`, and `tool/verify_codegen.dart` into the CLI package.

Compatibility wrappers under `tool/` may delegate to the CLI during this phase.

### Phase 3: Convert Shell Public Surface To Dart Commands

Implement duplication profiles directly as Dart orchestration around:

- `npx --yes jscpd`;
- `tool/filter_duplication_report.dart`;
- existing `.jscpd*.json`;
- existing allowlist files.

Keep the shell scripts as compatibility wrappers until documentation and CI no longer depend on them.

### Phase 4: Update Documentation And CI

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

### Phase 5: Remove Old Public Entry Points

After one transition window:

- remove compatibility wrappers for public `tool/` commands;
- make `mobilekit` the only supported public command surface;
- keep internal config/data files under `tool/` where they remain the right ownership boundary.

## Compatibility And Rollback

Compatibility during migration should be explicit:

- Existing `dart run tool/*.dart` commands continue to work during the first phases.
- Existing `./tool/check_*.sh` commands continue to work until the Dart duplication command is proven.
- CI switches only after local parity is verified.
- The rollback path is to restore CI/docs to the old script paths; no app runtime behavior is involved.

The main compatibility risk is developer global activation drift. A globally activated `mobilekit` may point at stale local package code.

Mitigation:

- CI uses `dart run mobile_core_kit_cli:mobilekit`.
- Bootstrap docs tell developers to rerun local activation after pulling CLI changes.
- `mobilekit doctor` reports the local toolchain state and can call out likely stale activation symptoms where detectable.

Do not add self-updating or automatic reactivation machinery in the first pass. `mobilekit doctor` should diagnose; installation remains explicit.

## Risks And Tradeoffs

| Risk | Impact | Mitigation |
| --- | --- | --- |
| CLI becomes a dumping ground | The command surface becomes as scattered as `tool/` | Expose workflow commands only; keep internal helpers private |
| Global activation drift | Developers may run stale command code | Keep CI pinned; document reactivation |
| Behavior changes during migration | Existing verification guarantees weaken accidentally | Port by delegation first, then refactor internals |
| Shell-to-Dart duplication conversion changes results | Duplication findings may differ | Keep old shell scripts until parity is verified |
| More package structure than today | Slightly more files and indirection | Justified because verification and scaffolding are public repo workflows |
| Doctor command scope creeps into environment management | CLI starts mutating developer machines unexpectedly | Keep `doctor` read-only by default; provide explicit commands for remediation |

## Acceptance Criteria

The proposal should be considered implemented when:

- `mobilekit verify --env dev` runs the same canonical gate currently represented by `dart run tool/verify.dart --env dev`.
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` works without global activation.
- `dart pub global activate --source path packages/mobile_core_kit_cli` exposes `mobilekit`.
- Existing `tool/` entry points still work during migration.
- Existing public `tool/` wrappers are removed after migration.
- CI uses pinned CLI execution after parity is established.
- Documentation points developers to `mobilekit` for normal workflows.
- Duplication profiles remain available through both old wrappers and `mobilekit duplication check` during the transition.
- `mobilekit doctor` reports required local tooling status without modifying the machine by default.
- No architecture lint policy, duplication allowlist data, or jscpd profile config is hidden inside CLI code.

## Verification Expectations

Implementation should be treated as a medium-risk tooling change because it touches repository verification and CI ergonomics.

Required mechanical checks after implementation:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
dart run tool/verify.dart --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit doctor
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit verify --env dev --skip-tests
mobilekit doctor
```

Before CI migration, run the full gate once through the new pinned command:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Command output and evidence belong in the execution plan or PR, not in this proposal.

## Settled Decisions

1. Old public `tool/` wrappers will be deleted after migration.

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
