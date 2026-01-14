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

---

## 2) Top‑Level Layout

Reflects the current repository shape.

```
lib/
├─ app.dart                       # MaterialApp.router + theme
├─ main_dev.dart                  # entrypoint (ENV=dev)
├─ main_staging.dart              # entrypoint (ENV=staging) [optional]
├─ main_prod.dart                 # entrypoint (ENV=prod) [optional]
├─ core/                          # cross‑cutting infrastructure
│  ├─ configs/                    # AppConfig/BuildConfig (env‑driven)
│  ├─ databases/                  # sqflite DB bootstrap
│  ├─ di/                         # service locator (GetIt)
│  ├─ events/                     # AppEventBus (cross‑feature refresh)
│  ├─ network/                    # ApiClient, ApiHelper, endpoints, interceptors
│  ├─ result/                     # Paginated<T>, PaginationInfo
│  ├─ services/                   # session, device, fcm, navigation, etc.
│  ├─ storage/                    # secure storage
│  ├─ theme/                      # tokens, typography, responsive spacing
│  └─ widgets/                    # shared UI components
├─ features/
│  └─ <feature>/
│     ├─ data/                    # datasource, model, mapper, repository impl
│     │  ├─ datasource/
│     │  │  ├─ remote/
│     │  │  │  └─ <feature>_remote_datasource.dart
│     │  │  └─ local/
│     │  │     └─ <feature>_local_datasource.dart
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

### Feature Directory Anatomy (features/<feature>/)

- data/
  - datasource/
    - remote/: API calls via ApiHelper (typed parsers, list/paginated helpers).
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

---

## 3) Domain Layer (per feature)

Contains entity/, value/, failure/, repository/ (interfaces), and usecase/.

- Pure Dart (no Flutter/framework dependencies).
- Entities and values are UI‑agnostic.
- Repository interfaces describe operations in domain terms.
- Use cases encode business rules and return `Either<Failure, T>`.

Examples in repo for reference:
- Repository interface: `lib/features/<feature>/domain/repository/...`
- Use case: `lib/features/<feature>/domain/usecase/...`
- Failure type: `lib/features/<feature>/domain/failure/...`

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
- Network stack uses `ApiClient` (Dio + interceptors) and `ApiHelper` helpers for one/list/paginated requests; endpoints are centralized under `core/network/endpoints`.

Examples in repo for reference:
- Remote datasource: `lib/features/<feature>/data/datasource/remote/...`
- Repository impl: `lib/features/<feature>/data/repository/...`
- API plumbing: `lib/core/network/api/api_client.dart`, `lib/core/network/api/api_helper.dart`

Mapping & error policy:
- Map DTOs to domain entities in repository implementations or dedicated mappers.
- Translate transport/HTTP errors to domain Failures (keep user‑facing messages consistent).
- Keep API endpoint strings centralized under `core/network/endpoints`.
- Use `Paginated<T>` and `PaginationInfo` for paginated repository results.

---

## 5) Presentation Layer (per slice)

Contains Bloc/Cubit, state, pages, and feature widgets.

- Bloc/Cubit drive user intents (events or methods) and emit a single immutable State describing the screen.
- State modeling policy: default to a single state + `status` enum; for complex/mutually exclusive states consider sealed unions with Freezed.
- Rendering and effects: one BlocBuilder switching on `status`; one‑shot effects via `BlocListener`. Keep skeletons lightweight and colocated.
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
- pages/: subscribe to effects via `BlocListener`; dispatch initial intent in providers, not inside `build`.
- widgets/: colocate skeletons under `widgets/skeleton/`; keep helpers small and theme‑aware.

---

## 6) Dependency Injection (GetIt)

Modularized DI keeps boundaries explicit and wiring minimal.

- Global setup: `lib/core/di/service_locator.dart` composes modules in order (auth → core → features) and awaits async singletons.
- Core module: `lib/core/di/core_module.dart` registers infrastructure (ApiClient/Helper, DB, secure storage, session, services, event bus, navigation/deep link).
- Feature modules: `lib/features/<feature>/di/*_module.dart` register datasources, repositories, use cases, and Bloc/Cubit factories.
- Route‑time providers: create Bloc/Cubit instances inside route builders via `BlocProvider`/`MultiBlocProvider` and dispatch initial intents there.

Registration guidelines:
- Prefer `registerLazySingleton` for repositories/services and `registerFactory` for Bloc/Cubit.
- Mark async singletons with `registerSingletonAsync` and await `locator.allReady()` before runApp.
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

- Environment YAMLs live under `.env/`. The generator `tool/gen_config.dart` produces `lib/core/configs/build_config_values.dart`.
- `BuildConfig` reads compile‑time env via `--dart-define=ENV=<env>` and exposes URLs, logging flags, and OAuth client IDs.
- `AppConfig` holds runtime config (e.g., access token) and proxies to `BuildConfig` for hosts and flags.

Commands:
- Generate config: `dart run tool/gen_config.dart -e dev` (or `staging`/`prod`).
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
- Presentation: use `bloc_test` to assert intent → state sequences and one‑shot effects; keep widget tests for key screens.

Paths:
- Place tests under `test/<feature>/<slice>/...` mirroring `lib/` paths.
- Name files `*_test.dart`; keep unit tests fast and focused on the smallest unit.

---

## 11) Migration Notes

- Presentation layer standard is Bloc/Cubit. No GetX.
- New and edited slices follow the UI state guide and this architecture. Existing legacy code can be migrated incrementally as slices are touched.
