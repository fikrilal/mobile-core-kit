# Unified Mobile Runtime Evidence

## Goal

Add a backward-compatible lane selector to the mobile runtime evidence entry
point and aggregate Flutter integration and Maestro compiled-app evidence.

## Scope

- [x] Preserve the existing Flutter implementation behind a dedicated runner.
- [x] Add `--lane flutter|maestro|all`, defaulting to `flutter`.
- [x] Keep lane-specific arguments explicit and validated.
- [x] Run both lanes to completion for `--lane all`.
- [x] Emit one aggregate summary and machine-readable status.
- [x] Add deterministic orchestration tests.
- [x] Update stable engineering docs.
- [x] Verify standalone and aggregate runtime behavior.

## Exit Criteria

- `--lane flutter` preserves current behavior.
- `--lane maestro` does not execute Flutter integration tests.
- `--lane all` retains both lane artifacts and returns failure when either lane
  fails.

## Verification Evidence

- Shell syntax and deterministic lane-contract tests passed.
- Maestro-only unified entry point passed on API 34:
  `_artifacts/mobile/20260606_phase3_maestro_only/`.
- Aggregate run retained both lanes and returned failure with
  `flutter_exit_status=1` and `maestro_exit_status=0`:
  `_artifacts/mobile/20260606_phase3_aggregate_verified/`.
- The Flutter failure is the existing deep-link integration assertion timing
  out on `PROFILE`; Maestro still ran and passed.
- Explicit APK input is snapshotted before the Flutter lane to prevent its
  integration build from replacing the binary consumed by Maestro.
