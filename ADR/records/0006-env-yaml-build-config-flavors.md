---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers, DevOps]
informed: [All contributors]
scope: template
tags: [config, flavors, build-config]
---

# Environment YAML + BuildConfig Generator for Flavors

## Context and Problem Statement

Apps derived from this template need flavor‑aware configuration (dev/staging/prod) such as API hosts, logging flags, and analytics defaults. We want configuration to be easy to edit per environment, safe from accidental secret commits, and available at compile time.

## Decision Drivers

* Clear separation of environment values.
* Compile‑time selection per build flavor.
* Minimal runtime overhead and no new infra dependency.
* Simple developer workflow for adding/editing env values.

## Considered Options

* Use only `--dart-define` values in CI and local builds.
* Use Firebase Remote Config for all environments.
* Use `.env/*.yaml` with a generator into `BuildConfig` (chosen).

## Decision Outcome

Chosen option: **Environment YAML files compiled into `BuildConfig` via `tool/gen_config.dart`**, because it provides a straightforward, version‑controlled source of truth and a stable API for code to consume.

Pattern:

* Per‑environment YAML lives in `.env/dev.yaml`, `.env/staging.yaml`, `.env/prod.yaml`.
* `dart run tool/gen_config.dart --env <env>` generates `lib/core/configs/build_config.g.dart`.
* Builds select the env via `--dart-define=ENV=<env>`, read by `BuildConfig`.
* Runtime config (e.g., access token) lives in `AppConfig`.

### Consequences

* Good, because environment values are explicit and easy to diff.
* Good, because compile‑time constants enable tree‑shaking and safe defaults.
* Neutral, because developers must remember to re‑run the generator after edits.
* Bad, because forgetting to generate can cause mismatches until CI/analyze catches it.

### Confirmation

Confirmed when:

* Env changes update YAML and re‑generate `build_config.g.dart` in the same PR.
* New env keys are surfaced through `BuildConfig` getters.

