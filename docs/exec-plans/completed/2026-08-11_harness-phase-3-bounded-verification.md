# Harness Phase 3 — Risk-Aware Verification and Bounded Repair

**Plan version:** 2
**Task ID:** mobile-harness-phase-3-bounded-verification
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 3 locally; no external mutation
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/task/, packages/mobile_core_kit_cli/lib/src/verification/, packages/mobile_core_kit_cli/lib/src/process/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/workflows/verify_workflow.dart, packages/mobile_core_kit_cli/test/, AGENTS.md, docs/README.md, docs/engineering/, docs/exec-plans/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h

Date: 2026-08-11
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Turn report-only task authority into a bounded verification controller that
selects canonical lanes from effective mobile risk, records stable failures
and sanitized diagnostics, permits finite conversational-agent repairs, and
escalates deterministically instead of looping.

## Constraints

- Architecture constraints: keep orchestration in `mobilekit`; reuse the
  existing verify owner and command runner; do not touch application Clean
  Architecture or introduce a second agent runtime.
- Product/runtime constraints: every transition must be recoverable from
  ignored versioned state; diagnostics must be bounded and sanitized; task and
  wall-clock fingerprints must bind evidence to the exact candidate.
- Out of scope: automatic code edits, linked worktrees, runtime oracle
  registry, OpenAPI drift, event intake, publication, and hill climbing.

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

1. Given an authorized task, when `mobilekit task verify --task <id>` runs,
   then preflight selects documented lanes from effective risk, executes them
   fail-fast through the canonical owners, and records candidate-bound results.
2. Given a failed command with secrets or excessive output, when evidence is
   persisted, then it carries a stable boundary/category, redacted bounded
   diagnostics, remediation, duration, and no raw environment or credentials.
3. Given the same failure and unchanged task fingerprint, when the agent asks
   for repair again, then the finite repair budget is consumed and exhaustion
   escalates; a changed fingerprint resets the consecutive repeat count.
4. Given an expired timeout, scope escape, ambiguous state, or unavailable
   required infrastructure, when a controlled transition is attempted, then
   the task escalates without executing another lane.
5. Given a task failure, when the current conversational agent repairs code,
   then `mobilekit` records intent/outcome but never invokes an agent or edits
   production code itself.

## Acceptance Criteria

1. State schema records lifecycle, attempts, selected lanes, fingerprints,
   transitions, failures, repair counters, and escalation reason.
2. Stable failure boundaries and categories are centralized, tested, and
   mapped from canonical verification steps without parsing prose.
3. Lane selection is deterministic: low uses fast; medium/high use full; CI
   and runtime remain separate explicit evidence owners.
4. Task verification enforces plan timeout, preflight, fail-fast execution,
   bounded sanitized capture, and atomic transition persistence.
5. Repair request/outcome commands enforce meaningful candidate change,
   repeated-failure limits, and no automated implementation.
6. A sanitized ignored episode artifact can reconstruct the local loop and
   rejects unsupported schemas.
7. Phase 2 negative tests and Phase 1 fast/full profiles remain green.

## Implementation Checklist

- [x] Define stable task lifecycle, failure taxonomy, and lane registry.
- [x] Extend atomic task state and add sanitized episode persistence.
- [x] Implement timeout-aware task verification through canonical owners.
- [x] Implement bounded repair intent/outcome and repeat-fingerprint policy.
- [x] Add deterministic escalation for exhaustion and unsafe controller state.
- [x] Add CLI routing, negative fixtures, and fail-fast integration tests.
- [x] Document the current-agent verification/repair protocol.
- [x] Exercise a controlled failure/repair/escalation fixture and verify Phase 3.

## Decision Log

- 2026-08-11: Select existing `fast` and `full` profiles as initial lanes ->
  one tested verification owner is simpler and prevents gate drift.
- 2026-08-11: Require the conversational agent to perform repairs -> the
  repository controls the loop but does not become another coding tool.
- 2026-08-11: Persist bounded structured diagnostics, not raw transcripts ->
  local rediscovery remains useful without creating a secret/PII sink.
- 2026-08-11: Add only `verify_workflow.dart` to the original path authority ->
  the canonical owner needs a typed result observer; preflight correctly
  rejected the omission before verification or commit.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit task preflight --task mobile-harness-phase-3-bounded-verification --action verify
dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Outcomes on 2026-08-11:

- package analysis: passed with no issues;
- CLI package tests: 133 passed, including controlled success, redaction,
  changed-candidate repair, repeated unchanged exhaustion, timeout,
  infrastructure escalation, episode recovery, and deadline refusal fixtures;
- knowledge verification: passed;
- authority-scope negative evidence: the first preflight rejected the omitted
  canonical `verify_workflow.dart` path; the plan was narrowed correctly and a
  clean zero-pre-existing-path baseline was re-established before continuing;
- real high-risk `task verify`: selected `full` and passed twice, with final
  fingerprint `e963d7a0ee540a243e49b067843f6e677df7fe27069a061395dc9a4c59e0e94b`
  in 107189 ms;
- final full lane: codegen freshness, knowledge/format/architecture checks, 133
  CLI tests, 11 custom-lint tests, unchanged advisory duplication baselines,
  and 553 application tests passed;
- ignored state migrated from schema 1 to 2 and the episode recorded only
  bounded structured start/pass events.

## Runtime Evidence

No app/device behavior changes. Runtime evidence is a local controller fixture
that proves success, bounded failure capture, candidate-change repair, repeated
failure escalation, timeout escalation, and episode-state recovery.

## Rollback

Remove Phase 3 controller/taxonomy/episode additions and restore the Phase 2
report-only task commands/state schema. Ignored local task state is disposable;
no application or external data migration is required.

## Risks And Mitigations

- Risk: a wrapper creates a second, weaker verification implementation.
- Mitigation: select and invoke the existing typed verify profiles directly.
- Risk: failure output leaks credentials or becomes unbounded context.
- Mitigation: allowlisted structured fields, aggressive redaction, byte/line
  limits, and secret-shaped negative fixtures.
- Risk: repair control loops forever or mistakes retries for progress.
- Mitigation: candidate fingerprints, consecutive-boundary tracking, finite
  counters, plan timeout, and explicit escalated terminal state.

## Completion Notes

Phase 3 added a bounded verification controller around the existing typed
profiles. Effective low risk selects `fast`; medium/high selects `full`.
Failures now have stable categories, bounded redacted diagnostics, atomic
lifecycle/attempt/repair state, and a sanitized local episode. The current
conversational agent still performs every code repair; `mobilekit` only proves
whether the candidate changed and deterministically escalates timeout,
ambiguity, infrastructure loss, scope escape, or repair exhaustion.

## Follow-ups

- [x] Create Phase 4 only after Phase 3 evidence passes.
