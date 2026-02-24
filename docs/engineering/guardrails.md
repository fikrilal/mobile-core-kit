# Guardrails (Lints + Verify + Scaffolding)

This template is designed to be **AI-friendly** and **review-friendly**: the codebase stays maintainable because correctness and consistency are enforced by automated guardrails.

**Principle:** the “happy path” should also be the *fastest* path:
- Use the standard structure (feature scaffolder).
- Run one canonical verification command before opening a PR.
- Let lints/verify fail fast when something is off.

## TL;DR (what to run)

- Auto-fix safe style issues (format + directive ordering):
  - `dart run tool/fix.dart --apply`
- Canonical quality gate (local):
  - `dart run tool/verify.dart --env dev`
- In WSL (use Windows toolchain wrappers):
  - `dart run tool/fix.dart --apply`
  - `dart run tool/verify.dart --env dev`

## Where guardrails live

- Analyzer + custom lints:
  - `analysis_options.yaml`
  - `tool/lints/architecture_lints.yaml` (architecture import boundaries)
  - `packages/mobile_core_kit_lints/` (custom lint plugin)
- Verify pipeline:
  - `tool/verify.dart` (canonical)
  - `tool/verify_*.dart` (specialized gates)
  - `tool/fix.dart` (safe auto-fix)
- Scaffolding:
  - `tool/scaffold_feature.dart`
- CI parity:
  - `.github/workflows/android.yml`

## Canonical gate: `tool/verify.dart`

`tool/verify.dart` is the single command that should represent “this PR is healthy”.

What it does (high-level):

- Dependency install: `flutter pub get`
- Build config generation: `dart run tool/gen_config.dart --env <env>`
- Localization generation: `flutter gen-l10n`
- I18n hygiene gate: `dart run tool/verify_untranslated_messages.dart`
- Static analysis: `flutter analyze`
- Custom lints: `dart run custom_lint`
- Specialized gates:
  - `dart run tool/verify_modal_entrypoints.dart`
  - `dart run tool/verify_hardcoded_ui_colors.dart`
- Tests: `flutter test` (unless skipped)
- Formatting check: `dart format --set-exit-if-changed .` (unless skipped)

Optional flag:
- `--check-codegen` runs `tool/verify_codegen.dart` (build_runner freshness gate).

## Auto-fix: `tool/fix.dart`

`tool/fix.dart` is intentionally conservative:

- Applies `dart fix --apply --code directives_ordering`
- Runs `dart format .`

This keeps diffs clean and prevents “import order” noise from failing `flutter analyze`.

## Custom lints (IDE + CI)

Custom lints run:
- In IDEs via the analyzer plugin (`custom_lint`)
- In CI / verify via `dart run custom_lint`

The lints are the “policy layer” that keeps architecture + UX consistent as the codebase scales.

**How to suppress (rare):**

- Line-level: `// ignore: <lint_name>`
- File-level: `// ignore_for_file: <lint_name>`

If you find yourself suppressing often, prefer improving the rule (allowlist/config) instead.

### Architecture & dependency boundaries

- `architecture_imports` (config: `tool/lints/architecture_lints.yaml`)
  - Enforces Clean Architecture import boundaries and feature boundaries.
  - Also restricts importing `lib/core/di/service_locator.dart` to composition roots.
- `restricted_imports` (config: `analysis_options.yaml`)
  - Prevents importing low-level dependencies (e.g., `dio`, `firebase_*`, `shared_preferences`) outside approved scopes.

### UX/content consistency

- `hardcoded_ui_strings`
  - Blocks user-facing string literals in common widget contexts (prefer `context.l10n.*`).
- `route_string_literals`
  - Blocks route path literals in navigation calls and route definitions (prefer route constants).

### Design token usage (avoid “magic numbers”)

- `hardcoded_ui_colors`
- `hardcoded_font_sizes`
- `manual_text_scaling`
- `spacing_tokens`
- `radius_tokens`
- `icon_size_tokens`
- `state_opacity_tokens`
- `motion_durations`

### Networking policy (feature datasources)

- `api_helper_datasource_policy`
  - Enforces explicit `host:` + `throwOnError: false` + explicit `requiresAuth:` for `_apiHelper.*` calls in feature datasources.

For more detail on rule intent and extension patterns, see `docs/engineering/architecture_linting.md`.

## Specialized verify scripts

These scripts are used directly in CI and/or called by `tool/verify.dart`:

- `tool/verify_untranslated_messages.dart`
  - Fails if `tool/untranslated_messages.json` contains untranslated keys.
- `tool/verify_codegen.dart`
  - Runs `build_runner` and fails if generated outputs (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are out of date.
- `tool/verify_modal_entrypoints.dart`
  - Ensures modal entrypoints follow the modal governance rules.
- `tool/verify_hardcoded_ui_colors.dart`
  - Verifies no hardcoded UI colors appear in the codebase.

## Feature scaffolding: `tool/scaffold_feature.dart`

Use the scaffolder to avoid “structure drift” and to create lint-friendly, review-friendly defaults.

Examples:
- `dart run tool/scaffold_feature.dart --feature review`
- `dart run tool/scaffold_feature.dart --feature review --slice list`
- `dart run tool/scaffold_feature.dart --feature review --slice list --dry-run`

What it generates:
- `lib/features/<feature>/...` (data/domain/presentation/di + skeletons)
- `lib/navigation/<feature>/...` (routes stubs)
- `test/features/<feature>/...` (test skeleton mirroring lib paths)

Important behavior:
- Refuses invalid `snake_case` feature/slice names.
- Refuses to overwrite existing directories/files.
- Does **not** auto-create l10n keys (to avoid failing the untranslated messages gate); it prints a checklist instead.

## CI parity

CI should run the same gate as local development to keep trust high:

- `.github/workflows/android.yml` uses `dart run tool/verify.dart --env prod --check-codegen` as the canonical gate.
- Lint plugin tests (`packages/mobile_core_kit_lints`) run separately because they are a different package boundary.

## How to add a new guardrail

1) Prefer config-driven rules first:
- Add/extend architecture boundaries in `tool/lints/architecture_lints.yaml`.

2) If you need AST-level enforcement:
- Add a custom lint rule in `packages/mobile_core_kit_lints/`.
- Add config in `analysis_options.yaml`.
- Add unit tests in `packages/mobile_core_kit_lints/test/`.
- Document it in:
  - `docs/engineering/architecture_linting.md`
  - this file (`docs/engineering/guardrails.md`)

3) If the guardrail is a “repo gate”:
- Add a `tool/verify_*.dart` script and call it from `tool/verify.dart`.
- Add it to CI (or rely on CI calling `tool/verify.dart`).

