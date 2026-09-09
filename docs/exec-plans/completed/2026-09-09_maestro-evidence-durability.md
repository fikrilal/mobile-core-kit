# Maestro Evidence Durability Tag

**Plan version:** 2
**Task ID:** maestro-evidence-durability
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Fix `runtime evidence` so `summary.md` is tagged `durable-summary` (dart:io `File ==` is identity, not path). Add a CLI test that the produced `evidence.json` carries that tag. No commit, push, or draft-PR. No live Maestro rerun in this task.
**Allowed paths:** docs/exec-plans/queued/2026-09-09_maestro-evidence-durability.md, docs/exec-plans/active/2026-09-09_maestro-evidence-durability.md, docs/exec-plans/completed/2026-09-09_maestro-evidence-durability.md, packages/mobile_core_kit_cli/lib/src/runtime/runtime_evidence_workflow.dart, packages/mobile_core_kit_cli/test/runtime_evidence_workflow_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 2h
**Oracle IDs:** harness.full

Date: 2026-09-09
Related issue/PR: `maestro-login-pilot` handoff; `_WIP/2026-09-06_maestro-device-proof-proposal.md`

## Objective

Make a passing `evidence.json` satisfy `CompletionEvidenceReader` for
`maestro-flow` / `integration-test`. Today the writer compares `File`
instances; dart:io equality is identity, so `summary.md` is stored as
`transient-local-log` and `handoff check` ignores the passing run.

## Constraints

- Architecture constraints: compare paths, not `File` identity. Do not
  change the evidence schema, artifact root, or reader contract.
- Product/runtime constraints: none. No live device in this task.
- Out of scope: re-running `maestro/login.yaml`; forging
  `manual-evidence.json`; commit/push/draft-PR; Maestro Cloud; CI.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given `RuntimeEvidenceWorkflow` writes a passing manifest, when
   `evidence.json` is read, then the `summary.md` artifact entry has
   `durability: durable-summary`.
2. Given a verified task with a `maestro-flow` oracle and that manifest,
   when `handoff check` runs, then the reader no longer rejects the run
   for missing `durable-summary`.

## Acceptance Criteria

1. Writer compares `file.path` to the summary path, not `File ==`.
2. `runtime_evidence_workflow_test.dart` asserts `"durable-summary"` in
   the produced `evidence.json`.
3. `task verify --task maestro-evidence-durability --env dev` passes.

## Implementation Checklist

- [x] Compare summary path in `_writeManifest`.
- [x] Assert `durable-summary` in the CLI workflow tests.
- [x] `task verify` at current fingerprint.

## Decision Log

- 2026-09-09: Login-pilot Maestro run passed. Handoff still red because
  `File ==` never matched `summaryFile` getter instances. User authorized
  this CLI follow-up. Login-pilot parked to queued (one active V2).
- 2026-09-09: Live re-evidence stays on `maestro-login-pilot` after this
  writer fix. This task is the unit-level gate only.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-evidence-durability --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-evidence-durability --env dev
```

## Runtime Evidence

Not required. Writer/reader contract is proven by CLI tests. Device
journey proof remains `maestro-login-pilot`.

## Rollback

Revert the two task-owned files. Leave login-pilot queued until the
writer fix is in the working tree, then restore it.

## Risks And Mitigations

- Risk: login-pilot `handoff check` still fails until evidence is
  rewritten with the new writer. Mitigation: resume login-pilot after
  this verify; CLI files must be preexisting at that re-begin.
- Risk: other `File ==` path comparisons. Mitigation: grep showed this
  was the only durability tag site.

## Completion Notes

Writer compares `file.path` to the summary path. CLI tests assert
`durable-summary`. `task verify --task maestro-evidence-durability --env
dev` passed (profile=full, attempt=1) on 2026-09-09. No commit.
## Follow-ups

Resume `maestro-login-pilot`, re-run `runtime evidence`, then
`handoff check --task maestro-login-pilot`.
`runtime.mobile-evidence` still needs a real human procedure receipt.
Do not forge it.
