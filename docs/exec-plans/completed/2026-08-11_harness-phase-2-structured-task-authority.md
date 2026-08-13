# Harness Phase 2 — Structured Task Authority

**Plan version:** 2
**Task ID:** mobile-harness-phase-2-task-authority
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 2 locally; no external mutation
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/task/, packages/mobile_core_kit_cli/lib/src/policy/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/workflows/knowledge_workflow.dart, packages/mobile_core_kit_cli/test/, packages/mobile_core_kit_cli/pubspec.yaml, packages/mobile_core_kit_cli/pubspec.lock, pubspec.lock, .gitignore, AGENTS.md, docs/README.md, docs/engineering/, docs/exec-plans/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h

Date: 2026-08-11
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Introduce a prospective V2 execution-plan contract and local task baseline so
the repository can distinguish human-granted scope from an agent's execution,
protect pre-existing work, and conservatively classify effective task risk.

## Constraints

- Architecture constraints: keep task control inside `mobilekit`; keep the
  controller outside application `lib/`; preserve Clean Architecture lints.
- Product/runtime constraints: state must be schema-versioned, ignored,
  atomic, and rediscoverable; path authority must be repository-relative and
  explicit; automation may raise risk and never lower it.
- Out of scope: running verification lanes, automated repair, worktree
  creation, events, publication, operating evidence, and hill climbing.

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

1. Given a valid active V2 plan, `mobilekit task begin --plan <path>` records
   its immutable authority, Git base revision, and fingerprints for every
   pre-existing dirty path in ignored local state.
2. Given missing, duplicate, broad, absolute, traversal, globbed, unsupported,
   or internally inconsistent authority metadata, plan validation fails before
   state is created.
3. Given task-owned changes outside allowed paths, changed authority metadata,
   an unauthorized action, or effective risk above the maximum, task preflight
   fails with a stable code.
4. Given a pre-existing dirty path whose fingerprint is unchanged, preflight
   preserves it as user-owned; after the task changes it, preflight treats it
   as task-owned.
5. Given sensitive mobile, dependency, platform, CI, lint, or harness paths,
   effective risk is raised to high; unknown executable paths are at least
   medium; narrow non-policy docs may remain low.

## Acceptance Criteria

1. V2 metadata, impact declarations, required narrative sections, path/action
   boundaries, risk ceiling, repair limit, and timeout are parsed and hashed.
2. New active/queued plans require V2; historical completed plans remain valid
   records and pre-existing legacy active plans are explicitly grandfathered.
3. Task state is written atomically beneath `.tmp/mobilekit/tasks/` and rejects
   unsupported or malformed schemas.
4. Begin and preflight use Git evidence for base revision, committed/dirty
   paths, and content fingerprints.
5. `mobilekit task begin`, `mobilekit task preflight`, `mobilekit task status`,
   and `mobilekit risk classify` are documented and negatively tested.
6. Phase 1 fast/full profiles remain green.

## Implementation Checklist

- [x] Implement V2 plan and authority parsing.
- [x] Implement conservative mobile path/impact risk classification.
- [x] Implement Git change discovery and content fingerprints.
- [x] Implement validated atomic local task state.
- [x] Implement task begin, status, and report-only preflight.
- [x] Upgrade knowledge validation and the execution-plan template.
- [x] Add CLI routing, focused tests, and agent documentation.
- [x] Exercise begin/preflight against this repository and verify Phase 2.

## Decision Log

- 2026-08-11: Keep state under `.tmp/mobilekit/tasks/` -> it is already ignored,
  local, disposable controller state and needs no service dependency.
- 2026-08-11: Use path plus content fingerprint for pre-existing ownership ->
  this protects dirty user work without line-level ownership complexity.
- 2026-08-11: Grandfather completed plans and pre-Phase-2 active plans ->
  historical records remain readable while all new authority is V2.
- 2026-08-11: Bootstrap Phase 2 in one local commit before `task begin` -> the
  repository cannot enforce a controller that does not yet exist; all later
  phases must begin from the committed controller and use preflight normally.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit risk classify
dart run mobile_core_kit_cli:mobilekit task begin --plan docs/exec-plans/active/2026-08-11_harness-phase-2-structured-task-authority.md
dart run mobile_core_kit_cli:mobilekit task preflight --task mobile-harness-phase-2-task-authority --action verify
dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Outcomes on 2026-08-11:

- package analysis: passed with no issues;
- CLI package tests: 121 passed;
- knowledge verification: passed;
- real task begin/status/risk/preflight cycle: passed from clean revision
  `64907f8628dc242ef128b61000b297ed152e2d3a` with no pre-existing paths;
- fast profile: passed, including architecture and both harness test suites;
- full profile: passed, including codegen freshness, architecture checks, 121
  CLI tests, 11 custom-lint tests, advisory duplication reports, and 553
  application tests.

## Runtime Evidence

The applicable runtime evidence is a real begin/status/preflight cycle in this
Git checkout. No application or device behavior changes in Phase 2.

## Rollback

Remove the task/policy modules and CLI routes, restore the legacy plan template
and knowledge validator, and delete ignored `.tmp/mobilekit/tasks/` state. No
application or external data requires migration.

## Risks And Mitigations

- Risk: broad or ambiguous paths accidentally grant authority.
- Mitigation: reject repository roots, traversal, globs, whitespace ambiguity,
  duplicates, protected `.git` paths, and symlink escapes.
- Risk: controller state claims ownership of user work.
- Mitigation: fingerprint every pre-existing path before task execution and
  fail closed on unreadable state.
- Risk: policy makes historical documents invalid.
- Mitigation: enforce V2 prospectively and preserve completed history.

## Completion Notes

Phase 2 added executable V2 task authority without introducing another coding
agent. Existing chat-driven agents can establish a local Git baseline, protect
pre-existing work, inspect risk, and prove scope/action/risk compliance before
they explicitly run a controlled action. The controller state is local,
ignored, versioned, atomic, and fail-closed. Historical plans remain readable;
new plans use the enforced lifecycle contract.

## Follow-ups

- [x] Create Phase 3 only after Phase 2 evidence passes.
