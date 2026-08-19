# Harness Phase 6 — Event Intake, Maintenance, And Verified Handoff

**Plan version:** 2
**Task ID:** mobile-harness-phase-6-event-maintenance-handoff
**Status:** active
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 6 locally; do not push, create or update a pull request, merge, deploy, sign, migrate, release, or invoke any external publication adapter
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/ci/, packages/mobile_core_kit_cli/lib/src/events/, packages/mobile_core_kit_cli/lib/src/handoff/, packages/mobile_core_kit_cli/lib/src/maintenance/, packages/mobile_core_kit_cli/lib/src/task/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/test/, harness/, .github/actions/, .github/workflows/, .github/pull_request_template.md, AGENTS.md, docs/README.md, docs/engineering/, docs/exec-plans/, ADR/records/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 10h
**Oracle IDs:** harness.full, external.human-review

Date: 2026-08-12
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Make queued work safely selectable without creating authority, provide a fixed
read-only maintenance loop, independently classify and verify clean CI
candidates behind one stable required status, and make commit/push/draft-PR
handoff possible only through fresh action-specific approval.

## Constraints

- Architecture constraints: extend the existing Dart `mobilekit` control
  plane; keep application Clean Architecture untouched; use bounded local
  state and explicit adapters rather than a daemon or agent platform.
- Product/runtime constraints: CI must not trust local task state; maintenance
  must not change tracked source; publication operations must bind the exact
  verified candidate, task paths, branch, remote, and one expiring approval.
- Out of scope: launching agents, deriving tasks from event payloads, automatic
  retries of ambiguous external actions, force push, merge, deployment,
  signing, migrations, release, and executing push or draft-PR in this phase.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: yes

## Acceptance Scenarios

1. Given one already-authorized queued V2 plan and no active V2 task, when
   one-shot event intake runs, then it atomically promotes exactly that plan,
   begins its task, and records a private strict receipt bound to the plan and
   authority hashes.
2. Given the same event is delivered again or intake is interrupted after its
   claim, when intake reruns, then it deterministically returns the accepted
   result or recovers the single claim without creating a second task.
3. Given an active V2 task, ambiguous claims, a changed queued plan, or event
   data that attempts to supply paths/actions/risk/credentials, when intake
   runs, then it fails closed without creating authority.
4. Given scheduled maintenance, when its one-shot command runs, then only the
   checked-in fixed registry executes, tracked source remains byte-for-byte
   unchanged, and the sanitized report covers lifecycle/knowledge,
   architecture, duplication, dependency/codegen drift, stale evidence, and
   harness honesty.
5. Given clean base/head revisions, when CI classification runs, then it uses
   Git diff plus changed V2 plan risk/impacts, fails closed on invalid plans,
   and emits deterministic outputs for runtime selection.
6. Given hosted CI, when a candidate runs, then independent `CI Risk`, `CI
   Full`, selected `CI Runtime`, and `CI Governance` lanes feed exactly one
   stable `CI Required` result with immutable actions, bounded permissions,
   timeouts, cancellation, and sanitized short-lived artifacts.
7. Given a freshly verified task, when handoff dry-run runs for one of commit,
   push, or draft-PR, then it revalidates candidate fingerprint, successful
   episode, exact paths, branch, and credential-free remote and creates one
   expiring action-specific challenge whose hash alone is persisted.
8. Given no valid fresh challenge, a changed candidate, pre-staged paths, an
   unexpected branch/remote, expired/reused approval, or an uncertain prior
   outcome, when a handoff mutation is attempted, then it fails closed.
9. Given an authorized mutation, then commit stages only exact verified paths,
   push has no force capability, draft PR is draft-only, and merge/deploy/
   signing/migration/release are absent from the adapter API.

## Acceptance Criteria

1. Event intake is one-shot, deterministic, crash-recoverable, idempotent, and
   promotes only a checked-in queued V2 plan whose authority already exists.
2. Strict private event receipts are size-bounded, schema-validated, atomic,
   and contain no raw webhook payload, credentials, machine identity, or free
   text from an external event.
3. Maintenance uses a source-owned registry, cannot accept command text, runs
   with a lock and deadlines, proves tracked-source non-mutation, and emits a
   bounded sanitized report under ignored local state.
4. Base/head classification and CI runtime selection are deterministic and
   covered by positive and fail-closed fixtures.
5. A clean-checkout workflow exposes the five named CI jobs and its sole
   aggregate accepts runtime only as success or an intentional skip.
6. All third-party actions used by required CI are pinned to full immutable
   SHAs; checkout credentials are not persisted; workflow/job permissions,
   concurrency, timeouts, and retention are explicit.
7. Handoff freshness and separate authority are independently enforced with
   strict private approval state and ambiguous outcomes are never replayed.
8. CLI help, operating docs, ADRs, task/PR guidance, and AGENTS describe the
   commands, trust boundaries, unavailable actions, and no-daemon workflow.
9. Focused tests, package analysis, knowledge/oracle/contract gates, and the
   real controller-managed full verification pass.

## Implementation Checklist

- [ ] Add queued-plan event activation, strict receipts, recovery, and tests.
- [ ] Add the fixed read-only maintenance registry, report, and tests.
- [ ] Add clean base/head CI classification and output rendering.
- [ ] Add fresh action-specific handoff approval and narrow adapters.
- [ ] Add the independent stable required CI workflow and policy checks.
- [ ] Pin required CI actions and document security/retention boundaries.
- [ ] Update CLI routing, harness docs, ADRs, AGENTS, and PR guidance.
- [ ] Exercise negative authority/freshness/ambiguity fixtures.
- [ ] Run the real Phase 6 task through controlled full verification.

## Decision Log

- 2026-08-12: Treat event intake as deterministic queued-plan discovery rather
  than accepting a payload-selected plan -> an event may select existing
  authority but must never manufacture it.
- 2026-08-12: Preserve action-specific handoff adapters but do not invoke push
  or draft-PR -> implementation authority is distinct from publication
  authority and the user requested a local-only result.
- 2026-08-12: Use one mobile-owned CI workflow for the stable aggregate ->
  cross-workflow status composition is less deterministic for branch rules.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit oracle verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run mobile_core_kit_cli:mobilekit task verify --task mobile-harness-phase-6-event-maintenance-handoff --env dev
```

## Runtime Evidence

No application behavior changes. Native Git/filesystem fixtures must prove
event promotion/recovery, source-clean maintenance, clean-diff CI selection,
and handoff freshness/approval/path/branch/remote behavior. Hosted CI and real
external handoff evidence remain unavailable until a separately authorized
push; this limitation must be recorded without weakening local policy tests.

## Rollback

Revert the Phase 6 command modules, workflow, and documentation commits. Keep
any uncertain handoff receipt for manual reconciliation; never delete or retry
an ambiguous external outcome automatically.

## Risks And Mitigations

- Risk: an untrusted event silently broadens task authority.
- Mitigation: derive identity from the queued plan itself, bind receipt hashes,
  and expose no payload fields for paths/actions/risk/oracles.
- Risk: maintenance intended as observation mutates generated source.
- Mitigation: use fixed non-mutating checks and compare tracked repository
  state before/after every run.
- Risk: local verification becomes mistaken for publication permission.
- Mitigation: require a fresh one-time action-specific approval and persist
  executing/uncertain before external mutation.
- Risk: a passing local fixture overstates hosted CI correctness.
- Mitigation: statically verify workflow invariants now and explicitly defer
  hosted-run evidence until the separately authorized push.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
