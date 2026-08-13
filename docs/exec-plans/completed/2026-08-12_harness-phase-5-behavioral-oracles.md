# Harness Phase 5 — Behavioral Oracles And Mobile Evidence

**Plan version:** 2
**Task ID:** mobile-harness-phase-5-behavioral-oracles
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 5 locally; no device mutation without an explicit runtime command and no external publication
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/task/, packages/mobile_core_kit_cli/lib/src/oracle/, packages/mobile_core_kit_cli/lib/src/contracts/, packages/mobile_core_kit_cli/lib/src/runtime/, packages/mobile_core_kit_cli/lib/src/verification/, packages/mobile_core_kit_cli/lib/src/workflows/verify_workflow.dart, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/test/, harness/, docs/contracts/, integration_test/, .github/pull_request_template.md, AGENTS.md, docs/README.md, docs/engineering/, docs/exec-plans/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 8h
**Oracle IDs:** harness.full, contract.openapi.snapshot, runtime.mobile-evidence

Date: 2026-08-12
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Make medium/high-risk acceptance evidence independent, registered, and
machine-checkable; give this repository an owned API contract snapshot; and
bind sanitized mobile runtime evidence to the exact controlled task candidate.

## Constraints

- Architecture constraints: extend the existing `mobilekit` control plane;
  keep application Clean Architecture untouched; use small filesystem-backed
  contracts rather than a service or agent launcher.
- Product/runtime constraints: device execution remains explicit and
  single-flight; durable evidence contains sanitized metadata and hashes, not
  secrets, raw identifiers, absolute local paths, or full logs.
- Out of scope: provisioning a device farm, changing backend behavior,
  publishing artifacts, automatic merge, and inventing new application tests
  where no independent acceptance boundary exists.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: yes
- Database/migrations: no
- Platform/Firebase/permissions: yes
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given a medium/high-risk V2 plan, when task authorization or preflight runs,
   then every declared oracle ID resolves in the checked-in registry and the
   registry coverage is compatible with the declared impact areas.
2. Given the checked-in backend OpenAPI snapshot, when contract verification
   runs in a clean clone, then structure and digest are deterministic without
   an absolute sibling-repository dependency.
3. Given an explicitly accepted upstream OpenAPI file, when contract sync runs,
   then it validates first and atomically updates the snapshot and lock without
   recording the operator's absolute source path.
4. Given a controlled task at an exact verified fingerprint, when runtime
   evidence runs, then its durable manifest binds task, plan, base/candidate,
   targets, timing, outcome, artifact hashes, and a stable behavior boundary.
5. Given device IDs, environment values, Firebase source paths, credentials,
   authorization headers, request/response bodies, or raw traces, when durable
   evidence is emitted, then those values are absent; raw logs stay transient,
   bounded, ignored, and separate from the durable manifest.
6. Given runtime preparation needs generated env or Firebase configuration,
   when the run ends or fails, then pre-existing files are restored and newly
   created files are removed so the task candidate is not silently changed.

## Acceptance Criteria

1. V2 task plans support authority-bearing registered oracle IDs; task state
   persists the oracle contract with backward migration and preflight rejects
   drift, missing IDs, and incompatible medium/high-risk coverage.
2. A minimal checked-in oracle registry maps stable IDs to existing profile,
   contract, integration, golden, metric, or manual-review boundaries and is
   validated by `mobilekit` plus tests.
3. A repository-owned OpenAPI snapshot and lock are reviewable, deterministic,
   usable from a clean clone, and managed by explicit verify/sync commands.
4. Runtime evidence requires a controlled task binding for completion-grade
   evidence and verifies the exact current task fingerprint before execution.
5. Durable JSON evidence is schema-versioned, sanitized, repository-relative,
   hash-addressed, size-bounded, and records pass/fail even on early failure.
6. Runtime preparation is transactional for generated env and Firebase files;
   failure-path tests prove restoration.
