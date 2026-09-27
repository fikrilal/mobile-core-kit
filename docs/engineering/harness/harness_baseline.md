# Harness Baseline

This document records measured harness facts before enforcement changes. It is
an observation, not a quality target. Update it only with a dated measurement
and the exact command used.

## 2026-08-10 Pre-Phase-1 Baseline

Environment: local Linux checkout using the repository-pinned FVM Flutter SDK.

| Signal | Observation |
| --- | --- |
| Root test files | 143 `*_test.dart` files |
| CLI package test files | 16 files; 82 tests passed in 3.71 seconds |
| Custom-lint test files | 2 files; 11 tests passed in 6.38 seconds |
| Device integration targets | 2 files |
| Root Flutter tests | 553 tests passed during canonical verification |
| Existing canonical duration | 194.69 seconds with codegen enabled |
| Existing canonical outcome | Failed at the final format check |
| Project-map check | Returned success after skipping a missing map |
| Core duplication | 5 actionable groups; advisory exit |
| Small-helper duplication | 126 actionable groups; advisory exit |
| Coverage policy | CI floor is 55%; current measured value pending Phase 1 verification |

Commands:

```bash
dart test                         # from packages/mobile_core_kit_cli
dart test                         # from packages/mobile_core_kit_lints
dart run mobile_core_kit_cli:mobilekit project-map verify
dart run mobile_core_kit_cli:mobilekit verify --env dev --check-codegen
```

Known blind spots at this point:

- the canonical command did not execute either harness package's tests;
- project-map verification silently skipped missing policy;
- codegen strength differed between local and CI invocations;
- runtime evidence was not selected from task risk or candidate identity;
- no stable task, failure, repair, event, or operating-evidence record existed;
- coverage, duration, and duplication had not yet been calibrated as a joined
  operating baseline.

## 2026-08-10 Phase 1 Completion Baseline

The checkout was warm after dependency resolution and code generation, so the
durations are operational comparisons rather than cold-start guarantees.

| Signal | Observation |
| --- | --- |
| Explicit `fast` profile | Passed in 65.04 seconds |
| Explicit `full` profile | Passed in 125.29 seconds |
| CLI package tests | 97 tests after Phase 1 additions |
| Custom-lint package tests | 11 tests |
| Root Flutter tests | 553 tests in `full` |
| Non-golden coverage run | 549 tests in 59.46 seconds |
| Line coverage | 6,277 / 9,998 lines = 62.78% |
| Core duplication | 5 actionable groups; explicitly advisory |
| Small-helper duplication | 126 actionable groups; explicitly advisory |
| Project-map and knowledge | Required and fail-closed |
| Toolchain | Checkout-local FVM SDK reported; PATH fallback has a stable warning |

Commands:

```bash
dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
fvm flutter test --coverage <all non-golden test files>
```

Phase 1 intentionally does not set new duration, coverage, duplication, or file
size budgets. Coverage remains above the existing 55% CI floor. Later phases
may select or calibrate additional gates only from reviewed task outcomes.
