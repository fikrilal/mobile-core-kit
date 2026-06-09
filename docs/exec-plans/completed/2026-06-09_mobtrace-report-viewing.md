# MobTrace Report Viewing Ergonomics

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent CLI

## Objective

Add `mobtrace show` so agents can print a full Markdown report without
remembering artifact paths or accidentally rerunning mobile evidence.

## Constraints

- `show` may invoke only the report generator.
- Historical pass/fail status must not control the command exit code.
- Refresh reports when missing or when relevant inputs are newer.
- Print report Markdown only on stdout.

## Acceptance Criteria

- `./mobtrace show latest` resolves and prints the newest report.
- `./mobtrace show <run>` prints an explicit run.
- Fresh reports are reused.
- Missing or stale reports are regenerated.
- Evidence runners are never invoked by `show`.
- Historical failed runs still return exit status `0`.

## Checklist

- [x] Add report freshness detection.
- [x] Add `show` command parsing and Markdown output.
- [x] Add public CLI contract coverage.
- [x] Run shell and surrounding harness verification.
- [x] Update roadmap and move this plan to completed.

## Verification Evidence

- `bash -n mobtrace tool/agent/mobtrace.sh tool/agent/test_mobtrace.sh`
- `shellcheck mobtrace tool/agent/mobtrace.sh tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobile_failure_report.sh`
- `tool/agent/test_mobile_evidence_check.sh`
- `tool/agent/test_maestro_evidence_check.sh`
- `git diff --check`
