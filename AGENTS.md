# Repository Guidelines

## Project Map (where to look)

```
assets/
├─ fonts/
├─ icons/
└─ images/

lib/
├─ app.dart                        # MaterialApp.router + theme
├─ main_dev.dart                   # entrypoint (ENV=dev)
├─ main_staging.dart               # entrypoint (ENV=staging) [optional]
├─ main_prod.dart                  # entrypoint (ENV=prod) [optional]
├─ core/                           # cross-cutting infrastructure (template-level)
│  ├─ adaptive/                    # responsive tokens + adaptive widgets
│  ├─ configs/                     # AppConfig/BuildConfig (env-driven)
│  ├─ database/                    # sqflite bootstrap + schema registration
│  ├─ di/                          # GetIt composition (imports feature modules)
│  ├─ events/                      # AppEventBus (cross-feature lifecycle)
│  ├─ network/                     # ApiClient/ApiHelper, endpoints, interceptors, errors
│  ├─ services/                    # app-wide services (analytics, startup, etc.)
│  ├─ session/                     # session + token refresh orchestration
│  ├─ theme/                       # tokens, typography, responsive spacing
│  ├─ user/                        # core user entities + current user abstractions
│  ├─ validation/                  # ValidationError + codes/localizer
│  └─ widgets/                     # shared UI components
├─ features/                       # vertical slices
│  └─ <feature>/
│     ├─ data/                     # datasources + DTOs + repository impl
│     ├─ domain/                   # entities/values/usecases + repo interfaces
│     ├─ presentation/             # bloc|cubit, pages, widgets
│     └─ di/                       # <feature>_module.dart
└─ navigation/                     # GoRouter composition per feature + shells

test/
└─ mirrors lib/                    # `test/<path-under-lib>_test.dart`

.env/
├─ dev.yaml
├─ staging.yaml
└─ prod.yaml

tool/
├─ agent/                          # Windows toolchain wrappers (WSL-safe)
└─ verify.dart                     # full verify pipeline
```

## Simplicity First

- Minimum code that solves the problem. Nothing speculative.
- Combat the tendency toward overengineering:
  - No features beyond what was asked
  - No abstractions for single-use code
  - No "flexibility" or "configurability" that wasn't requested
  - No error handling for impossible scenarios
  - If 200 lines could be 50, rewrite it
- The test: Would a senior engineer say this is overcomplicated? If yes, simplify.

## Coding Style & Naming

- Lints: `flutter_lints` (see `analysis_options.yaml`).
- Custom lints: `custom_lint` is enabled (see `analysis_options.yaml`). Run it via `dart run custom_lint`
  (note: `flutter analyze` does **not** run custom lints).
  - `architecture_imports` (config: `tool/lints/architecture_lints.yaml`) — enforces Clean Architecture import boundaries.
  - `modal_entrypoints` — modal routing/widget entrypoints conventions.
  - `hardcoded_ui_colors` — bans hardcoded UI colors (use tokens; allowlist is in `analysis_options.yaml`).
  - `hardcoded_font_sizes` — bans hardcoded font sizes (use typography tokens/components).
  - `manual_text_scaling` — bans manual text scaling in UI widgets.
  - `spacing_tokens` — enforces spacing tokens usage (no raw padding/margins).
  - `state_opacity_tokens` — enforces opacity tokens usage.
  - `motion_durations` — enforces motion duration tokens usage.
- Indentation: 2 spaces; file names `snake_case.dart`.
- Widgets/classes: `PascalCase`; methods/fields: `camelCase`.
- Use Freezed for immutable models and JSON (keep `part '*.g.dart'` lines in sync via build_runner).
- Aim for industry-grade code: SOLID, DRY, and clean, readable implementations.
  - Keep responsibilities small and cohesive.
  - Avoid duplication; prefer shared utilities/components when it improves clarity.
  - Keep public APIs minimal and consistent; avoid “god” services and over-abstracted layers.

## Testing Guidelines

- Follow `docs/engineering/testing_strategy.md` (source of truth).
- Quick rules of thumb:
  - Mirror paths: `lib/...` → `test/...`
  - Name files `*_test.dart`
  - Prefer unit tests for: Value Objects, use cases, mappers, failure mapping
  - Prefer `bloc_test`/`mocktail` for Bloc/Cubit tests
  - Add widget tests only when UI behavior needs coverage

## Git, Commits & PRs

- PRs: clear description, linked issues, steps to test, and screenshots/GIFs for UI.
- Keep CI green: analyze, tests, and generated code up to date.
- Use `tool/agent/gitw --no-stdin` for git commands in WSL.
- Don’t commit or push unless explicitly asked; if committing, use Conventional Commits.

## Agent Verification (required)

Agents must verify changes before claiming completion (when feasible). Prefer these wrappers:

- Flutter: `tool/agent/flutterw --no-stdin <command...>`
- Dart: `tool/agent/dartw --no-stdin <command...>`

Minimum checks (pick what’s relevant to what you changed):

