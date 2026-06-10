# MobTrace Failure Domain Classification

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent failure diagnosis

## Objective

Classify each MobTrace result by the system area an agent should inspect:
infrastructure, test harness, backend, app, unknown, or none.

## Constraints

- Classification stays deterministic and evidence-based.
- The forensic reporter owns the domain; CLI layers only display it.
- Cleanup failures with an HTTP/backend signal map to `backend`; other cleanup
  failures map to `test_harness`.
- Existing failure classes and runner exit behavior remain unchanged.

## Acceptance Criteria

- `failure_report.json` contains `failureDomain`.
- Markdown and inline diagnosis display the domain.
- Summary JSON uses the reporter-provided domain.
- All specified class-to-domain mappings have contract coverage.
- Passed runs use `failureDomain: none`.

## Checklist

- [x] Add domain classification to the reporter.
- [x] Display domain in markdown and inline output.
- [x] Add reporter and CLI contract coverage.
- [x] Run shell and surrounding harness verification.
- [x] Update roadmap and move this plan to completed.

## Verification Evidence

- `bash -n mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh tool/agent/test_mobile_failure_report.sh`
- `shellcheck mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh tool/agent/test_mobile_failure_report.sh`
- `tool/agent/test_mobile_failure_report.sh`
- `tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobile_evidence_check.sh`
- `tool/agent/test_maestro_evidence_check.sh`
- `git diff --check`
