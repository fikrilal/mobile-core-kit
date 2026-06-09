# MobTrace Known Failure Signatures

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent failure diagnosis

## Objective

Capture recurring mobile failure patterns as reviewed, deterministic data so
agents receive a concrete next action without relying on prior agent memory.

## Constraints

- Signatures live in `tool/agent/mobtrace_signatures.json`.
- Matching supports failure message, failed command, hierarchy, logs, changed
  files, and failure class.
- Every declared condition must match.
- First matching signature wins in file order.
- Unmatched failures retain generic classification and action.
- No AI-generated diagnosis.

## Acceptance Criteria

- At least three historical signatures are encoded.
- Matched signature ID and action appear in JSON and markdown.
- Signature actions replace the generic suggested action.
- Unmatched runs contain no signature and retain the generic action.

## Checklist

- [x] Add the signature schema and historical signatures.
- [x] Add deterministic signature matching.
- [x] Add signature output to JSON and markdown.
- [x] Add matched and unmatched contract coverage.
- [x] Run shell and surrounding harness verification.
- [x] Update roadmap and move this plan to completed.

## Verification Evidence

- `bash -n tool/agent/mobile_failure_report.sh tool/agent/test_mobile_failure_report.sh`
- `shellcheck tool/agent/mobile_failure_report.sh tool/agent/test_mobile_failure_report.sh`
- `tool/agent/test_mobile_failure_report.sh`
- `tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobile_evidence_check.sh`
- `tool/agent/test_maestro_evidence_check.sh`
- `git diff --check`
