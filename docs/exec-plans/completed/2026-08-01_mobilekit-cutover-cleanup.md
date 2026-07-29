# Mobilekit Cutover And Cleanup

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-scaffold-duplication.md`

## Objective

Make `mobilekit` the repository's supported public tooling interface.

This plan updates docs and CI to use the pinned CLI command, removes old public `tool/` wrappers after migration, and keeps internal policy/config files in place.

## Constraints

- architectural constraints:
  - keep policy/config data where it belongs: `lint/architecture_lints.yaml`, `.jscpd*.json`, `duplication/*.json`
  - do not delete internal helper/config files still used by the CLI
  - public command surface should be `mobilekit`
- product/runtime constraints:
  - no Flutter app runtime behavior should change
  - CI must remain pinned to repository code through `dart run mobile_core_kit_cli:mobilekit`
  - global `mobilekit` usage is for local developer ergonomics only
- out of scope:
  - adding new CLI features beyond accepted proposal scope
  - changing app verification semantics
  - publishing the CLI package

## Acceptance Criteria

1. `AGENTS.md`, `README.md`, PR template, and engineering docs point to `mobilekit` for public workflows.
2. CI uses pinned execution: `dart run mobile_core_kit_cli:mobilekit verify ...`.
3. Old public `tool/` wrappers are deleted after parity is established.
4. Internal config/data files under `tool/` remain if still used by the CLI or custom lints.
5. Full verification passes through the new pinned CLI command.
6. Installed local usage works after activation.

## Implementation Checklist

- [x] Update `AGENTS.md` canonical commands.
- [x] Update `README.md`.
- [x] Update `.github/pull_request_template.md`.
- [x] Update `.github/workflows/android.yml`.
- [x] Update `.github/actions/flutter-bootstrap/action.yml` where relevant.
- [x] Update `docs/engineering/guardrails.md`.
- [x] Update `docs/engineering/agent_pr_loop.md`.
- [x] Update `docs/engineering/duplication_harness.md`.
- [x] Update any additional references found by searching old `tool/` public command strings.
- [x] Delete old public `tool/` wrappers after confirming equivalent `mobilekit` commands exist.
- [x] Keep internal files required by lints, config generation, duplication profiles, or report filtering.
- [x] Run final pinned CLI verification.
- [x] Run installed-mode smoke verification.

## Decision Log

- 2026-08-01: Old public `tool/` wrappers will be deleted after migration -> `mobilekit` becomes the supported public command surface.
- 2026-08-01: CI uses pinned CLI execution -> avoids global activation drift.
- 2026-08-01: Internal policy/config files stay repo-local -> CLI executes them but does not own their policy.
- 2026-08-01: Retain the Dart files under `tool/` that still implement delegated workflows -> they are internal behavior owners, not public command entrypoints.
- 2026-08-01: Keep explicit Windows `cmd.exe` handling for CLI-launched `npx` commands -> preserve the existing jscpd invocation across supported host platforms.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
rg -n "dart run tool/|\\./tool/check_|tool/verify\\.dart|tool/fix\\.dart|tool/scaffold_feature\\.dart" AGENTS.md README.md docs/engineering docs/template docs/core .github tool/agent
dart run mobile_core_kit_cli:mobilekit doctor
dart run mobile_core_kit_cli:mobilekit verify --env dev
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit doctor
mobilekit verify --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart analyze packages/mobile_core_kit_cli
dart run test packages/mobile_core_kit_cli
git diff --check
```

Outcome: the public-scope audit returned no old command references. The pinned
doctor and full `mobilekit verify --env dev` passed, including env/config
generation, localization, Flutter analyze, custom lints, core and
small-helper duplication, modal/color guardrails, 553 Flutter tests, and the
format check. The installed `mobilekit doctor` and
`mobilekit verify --env dev --skip-tests` also passed. The presentation profile,
CLI package analysis, 21 CLI tests, and `git diff --check` passed.

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static/tooling and CI verification are sufficient. This change does not alter app runtime behavior.

## Risks And Mitigations

- Risk: docs still reference removed public wrappers.
- Mitigation: search for old command strings before completing the plan.

- Risk: CI command changes hide a behavior difference.
- Mitigation: perform cutover only after old/new parity from prior plans and run full pinned CLI verification.

- Risk: deleting too much from `tool/` breaks custom lints or duplication policy.
- Mitigation: delete only public wrappers; keep config/data/helper files that remain referenced.

## Completion Notes

Migrated repository docs, PR guidance, CI workflows, bootstrap actions, agent
helpers, and engineering references to the pinned `mobilekit` interface.

Deleted the three superseded public shell wrappers:
`tool/check_duplication.sh`, `tool/check_small_helper_duplication.sh`, and
`tool/check_presentation_duplication.sh`. The equivalent CLI profiles were
verified, while policy/config/allowlist/filter files and delegated Dart
implementation helpers remain repo-local.

No Flutter application runtime behavior changed.

## Follow-ups

- [x] No unresolved public wrapper debt remains; historical exec plans and ADRs retain original commands as audit history.
