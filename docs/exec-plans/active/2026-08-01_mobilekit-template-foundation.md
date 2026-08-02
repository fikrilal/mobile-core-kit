# Establish the Mobilekit Template Lifecycle and Manifest Contract

Date: 2026-08-01
Owner: Dante
Status: active (implementation complete, awaiting review)
Risk class: medium
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Establish the repository contract that lets the CLI recognize a copied
mobile-core-kit template before Git initialization and represent customization
state without storing secrets.

This plan provides the foundation for the later transformations. It should
introduce the lifecycle and data contracts without implementing the Android,
iOS, deep-link, Firebase, or broad application-identity transformations.

## Constraints

- architectural constraints:
  - Keep mobile_core_kit_cli and mobile_core_kit_lints as stable harness package names.
  - Keep repository-root discovery and lifecycle orchestration inside the CLI package.
  - Use a checked-in .mobilekit/template.yaml marker instead of the removed tool/ directory.
  - Version .mobilekit/project.yaml; reject unknown schema versions with an actionable error.
- product/runtime constraints:
  - mobilekit init must enter customization automatically.
  - Interactive and non-interactive inputs must normalize to the same internal model.
  - Do not prompt for API endpoints or OIDC client IDs.
  - Do not configure Firebase, signing, Git remotes, or external hosting state.
- out of scope:
  - Applying application, Android, iOS, deep-link, environment, or Firebase transformations.
  - Generation workflow integration beyond command contracts.
  - Residual-default scanning and runtime evidence.

## Acceptance Criteria

1. A copied template is recognized from a nested working directory before
   git init, without relying on .git or tool/.
2. .mobilekit/template.yaml identifies the supported template and can be
   validated independently of the application package name.
3. .mobilekit/project.yaml has a versioned, non-secret model covering the
   repository slug, display name, Dart package, Android identity, iOS identity,
   deep-link mode, Firebase mode, and managed-surface metadata.
4. init and customize expose stable argument/help contracts, and init enters
   the customization flow by default.
5. Interactive input, config-file input, validation errors, normalized derived
   values, and dry-run planning are covered by CLI tests.
6. Secrets and unsupported runtime environment values are rejected from tracked
   manifest/config input.
7. Existing CLI commands and root-location behavior remain compatible for
   already initialized repositories.

## Implementation Checklist

- [x] Add the .mobilekit/template.yaml marker contract and a fixture for a
  repository with no Git metadata.
- [x] Replace the stale tool/-directory root-detection fallback with marker-
  based detection while retaining initialized-project discovery.
- [x] Define manifest/input data types, schema versioning, serialization, and
  validation for identity and integration choices.
- [x] Add normalized input handling for interactive and non-interactive modes,
  including derived Dart package and iOS test bundle ID values, normalized
  Android identity values, and derived flavor IDs.
- [x] Add init and customize command routing, help text, and shared lifecycle
  interfaces without duplicating existing workflow execution.
- [x] Add plan/result models that represent changed, skipped, conflicted,
  external, and generated work.
- [x] Add tests for malformed input, unsupported schema, invalid names/IDs,
  disabled deep links, and secret-like values.
- [x] Update the command reference with the new contract only; defer detailed
  transformation behavior to the later plans.

## Decision Log

- 2026-08-01: Use .mobilekit/template.yaml for root discovery -> copied
  templates may not have Git metadata and the old public tool/ directory is
  no longer a valid identity marker.
- 2026-08-01: Keep the manifest tracked and non-secret -> future customization
  runs need a reviewable source of identity state, but runtime credentials must
  remain outside Git.
- 2026-08-01: Make init enter customization automatically -> the first-use
  workflow should require one post-activation command.
- 2026-08-01: Do not collect API endpoints or OIDC IDs here -> environment
  configuration is separate user-owned runtime setup.

## Verification

Executed after implementation:

~~~bash
(cd packages/mobile_core_kit_cli && dart test)
dart run mobile_core_kit_cli:mobilekit --help
dart run mobile_core_kit_cli:mobilekit doctor
fvm flutter analyze
fvm flutter test
dart run mobile_core_kit_cli:mobilekit verify --env dev
~~~

Outcome: all checks passed. The CLI package suite passed 56 tests; help exposed
the lifecycle commands; doctor passed; Flutter analyze passed; the Flutter
suite passed 553 tests; and the canonical verify gate passed, including
environment/configuration generation, custom lints, duplication checks, and
format verification. Fixture tests prove root discovery through the marker
without .git or tool/.

Additional targeted checks, both passed:

~~~bash
git diff --check
dart run custom_lint
~~~

## Runtime Evidence

Not required for this contract-only plan. Runtime evidence is required after
the platform and integration plans are complete.

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: CLI and fixture evidence are sufficient for this stage.

## Risks And Mitigations

- Risk: The marker is accepted in an unrelated Dart repository.
  Mitigation: Require both the marker and the expected root pubspec structure,
  then validate the template identifier.
- Risk: Manifest schema duplicates mutable runtime configuration.
  Mitigation: Store identity and policy only; keep API/OIDC values in existing
  environment files.
- Risk: Global and pinned CLI invocations diverge.
  Mitigation: Test both command paths and keep orchestration in one CLI package.

## Completion Notes

Implemented the marker contract, versioned non-secret manifest, normalized
interactive/config input, init/customize routing, validation, dry-run and
confirmation behavior, and focused CLI/root-discovery tests. Platform and
source transformations remain follow-on work covered by the later execution
plans.

## Follow-ups

- [x] No unresolved debt was identified for this contract-only execution. The
  later platform/integration plans own the remaining transformations.
