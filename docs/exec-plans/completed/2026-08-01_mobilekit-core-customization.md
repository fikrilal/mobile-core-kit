# Build the Safe Core Customization Engine

Date: 2026-08-01
Owner: Dante
Status: completed
Risk class: medium
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Implement the controlled planning and application engine used by mobilekit init
and mobilekit customize, then use it for application-level package and branding
changes.

The outcome is a safe, repeatable transformation path for Dart package
identity, localized product branding, root metadata, and selected current
documentation. Native platform transformations remain in the Android and iOS
plans.

## Constraints

- architectural constraints:
  - Transformations must be explicit, allowlisted, and owned by the CLI.
  - Keep planning separate from file mutation so dry runs cannot write.
  - Keep the stable CLI/lint package names unchanged.
  - Use the manifest as the baseline for reruns; do not depend on finding the
    original template string everywhere.
- product/runtime constraints:
  - Preserve pseudo-localization markers in ARB files.
  - Do not modify runtime API endpoints or OIDC client IDs.
  - Do not hand-edit generated configuration/codegen outputs.
  - Preserve behavior other than the requested identity/branding changes.
- out of scope:
  - Android Gradle/package-path changes.
  - iOS project/bundle changes.
  - Deep-link policy, Firebase state, external setup, and runtime evidence.
  - Unrestricted rewriting of historical ADRs or engineering records.

## Acceptance Criteria

1. A dry-run produces a categorized plan for package, branding, and selected
   documentation changes without modifying the worktree.
2. The apply path detects changed managed files, requires explicit confirmation,
   and restores the pre-apply state if a write or transformation fails.
3. Changing the Dart package updates the root package name and allowlisted
   package:mobile_core_kit/... imports across application, test, and
   integration-test sources.
4. Localized appTitle values and the root project description are updated while
   pseudo-localized ARB variants retain their markers.
5. Repeating the same customization is idempotent, and a second customization
   can use the manifest rather than the old template values.
6. Unknown occurrences of old identity values are reported rather than silently
   rewritten.

## Implementation Checklist

- [x] Define transformation and file-change interfaces for plan, apply, skip,
  conflict, and external follow-up results.
- [x] Implement managed-file fingerprints or equivalent conflict detection.
- [x] Implement atomic writes/rollback for the planned file set.
- [x] Add validators for Dart package names, repository slugs, display names, and
  path collisions.
- [x] Implement root pubspec.yaml name/description transformation.
- [x] Implement allowlisted Dart import URI transformation without touching CLI
  or lint package imports.
- [x] Implement ARB appTitle transformation while preserving pseudo-locale
  prefixes/suffixes.
- [x] Update selected current README/template references and test fixtures;
  leave historical documents for residual reporting.
- [x] Add fixture-based tests for dry-run, apply, rollback, conflict, and
  idempotency behavior.
- [x] Connect the engine to the init/customize lifecycle from plan 1.

## Decision Log

- 2026-08-01: Use an allowlist rather than global replacement -> package
  imports, generated files, historical docs, and native targets need different
  treatment.
- 2026-08-01: Keep the manifest as the rerun baseline -> later renames must
  remain possible after the original template strings disappear.
- 2026-08-01: Do not prompt for or write API/OIDC values -> the identity engine
  must not become a credential/configuration editor.

## Verification

Executed after implementation:

~~~bash
(cd packages/mobile_core_kit_cli && dart test)
fvm flutter analyze
dart run custom_lint
dart run mobile_core_kit_cli:mobilekit lint
dart run mobile_core_kit_cli:mobilekit verify --env dev
~~~

Outcome: all listed checks passed. The CLI package suite passed 61 tests;
Flutter analyze passed; custom lints passed; the CLI lint workflow passed; and
the canonical verify gate passed all 553 Flutter tests, both duplication
harnesses, modal/color checks, and formatting. Fixture tests cover dry-run,
apply, rollback, conflict, idempotency, residual reporting, pseudo-locale
markers, and harness-package import boundaries.

Additional targeted checks, both passed:

~~~bash
git diff --check
dart format --output=none --set-exit-if-changed \
  packages/mobile_core_kit_cli/lib/src/template \
  packages/mobile_core_kit_cli/test/template_customization_engine_test.dart \
  packages/mobile_core_kit_cli/test/template_workflow_test.dart
~~~

The fixture dry-run left its worktree unchanged. The repository diff and
package format checks also passed. A real repository dry-run requires an
initialized `.mobilekit/project.yaml` or an explicit `--config` input; no
current repository files were customized as part of this execution.

## Runtime Evidence

Not required to prove the pure core engine. Platform behavior is validated by
the Android, iOS, and final end-to-end plans.

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: Compile/analyze plus fixture coverage should prove this stage.

## Risks And Mitigations

- Risk: A package rename misses a source file or changes a stable tooling
  import.
  Mitigation: Scan all application/test/integration source paths, assert no
  stale managed imports remain, and explicitly exclude CLI/lint packages.
- Risk: Rollback leaves a partially rewritten file set.
  Mitigation: Stage all writes, preserve original bytes, and test an injected
  failure during the apply phase.
- Risk: Branding changes invalidate pseudo-locale coverage.
  Mitigation: Test all ARB variants and preserve transformation markers exactly.
- Risk: Documentation updates create noise in historical records.
  Mitigation: Apply a small current-doc allowlist and report the rest.

## Completion Notes

Implemented an explicit transformation registry for root metadata, application
package imports, localized app branding, and the current README heading. The
engine records non-secret managed-file fingerprints in `.mobilekit/project.yaml`,
detects edits before reruns, reports residual defaults as external follow-up,
and applies all writes transactionally with rollback on failure. Native platform
and integration transformations remain assigned to the later execution plans.

## Follow-ups

- [x] No new unresolved debt was identified. Residual references in historical
  or non-allowlisted files are reported by the plan as external follow-up.
