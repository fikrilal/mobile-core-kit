# Harness Phase 8 — Controlled Improvement Analysis

**Plan version:** 2
**Task ID:** mobile-harness-phase-8-controlled-improvement
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 8 locally; create only an empty improvement ledger and do not add a hypothesis, alter harness enforcement, push, create or update a pull request, merge, deploy, sign, migrate, or release
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/improvement/, packages/mobile_core_kit_cli/lib/src/evidence/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/workflows/knowledge_workflow.dart, packages/mobile_core_kit_cli/test/, docs/README.md, docs/engineering/, docs/exec-plans/, ADR/records/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 8h
**Oracle IDs:** harness.full, external.human-review

Date: 2026-08-12
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Add deterministic, read-only trend analysis and a strict falsifiable harness
improvement protocol that stays disabled until independently reviewed operating
evidence is eligible and never grants authority to change its own policy.

## Constraints

- Architecture constraints: extend `mobilekit`; keep application Clean
  Architecture untouched; keep counting and decisions deterministic and small.
- Product/runtime constraints: hypotheses and evaluations use only strict
  reviewed categorical evidence, one isolated high-risk plan, shadow outcomes,
  immutable safety invariants, and human terminal decisions.
- Out of scope: adding a current hypothesis, self-creating a plan, editing a
  gate, automatic keep/revert, launching an agent, commit/push/PR/merge/deploy,
  statistical significance claims, or unrestricted prose/model telemetry.

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

1. Given the current empty operating ledger, when improvement analysis or
   shadow evaluation runs, then status is `disabled`, no recommendation exists,
   and no tracked file changes.
2. Given eligible reviewed evidence, when trends are analyzed, then recurring
   categorical boundaries and rates are aggregated deterministically without
   interpreting prose or agent output.
3. Given a malformed, concurrent, non-falsifiable, authority-expanding,
   risk-lowering, verification-weakening, privacy-expanding, or publication-
   expanding hypothesis, when validation runs, then it fails closed.
4. Given one human-approved evaluating hypothesis and enough disjoint later
   reviewed outcomes, when shadow evaluation runs, then it emits exactly
   `keep`, `revert`, or `inconclusive` from the declared metric/effect/cost
   contract and makes no policy mutation.
5. Given a terminal ledger entry, when validation runs, then its recorded
   recommendation and evidence window must match deterministic shadow results
   while its human decision remains explicit.

## Acceptance Criteria

1. The strict size-bounded improvement ledger starts empty and rejects extra
   fields, duplicate/unsorted IDs, multiple evaluating hypotheses, unsafe
   paths, missing invariants, and evidence or plan mismatches.
2. Analysis stays disabled until Phase 7 eligibility is true and eligibility
   itself grants no plan, edit, publication, or policy authority.
3. Hypotheses identify a recurring stable pattern, baseline IDs, target,
   metric, minimum effect, cost ceiling, later evaluation window, immutable
   invariants, exact rollback paths, human owner/approver, and separate plan.
4. Approved/evaluating plans are high risk, harness-impacting, scope-bounded,
   and grant exactly edit/verify; owner and approver are distinct stable human
   IDs.
5. Shadow evaluation excludes baseline tasks, uses only later reviewed records,
   and changes no source or enforcement.
6. CLI help, operating docs, ADR, docs index, and repository knowledge describe
   and enforce the disabled-by-default protocol.
7. Focused tests, package analysis, knowledge/evidence/oracle/contract checks,
   and controller-managed full verification pass.

## Implementation Checklist

- [x] Add deterministic trend aggregation and strict improvement-ledger parsing.
- [x] Add hypothesis/plan/invariant validation and shadow evaluation.
- [x] Add the empty ledger, CLI check/analyze/shadow commands, and tests.
- [x] Integrate improvement integrity with repository knowledge verification.
- [x] Update engineering docs, ADR, CLI reference, and docs index.
- [x] Run the real Phase 8 task through controlled full verification.

## Decision Log

- 2026-08-12: Keep the initial improvement ledger empty -> operating evidence
  is currently ineligible, so no valid hypothesis can be proposed.
- 2026-08-12: Make recommendations read-only and human-terminal -> evidence can
  support a decision but cannot grant authority or modify the harness.
- 2026-08-12: Permit one evaluating hypothesis -> overlapping harness changes
  would make shadow attribution ambiguous.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit improve check
dart run mobile_core_kit_cli:mobilekit improve analyze
dart run mobile_core_kit_cli:mobilekit improve shadow
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit oracle verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run mobile_core_kit_cli:mobilekit task verify --task mobile-harness-phase-8-controlled-improvement --env dev
```

Results on the final candidate:

- controller-managed full verification passed on attempt 1;
- 205 CLI tests, 11 custom-lint tests, and 553 application tests passed;
- analyzer, custom lint, formatting, knowledge/evidence/improvement, oracles,
  OpenAPI, codegen, and both required duplication profiles passed;
- real analysis and shadow commands stayed disabled against the empty ledger,
  emitted no recommendation, and made no mutation;
- fixtures proved eligible trends, inconclusive windows, keep/revert decisions,
  terminal recomputation, plan/invariant/privacy/path/risk, and concurrency rules.

## Runtime Evidence

No application behavior changes. Deterministic fixtures must prove disabled,
eligible, invalid, inconclusive, keep, and revert cases plus source
non-mutation. Hosted CI remains unavailable until separate publication
authority and is not inferred locally.

## Rollback

Revert the Phase 8 improvement module, empty ledger, verification hook, tests,
and documentation. Preserve Phase 7 operating evidence unchanged.

## Risks And Mitigations

- Risk: recommendations silently become self-modifying policy.
- Mitigation: commands are read-only, lifecycle edits are reviewed source
  changes, and every actual experiment requires separate high-risk authority.
- Risk: weak or cherry-picked evidence produces an attractive false signal.
- Mitigation: strict recurring patterns, disjoint baseline/later windows,
  minimum sample sizes, cost ceilings, and explicit inconclusive results.
- Risk: overlapping experiments destroy attribution.
- Mitigation: allow at most one evaluating hypothesis.

## Completion Notes

Established deterministic, read-only, human-terminal harness improvement. The
checked-in ledger remains empty and the real loop remains disabled because no
operating record yet satisfies the independent review and hosted-CI contract.
No hypothesis, policy change, agent runtime, publication, or external action
was introduced.

## Follow-ups

- [x] No unresolved implementation debt; evidence collection and any future
  hypothesis are deliberately separate reviewed operating work.
