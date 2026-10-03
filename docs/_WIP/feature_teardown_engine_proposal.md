# Engineering Proposal: Feature Teardown Engine (`mobilekit remove feature`)

**Status:** Proposed (Under Review)  
**Date:** 2026-10-03  
**Target Repository:** `mobile-core-kit` (`packages/mobile_core_kit_cli`)  
**Author:** Ahmad Fikril  
**Source References:**  
- Scaffolding Workflow: [`packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart`](../../packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart)  
- CLI Entrypoint: [`packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart`](../../packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart)  
- Architecture Linting: [`lint/architecture_lints.yaml`](../../lint/architecture_lints.yaml)  
- Architecture Decision: [`ADR/records/0002-clean-architecture-vertical-slices.md`](../../ADR/records/0002-clean-architecture-vertical-slices.md)

---

## 1. Summary & Recommendation

We propose adding a first-class feature teardown command to the repository tooling:
```bash
mobilekit remove feature <feature_name> [options]
```

While `mobilekit scaffold feature` cleanly stamps out a new feature slice, there is currently **no automated inverse operation**. When developers clone `mobile-core-kit` as a foundation for a new product, reference/demo features (such as `merchant_onboarding`) must be manually removed. 

Manual teardown requires editing or deleting files across **9 distinct decoupled touchpoints** (feature code, navigation routes, router registry, DI registrar, home page navigation triggers, architectural lint allowlists, test suites, oracles, and localization strings). Omitting even one step breaks `mobilekit verify` and leaves stale imports or dead code.

The proposed `RemoveFeatureWorkflow` will provide a safe, atomic, and dry-run-capable mechanism to completely unlink and purge any non-protected feature slice while keeping the repository green.

---

## 2. Context & Problem Statement

### 2.1 The Asymmetry Between Scaffolding and Teardown
`mobile-core-kit` acts as an enterprise template. To demonstrate production architecture, it includes complete, verified vertical slices:
- `auth`: Foundational authentication slice.
- `account`: Profile, security, sessions, and account lifecycle.
- `home`: Shell landing page with demo launch entries.
- `merchant_onboarding`: A comprehensive 4-step wizard with reference data caching, aggregate validation, cubit state management, and Maestro integration flows.

When starting a new product (e.g. an e-commerce, banking, or healthcare app), `merchant_onboarding` is irrelevant. However, removing it today requires manual surgical edits across 9 files and directories:

| Step | Area | Location | Manual Action Today | Failure Mode If Missed |
|---|---|---|---|---|
| **1** | Feature Directory | `lib/features/<name>/` | `rm -rf` | Dead code remains compiled |
| **2** | Navigation Directory | `lib/navigation/<name>/` | `rm -rf` | Unused routes compiled |
| **3** | Route Registration | `lib/navigation/app_router.dart` | Remove `import` & `...<name>Routes,` | Analyzer error (`undefined_identifier`) |
| **4** | DI Registration | `lib/core/di/registrars/feature_modules_registrar.dart` | Remove `import` & `<Name>Module.register(locator);` | Analyzer error (`undefined_identifier`) |
| **5** | Architecture Lints | `lint/architecture_lints.yaml` | Remove `- lib/features/<name>/**` block | Unused exception drift |
| **6** | UI Navigation Entry | `lib/features/home/presentation/pages/home_page.dart` | Remove launch button & routes import | Compilation failure |
| **7** | Unit/Widget Tests | `test/features/<name>/` & `test/navigation/<name>/` | `rm -rf` | Broken tests failing CI |
| **8** | Behavioral Oracles | `harness/oracles.yaml` & `maestro/<name>.yaml` | Remove oracle entry & delete YAML | Oracle verification fails |
| **9** | Localization Keys | `lib/l10n/*.arb` (5 files) | Remove associated ARB keys | L10n bloat & translation noise |

This manual process is error-prone, takes 20–30 minutes per feature, and creates unnecessary friction for engineers adopting the template.

---

## 3. Goals & Non-Goals

### Goals
- **Complete Decoupled Teardown:** Completely delete feature directories and reliably unwire all cross-layer references in a single command.
- **Safety & Protected Features:** Protect foundational core slices (`auth`, `account`, `home`, `onboarding`) from accidental deletion unless an explicit `--force-core` flag is passed.
- **Atomic & Reversible (`--dry-run`):** Provide a rich `--dry-run` summary previewing every file deletion and AST/code unwiring before any mutation occurs.
- **Selective L10n Pruning:** Automatically scan and prune matching `<camelCaseFeature>*` keys from all 5 `.arb` translation files, with a `--keep-l10n` bypass flag.
- **Oracle & E2E Alignment:** Automatically remove associated entries in `harness/oracles.yaml` and purge matching Maestro test flows in `maestro/`.
- **Clean Verification Guarantee:** After execution, the tool formats edited files and runs `mobilekit verify --profile fast` to prove the repository remains green.

