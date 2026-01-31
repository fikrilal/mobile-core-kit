# Data & Domain Layer Guide

This guide codifies how features in this codebase structure and implement their Data and Domain
layers. It aims to make implementations predictable and readable, simplify pagination, and reduce
ambiguity between model mapping and query serialization.

## Goals

- Keep responsibilities clear between Domain, Data, and Presentation layers.
- Standardize pagination and error handling with core helpers.
- Make repositories thin (orchestration only) and keep HTTP/DB details in datasources.
- Put model→domain mapping next to the model; keep mappers for query serialization only.

## Layer Responsibilities

- Domain
    - Entities (Freezed): immutable, UI‑agnostic domain objects.
    - Value Objects (VOs): typed inputs and invariants (immutable).
    - Param VOs: typed query parameters for GET endpoints (immutable).
    - Failures: feature‑scoped failure types (with `userMessage`).
    - Usecases: domain entry points. Return `Either<Failure, Domain>`.

- Data
    - Models (remote/local): Freezed + JSON. Own model→domain mapping via extensions or helpers in
      the same file.
    - Datasources (remote/local): own HTTP/DB specifics (paths, headers, serialization) and call
      core `ApiHelper` / DB adapters.
      - GET endpoints: accept a Param VO and serialize via a mapper (`*_mapper.dart`) into query
        parameters.
      - POST/PATCH endpoints: accept a request model (built via `Model.fromEntity(...)`) and call
        `toJson()` for request bodies.
    - Mappers: for Param VO → query parameter maps only (keep simple and pure).
    - Failure mappers: map `ApiFailure`/backend codes into feature failures (keep repo readable).
    - Repositories: orchestrate datasource calls, convert `ApiResponse<T>` to `Either`, map
      failures, and invoke model‑owned mapping to return domain types.

- Presentation
    - BLoC/Cubit: consume usecases and manage UI state (covered in UI state docs).

## Project Structure (conventions)

- Domain
    - `lib/features/<feature>/domain/entity/*_entity.dart`
    - `lib/features/<feature>/domain/value/*` (Value Objects for inputs/invariants)
    - `lib/features/<feature>/domain/param/*_query.dart`
    - `lib/features/<feature>/domain/repository/*_repository.dart`
    - `lib/features/<feature>/domain/usecase/*_usecase.dart`

- Data
    - `lib/features/<feature>/data/model/remote/*_model.dart`
    - `lib/features/<feature>/data/model/local/*_model.dart`
    - `lib/features/<feature>/data/datasource/remote/*_remote_datasource.dart`
    - `lib/features/<feature>/data/datasource/local/*_local_datasource.dart`
    - `lib/features/<feature>/data/repository/*_repository_impl.dart`
    - `lib/features/<feature>/data/mapper/*_mapper.dart` (VO→query params only)
    - `lib/features/<feature>/data/error/*_failure_mapper.dart`

- DI
    - `lib/features/<feature>/di/*_module.dart`

## Core Helpers You Should Use

- Pagination (cursor‑based, typed): `ApiHelper.getPaginated` / `ApiHelper.postPaginated` +
  `ApiPaginatedResult<T>`
    - Cursor: `ApiPaginatedResult.nextCursor`
    - Limit: `ApiPaginatedResult.limit`
    - Extra meta: `ApiPaginatedResult.additionalMeta` (all meta keys except `nextCursor`/`limit`)
- Response to Either: `ApiResponseEitherX.toEitherWithFallback()`

## Canonical Pattern (example: Book Reviews)

- VO (Domain): `lib/features/review/domain/param/review_comments_query.dart`

```dart
@immutable
class ReviewCommentsQuery {
  const ReviewCommentsQuery({
    required this.workId,
    this.limit = 10,
    this.cursor,
    this.sortBy = ReviewSortBy.recent,
    this.sortOrder = ReviewSortOrder.desc,
    this.visibility = ReviewVisibility.public,
    this.status = ReviewStatus.published,
  });
// fields...
  final String? cursor;
}
```

- VO → Query params (Mapper): `lib/features/review/data/mapper/review_comment_mapper.dart`

```dart
Map<String, dynamic> bookReviewsQueryToMap(ReviewCommentsQuery q) =>
    {
      'limit': q.limit,
      if (q.cursor != null) 'cursor': q.cursor,
      'sortBy': q.sortBy.toJson(),
      'sortOrder': q.sortOrder.toJson(),
      'visibility': q.visibility.toJson(),
      'status': q.status.toJson(),
    };
```

- Datasource (VO‑driven, typed pagination):
  `lib/features/review/data/datasource/remote/review_remote_datasource.dart`

```dart
Future<ApiResponse<ApiPaginatedResult<ReviewCommentModel>>> getBookReviews({
  required ReviewCommentsQuery query,
}) =>
    _apiHelper.getPaginated(
      DiscoverEndpoint.bookReviews(query.workId),
      host: ApiHost.core,
      queryParameters: bookReviewsQueryToMap(query),
      itemParser: (j) => ReviewCommentModel.fromJson(Map<String, dynamic>.from(j)),
    );
```

- Repository (orchestration only): `lib/features/review/data/repository/review_repository_impl.dart`

```dart

final resp = await
_remote.getBookReviews
(
query: query);
return resp
    .toEitherWithFallback('Failed to load book reviews.')
    .mapLeft(_mapApiFailure)
    .map(
bookReviewsResultToEntity
);
```

