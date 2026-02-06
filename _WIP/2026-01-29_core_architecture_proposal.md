# Proposal — Restructure `lib/core/**` into explicit layers (template-grade, stable core)

**Repo:** `mobile-core-kit`  
**Date:** 2026-01-29  
**Status:** Proposed (WIP)  

## Context (problem)

The feature-level architecture is stable (Clean Architecture + vertical slices). The main pain is
`lib/core/**`:

- It currently mixes multiple concerns (foundation utilities, infrastructure, runtime/app policy,
  and design system UI).
- "Shared feature stuff" (auth ↔ user) has no obvious home, so it leaks as cross-feature imports
  and lint allowlists (e.g. `tool/lints/architecture_lints.yaml` TEMP exceptions).
- `core/services/**` is a catch-all, so future teams won't know where to put new capabilities or
  shared contracts.

Because this repository is a **starter template**, the core must be:

- Stable and predictable
- Easy to delete capabilities from
- Hard to accidentally create bad dependencies in

This proposal restructures `lib/core/**` into **explicit internal layers** with clear dependency
rules and enforceable lint boundaries.

---

## Goals

1) Make "where shared contracts go" objective (no more "shared feature stuff").  
2) Separate **pure contracts** from **IO/infra** from **runtime orchestration** from **UI system**.  
3) Keep the template easy to clone:
   - teams mostly work in `lib/features/**`
   - teams can swap design system and remove unused capabilities cleanly
4) Add lint-enforced dependency rules inside core (similar to existing feature rules).

## Non-goals

- Changing the feature slice structure (`data/domain/presentation/di`).
- Extracting modules into separate packages (could be a later step).
- Perfect "enterprise architecture"; this aims for pragmatic, template-grade clarity.

---

## Proposed `core` layers (what each folder means)

### 1) `core/foundation/**` (pure)

**Pure Dart** primitives used anywhere (core + features), without app policy.

Examples:
- generic failures + error codes (`AppFailure`, telemetry-safe codes)
- validation primitives (`ValidationError`, codes)
- generic VO failures (e.g. `ValueFailure` that multiple features use)
- utilities (`idempotency_key_utils`, formatting helpers, etc.)

**Rule:** no Flutter UI, no Dio, no storage/database.

### 2) `core/domain/**` (pure cross-cutting domain + ports)

Cross-cutting domain contracts that multiple features depend on.

Examples:
- session entities + ports: `AuthSession`, `AuthTokens`, `TokenRefresher` port
- user identity entity + ports: `UserEntity`, `CurrentUserFetcher` port

**Rule:** depends only on `core/foundation/**` (no infra, no runtime, no UI).

### 3) `core/infra/**` (IO + external systems)

Infrastructure code that touches IO/external systems, but is not "app policy".

Examples:
- networking stack (Dio, interceptors, `ApiClient`, `ApiHelper`, endpoints, failures)
- persistence (`sqflite`, secure storage, shared preferences stores)
- environment config loading/generation and config accessors

**Rule:** may depend on `core/foundation/**` + `core/domain/**`, but not on runtime or UI.

### 4) `core/platform/**` (plugin/OS wrappers)

Thin adapters around OS/platform plugins and device state.

Examples:
- connectivity source
- device identity
- app links/deep link sources
- media pickers
- federated auth SDK wrappers
- push token provider

**Rule:** no app policy (no "when to hydrate", "what route to go to", etc.).

### 5) `core/runtime/**` (application layer orchestration)

Long-lived orchestrators/controllers that coordinate session, startup, deep links, push, etc.

Examples:
- session orchestration (`SessionManager`)
- startup gate (`AppStartupController`)
- UI-facing derived session/user view model (`UserContextService`)
- event bus
- push token sync orchestration
- navigation glue helpers (non-UI)

**Rule:** can depend on `foundation + domain + infra + platform`, but **must not depend on**
`core/design_system/**` (no Widgets/Theme inside runtime).

### 6) `core/design_system/**` (UI-only)

The app's visual system and reusable components.

Examples:
- tokens: spacing/radii/sizing, semantic colors
- theme builder + typography system
- adaptive spec + adaptive widgets (layout)
- shared UI components (buttons, fields, etc.)
- localization helpers for UI (context extensions, shared localizers)

**Rule:** must not depend on infra/runtime/platform. It may depend on `foundation` (and only
"pure" types).

### 7) `core/di/**` (composition root)

GetIt wiring only:

- registers core modules
- composes feature DI modules
- provides policy overrides (if needed)

**Rule:** this is one of the few places allowed to import:
- feature DI (`lib/features/*/di/**`)
- almost anything in core

### 8) `core/dev_tools/**`

