# MobTrace Diff Hunk Inspection

Date: 2026-06-09
Status: completed
Risk: low
Impact: local agent failure ranking

## Objective

Use deterministic Git diff-hunk signals to rank suspicious changed files more
precisely than path-only heuristics.

## Constraints

- Read `git diff --no-ext-diff --unified=80`.
- Inspect only added and removed hunk lines.
- Keep path-based ranking as a fallback.
- Do not add AI-generated analysis.
- Keep test inputs isolated from the developer's current worktree.

## Acceptance Criteria

- Changed Maestro selector hunks lead selector failures.
- Changed semantics/test-ID hunks are considered for selector failures.
- Changed API payload/endpoint hunks lead backend failures.
- Changed route/session hunks lead navigation failures.
- Changed fixture/cleanup hunks lead fixture cleanup failures.

## Checklist

- [x] Capture diff hunks and support isolated test inputs.
- [x] Add deterministic hunk matchers and ranking.
- [x] Add reporter contract coverage for required ranking cases.
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
