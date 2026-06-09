# MobTrace Flow Metadata Correlation

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent failure ranking

## Objective

Allow Maestro flows to declare code ownership in comments and use that
metadata to bias MobTrace suspicious-file ranking.

## Constraints

- Metadata must remain YAML comments and not affect Maestro.
- Metadata is optional.
- Resolve flow files from existing evidence `metadata.txt`.
- Strong diff-hunk evidence stays ahead of metadata ownership.
- Existing deterministic path fallback remains unchanged when metadata is
  absent or invalid.

## Acceptance Criteria

- Login/logout metadata covers auth, session runtime, and navigation.
- Changed files under owned prefixes rank ahead of generic path fallback.
- Missing metadata produces the same fallback ranking as before.
- Parsed metadata is visible in generated JSON and markdown.

## Checklist

- [x] Add metadata to the login/logout flow.
- [x] Resolve and parse optional flow metadata.
- [x] Integrate ownership into ranking.
- [x] Add metadata and fallback contract coverage.
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