### Non-Goals
- **Arbitrary Code AST Refactoring:** The command will not attempt to rewrite arbitrary custom business logic in third-party features that may have created bespoke couplings. It adheres strictly to the repository's known registration contracts (`app_router.dart`, `feature_modules_registrar.dart`, `home_page.dart`, `architecture_lints.yaml`, and `oracles.yaml`).
- **Interactive Selective File Picker:** Deleting a feature is an all-or-nothing operation for that slice; granular file-by-file deletion within a feature is out of scope.

---

## 4. Architectural Invariants & Constraints

1. **Pre-flight Cleanliness:** If the repository has uncommitted tracked changes in the files targeted for unlinking (`app_router.dart`, `feature_modules_registrar.dart`, `home_page.dart`, `architecture_lints.yaml`), the command must abort unless `--force` is specified.
2. **Idempotent Pattern Matching:** Unwiring logic must be idempotent: running the removal against an already-unwired or partially removed feature must not crash or corrupt adjacent registrations.
3. **Protected Core Slices:** `auth`, `account`, `home`, and `onboarding` are classified as `ProtectedCore`. Invoking `mobilekit remove feature auth` without `--force-core` must immediately exit with status code `2`.
4. **Localization Parity:** When pruning ARB keys, the tool must update all active project locales (`app_en.arb`, `app_id.arb`, `app_ar.arb`, `app_en_XA.arb`, `app_ar_XB.arb`) synchronously, maintaining metadata (`@key`) symmetry.

---

## 5. System Design & Component Ownership

```
Developer runs:
$ mobilekit remove feature merchant_onboarding [--dry-run]
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│               STEP 1: PREFLIGHT & VALIDATION           │
│ • Validates feature name format (snake_case)           │
│ • Checks if feature is in ProtectedCore list           │
│ • Verifies existence of `lib/features/<feature>`       │
│ • Resolves all targeted files and wiring points        │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│             STEP 2: PLAN EXECUTION MATRIX              │
│ 1. Directories to Delete:                              │
│    - lib/features/<feature>/                           │
│    - lib/navigation/<feature>/                         │
│    - test/features/<feature>/                          │
│    - test/navigation/<feature>/                        │
│ 2. Unwiring Files:                                     │
│    - lib/navigation/app_router.dart                    │
│    - lib/core/di/registrars/feature_modules_registrar  │
│    - lib/features/home/presentation/pages/home_page    │
│    - lint/architecture_lints.yaml                      │
│    - harness/oracles.yaml                              │
│ 3. Files to Delete:                                    │
│    - maestro/<feature>.yaml (if exists)                │
│ 4. L10n ARB Keys to Prune:                             │
│    - lib/l10n/*.arb (prefix: <featureCamelCase>)       │
└───────────────────────────┬────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              │ [Is --dry-run active?]    │
              ├──────────────┬────────────┤
             YES             │           NO
              ▼              │            ▼
   ┌────────────────────┐    │   ┌────────────────────────────────┐
   │ Print Diff Plan &  │    │   │ Execute Unwiring & Deletions:  │
   │ Exit Cleanly (0)   │    │   │ 1. Rewrite wiring files        │
   └────────────────────┘    │   │ 2. Delete directories & files  │
                             │   │ 3. Prune ARB keys & gen-l10n   │
                             │   │ 4. Run `dart format`           │
                             │   │ 5. Trigger verify --profile fast│
                             │   └────────────────────────────────┘
```

### 5.1 Component Ownership in `packages/mobile_core_kit_cli`

| Class / File | Layer | Responsibility |
|---|---|---|
| `RemoveFeatureWorkflow` | Workflow (`src/workflows/`) | Top-level workflow coordinator; orchestrates discovery, plan construction, interactive confirmation, execution, and verification. |
| `FeatureUnwiringEngine` | Engine (`src/workflows/`) | Encapsulates pattern matching, import stripping, and registration pruning for `app_router.dart`, `feature_modules_registrar.dart`, `home_page.dart`, `architecture_lints.yaml`, and `oracles.yaml`. |
| `ArbKeyPruner` | Utility (`src/workflows/`) | Parses JSON ARB files, detects keys prefixed with the camelCase feature name, prunes both value and `@key` metadata entries, and rewrites clean JSON. |
| `MobilekitCli` | CLI Dispatch (`src/cli/`) | Routes `mobilekit remove feature <name>` arguments and registers help text. |

---

## 6. Detailed Unwiring Specifications

### 6.1 `lib/navigation/app_router.dart`
- **Imports to remove:** Lines matching:
  `import 'package:mobile_core_kit/navigation/<feature>/...';`
- **Routes list to remove:** Lines matching:
  `...\b${featureCamelCase}Routes\b,?`

### 6.2 `lib/core/di/registrars/feature_modules_registrar.dart`
- **Imports to remove:** Lines matching:
  `import 'package:mobile_core_kit/features/<feature>/di/...';`
- **Module call to remove:** Lines matching:
  `\b${featurePascalCase}Module\.register\(locator\);`

### 6.3 `lib/features/home/presentation/pages/home_page.dart`
- **Imports to remove:** Lines matching:
  `import 'package:mobile_core_kit/navigation/<feature>/...';`
