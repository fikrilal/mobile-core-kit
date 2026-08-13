# Project Architecture — Clean Architecture + Vertical Slices (Flutter)

Big‑picture blueprint for scaling features and subfeatures using Clean Architecture, GetIt DI, GoRouter, and a Bloc/Cubit‑based presentation layer. This document is high‑level (Data, Domain, Presentation) and pairs with the UI state guide for detailed UI patterns.

Important: We use Bloc/Cubit only in presentation. No GetX.

---

## 1) Goals & Principles

1. Feature‑first structure. A feature is the boundary; subfeatures are vertical slices.
2. Separation of concerns. Keep Domain ↔ Data ↔ Presentation boundaries clean.
3. Testability. Business rules live in use cases (pure and easy to test).
4. Reusability with discipline. Share only when ≥2 slices need it now.
5. Evolvability. Scales to extracting large features into local packages.
6. Presentation uses Bloc/Cubit with a single source of truth per screen.
7. Enforced boundaries. Import rules are enforced via `custom_lint` (see `docs/engineering/architecture_linting.md`).
8. Localization-first. User-facing copy lives in ARB (see `docs/engineering/localization.md`).

---

## 2) Top‑Level Layout

Recommended template shape.

```
lib/
├─ app.dart                       # MaterialApp.router + theme
├─ main_dev.dart                  # entrypoint (ENV=dev)
├─ main_staging.dart              # entrypoint (ENV=staging) [optional]
├─ main_prod.dart                 # entrypoint (ENV=prod) [optional]
├─ core/                          # cross‑cutting infrastructure
│  ├─ design_system/              # UI tokens + adaptive widgets + shared components (UI-only)
│  ├─ presentation/               # shared UI helpers (localization, formatters, error copy)
│  ├─ foundation/                 # pure foundation utilities + compile-time config surfaces
│  ├─ domain/                     # pure cross-cutting domain contracts (session/user)
│  ├─ infra/                      # app-owned infrastructure (network/storage/database)
│  ├─ platform/                   # plugin/vendor adapters (connectivity, app links, etc.)
│  ├─ runtime/                    # app orchestration/services (startup/session/user context)
│  ├─ di/                         # service locator (GetIt) composition
│  └─ dev_tools/                  # dev-only tooling (guarded by env)
├─ features/
│  └─ <feature>/
│     ├─ data/                    # datasource, model, mapper, repository impl
│     │  ├─ datasource/
│     │  │  ├─ remote/
│     │  │  │  └─ <feature>_remote_datasource.dart
│     │  │  └─ local/
│     │  │     └─ <feature>_local_datasource.dart
│     │  ├─ services/             # feature-owned runtime listeners/adapters (optional)
│     │  ├─ error/                # API failure mapping + backend error codes
│     │  │  ├─ <feature>_failure_mapper.dart
│     │  │  └─ <feature>_error_codes.dart
│     │  ├─ model/
│     │  │  └─ <dto>.dart (+ generated *.g.dart)
│     │  ├─ mapper/
│     │  │  └─ <mapper>.dart
│     │  └─ repository/
│     │     └─ <feature>_repository_impl.dart
│     ├─ domain/                  # entity, value, failure, repository (interfaces), usecase
│     │  ├─ entity/
│     │  │  └─ <entity>.dart
│     │  ├─ value/
│     │  │  └─ <value>.dart
│     │  ├─ failure/
│     │  │  └─ <feature>_failure.dart
│     │  ├─ repository/
│     │  │  └─ <feature>_repository.dart
│     │  └─ usecase/
│     │     └─ <use_case>.dart
│     ├─ presentation/            # bloc/ or cubit/, pages, widgets
│     │  ├─ bloc/
│     │  │  └─ <slice>/
│     │  │     ├─ <slice>_bloc.dart
│     │  │     ├─ <slice>_event.dart
│     │  │     └─ <slice>_state.dart
│     │  ├─ cubit/
│     │  │  └─ <slice>/
│     │  │     ├─ <slice>_cubit.dart
│     │  │     └─ <slice>_state.dart
│     │  ├─ pages/
│     │  │  └─ <slice>_page.dart
│     │  └─ widgets/
│     │     ├─ skeleton/
│     │     └─ ...
│     └─ di/
│        └─ <feature>_module.dart
├─ navigation/                    # GoRouter composition per feature + shells
│  ├─ app_router.dart
│  ├─ main/
│  │  ├─ main_routes_list.dart
│  │  └─ main_routes.dart
│  ├─ <feature>/
│  │  ├─ <feature>_routes_list.dart
│  │  └─ <feature>_routes.dart
│  └─ showcase/ ...
└─ ...
```

