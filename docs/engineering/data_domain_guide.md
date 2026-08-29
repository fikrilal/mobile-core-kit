# Data & Domain Guide

This guide explains how to write feature `data/` and `domain/` code in this repository.

Use this document when deciding:
- where code belongs
- what a datasource should do
- what a repository should do
- when a type belongs in feature `domain/` vs `core/domain/`
- how remote/local persistence should map into domain objects

For the exact shape of models and entities, see:
- `docs/engineering/model_entity_guide.md`

## Goals

- Keep ownership explicit between `domain/`, `data/`, and `presentation/`.
- Make datasource, repository, and mapper code predictable across features.
- Keep repositories thin but meaningful.
- Keep transport, storage, and serialization details out of domain code.
- Keep structural model/entity mapping easy to find and easy to test.

## 1. Layer Responsibilities

### Domain

Feature `domain/` owns business-facing contracts and types for that feature.

It contains:
- entities
- value objects
- feature failures
- repository interfaces
- use cases

It does not contain:
- HTTP payloads
- database rows
- Dio/sqflite/GetIt imports
- endpoint paths
- JSON or SQL serialization

### Data

Feature `data/` owns implementation details.

It contains:
- remote and local datasources
- request/response/cache models
- query mappers
- failure mappers
- repository implementations
- feature-owned runtime listeners/adapters when needed

It does not contain:
- presentation state
- UI concerns
- domain business rules that belong in use cases/value objects

### Presentation

Presentation consumes use cases and domain types.

It should not know:
- endpoint paths
- raw JSON shapes
- local database details
- `ApiFailure`

## 2. Feature `domain/` vs `core/domain/`

This repository uses `core/domain/` as a shared kernel for cross-feature contracts.

Put code in feature `domain/` when:
- it belongs to one feature or subfeature
- it describes one workflow or product area
- other features should not depend on it directly

Put code in `core/domain/` when all of these are true:
- it is cross-feature or runtime-facing
- it is pure Dart
- it is a stable contract or shared business type
- `core/runtime` or multiple features need it

Typical shared-kernel examples:
- a `CurrentUserFetcher` contract used by runtime to refresh the signed-in user
- a `CachedUserStore` contract used by session/runtime to persist the current user
- a shared `UserEntity` consumed by multiple features and runtime services
- a shared `AuthFailure` vocabulary used by auth/session-related flows

Rule:
- feature `data/` may implement a `core/domain` port
- `core/domain` must not import feature code

See also:
- `lib/core/domain/README.md`
- `docs/engineering/project_architecture.md`

## 3. Datasource Rules

Datasources own transport and persistence details. Nothing more.

### Remote datasource responsibilities

A remote datasource should:
- choose the endpoint
- choose the host
- serialize request payloads
- pass query parameters
- choose the `ApiHelper` method (`getOne`, `getList`, `getPaginated`, `post`, etc.)
- provide the response parser
- optionally emit high-level request-start logs when useful

A remote datasource should not:
- return `Either`
- map to feature failures
- build domain entities
- own business branching
- duplicate API failure logging already handled by `ApiHelper`

Generic pattern:

```dart
class UserRemoteDataSource {
  UserRemoteDataSource(this._apiHelper);

  final ApiHelper _apiHelper;

  Future<ApiResponse<UserModel>> getCurrentUser() {
    return _apiHelper.getOne<UserModel>(
      UserEndpoint.me,
      host: ApiHost.core,
      requiresAuth: true,
      throwOnError: false,
      parser: UserModel.fromJson,
    );
  }
}
```

### Local datasource responsibilities

A local datasource should:
- read/write/delete from the concrete storage layer
- own DAO usage and transaction boundaries
- convert local models to and from storage maps
- return local models or domain objects only when that boundary is already standardized in the feature

A local datasource should not:
- know feature failures
- return `Either`
- contain workflow orchestration
- duplicate repository decisions

Generic local pattern:

```dart
class CachedUserLocalDataSource {
  const CachedUserLocalDataSource(this._dao);

  final CachedUserDao _dao;

  Future<UserEntity?> read() async {
    final model = await _dao.getFirst();
    return model?.toEntity();
  }

  Future<void> write(UserEntity user) async {
    await _dao.replace(UserLocalModel.fromEntity(user));
  }

  Future<void> clear() => _dao.deleteAll();
}
```

### Datasource method signatures

Preferred patterns:
- remote: `Future<ApiResponse<Model>>`
- remote paginated: `Future<ApiResponse<ApiPaginatedResult<Model>>>`
- local: `Future<Model?>`, `Future<void>`, `Future<List<Model>>`, or another simple storage-facing shape

