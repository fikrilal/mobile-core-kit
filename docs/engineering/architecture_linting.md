# Architecture Linting (IDE + CI)

This repo enforces **architecture import boundaries** in two places:

- **In the IDE** (VS Code / Android Studio) via `custom_lint` (an analyzer plugin).
- **In CI and `tool/verify.dart`** via `dart run custom_lint` (because `flutter analyze` does not run custom lints).

The goal is to make boundary violations hard to introduce accidentally and easy to catch during reviews.

## What Is Enforced

The main rule today is `architecture_imports`, configured by:

- `tool/lints/architecture_lints.yaml`

This file is the **single source of truth** for the architecture rules. It uses glob patterns relative to the repo root (always use `/` as the separator).

### Current Policy (Core → Features)

- Default: `lib/core/**` MUST NOT import `lib/features/**`.
- Exceptions are explicitly allowlisted in `tool/lints/architecture_lints.yaml` (e.g. feature DI composition).

Note: some exceptions are marked **TEMP** and have TODOs to refactor away.

## Running Locally (CLI)

Run custom lints:

```bash
dart run custom_lint
```

Run the full verify pipeline (includes custom lint):

```bash
dart run tool/verify.dart --env dev
```

If you are in WSL, prefer the Windows toolchain wrappers:

```bash
tool/agent/dartw run custom_lint
tool/agent/dartw run tool/verify.dart --env dev
```

## IDE Setup

Custom linting is enabled through `analysis_options.yaml`:

- `analyzer.plugins: [custom_lint]`
- `custom_lint.rules` is configured in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - architecture_imports:
      config: tool/lints/architecture_lints.yaml
```

After you run `flutter pub get`, you may need to restart the analyzer:

- **VS Code**: Command Palette → `Dart: Restart Analysis Server`
- **Android Studio / IntelliJ**: `Tools` → `Dart` → `Restart Dart Analysis Server`

## Extending the Rules

Add new rules in `tool/lints/architecture_lints.yaml`. Each rule has:

- `from`: files the rule applies to
- `deny`: forbidden import targets (project-relative)
- `exceptions`: allowlists scoped by `from` + `allow`

Examples of common “next rules” in mature apps:

- Domain purity: `features/*/domain/**` cannot import Flutter/UI, networking, or platform SDK packages.
- Feature layering: `features/*/presentation/**` cannot import `features/*/data/**`.
- Cross-feature boundaries: restrict direct imports between features (route through `core/` or a shared contract).

## Troubleshooting

- If you only run `flutter analyze`, you will **not** see `custom_lint` violations. Use `dart run custom_lint` or `dart run tool/verify.dart`.
- If lints don’t show in the IDE, confirm:
  - `custom_lint` is in `dev_dependencies` in `pubspec.yaml`
  - `analysis_options.yaml` has `analyzer.plugins: [custom_lint]`
  - You ran `flutter pub get`
  - You restarted the Dart analysis server