### Session & Current User (Template Standard)

Keep session/runtime concerns separate from feature workflows:

- **Session contracts** live in `lib/core/domain/session/`
  - examples: a session repository contract, a token refresher port, a session failure type, a cached-user store contract
- **Session orchestration** lives in `lib/core/runtime/session/`
  - examples: a session manager/coordinator and its runtime-facing repository implementation
- **Current-user identity** is exposed to UI via `lib/core/runtime/user_context/`
  - examples: a current-user context service or notifier
- **Feature-owned auth flows** provide the `TokenRefresher` implementation through DI
- **Feature-owned current-user support** provides:
  - a `CurrentUserFetcher` implementation
  - a `CachedUserStore` implementation when runtime/session needs persisted user identity

Usage guide: `docs/template/current_user.md`

### Feature Directory Anatomy (features/<feature>/)

- data/
  - datasource/
    - remote/: API calls via the project's HTTP helper abstractions.
    - local/: sqflite DAOs, shared_prefs, caches if applicable.
  - model/: DTOs and JSON serialization; Freezed/JSON generated code.
  - mapper/: DTO ↔ entity mappers, query parameter mappers, pagination mappers.
  - repository/: concrete repository implementations (translate infra errors to domain Failures).
- domain/
  - entity/: domain entities (Freezed preferred) — UI agnostic.
  - value/: value objects, small types and enums.
  - failure/: domain failure types with userMessage mapping.
  - repository/: repository interfaces used by use cases and presentation.
  - usecase/: business rules; return `Either<Failure, T>`; names as verbs.
- presentation/
  - bloc/ and/or cubit/: presentation logic per slice (events/methods + state).
  - pages/: Flutter Widgets for screens; small helpers and builders.
  - widgets/: feature‑local reusable widgets; skeletons under `widgets/skeleton/`.
- di/
  - `<feature>_module.dart`: registers datasources, repositories, use cases, and Bloc/Cubit factories.

### Subfeatures (vertical slices)

Use subfeatures when a feature grows and has multiple independent slices (e.g., overview, creation, playing).

1) Full vertical slice (recommended)
```
features/<feature>/subfeatures/<slice>/
  data/            # if the slice owns distinct endpoints/DTOs
  domain/          # entities/values/usecases unique to the slice
  presentation/    # bloc|cubit, state, pages, widgets
```

Prefer keeping domain/data at the feature root unless a slice truly needs different contracts.

### Choosing Feature Internal Structure

Not every feature should have the same internal folder shape.

Use the smallest structure that matches the actual maintenance pressure:

1. Flat feature
```
features/<feature>/
  data/
  domain/
  presentation/
  di/
```

Use this when the feature is still easy to navigate and most behavior belongs to
one shared flow family.

2. Presentation-first subfeatures
```
features/<feature>/
  data/            # shared
  domain/          # shared
  subfeatures/
    <slice>/presentation/
  di/
```

Use this when:

- the feature is still one cohesive bounded context
- pages, cubits, and route bindings are becoming crowded
- data/domain are still shared and do not justify separate repositories or
  datasources

3. Full vertical subfeatures
```
features/<feature>/
  subfeatures/
    <slice>/
      data/
      domain/
      presentation/
  di/
```

Use this when slices have clearly different:

- workflows
- data ownership or endpoints
- domain contracts or use cases
- change cadence
- review/ownership boundaries

Guiding rule:

- keep principles universal
- do not force folder symmetry

Examples of when each shape fits:

