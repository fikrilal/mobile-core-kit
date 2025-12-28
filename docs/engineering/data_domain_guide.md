# Data & Domain Layer Guide

This guide codifies how features in this codebase structure and implement their Data and Domain
layers. It aims to make implementations predictable and readable, simplify pagination, and reduce
ambiguity between model mapping and query serialization.

## Goals

- Keep responsibilities clear between Domain, Data, and Presentation layers.
- Standardize pagination and error handling with core helpers.
- Make repositories thin (orchestration only) and datasources VO‑driven.
- Put model→domain mapping next to the model; keep mappers for query serialization only.

## Layer Responsibilities

- Domain
    - Entities (Freezed): immutable, UI‑agnostic domain objects.
    - Value Objects (VOs): typed query/input parameters (immutable).
    - Failures: feature‑scoped failure types (with `userMessage`).
    - Usecases: domain entry points. Return `Either<Failure, Domain>`.

- Data
    - Models (remote/local): Freezed + JSON. Own model→domain mapping via extensions or helpers in
      the same file.
    - Datasources (remote/local): own HTTP/DB specifics, build paths from VO, serialize VO to query
      parameters internally, call core `ApiHelper`.
    - Mappers: for VO→query parameter maps only (keep simple and pure).
    - Repositories: orchestrate datasource calls, convert `ApiResponse<T>` to `Either`, map
      failures, and invoke model‑owned mapping to return domain types.

- Presentation
    - BLoC/Cubit: consume usecases and manage UI state (covered in UI state docs).

## Project Structure (conventions)

- Domain
    - `lib/features/<feature>/domain/entity/*_entity.dart`
    - `lib/features/<feature>/domain/param/*_query.dart`
    - `lib/features/<feature>/domain/repository/*_repository.dart`
    - `lib/features/<feature>/domain/usecase/*_usecase.dart`

- Data
    - `lib/features/<feature>/data/model/remote/*_model.dart`
    - `lib/features/<feature>/data/datasource/remote/*_remote_datasource.dart`
    - `lib/features/<feature>/data/repository/*_repository_impl.dart`
    - `lib/features/<feature>/data/mapper/*_mapper.dart` (VO→query params only)

- DI
    - `lib/features/<feature>/di/*_module.dart`

## Core Helpers You Should Use

- Pagination (typed): `ApiHelper.getPaginated` + `ApiPaginatedResult<T>` + `PaginationMeta` (
  offset‑aware)
    - Offset getter: `PaginationMetaX.offset` (from core)
- Response to Either: `ApiResponseEitherX.toEitherWithFallback()`

## Canonical Pattern (example: Book Reviews)

- VO (Domain): `lib/features/review/domain/param/review_comments_query.dart`

```dart
@immutable
class ReviewCommentsQuery {
  const ReviewCommentsQuery({
    required this.workId,
    this.limit = 10,
    this.offset = 0,
    this.sortBy = ReviewSortBy.recent,
    this.sortOrder = ReviewSortOrder.desc,
    this.visibility = ReviewVisibility.public,
    this.status = ReviewStatus.published,
  });
// fields...
}
```

- VO → Query params (Mapper): `lib/features/review/data/mapper/review_comment_mapper.dart`

```dart
Map<String, dynamic> bookReviewsQueryToMap(ReviewCommentsQuery q) =>
    {
      'limit': q.limit,
      'offset': q.offset,
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
  final p = result.toDomainOffsetPagination(); // uses PaginationMetaX.offset
  final meta = result.additionalMeta ?? const <String, dynamic>{};
  final f = (meta['filters'] is Map)
      ? Map<String, dynamic>.from(meta['filters'] as Map)
      : const <String, dynamic>{};
  return ReviewCommentsEntity(
    comments: items,
    meta: ReviewCommentsMetaEntity(
      workId: (meta['workId'] as String?) ?? '',
      pagination: ReviewCommentsPaginationEntity(
        total: p.total,
        limit: p.limit,
        offset: p.offset,
        hasNext: p.hasNext,
        hasPrev: p.hasPrev,
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

- Use `getPaginated` whenever the backend returns `meta.pagination`.
- The core `PaginationMeta.fromJson` is offset‑aware (derives `page` from `offset/limit` when
  needed).
- Use `PaginationMetaX.offset` or `toDomainOffsetPagination()` to avoid recomputing offset.
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

- Prefer `getPaginated` for list endpoints that include `meta.pagination` (page or offset).
- Move model→domain mapping into model files. Keep mappers for VO→params only.
- Repos should not rebuild `meta` maps; rely on typed `ApiPaginatedResult` and core pagination
  helpers.
- Avoid legacy `normalize*` helpers for meta in new code (typed path supersedes them).

## FAQ

- Mapper vs Model mapping?
    - Mapper: VO→query params only. Model mapping belongs to the model file (via extensions), so
      conversions are easy to find and test.
- When to use `getList`?
    - Only for plain arrays without pagination/meta. If there’s `meta.pagination`, use
      `getPaginated`.
- How to add a new paginated endpoint?
    - Add VO (Domain), add VO→params mapper, add VO‑driven datasource with `getPaginated`, add
      repository method using `toEitherWithFallback` + model‑owned mapping.

## Related Docs

- `docs/engineering/api_pagination_offset_support.md` — details on offset‑aware pagination and
  `getPaginated`.
- UI state, VO validation, and architecture docs under `docs/engineering/`.