Do not return:
- `Either`
- feature failures
- presentation states

### Logging rule

Transport-level API failure logging belongs in `ApiHelper`.

Datasource logging should be limited to:
- useful request-start diagnostics
- non-duplicative local-storage diagnostics if they materially help debugging

Do not add per-method `if (response.isError) Log.warning(...)` branches in datasources.

## 4. Model Rules

Models represent concrete payload/storage shapes.

Use models for:
- remote request DTOs
- remote response DTOs
- local cache/database rows

Do not use models as domain contracts in presentation.

General rule:
- structural `model -> entity` mapping lives close to the model
- repositories orchestrate when multiple models or additional metadata need to be combined

For detailed model/entity authoring rules, see:
- `docs/engineering/model_entity_guide.md`

## 5. Repository Rules

Repositories are the feature's implementation boundary.

A repository implementation should:
- call one or more datasources
- convert `ApiResponse<T>` into `Either`
- map `ApiFailure` into feature or shared domain failures
- map models into domain entities
- orchestrate multi-step reads/writes when a single use case needs it

A repository should not:
- build raw query maps
- know endpoint paths
- write JSON bodies directly
- contain widget/UI logic
- duplicate simple storage/transport details that belong in datasources

Canonical pattern:

```dart
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Either<UserFailure, UserEntity>> getCurrentUser() async {
    try {
      final apiResponse = await _remote.getCurrentUser();
      return apiResponse
          .toEitherWithFallback('Failed to load user.')
          .mapLeft(mapUserFailure)
          .map((model) => model.toEntity());
    } catch (_) {
      return left(const UserFailure.unexpected());
    }
  }
}
```

### Repository error handling

Use this pattern for remote calls:
1. datasource returns `ApiResponse<T>`
2. repository calls `toEitherWithFallback(...)`
3. repository maps `ApiFailure` to feature/shared domain failure
4. repository maps success payload to domain
5. repository catches truly unexpected exceptions and returns a stable fallback failure

Current helpers:
- `ApiResponseEitherX.toEitherWithFallback()`
- feature failure mappers in `data/error/`

Generic failure-mapper pattern:

```dart
FeatureFailure mapUserFailure(ApiFailure failure) {
  switch (failure.code) {
    case ApiErrorCodes.validationFailed:
      return FeatureFailure.validation(failure.validationErrors ?? const []);
    case ApiErrorCodes.unauthorized:
      return const FeatureFailure.unauthenticated();
    case ApiErrorCodes.rateLimited:
      return const FeatureFailure.tooManyRequests();
  }

  switch (failure.statusCode) {
    case 401:
      return const FeatureFailure.unauthenticated();
    case 429:
      return const FeatureFailure.tooManyRequests();
    case 500:
      return const FeatureFailure.serverError();
    default:
      return const FeatureFailure.unexpected();
  }
}
```

### Repository-local mapping vs model-owned mapping

Prefer model-owned mapping for pure structural conversion:
- `UserModel.toEntity()`
- `UserLocalModel.toEntity()`

Use repository-local helpers only when the repository must combine:
- multiple models
- paginated metadata
- endpoint-specific derived state
- cross-model orchestration

Rule:
- if the mapping is just one model becoming one entity, keep it near the model
- if the mapping depends on repository context, keep it in the repository (or a small repository-local helper)

## 6. Param Objects, Request Models, and Mappers

Use the following split:

### Value object / param object in `domain/`

Use a domain type when the input is part of the feature contract.

Typical examples:
- filters and pagination queries
- validated request inputs
- typed sort/order enums

### Request model in `data/model/remote/`

Use a request DTO when talking to the backend.

Typical examples:
- `LoginRequestModel`
- `UpdateProfileRequestModel`
- `RevokeSessionRequestModel`

Rule:
- a request model mirrors the backend payload shape
- for validated forms, map the validated domain aggregate via a focused factory
  such as `Model.fromCredentials(...)`
- for non-form operations, `Model.fromEntity(...)` remains appropriate when a
  genuine domain entity owns the input shape

### Mapper in `data/mapper/`

Use a mapper only for small pure conversions such as:
- query object -> `Map<String, dynamic>`

Do not create mapper files for every model/entity conversion by default.

## 7. Remote API Pattern

Preferred flow:

1. Use case calls repository interface
2. Repository builds request model if needed
3. Repository calls datasource
4. Datasource calls `ApiHelper`
5. Repository converts `ApiResponse<T>` -> `Either`
6. Repository maps failure and success into domain
7. Presentation consumes domain output only