- presentation-first subfeatures:
  - one cohesive bounded context
  - many screens/cubits/routes
  - shared data/domain surface still makes sense
- full vertical subfeatures:
  - slices own materially different endpoints or persistence
  - slices have different use cases or failure mapping
  - slices evolve at different speeds or under different ownership

If a feature feels "big", ask two questions before splitting:

1. Is the feature hard to navigate mainly because of presentation/workflow
   volume?
2. Or do the slices also have different data/domain ownership?

If only the first is true, prefer presentation-first subfeatures. If both are
true, use full vertical subfeatures.

---

## 3) Domain Layer (per feature)

Contains entity/, value/, failure/, repository/ (interfaces), and optionally
usecase/.

- Pure Dart (no Flutter/framework dependencies).
- Entities and values are UI‑agnostic.
- Repository interfaces describe operations in domain terms.
- Use cases encode business rules and return `Either<Failure, T>`.
- The `usecase/` folder is **optional**: add a use case only when the operation
  has logic worth isolating (validation, multi-step orchestration). A pure
  pass-through use case should not exist — presentation calls the repository
  directly in that case (cubit → repository).

Common examples:
- repository interface
- use case
- failure type

Naming conventions:
- Use case names are verbs (e.g., GetTrendingBooks, CreateItem, UpdateProfile).
- Repository methods mirror domain verbs and return domain entities/values.

Folder rules:
- Keep domain pure (no Flutter imports, no Dio, no storage APIs).
- Do not put DTOs in domain; convert at the data layer boundaries.
- Prefer Freezed for entities/values where immutability and equality matter.

See also (validation):
- docs/engineering/validation_architecture.md:1
- docs/engineering/value_objects_validation.md:1
- docs/engineering/validation_cookbook.md:1

---

## 4) Data Layer (per feature)

Contains datasource/ (remote/local), model/ (DTOs), mapper/, and repository/ (impls).

- DTOs map to/from domain entities — never leak DTOs outside the data layer.
- Repositories glue data sources and translate infrastructure errors to domain Failures.
- Network stack uses an HTTP client plus helper abstractions for one/list/paginated requests; keep endpoints centralized under a dedicated endpoints module.

Typical pattern:
- remote datasource under `data/datasource/remote/`
- repository implementation under `data/repository/`
- API plumbing under `core/infra/network/`

Mapping & error policy:
- Map DTOs to domain entities in model-owned helpers or repository-local helpers.
- Translate transport/HTTP errors to domain Failures (keep user‑facing messages consistent).
- Keep API endpoint strings centralized under a dedicated endpoints module.
- For cursor‑paginated endpoints, prefer typed pagination helpers and
  return a typed paginated result from datasources.
  Feature domain can model pagination using `cursor`/`limit` Param VOs.

For the detailed datasource/repository rules, see:
- `docs/engineering/data_domain_guide.md`

---

## 5) Presentation Layer (per slice)

Contains Bloc/Cubit, state, pages, and feature widgets.

- Bloc/Cubit drive user intents (events or methods) and emit a single immutable State describing the screen.
- State modeling policy: default to a single state + `status` enum; for complex/mutually exclusive states consider sealed unions with Freezed.
- Rendering and effects: one BlocBuilder switching on `status`; mutation flows emit explicit one-shot effects. Keep skeletons lightweight and colocated.
- Dispatch initial intents at provider creation time (route builders), not inside `build` methods.
- Prefer Cubit first; use Bloc for orchestration, multi‑input flows, or when using event transformers.
- No GetX — all new and refactored UI state uses Bloc/Cubit.

See the dedicated UI state guide for detailed patterns (rendering, effects, concurrency, and examples):
`docs/engineering/ui_state_architecture.md`

Form validation references:
- docs/engineering/validation_architecture.md:1
- docs/engineering/validation_cookbook.md:1

