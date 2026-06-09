# MobTrace Inline Agent Diagnosis

Date: 2026-06-08
Status: completed
Risk: low
Impact: local agent harness CLI

## Objective

Print a compact, actionable diagnosis after `mobtrace report` and
`mobtrace verify` without requiring agents to open generated report files.

## Constraints

- Keep `failure_report.json` as the diagnosis source of truth.
- Preserve evidence runner exit status from `mobtrace verify`.
- Do not change Maestro, fixture, or device execution behavior.
- Keep output deterministic and shell-testable.

## Acceptance Criteria

- `./mobtrace report latest` prints flow, result, failure class, selector when
  available, suspicious files, suggested action, and report paths.
- `./mobtrace verify ...` prints the same diagnosis after evidence collection.
- A failed evidence runner retains its original exit status.
- Passed reports omit empty failure-only fields cleanly.

## Checklist

- [x] Add compact diagnosis rendering.
- [x] Add MobTrace CLI contract tests.
- [x] Run Bash syntax and ShellCheck verification.
- [x] Run focused MobTrace contract tests.
- [x] Update roadmap status and move this plan to completed.

## Decisions

- Parse the generated JSON with `jq`; do not parse markdown.
- Use environment overrides for test-only reporter and runner substitution,
  matching existing harness patterns.

## Verification Evidence

- `bash -n mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh`
- `shellcheck mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobile_evidence_check.sh`
- `tool/agent/test_maestro_evidence_check.sh`
- `git diff --check`