Dev-only screens and showcases (can be UI-heavy, but must not leak into production routes by
default; routing gated by env).

---

## Proposed folder tree (target state)

```
lib/
├── app.dart
├── main_*.dart
├── navigation/
├── features/
└── core/
    ├── di/
    ├── dev_tools/
    ├── foundation/
    │   ├── errors/
    │   ├── validation/
    │   ├── utilities/
    │   └── types/
    ├── domain/
    │   ├── session/
    │   └── user/
    ├── infra/
    │   ├── config/
    │   ├── database/
    │   ├── network/
    │   └── storage/
    ├── platform/
    │   ├── app_links/
    │   ├── connectivity/
    │   ├── device_identity/
    │   ├── federated_auth/
    │   ├── media/
    │   └── push/
    ├── runtime/
    │   ├── analytics/
    │   ├── events/
    │   ├── navigation/
    │   ├── push/
    │   ├── session/
    │   ├── startup/
    │   └── user_context/
    └── design_system/
        ├── adaptive/
        ├── localization/
        ├── theme/
        └── widgets/
```

Notes:
- The names are intentionally descriptive ("infra", "runtime", "design_system") so authors can
  categorize code without tribal knowledge.
- This keeps feature slices untouched while making `core` less ambiguous.

---

## System tree (ownership + dataflow)

### Ownership map (core modules)

```
App composition (wiring only):
- lib/main_*.dart
- lib/app.dart
- lib/navigation/**
- lib/core/di/**

Runtime orchestration (process-level state machines):
- core/runtime/analytics/**     (analytics event sink + screen tracking)
- core/runtime/session/**      (SessionManager orchestration)
- core/runtime/startup/**      (AppStartupController orchestration)
- core/runtime/user_context/** (UserContextService derived UI state)
- core/runtime/push/**         (push token sync orchestration)
- core/runtime/events/**       (AppEventBus + app events)

Domain contracts (pure types + ports):
- core/domain/session/**       (AuthSession/AuthTokens + ports: TokenRefresher, SessionRepository iface)
- core/domain/user/**          (UserEntity + port: CurrentUserFetcher)

Infra + platform implementation details:
- core/infra/network/**        (ApiClient/ApiHelper/interceptors)
- core/infra/storage/**        (secure storage, prefs stores)
- core/infra/database/**       (sqflite bootstrap, migrations)
- core/platform/**             (connectivity/device id/app links/media/push token provider)

Design system (UI-only):
- core/design_system/theme/**
- core/design_system/adaptive/**
- core/design_system/widgets/**

Presentation (UI-only shared helpers):
- core/presentation/localization/**
```

### Dataflow diagram (high level)

```mermaid
flowchart LR
  subgraph App[Composition Root]
    main[main_*.dart] --> di[core/di]
    di --> nav[navigation/* (GoRouter)]
    nav --> ui[features/*/presentation (screens)]
  end

  subgraph Foundation[core/foundation (pure)]
    ferrors[errors + codes]
    fvalidation[validation]
    futils[utilities]
  end

  subgraph Runtime[core/runtime (orchestration)]
    startup[AppStartupController]
    session[SessionManager]
    userctx[UserContextService]
    deeplinks[PendingDeepLinkController + listener]
  end

  subgraph Domain[core/domain (pure contracts)]
    userEntity[UserEntity]
    sessionEntity[AuthSession/AuthTokens]
    ports[Ports: CurrentUserFetcher, TokenRefresher, CachedUserStore]
  end

  subgraph Infra[core/infra (IO)]
    network[ApiClient/ApiHelper + interceptors]
    storage[Secure storage + prefs]
    db[AppDatabase + DAOs]
  end

  subgraph Platform[core/platform (plugins)]
    conn[Connectivity]
    links[App Links]
    push[Push token provider]
    media[Media pickers]
  end

  subgraph DS[core/design_system (UI-only)]
    tokens[Tokens + Theme + Adaptive]
    widgets[Shared widgets/components]
  end

  ui -->|intents/usecases| Runtime
  Runtime --> Domain
  Runtime --> Infra
  Runtime --> Platform
  Domain --> Foundation
  Infra --> Foundation
  Platform --> Foundation
  DS --> Foundation
```

The intent:
- UI (features) interacts with **runtime** (controllers/services), not directly with infra.
- Runtime orchestrates infra/platform and updates session/user state.
- Domain is pure and shared, so multiple features can depend on it without cross-feature imports.
- Design system stays UI-only.

---

## Dependency rules (what may import what)

### Layer dependency rule (simple)

Allowed direction:

```
design_system  → foundation (only)
domain         → foundation
infra          → foundation + domain
platform       → foundation (+ domain optional)
runtime        → foundation + domain + infra + platform
di             → everything (composition root)
```