7. Independent CI coverage verifies registry/contract integrity without a
   device; device procedures remain explicit and single-flight where CI cannot
   credibly provide hardware.
8. Operating docs, task template, CLI reference, runtime guide, and PR loop
   explain oracle selection, evidence eligibility, sanitization, and limits.

## Implementation Checklist

- [x] Add authority-bearing oracle IDs to task plans/state and migrate safely.
- [x] Add and validate the checked-in oracle registry.
- [x] Pin the backend OpenAPI snapshot and deterministic lock.
- [x] Add explicit OpenAPI verify and accepted sync workflows.
- [x] Bind runtime evidence to verified task identity and candidate state.
- [x] Sanitize/hash durable evidence and bound transient logs.
- [x] Make env/Firebase preparation transactional on success and failure.
- [x] Add positive, negative, clean-clone, and failure-path tests.
- [x] Update CI/profile integration and operating documentation.
- [x] Exercise the real Phase 5 task through controlled full verification.

## Decision Log

- 2026-08-12: Treat oracle declarations as task authority, not suggestions ->
  changing the acceptance boundary must require reauthorization.
- 2026-08-12: Keep raw device logs transient and ignored -> durable evidence
  carries only hashes and narrowly redacted signals.
- 2026-08-12: Pin a mobile-owned OpenAPI snapshot -> agents and CI must not
  depend on one developer's absolute backend checkout path.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit oracle verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit task verify --task mobile-harness-phase-5-behavioral-oracles --env dev
```

Outcomes on 2026-08-12:

- package analysis passed with no issues;
- 152 mobilekit CLI tests and 11 custom-lint tests passed;
- 553 application tests passed;
- `oracle verify` validated seven registered oracles and the active plan's
  declared impact coverage;
- `contract openapi verify` validated the pinned snapshot digest
  `a11ba2c6bdaa706c7b41e80b4dead323ae8bb36ce700c2c9fa88e27b0c02c3e3`
  at accepted backend revision `cd06b44b01b99a3ef667ff5fe2a1bff9cb76a3b6`;
- existing advisory duplication baselines remained five core and 126
  small-helper groups;
- real controller-managed `full` verification passed at task fingerprint
  `1d19deee469ed50ef0ff330703174b6f1a2d2137962197a7e6f1f5fab8c880c6`.

## Runtime Evidence

No application behavior changed. Native temporary fixtures proved exact task
binding, selected-oracle enforcement, sanitization, artifact hashing, live and
final 1 MiB log bounds, POSIX owner-only log permissions, transactional
configuration restoration on success/failure, and repository-local contract
verification. A physical device run was neither necessary nor credible for
this harness-only phase.

## Rollback

Remove the registry, contract, and runtime-manifest additions; migrate task
state back only through the supported reader; retain the OpenAPI snapshot for
inspection rather than deleting unrelated runtime artifacts or task branches.

## Risks And Mitigations

- Risk: agent-authored tests become circular evidence.
- Mitigation: register stable boundaries and require impact-compatible oracles
  such as pinned contracts, existing regressions, device procedures, or
  explicit human review rather than accepting any new test path.
- Risk: runtime evidence leaks secrets or machine identity.
- Mitigation: allowlisted durable fields, hashed identifiers, relative paths,
  bounded transient logs, and adversarial negative tests.
- Risk: contract sync silently blesses incompatible backend changes.
- Mitigation: require an explicit accepted sync action, validate before write,
  expose the digest diff for review, and keep backend acceptance human-owned.

## Completion Notes

Phase 5 makes oracle selection part of immutable task authority, validates
impact coverage from a checked-in registry, and adds a mobile-owned locked
OpenAPI snapshot to full/CI. Runtime evidence now requires an exact verified
task and selected integration oracle, emits a sanitized hash-addressed
manifest, confines raw logs, and restores temporary environment/Firebase/build
configuration on every exit path. It remains a repository harness used by the
current conversational agent, not a separate coding-agent product.

## Follow-ups

- [x] Create Phase 6 only after Phase 5 evidence passes.