- Analyze: `tool/agent/flutterw --no-stdin analyze`
- Custom lints: `tool/agent/dartw --no-stdin run custom_lint`
- Tests: `tool/agent/flutterw --no-stdin test`
- Codegen (if touching Freezed/JSON/build config): `tool/agent/dartw --no-stdin run build_runner build --delete-conflicting-outputs`

Full pipeline (preferred for non-trivial changes):

- `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

Auto-fix (format + import/directive ordering):

- `tool/agent/dartw --no-stdin run tool/fix.dart --apply`

## Agent Preferences (Code Authoring)

- Prioritize clean, readable code. Keep widgets small and focused; extract private helpers for
  clarity.
- Before adding new UI constants or bespoke widgets, search `lib/core/` for existing tokens,
  theme extensions (`context.*`), adaptive specs, core widgets, and shared services. Avoid
  hardcoded spacing/sizing/colors/typography; if a token/component is missing, add it to
  `lib/core/` and use it from there.
- UI state must follow `docs/engineering/ui_state_architecture.md`:
  - Cubit-first (forms/simple slices). Prefer Bloc for complex orchestration/concurrency.
  - State is a single immutable snapshot. Default to a `status` enum; use Freezed union states for complex/mutually-exclusive states.
  - For multi-status screens, render via `BlocBuilder` + `switch (state.status)` and delegate to private `_build...` methods for readability.
  - One-shot effects (snackbar/nav) via `BlocListener` + `listenWhen`; avoid side effects inside `build`.
  - Dispatch initial intent at provider creation (route builder), not inside widgets/post-frame.
- Provide skeletons/placeholders for loading states (when applicable), colocated under `presentation/widgets/skeleton/`.
- Prefer enums and value objects over raw strings for domain concepts (avoid “magic strings”).
- For forms, follow the validation architecture: real-time validation in Bloc/Cubit + final-gate validation in use cases (use VOs + stable `ValidationError.code`).
- Reuse theme tokens and extensions (`context.*`) for colors/spacing/typography; avoid hard-coded
  styling values when a token exists.
- Prefer existing components in `lib/core/widgets` (buttons, toggles, etc.). If a required UI
  piece is missing, pause and confirm with the user before introducing a new bespoke widget.
- Keep UI responsive and accessible: avoid cramped rows, prefer Wrap/Grid when space-constrained,
  and respect existing spacing scales.
- Respect existing DI patterns: register datasources, repositories, usecases, and BLoCs in the
  feature `di/*_module.dart` and consume via `locator`.
- Navigation: use the route constants under `navigation/*` and pass parameters via `state.extra` or
  query parameters as established.
- Avoid adding speculative features or placeholders (e.g., social interactions) unless backed by
  data in this repo.
- When mapping API -> model -> entity, keep conversion helpers small, null-safe, and symmetric with
  existing patterns.

## Documentation & Best Practices

- Start here: `docs/README.md` (docs index + navigation).
- Backend contract source of truth (for any API/network/auth/users work): `/mnt/c/Development/_CORE/backend-core-kit`
  - OpenAPI: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
  - Standards: `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/`
- For dependency/package changes:
  - Read upstream docs/changelogs; if web access is needed, ask before guessing.
  - Use `flutter pub outdated` to review version constraints and plan safe upgrades.
- Record architectural changes with ADRs (template-level decisions):
  - Use `ADR/records/` (do not rewrite historical ADRs).
  - Create new ADRs by copying `ADR/template/adr-template.md` to `ADR/records/00xx-short-title.md` (next number).
  - If a decision changes, add a new ADR and mark the old one as superseded.
  - Link the ADR from relevant docs (usually under `docs/engineering/` or `docs/template/`).
- Key engineering guides (source of truth):
  - Architecture & boundaries:
    - `docs/engineering/project_architecture.md`
    - `docs/engineering/data_domain_guide.md`
    - `docs/engineering/model_entity_guide.md`
    - `docs/engineering/architecture_linting.md`
  - UI state & UX governance:
    - `docs/engineering/ui_state_architecture.md`
    - `docs/engineering/modal_governance.md`
    - `docs/engineering/splash_best_practices.md`
  - Validation:
    - `docs/engineering/validation_architecture.md`
    - `docs/engineering/validation_cookbook.md`
    - `docs/engineering/value_objects_validation.md`
  - API contracts & usage:
    - `docs/engineering/api/api_error_handling_contract.md`
    - `docs/engineering/api/api_pagination_cursor_support.md`
    - `docs/engineering/api/api_usage_get.md`
    - `docs/engineering/api/api_usage_post.md`
    - `docs/engineering/api/` (see usage examples)
  - Localization:
    - `docs/engineering/localization.md`
    - `docs/engineering/localization_playbook.md`
  - Testing:
    - `docs/engineering/testing_strategy.md`
  - Analytics:
    - `docs/engineering/analytics_documentation.md`
  - Firebase:
    - `docs/engineering/firebase_setup.md`
  - CI/CD:
    - `docs/engineering/android_ci_cd.md`
- Template + core docs (how to apply this repo as a starter):
  - `docs/template/README.md`
  - `docs/core/README.md` and `docs/core/session/README.md`
  - `docs/contracts/README.md`
- After every code change, run the verification commands in “Agent Verification (required)” above.