- Model → Domain mapping (in the model):
  `lib/features/review/data/model/remote/review_comment_model.dart`

```dart
extension ReviewCommentModelX on ReviewCommentModel {
  ReviewCommentEntity toEntity() =>
      ReviewCommentEntity(
        id: id,
        userId: userId,
        workId: workId,
        editionId: editionId,
        rating: rating,
        reviewText: reviewText,
        visibility: ReviewVisibility.fromJson(visibility),
        status: ReviewStatus.fromJson(status),
        isSpoiler: isSpoiler,
        helpfulCount: helpfulCount,
        flagCount: flagCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        user: ReviewCommentUserEntity(
          id: user.id, username: user.username,
          displayName: user.displayName, avatarUrl: user.avatarUrl,
        ),
      );
}

ReviewCommentsEntity bookReviewsResultToEntity(ApiPaginatedResult<ReviewCommentModel> result,) {
  final items = result.items.map((m) => m.toEntity()).toList(growable: false);
  final meta = result.additionalMeta ?? const <String, dynamic>{};
  final f = (meta['filters'] is Map)
      ? Map<String, dynamic>.from(meta['filters'] as Map)
      : const <String, dynamic>{};
  return ReviewCommentsEntity(
    comments: items,
    meta: ReviewCommentsMetaEntity(
      workId: (meta['workId'] as String?) ?? '',
      pagination: ReviewCommentsPaginationEntity(
        limit: result.limit ?? 0,
        nextCursor: result.nextCursor,
        hasNext: result.nextCursor != null && result.nextCursor!.isNotEmpty,
      ),
      filters: ReviewCommentFiltersEntity(
        visibility: ReviewVisibility.fromJson(f['visibility'] as String?),
        status: ReviewStatus.fromJson(f['status'] as String?),
        sortBy: ReviewSortBy.fromJson(f['sortBy'] as String?),
        sortOrder: ReviewSortOrder.fromJson(f['sortOrder'] as String?),
      ),
    ),
  );
}
```

## Repository Rules

- Accept VO. Don’t build raw query maps here.
- Call VO‑driven datasource. Datasource assembles path and params.
- Convert `ApiResponse<T>` → `Either<ApiFailure, T>` using core helper.
- Map left to feature failure, right to model‑owned mapping that returns domain.
- Return `Either<FeatureFailure, Domain>`.

## Pagination Rules

- Use `getPaginated` / `postPaginated` whenever the backend returns cursor pagination metadata
  (`meta.nextCursor`, optionally `meta.limit`).
- Model cursor pagination in a Param VO:
  - `cursor: String?` (null means first page)
  - `limit: int` (optional; keep a stable default)
- Pass `cursor` as a query parameter (only when non‑null) and store the returned
  `ApiPaginatedResult.nextCursor` for the next request.
- Treat `nextCursor == null` (or empty) as “no next page”.
- Read non‑pagination meta from `ApiPaginatedResult.additionalMeta`.

## Error Handling

- Datasources return `ApiResponse<T>` without throwing on logical errors.
- Repositories turn `ApiResponse<T>` into `Either` with `toEitherWithFallback()`, then map to
  feature failure.
- Keep user messages in failure types via `userMessage` extensions.
- Prefer mapping by backend `code` first, and fall back to HTTP status codes for resilience.
  See `docs/engineering/api/api_error_handling_contract.md`.

## DI Guidelines

- Register in the feature DI module:
    - `ReviewRemoteDataSource` (lazy singleton)
    - `ReviewRepository` (lazy singleton)
    - Usecases (lazy singleton)
    - BLoC (factory) in the module where it’s consumed

## Testing Guidelines

- Mapper tests (pure):
    - VO → query params
    - Model → entity
- Repository tests:
    - Mock datasource `ApiResponse` (success/error), assert `Either` mapping
- Don’t test HTTP in repositories; cover path assembly and `itemParser` in datasource tests if
  needed

## Migration Notes

- Prefer `getPaginated` / `postPaginated` for list endpoints that include cursor pagination metadata
  (`meta.nextCursor`, `meta.limit`).
- Move model→domain mapping into model files. Keep mappers for Param VO→query params only.
- Repos should not rebuild `meta` maps; rely on typed `ApiPaginatedResult` and
  `ApiPaginatedResult.additionalMeta`.

## FAQ

- Mapper vs Model mapping?
    - Mapper: VO→query params only. Model mapping belongs to the model file (via extensions), so
      conversions are easy to find and test.
- When to use `getList`?
    - Only for plain arrays without pagination/meta. If the backend returns cursor pagination
      metadata (`meta.nextCursor`), use `getPaginated` / `postPaginated`.
- How to add a new paginated endpoint?
    - Add VO (Domain), add VO→params mapper, add VO‑driven datasource with `getPaginated`, add
      repository method using `toEitherWithFallback` + model‑owned mapping.

## Related Docs

- `docs/engineering/api/api_pagination_cursor_support.md` — cursor pagination contract (`nextCursor`).
- `docs/engineering/api/api_error_handling_contract.md` — error payload + mapping rules.
- `lib/core/infra/network/api/api_documentation.md` — `ApiHelper` usage patterns and examples.
- UI state, VO validation, and architecture docs under `docs/engineering/`.