Forbidden direction (examples):

- `design_system/**` must not import `infra/**` or `runtime/**` (no network/session in widgets).
- `domain/**` must not import `infra/**` or `platform/**` (keep pure).
- `infra/**` must not import `runtime/**` (no "app policy" in low-level IO).
- `runtime/**` must not import `design_system/**` (no Widgets in controllers).

### Feature rules (unchanged intent, updated paths)

- `features/*/domain/**` stays pure:
  - MUST NOT import `core/infra/**`, `core/platform/**`, `core/runtime/**`, `core/design_system/**`, `navigation/**`.
- `features/*/presentation/**` MUST NOT import `features/*/data/**` directly (use usecases/repos).
- `core/**` MUST NOT import `features/**` (except `core/di/**` composing feature DI).

---

## Proposed enforcement (custom_lint `architecture_imports`)

Below is a **proposed** extension of `tool/lints/architecture_lints.yaml` to enforce core layering.
Exact globs may be tweaked during implementation.

```yaml
rules:
  # Keep existing:
  - id: core_no_features
    from: lib/core/**
    deny: [lib/features/**]
    exceptions:
      - from: lib/core/di/**
        allow: [lib/features/*/di/**]

  # Core layering:
  - id: core_foundation_no_higher_layers
    from: lib/core/foundation/**
    deny:
      - lib/core/domain/**
      - lib/core/infra/**
      - lib/core/platform/**
      - lib/core/runtime/**
      - lib/core/design_system/**

  - id: core_domain_pure
    from: lib/core/domain/**
    deny:
      - lib/core/infra/**
      - lib/core/platform/**
      - lib/core/runtime/**
      - lib/core/design_system/**
      - lib/core/di/**

  - id: core_infra_no_runtime_or_ui
    from: lib/core/infra/**
    deny:
      - lib/core/runtime/**
      - lib/core/design_system/**
      - lib/core/dev_tools/**

  - id: core_platform_no_runtime_or_ui
    from: lib/core/platform/**
    deny:
      - lib/core/runtime/**
      - lib/core/design_system/**
      - lib/core/dev_tools/**

  - id: core_runtime_no_ui
    from: lib/core/runtime/**
    deny:
      - lib/core/design_system/**

  - id: core_design_system_no_runtime_or_infra
    from: lib/core/design_system/**
    deny:
      - lib/core/runtime/**
      - lib/core/infra/**
      - lib/core/platform/**
      - lib/core/di/**
```

Notes:
- Package-level restrictions (e.g. "no dio import outside infra/network") stay in `analysis_options.yaml`
  via `restricted_imports`.
- These rules are meant to make "where shared contracts go" non-negotiable.

---

## Migration mapping (current → target, high-level)

This is illustrative; details will change as we implement.

| Current | Proposed |
|---|---|
| `core/utilities/**` | `core/foundation/utilities/**` |
| `core/validation/**` | `core/foundation/validation/**` |
| `core/user/**` | `core/domain/user/**` |
| `core/session/**` (entities + ports) | `core/domain/session/**` |
| `core/session/session_manager.dart` | `core/runtime/session/**` |
| `core/services/app_startup/**` | `core/runtime/startup/**` |
| `core/services/user_context/**` | `core/runtime/user_context/**` |
| `core/events/**` | `core/runtime/events/**` |
| `core/network/**` | `core/infra/network/**` |
| `core/storage/**` | `core/infra/storage/**` |
| `core/database/**` | `core/infra/database/**` |
| `core/services/*` (plugin wrappers) | `core/platform/<capability>/**` |
| `core/theme/**` | `core/design_system/theme/**` |
| `core/adaptive/**` | `core/design_system/adaptive/**` |
| `core/widgets/**` | `core/design_system/widgets/**` |
| `core/localization/**` | `core/presentation/localization/**` |

---

## Why this fixes the "shared feature stuff" problem

With these layers:

- If `auth` and `user` share a type/localizer/VO failure, it must be promoted into:
  - `core/foundation/**` (generic) or
  - `core/domain/**` (cross-cutting domain)
  - `core/design_system/**` (UI-only components/tokens)
  - `core/presentation/**` (UI-only helpers like localization/copy)

This removes the need for:

- cross-feature imports
- TEMP lint allowlists
- "where do I put this?" debates

---

## Next steps (if we adopt)

1) Create the new folder structure under `lib/core/` (empty directories + move files).  
2) Update `tool/lints/architecture_lints.yaml` with the core-layer rules above.  
3) Fix imports + run `dart run tool/verify.dart --env dev` until green.  
4) Remove the TEMP allowlists related to auth/user cross-feature reuse by promoting shared contracts into core.
