# Mobilekit Cutover And Cleanup

Date: 2026-08-01
Owner: Unassigned
Status: active
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-scaffold-duplication.md`

## Objective

Make `mobilekit` the repository's supported public tooling interface.

This plan updates docs and CI to use the pinned CLI command, removes old public `tool/` wrappers after migration, and keeps internal policy/config files in place.

## Constraints

- architectural constraints:
  - keep policy/config data where it belongs: `tool/lints/architecture_lints.yaml`, `.jscpd*.json`, `tool/*allowlist.json`
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

- [ ] Update `AGENTS.md` canonical commands.
- [ ] Update `README.md`.
- [ ] Update `.github/pull_request_template.md`.
- [ ] Update `.github/workflows/android.yml`.
- [ ] Update `.github/actions/flutter-bootstrap/action.yml` where relevant.
- [ ] Update `docs/engineering/guardrails.md`.
- [ ] Update `docs/engineering/agent_pr_loop.md`.
- [ ] Update `docs/engineering/duplication_harness.md`.
- [ ] Update any additional references found by searching old `tool/` public command strings.
- [ ] Delete old public `tool/` wrappers after confirming equivalent `mobilekit` commands exist.
- [ ] Keep internal files required by lints, config generation, duplication profiles, or report filtering.
- [ ] Run final pinned CLI verification.
- [ ] Run installed-mode smoke verification.

## Decision Log

- 2026-08-01: Old public `tool/` wrappers will be deleted after migration -> `mobilekit` becomes the supported public command surface.
- 2026-08-01: CI uses pinned CLI execution -> avoids global activation drift.
- 2026-08-01: Internal policy/config files stay repo-local -> CLI executes them but does not own their policy.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
rg -n "dart run tool/|./tool/check_|tool/verify\\.dart|tool/fix\\.dart|tool/scaffold_feature\\.dart" AGENTS.md README.md docs .github
dart run mobile_core_kit_cli:mobilekit doctor
dart run mobile_core_kit_cli:mobilekit verify --env dev
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit doctor
mobilekit verify --env dev --skip-tests
```

If the full verify command is too expensive for the handoff agent's environment, record why and run the strongest targeted substitute:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit duplication check
```

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

Fill in after implementation.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md` if any wrapper or old command reference intentionally remains.
