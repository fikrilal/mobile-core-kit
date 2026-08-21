# Harness Phase 7 — Calibrated Operating Evidence

**Plan version:** 2
**Task ID:** mobile-harness-phase-7-operating-evidence
**Status:** active
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 7 locally; create only an empty checked-in operating ledger and do not promote task outcomes, push, create or update a pull request, merge, deploy, sign, migrate, or release
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/evidence/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/verification/, packages/mobile_core_kit_cli/lib/src/workflows/, packages/mobile_core_kit_cli/test/, harness/, .github/workflows/, docs/README.md, docs/engineering/, docs/exec-plans/, ADR/records/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 8h
**Oracle IDs:** harness.full, external.human-review

Date: 2026-08-12
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Calibrate the existing verification loop, make representative false-green
failures mechanically testable, and establish a strict sanitized operating
evidence ledger whose contents can support later improvement analysis only
after independent review and hosted CI reproduction.

## Constraints

- Architecture constraints: extend the existing Dart `mobilekit` control
  plane; keep application Clean Architecture untouched; prefer strict data and
  small policy functions over a telemetry service or agent platform.
- Product/runtime constraints: checked-in evidence contains only stable
  categorical data; local task state, prompts, reasoning, logs, diffs,
  environment values, credentials, and unrestricted prose never enter it.
- Out of scope: automatically promoting the current task, collecting agent
  internals, changing enforcement from statistical recommendations, running a
  broad mutation-testing service, or granting authority for later work.

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

1. Given the initial checked-in ledger, when evidence verification runs, then
   the empty schema-valid ledger passes while improvement eligibility remains
   explicitly false.
2. Given malformed, duplicate, unsorted, oversized, free-form, unreviewed, or
   non-CI-reproduced evidence, when validation runs, then it fails closed with
   no partial acceptance.
3. Given sanitized qualifying records, when evidence reporting runs, then it
   deterministically reports task count, risk diversity, repair/escalation
   count, profile coverage, duration observations, and unmet eligibility.
4. Given representative weakened gate policies, when the narrow mutation pilot
   runs, then existing policy examples kill the mutants without changing
   production source or becoming a default blocking lane.
5. Given full or hosted CI verification, when the candidate is checked, then
   operating-evidence schema integrity is part of the normal harness result.

## Acceptance Criteria

1. The ledger has a strict versioned, size-bounded, no-extra-fields schema with
   stable IDs, hashes, enums, bounded integer durations, unique sorted records,
   independent-human-review markers, and exact hosted-CI revision evidence.
2. The initial ledger is empty and no local Phase 1–7 result is represented as
   independently reviewed or hosted-CI reproduced.
3. Eligibility requires at least five unique tasks, two risk classes, one
   repair or escalation, and valid review/CI evidence for every record.
4. Calibration distinguishes observations and advisory budgets from gates;
   it does not invent coverage or duration measurements.
5. Gate-honesty fixtures exercise representative pass and fail-closed behavior,
   including a narrow deterministic mutation pilot.
6. CLI help, operating docs, ADR, docs index, and CI/full verification describe
   and enforce the evidence boundary without introducing an agent runtime.
7. Focused tests, package analysis, knowledge/oracle/contract checks, and the
   controller-managed full verification pass on the final candidate.

## Implementation Checklist

- [ ] Add the strict operating-ledger model, validator, report, and tests.
- [ ] Add the empty checked-in ledger and calibrated observation policy.
- [ ] Add consolidated gate-honesty fixtures and a narrow mutation pilot.
- [ ] Include evidence integrity in full and hosted CI verification.
- [ ] Update CLI help, engineering docs, ADR, and documentation index.
- [ ] Run the real Phase 7 task through controlled full verification.

## Decision Log

- 2026-08-12: Begin with an empty ledger -> local completion does not satisfy
  the independent human-review and hosted clean-checkout CI contract.
- 2026-08-12: Keep promotion as a separately reviewed source edit -> a command
  that accepts self-asserted attestations would add ceremony without adding an
  independent trust boundary.
- 2026-08-12: Limit mutation testing to a deterministic policy pilot -> broad
  mutation infrastructure is not justified until the pilot demonstrates value.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit evidence verify
dart run mobile_core_kit_cli:mobilekit evidence mutation-pilot
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit oracle verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run mobile_core_kit_cli:mobilekit task verify --task mobile-harness-phase-7-operating-evidence --env dev
```

## Runtime Evidence

No application behavior changes. Native filesystem and policy fixtures must
prove strict evidence parsing, deterministic reporting, eligibility, and
representative mutant detection. Hosted CI evidence remains unavailable until
a separately authorized push and must not be inferred from local workflow
validation.

## Rollback

Revert the Phase 7 evidence module, checked-in empty ledger, verification hook,
tests, and documentation. Local task episodes remain private and unchanged.

## Risks And Mitigations

- Risk: self-reported local outcomes are mistaken for independent evidence.
- Mitigation: require strict review and hosted-CI records and start empty.
- Risk: metrics become targets and encourage harness gaming.
- Mitigation: keep raw observations categorical/bounded and hill-climb
  eligibility advisory; policy changes remain separately authorized.
- Risk: a mutation framework expands dependency and runtime cost prematurely.
- Mitigation: use one deterministic non-default policy pilot with no new
  package dependency.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
