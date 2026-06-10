# MobTrace Machine-Friendly Summary

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent harness CLI

## Objective

Add a compact JSON-only report mode for agents and scripts.

## Constraints

- Keep `failure_report.json` as the full report artifact.
- Normal report output must remain human-readable.
- Summary mode must emit JSON only on stdout.
- `failureDomain` defaults to `unknown` until Phase 3 adds classification.

## Acceptance Criteria

- `./mobtrace report latest --summary` emits valid compact JSON.
- `./mobtrace report <run> --summary` emits the same stable schema.
- Summary output contains no prose.
- Full markdown and JSON artifacts remain generated.
- Existing normal report and verify behavior remains unchanged.

## Checklist

- [x] Add report argument parsing and summary rendering.
- [x] Extend MobTrace CLI contract tests.
- [x] Run Bash syntax and ShellCheck verification.
- [x] Run focused and surrounding harness contract tests.
- [x] Update roadmap and move this plan to completed.

## Verification Evidence

- `bash -n mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh`
- `shellcheck mobtrace tool/agent/mobtrace.sh tool/agent/mobile_failure_report.sh tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobtrace.sh`
- `tool/agent/test_mobile_evidence_check.sh`
- `tool/agent/test_maestro_evidence_check.sh`
- `git diff --check`