- **Widget button to remove:** Any `AppButton` block whose `onPressed` references `${featurePascalCase}Routes` or where the button text corresponds to the demo entrypoint.

### 6.4 `lint/architecture_lints.yaml`
- **Exception blocks to remove:** Remove YAML list items under `features_no_cross_feature_imports` matching:
  ```yaml
      - from: lib/features/<feature>/**
        allow:
          - lib/features/<feature>/**
  ```

### 6.5 `harness/oracles.yaml`
- **Oracle blocks to remove:** Any top-level oracle mapping where `target` references `maestro/<feature>.yaml` or `test/features/<feature>/**`.

### 6.6 `lib/l10n/*.arb`
- **Keys to prune:** Any key starting with the camelCase feature name (e.g. `merchantOnboarding*`), along with its `@merchantOnboarding*` metadata object.

---

## 7. CLI Command Specification

### Synopsis
```text
Usage: mobilekit remove feature <name> [options]

Options:
  -h, --help        Print command usage
  -n, --dry-run     Preview changes without deleting files or editing registrations
  -y, --yes         Skip interactive confirmation prompt
      --keep-l10n   Do not prune keys from lib/l10n/*.arb files
      --skip-verify Skip running verification after deletion
      --force-core  Allow deletion of protected core features (auth, account, home, onboarding)
```

### Example Output (`--dry-run`):
```text
$ mobilekit remove feature merchant_onboarding --dry-run

Dry run: would remove feature "merchant_onboarding".

Directories to delete:
- lib/features/merchant_onboarding
- lib/navigation/merchant_onboarding
- test/features/merchant_onboarding
- test/navigation/merchant_onboarding

Files to delete:
- maestro/merchant_onboarding.yaml

Registrations to unwire:
- lib/navigation/app_router.dart (remove import & ...merchantOnboardingRoutes)
- lib/core/di/registrars/feature_modules_registrar.dart (remove import & MerchantOnboardingModule.register)
- lib/features/home/presentation/pages/home_page.dart (remove demo navigation button)
- lint/architecture_lints.yaml (remove architecture exception block)
- harness/oracles.yaml (remove merchant.onboarding-journey)

Localization keys to prune (across 5 ARB files):
- 42 keys matching prefix "merchantOnboarding"

Run without --dry-run to apply this removal.
```

---

## 8. Material Risks & Tradeoffs

| Risk / Tradeoff | Impact | Mitigation Strategy |
|---|---|---|
| **Accidental Core Deletion** | A developer accidentally runs `mobilekit remove feature auth`, breaking the entire application foundation. | Enforce a hardcoded `ProtectedCore` allowlist (`auth`, `account`, `home`, `onboarding`). Abort immediately unless `--force-core` is explicitly supplied. |
| **Partial Regex Matching / Syntax Damage** | Regex matching on `home_page.dart` or `app_router.dart` leaves behind syntax errors (e.g. dangling commas or unbalanced brackets). | 1. Use bounded multiline regex patterns with trailing whitespace/comma trimming.<br>2. Run `dart format` immediately after editing.<br>3. Automatically run `mobilekit verify --profile fast` as a post-condition to catch any syntax defects. |
| **Git Conflicts with Uncommitted Work** | Running the command when the user has unstaged manual edits in `app_router.dart` could overwrite their work. | Pre-flight git dirty check: inspect `git status` for modified registration files and require `--yes` / `--force` if dirty. |

---

## 9. Acceptance Criteria

1. **CLI Interface:**
   - `mobilekit remove feature --help` renders full usage and options.
   - Calling without `<name>` outputs a helpful error with status code `2`.
   - Running with an invalid name (not `snake_case`) fails with status code `2`.
2. **Dry Run Safety:**
   - `--dry-run` lists every directory, file, and wiring modification without writing to disk.
3. **Core Feature Protection:**
   - Attempting to remove `auth` or `account` without `--force-core` is blocked.
4. **Complete End-to-End Teardown:**
   - Running `mobilekit remove feature merchant_onboarding --yes` in a clean checkout:
     1. Deletes `lib/features/merchant_onboarding` and `lib/navigation/merchant_onboarding`.
     2. Deletes `test/features/merchant_onboarding` and `test/navigation/merchant_onboarding`.
     3. Removes imports and registrations from `app_router.dart` and `feature_modules_registrar.dart`.
     4. Removes the demo trigger button from `home_page.dart`.
     5. Cleans `lint/architecture_lints.yaml` and `harness/oracles.yaml`.
     6. Prunes all `merchantOnboarding*` keys across all 5 ARB files.
     7. Runs localization generation (`flutter gen-l10n`).
5. **Post-Removal Verification:**
   - `mobilekit verify --profile fast` passes with 0 analyzer errors, 0 custom_lint violations, and 100% passing tests.
6. **Automated CLI Unit Tests:**
   - New unit tests in `packages/mobile_core_kit_cli/test/workflows/remove_feature_workflow_test.dart` achieve 100% coverage on unwiring logic and CLI options.
