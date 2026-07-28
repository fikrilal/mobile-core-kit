# Duplication Harness Phase 2

Date: 2026-04-19  
Owner: Dante  
Status: active (implementation complete, awaiting review)  
Risk class: medium  
Related issue/PR: N/A

## Objective

Advance the duplication harness from raw actionable detection to reviewed, workflow-usable signal.

Phase 2 must:
1. review the remaining auth model duplicate and decide whether to keep or refactor
2. add allowlist support for reviewed acceptable duplicates
3. teach the filter to distinguish reviewed acceptable duplicates from actionable ones
4. improve output categories so the report explains what kind of duplication it found
5. document how the duplication tool fits into self-review and PR preparation

## Constraints

- architectural constraints:
  - do not build a custom duplicate detector; extend the thin wrapper over `jscpd`
  - do not add paid dependencies
  - keep the review decision explicit in repository-local config, not tribal memory
- product/runtime constraints:
  - this is harness/tooling/documentation work; no product behavior should change
- out of scope:
  - CI hard-fail policy for duplication
  - expanding detection into noisy UI/presentation-heavy paths
  - refactoring the remaining auth model duplicate unless review proves it is worth the abstraction cost

## Acceptance Criteria

1. The remaining `auth_response_model` / `auth_result_model` duplicate is explicitly reviewed and recorded as either accepted or refactored.
2. The duplication filter can load an allowlist of reviewed acceptable duplicates with rationale.
3. The report distinguishes actionable duplicates from reviewed acceptable duplicates.
4. The report uses clearer categories than the current coarse `mapper` label.
5. The agent PR/self-review documentation tells contributors when and how to run the duplication check.

## Implementation Checklist

- [x] Review `lib/features/auth/data/model/remote/auth_response_model.dart` and `lib/features/auth/data/model/remote/auth_result_model.dart` and record the decision.
- [x] Add a repository-local allowlist file for reviewed acceptable duplicates.
- [x] Extend the CLI duplication report filter to:
  - [x] load the allowlist
  - [x] suppress allowlisted duplicates from actionable groups
  - [x] report reviewed acceptable groups separately
  - [x] support allowlist entries with rationale / review metadata
- [x] Improve duplicate categories to separate at least:
  - [x] failure mapper
  - [x] bridge translation
  - [x] model translation
  - [x] workflow tail/helper
  - [x] parser
  - [x] formatter
  - [x] normalization helper
- [x] Update the core duplication profile comments/output expectations if needed.
- [x] Document duplication-harness usage in `docs/engineering/agent_pr_loop.md`.
- [x] Update any docs index or related references if needed.
- [x] Run duplication harness, analyze, and custom lints.

## Decision Log

- 2026-04-19: Phase 2 focuses on reviewed-signal quality instead of broader detection scope -> the next leverage point is trustworthiness, not more raw findings.
- 2026-04-19: Keep `auth_response_model` / `auth_result_model` as reviewed acceptable duplication -> they represent distinct backend contracts and distinct user DTO types, so forcing a shared abstraction would make the models less honest than the detector output is helpful.

## Verification

List exact commands and outcomes.

```bash
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
# Passed
# Result: 0 actionable duplicate groups, 1 reviewed acceptable group
# (auth_response_model/auth_result_model with explicit rationale)

fvm flutter analyze
# Passed

dart run custom_lint
# Passed
```

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static verification is sufficient for this tooling/doc change.

## Risks And Mitigations

- Risk: an allowlist becomes a silent suppression mechanism for real debt.
- Mitigation: require rationale/review metadata and keep reviewed acceptable duplicates visible in the report summary.

- Risk: category heuristics become too clever and too brittle.
- Mitigation: keep category logic explicit and text-pattern-based; do not overfit beyond current repo needs.

## Completion Notes

Phase 2 shipped the reviewed-signal layer for duplication detection:
- added `tool/duplication_allowlist.json` for reviewed acceptable duplicates with rationale
- extended the CLI duplication report filter to separate actionable vs reviewed acceptable groups
- tightened duplicate categories so the report no longer misclassifies value objects or auth use cases
- documented duplication-check usage in the self-review / PR loop

The remaining auth model pair was reviewed and intentionally kept. The harness now reports it as a reviewed acceptable `model_translation` duplicate instead of open debt.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
