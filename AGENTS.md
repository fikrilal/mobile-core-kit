# Repository Guidelines

## Project Structure & Modules

- `lib/`: Dart source. Organized by feature: `core/` (config, theme, network, DI), `features/`,
  `navigation/`, `presentation/`.
- `assets/`: images, icons, fonts (declared in `pubspec.yaml`).
- `.env/`: YAML per environment (`dev.yaml`, `staging.yaml`, `prod.yaml`).
- `tool/`: project scripts (e.g., `gen_config.dart`).
- Platform folders: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`.
- `test/`: Flutter tests (by feature when present).

## Build, Test, Develop

- Install deps: `fvm flutter pub get`
- Generate config: `dart run tool/gen_config.dart --env dev` (or `staging`/`prod`)
- Codegen (Freezed/JSON): `dart run build_runner build --delete-conflicting-outputs`
- Run app (dev): `fvm flutter run -t lib/main_dev.dart --dart-define=ENV=dev`
- Analyze: `fvm flutter analyze`  • Format: `fvm dart format .`
- Tests: `fvm flutter test`

## Coding Style & Naming

- Lints: `flutter_lints` (see `analysis_options.yaml`).
- Indentation: 2 spaces; file names `snake_case.dart`.
- Widgets/classes: `PascalCase`; methods/fields: `camelCase`.
- Use Freezed for immutable models and JSON (keep `part '*.g.dart'` lines in sync via build_runner).
- Aim for industry-grade code: SOLID, DRY, and clean, readable implementations.
  - Keep responsibilities small and cohesive.
  - Avoid duplication; prefer shared utilities/components when it improves clarity.
  - Keep public APIs minimal and consistent; avoid “god” services and over-abstracted layers.

## Testing Guidelines

- Framework: `flutter_test`.
- Place tests under `test/<feature>/...` mirroring `lib/` paths.
- Name files `*_test.dart`; keep unit tests fast; prefer widget tests for UI.
- Run with `fvm flutter test`; aim to cover core logic and mappers.

## Commit & PR Guidelines

- Conventional commits (e.g., `feat:`, `fix:`, `chore:`, optional scope `feat(flashcard): ...`).
- PRs: clear description, linked issues, steps to test, and screenshots/GIFs for UI.
- Ensure CI passes: analyze, tests, and generated code up to date.
- **Do not run `git commit` unless the user explicitly asks for it.**

### Commit Flow (Windows host via CMD)

All Git commands must run through the Windows shell so they can access the host credentials:

1. Stage changes  
   `cmd.exe /c "cd /d C:\Development\_SIDE\orymu-mobile && git add -A"`
2. Commit with a conventional message (escape quotes carefully)  
   `cmd.exe /c "cd /d C:\Development\_SIDE\orymu-mobile && git commit -m \"feat(scope): message\""`
3. Push to origin (replace branch as needed)  
   `cmd.exe /c "cd /d C:\Development\_SIDE\orymu-mobile && git push origin <branch>"`

If escaping becomes messy, create a temporary `.bat` script with the desired command and execute it
via `cmd.exe /c script.bat`. Line-ending warnings about CRLF are expected on Windows and can be
silenced with `git config core.autocrlf true`.

## Security & Config

- Do not commit secrets; tokens flow via `AppConfig.init` and secure storage.
- Edit `.env/*.yaml` and re-run `gen_config.dart` to refresh `lib/core/configs/build_config_values.dart`.
- Firebase: ensure platform configs are present and FCM background handler remains registered.

## Agent Preferences (Code Authoring)

- Prioritize clean, readable code. Keep widgets small and focused; extract private helpers for
  clarity.
- Follow the feature BLoC builder pattern consistently:
    - Use a `BlocBuilder` with a `switch (state.status)` returning dedicated methods:
        - `initial/loading` -> `_buildLoadingState()` (or feature-specific)
        - `success` -> `_buildSuccessState(state)`
        - `failure` -> `_buildErrorState(state.errorMessage)`
        - `loadingMore` -> `_buildLoadingMoreState(state)` (if applicable)
- Always provide skeletons/placeholders for loading states, colocated under `widgets/skeleton/`
  where relevant.
- Prefer enums and value types over raw strings for domain concepts (e.g., use `FlashcardType`
  instead of hard-coded keys like 'QA', 'CLOZE').
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

- Always consult documentation when context is unclear or when changing package/dependency versions.
    - Fetch latest package docs/changelogs as needed. If internet access is restricted or fails,
      pause and ask the user for network access instead of forcing execution.
    - Use `flutter pub outdated` to review version constraints and plan safe upgrades.
- Follow the engineering guides under `docs/engineering/` for architecture and implementation details:
    - `docs/engineering/project_architecture.md` — Clean Architecture + vertical slices, DI,
      navigation.
    - `docs/engineering/ui_state_architecture.md` — UI state with Bloc/Cubit, status enums, effects.
    - `docs/engineering/model_entity_guide.md` — Freezed models, entities, and mapping patterns.
    - `docs/engineering/validation_architecture.md` — Layered, predictable validation approach.
    - `docs/engineering/validation_cookbook.md` — Practical validation patterns and snippets.
    - `docs/engineering/value_objects_validation.md` — Value objects for inputs and form validation.
    - `docs/engineering/firebase_setup.md` — Flavor-aware Firebase + env config.
    - `docs/engineering/testing_strategy.md` — Testing pyramid, patterns, and examples.
    - `docs/engineering/android_ci_cd.md` — Android CI/CD pipeline and Play upload strategy.
- Testing rules of the road live in `docs/engineering/testing_strategy.md`. Follow the pyramid +
  naming conventions there, use `bloc_test`/`mocktail`, and ensure every change adds/updates the
  required unit + bloc tests before merging.
- After every code change, run analyze/lints to detect regressions early. If tooling fails, request
  command access and do not force-run in constrained environments.

## Tooling Tips (FVM & WSL)

- Prefer using `fvm` for Flutter/Dart commands as pinned in `.fvmrc`. If you don’t use FVM, replace
  `fvm flutter` with `flutter` and `fvm dart` with `dart`.
- When working inside WSL, run Flutter/Dart via the Windows toolchain to avoid CRLF shim issues. The
  SDK is typically at: `D:\\DEV\\SDK\\Flutter\\fvm\\versions\\3.38.4\\bin` (adjust if your install differs).
    - Prefer repo-pinned SDK to avoid machine-specific paths:
      - `cmd.exe /C "cd /d D:\\Development\\_CORE\\mobile-core-kit && .fvm\\flutter_sdk\\bin\\flutter.bat analyze"`
      - `cmd.exe /C "cd /d D:\\Development\\_CORE\\mobile-core-kit && .fvm\\flutter_sdk\\bin\\dart.bat run build_runner build --delete-conflicting-outputs"`
    - Or use your global FVM SDK directly:
      - `cmd.exe /C D:\\DEV\\SDK\\Flutter\\fvm\\versions\\3.38.4\\bin\\flutter.bat analyze`
      - `cmd.exe /C D:\\DEV\\SDK\\Flutter\\fvm\\versions\\3.38.4\\bin\\dart.bat run build_runner build --delete-conflicting-outputs`
- Always run lint/analyze after making changes to catch errors early:
    - `fvm flutter analyze` (or the WSL/Windows command shown above)
- If analyze/lint or other commands fail due to environment or permission constraints, do not force
  execution. Ask the user for command access/approval to proceed.