Example:
- raw application input: `LoginInput`
- validated domain aggregate: `LoginCredentials`
- request model: `LoginRequestModel.fromCredentials(...)`
- datasource: `AuthRemoteDataSource.login(...)`
- repository: `AuthRepositoryImpl.login(...)`
- output: `Either<AuthFailure, AuthSession>`

## 8. Local Persistence Pattern

Preferred flow:

1. Repository or adapter decides to read/write cache
2. Local datasource uses DAO / database adapter
3. Local model owns `fromMap`, `toMap`, and usually `toEntity`
4. Repository or adapter returns domain-facing result

Guideline:
- keep SQL/table/column concerns in local models or DAOs
- do not leak storage row shape into repositories or presentation

## 9. Pagination Pattern

Use `ApiHelper.getPaginated` / `postPaginated` when the backend returns cursor pagination metadata.

Model cursor pagination in a domain query object:
- `cursor: String?`
- `limit: int`

Serialize it in a simple mapper:
- include `cursor` only when non-null
- keep default limits stable

Repository rules for paginated responses:
- map the list items to entities
- read `nextCursor` / `limit` from `ApiPaginatedResult`
- read other metadata from `additionalMeta`
- do not rebuild raw `meta` parsing logic in multiple places if one helper can keep it localized

## 10. Failure Mapping Pattern

Failure mapping belongs in `data/error/`.

Why:
- repositories stay readable
- backend code/status handling stays centralized per feature
- API contract drift is easier to update in one place

Preferred order:
1. backend `code`
2. HTTP status fallback
3. generic unexpected fallback

Rule:
- datasources do not map feature failures
- repositories do not inline large switch statements when a feature error mapper can own them cleanly

## 11. Use Case Rules

Use cases are optional domain entry points.

Add a use case only when the operation has logic worth isolating:
- validation / normalization (final gate before the repository)
- orchestration of multiple steps (e.g. upload = plan → presigned upload → complete)
- a business rule that needs its own unit test

Do NOT add a use case that is a pure pass-through:
- If `call(...)` just forwards to a repository method with no added logic,
  the presentation layer should call the repository directly (cubit → repository).
- This was applied across the template: profile draft/avatar use cases and
  pure pass-through use cases were removed where no domain logic remained.
  Login and registration retain use cases because they own the final
  raw-input-to-validated-aggregate transition.

When a use case exists:
- depend on the repository interface
- return `Either<Failure, T>` when the operation can fail
- keep business meaning explicit

A use case may be thin. That is acceptable, as long as it is not a pure
forwarder.

Do not add use cases only for ceremony.

For validated forms, follow
[ADR 0016](../../ADR/records/0016-validated-form-boundaries.md): presentation
submits raw `XInput`, the use case creates a validated aggregate, and the
repository accepts that aggregate rather than unchecked primitives.

## 12. Testing Rules

Test at the boundary where logic lives.

### Model tests
Test:
- `fromJson` / `toJson` when behavior is non-trivial
- `fromMap` / `toMap` for local models
- `toEntity()` and `fromEntity()` when present

### Mapper tests
Test:
- query object -> query map
- enum/string conversion helpers

### Repository tests
Test:
- datasource success -> correct domain mapping
- datasource error -> correct failure mapping
- repository orchestration when multiple steps are involved

Do not test:
- raw HTTP inside repository tests
- widget concerns in data/domain tests

### Datasource tests
Add datasource tests when they provide real value, for example:
- path assembly
- parser wiring
- local DAO interaction
- tricky request-body serialization

## 13. Decision Checklist

When adding new code, ask:

1. Is this a business-facing contract or pure type?
- put it in `domain/`

2. Is this a transport/storage implementation detail?
- put it in `data/`

3. Is this a shared runtime/kernel contract used across features?
- put it in `core/domain/`

4. Is this a simple structural model/entity conversion?
- keep it near the model

5. Is this mapping endpoint/repository-specific or combining multiple sources?
- keep it in the repository or a small repository-local helper

6. Am I about to make the datasource decide business behavior?
- stop and move that decision upward

7. Am I about to make the repository rebuild endpoint/query/body details?
- stop and move that detail downward

## 14. Related Docs

- `docs/engineering/model_entity_guide.md`
- `docs/engineering/project_architecture.md`
- `docs/engineering/api/api_error_handling_contract.md`
- `docs/engineering/api/api_pagination_cursor_support.md`
- [ADR 0016](../../ADR/records/0016-validated-form-boundaries.md)
- `lib/core/domain/README.md`
