# Repository Guidelines

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
- Custom lints: run `dart run custom_lint` (note: `flutter analyze` does **not** run custom lints).
- Architecture import boundaries are enforced via `tool/lints/architecture_lints.yaml`.
- UI token and modal conventions are enforced by custom lints; do not rely on memory where the lint already exists.
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
- Use native `git` commands.
- Don’t commit or push unless explicitly asked; if committing, use Conventional Commits.

## Harness Expectations

- Treat agent legibility as a repo-level quality goal:
  - keep boundaries explicit
  - keep naming stable and searchable
  - prefer code and docs that are easy for a future agent run to rediscover
- For non-trivial work, create an execution plan first:
  - `docs/exec-plans/README.md`
  - `docs/exec-plans/active/`
- If the same failure, review comment, or workflow gap appears 2+ times, promote it into the harness instead of relying on memory:
  - lint rule
  - verify script
  - template/scaffold update
  - engineering doc update
  - source-local `README.md`
- Keep `AGENTS.md` small. Use it for the operating contract. Put detailed guidance in:
  - `docs/engineering/*`
  - ADRs under `ADR/records/`
  - source-local `README.md` files near boundary-heavy code

## Agent Verification (required)

Agents must verify changes before claiming completion (when feasible). Use native commands:

- Flutter: `fvm flutter <command...>`
- Dart: `dart <command...>`

Minimum checks (pick what’s relevant to what you changed):

- Analyze: `fvm flutter analyze`
- Custom lints: `dart run custom_lint`
- Tests: `fvm flutter test`
- Codegen (if touching Freezed/JSON/build config): `dart run build_runner build --delete-conflicting-outputs`
- AGENTS project-map drift: `dart run tool/verify_project_map_drift.dart`

Full pipeline (preferred for non-trivial changes):

- `dart run tool/verify.dart --env dev`

Auto-fix (format + import/directive ordering):

- `dart run tool/fix.dart --apply`

Risk-based evidence expectations:

- `low`: code checks are usually sufficient
- `medium`: code checks + targeted runtime evidence when behavior is user-facing, navigation-related, API/session-related, or otherwise hard to prove statically
- `high`: code checks + runtime evidence + human review expectation before merge

Runtime evidence guidance:

- For medium/high-risk mobile changes, follow `docs/engineering/mobile_runtime_harness.md`
- PR delivery workflow and evidence expectations are defined in `docs/engineering/agent_pr_loop.md`

## Agent Preferences (Code Authoring)

- Prioritize clean, readable code. Keep responsibilities small and control flow simple.
- Reuse existing `lib/core/` tokens, theme extensions, widgets, and shared services before adding new UI primitives.
- Prefer small widgets and private helpers when they improve readability, not as ceremony.
- Follow the established architecture and state-management patterns:
  - `docs/engineering/project_architecture.md`
  - `docs/engineering/ui_state_architecture.md`
  - `docs/engineering/validation_architecture.md`
- Respect existing DI and navigation patterns:
  - register feature dependencies in `di/*_module.dart`
  - use established route constants and argument patterns under `navigation/*`
- Prefer enums and value objects over raw strings for domain concepts.
- Keep mapping code small, null-safe, and symmetric across API -> model -> entity conversions.
- Avoid speculative features, placeholder behavior, or bespoke components unless the repo clearly needs them.

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
- High-signal entry points:
  - Architecture & boundaries: `docs/engineering/project_architecture.md`
  - UI state: `docs/engineering/ui_state_architecture.md`
  - Testing: `docs/engineering/testing_strategy.md`
  - Agent delivery loop: `docs/engineering/agent_pr_loop.md`
  - Runtime evidence: `docs/engineering/mobile_runtime_harness.md`
  - Detailed topic docs remain indexed from `docs/README.md`
- After every code change, run the verification commands in “Agent Verification (required)” above.
- For non-trivial changes, default to the repo's harness workflow:
  - plan first
  - verify mechanically
  - collect runtime evidence when risk warrants it
