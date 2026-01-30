# Environment Config (`.env/*.yaml`)

This template uses YAML files under `.env/` to configure environment-specific settings (dev/staging/prod). A small generator script converts these YAML files into a typed `BuildConfig` API used by the app at runtime.

## Files

- `.env/dev.yaml`
- `.env/staging.yaml`
- `.env/prod.yaml`

Examples live next to them:

- `.env/dev.example.yaml`
- `.env/staging.example.yaml`
- `.env/prod.example.yaml`

## How It Works

1) You edit `.env/<env>.yaml`.

2) You run:

`dart run tool/gen_config.dart --env <env>`

3) The script writes:

`lib/core/foundation/config/build_config_values.dart` (generated; do not edit)

4) App code reads values via:

`lib/core/foundation/config/build_config.dart` (`BuildConfig.*`)

## Schema

All keys are optional in YAML, but your selected env file must exist and be non-empty when generating config.

### API hosts

Used by `BuildConfig.apiUrl(ApiHost.*)`:

- `core` (string) — base URL for core APIs
- `auth` (string) — base URL for auth APIs
- `profile` (string) — base URL for profile APIs

### Logging

- `enableLogging` (bool) — controls `BuildConfig.logEnabled`

### Experiments

- `reminderExperiment` (bool) — controls `BuildConfig.reminderExperiment`

### Analytics

- `analyticsEnabledDefault` (bool) — controls `BuildConfig.analyticsEnabledDefault`
- `analyticsDebugLoggingEnabled` (bool) — controls `BuildConfig.analyticsDebugLoggingEnabled`

### Network logging (console-only)

These map to:
- `netLogMode` (string) → `BuildConfig.netLogMode`
  - intended values: `off`, `summary`, `full`
- `netLogBodyLimitBytes` (int) → `BuildConfig.netLogBodyLimitBytes` (default `8192`)
- `netLogLargeThresholdBytes` (int) → `BuildConfig.netLogLargeThresholdBytes` (default `65536`)
- `netLogSlowMs` (int) → `BuildConfig.netLogSlowMs` (default `800`)
- `netLogRedact` (bool) → `BuildConfig.netLogRedact` (default `true`)

## What To Commit

Typical template defaults:

- Commit `.env/*.example.yaml` (safe placeholders).
- Commit `.env/*.yaml` only if they contain non-sensitive defaults (e.g., local dev hosts).
- Never commit secrets or tokens to these files.

## Verification

Use the verify script:

`dart run tool/verify.dart --env dev`

This runs config generation + analyze + tests, and will fail if `.env/<env>.yaml` is missing/empty.