Folder rules and conventions:
- bloc/ vs cubit/: prefer Cubit for ≤3 intents and simple flows; use Bloc for multi‑input orchestration or when using event transformers.
- events: name user intents and lifecycle triggers explicitly (`Started`, `Refreshed`, `FilterChanged`, `NextPageRequested`, `Submitted`).
- state: single immutable snapshot; UI‑shaped fields; derived getters encouraged; keep errors as user‑friendly strings on state.
- pages/: consume explicit effects for mutation flows; use `BlocListener` for simple read-flow state transitions or legacy slices. Dispatch initial intent in providers, not inside `build`.
- widgets/: colocate skeletons under `widgets/skeleton/`; keep helpers small and theme‑aware.

---

## 6) Dependency Injection (GetIt)

Modularized DI keeps boundaries explicit and wiring minimal.

- Global setup should compose registration in a stable order:
  core foundation → core platform → core infra → core runtime → feature modules → app orchestrators.
- Prefer splitting core DI across focused registrars instead of one large `core_module.dart`.
- Feature modules: `lib/features/<feature>/di/*_module.dart` register datasources, repositories, use cases, and Bloc/Cubit factories.
- Startup boot flow:
  - registration before `runApp()`
  - heavier initialization in a later bootstrap stage when needed
- Route‑time providers: create Bloc/Cubit instances inside route builders via `BlocProvider`/`MultiBlocProvider` and dispatch initial intents there.
- Service locator usage is restricted to composition roots (DI + navigation + app entrypoints). Presentation code should receive dependencies via providers/constructors.

Registration guidelines:
- Prefer `registerLazySingleton` for repositories/services and `registerFactory` for Bloc/Cubit.
- Put async/heavy initialization into bootstrap stages (`lib/core/di/bootstrap/locator_bootstrap_pipeline.dart`) instead of `registerSingletonAsync + allReady`.
- Keep DI wiring per feature to avoid a large central registrar.

---

## 7) Navigation & Shell

- GoRouter composes per‑feature route lists into a global router (`lib/navigation/app_router.dart`).
- Tabs use `ShellRoute`; the shell UI state is held in a simple Cubit.
- Route builders are responsible for providing Blocs/Cubits for their subtree and triggering initial loads.

Conventions:
- Keep initial location and redirects centralized in the app router; avoid route‑local redirect logic unless necessary.
- Pass parameters via GoRouter’s `state.extra` or query parameters consistently with the feature’s established pattern.

---

## 8) Config & Environments

- Environment YAMLs live under `.env/`. `mobilekit config generate` produces `lib/core/foundation/config/build_config_values.dart`.
- `BuildConfig` reads compile‑time env via `--dart-define=ENV=<env>` and exposes URLs, logging flags, and OAuth client IDs.
- `AppConfig` holds runtime config (e.g., access token) and proxies to `BuildConfig` for hosts and flags.

Commands:
- Generate config: `dart run mobile_core_kit_cli:mobilekit config generate -e dev` (or `staging`/`prod`).
- Run app (dev): `fvm flutter run -t lib/main_dev.dart --dart-define=ENV=dev`.

---

## 9) Cross‑Feature Refresh

- Use `AppEventBus` to publish domain‑level signals after successful mutations (e.g., entry changed, session finished).
- Presentation Blocs subscribe, filter by relevant IDs, and refetch authoritative data via repositories.
- Always cancel subscriptions in `close()`.

Notes:
- Treat events as signals; fetch fresh data from repositories rather than carrying payloads through the bus.
- Consider debouncing listeners if a mutation cascades multiple events quickly.

---

## 10) Testing Strategy

- Domain: unit test use cases with mocked repositories; assert business rules and return types.
- Data: verify DTO ↔ entity mappings and failure translation; add integration tests for API/DB paths where valuable.
- Presentation: use `bloc_test` to assert intent → state sequences and explicit one‑shot effects for mutations; keep widget tests for key screens.

Paths:
- Place tests under `test/` mirroring `lib/` paths.
- Name files `*_test.dart`; keep unit tests fast and focused on the smallest unit.

---

## 11) Migration Notes

- Presentation layer standard is Bloc/Cubit. No GetX.
- New and edited slices follow the UI state guide and this architecture. Existing legacy code can be migrated incrementally as slices are touched.
