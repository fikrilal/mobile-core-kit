# API Usage — GET (One, List, Paginated)

This guide standardizes how to call GET endpoints via `ApiHelper` and map results across Data → Domain → Presentation. It complements `api_usage_post.md` and `api_usage_get_paginated.md` with a consolidated, copy‑ready reference.

## When To Use

- `getOne<T>` — The endpoint returns a single item under `data` (object envelope).
- `getList<T>` — The endpoint returns a plain array under `data` and may include non‑pagination `meta`.
- `getPaginated<T>` — The endpoint returns an array under `data` and `meta.pagination` (page‑ or offset‑based). Prefer this whenever pagination is present.

## Expected Envelopes

Success — single item (getOne):
```json
{
  "status": "success",
  "data": { /* item */ },
  "message": "optional",
  "meta": { /* optional */ }
}
```

Success — list (getList/getPaginated):
```json
{
  "status": "success",
  "data": [ { /* item */ } ],
  "meta": {
    /* optional extras */
    "pagination": { /* present only for getPaginated */ }
  }
}
```

Error (any):
```json
{
  "status": "error",
  "message": "Human‑readable error",
  "errors": [ { "field": "...", "message": "...", "code": "..." } ]
}
```

Notes
- `ApiHelper` parses the envelope into `ApiResponse<T>` (`status`, `data`, `message`, `meta`, `errors`, `statusCode`).
- `getPaginated` transforms the envelope into `ApiResponse<ApiPaginatedResult<T>>` with typed `pagination` and `additionalMeta` (which is `meta` without `pagination`).

## Core Types

- `ApiResponse<T>` — Success/error wrapper used across the Data layer.
- `ApiPaginatedResult<T>` — Items + `PaginationMeta` + `additionalMeta`.
- `PaginationMeta` — Supports both page‑ and offset‑based schemas (see `api_pagination_offset_support.md`).
- `ApiResponseEitherX.toEitherWithFallback` — Converts ApiResponse → Either<ApiFailure, T>.

## Pattern — getOne (Single Item)

Use when the endpoint returns a single resource under `data`. Example: review summary.

Remote (VO‑driven):
```dart
Future<ApiResponse<ReviewSummaryModel>> getBookReviewSummary({
  required ReviewSummaryQuery query,
}) => _apiHelper.getOne<ReviewSummaryModel>(
  DiscoverEndpoint.bookReviewSummary(query.workId),
  host: ApiHost.core,
  queryParameters: reviewSummaryQueryToMap(query),
  parser: (json) => ReviewSummaryModel.fromJson(Map<String, dynamic>.from(json)),
);
```

Repository (orchestration only):
```dart
final resp = await _remote.getBookReviewSummary(query: query);
return resp
    .toEitherWithFallback('Failed to load book review summary.')
    .mapLeft(_mapApiFailure)
    .map((m) => m.toEntityWithMeta(resp.meta));
```

Model‑owned mapping (recommended):
```dart
extension ReviewSummaryModelX on ReviewSummaryModel {
  ReviewSummaryEntity toEntityWithMeta(Map<String, dynamic>? meta) { /* ... */ }
}
```

## Pattern — getList (Plain Array)

Use when the endpoint returns an array under `data` with no `meta.pagination`.

Remote:
```dart
Future<ApiResponse<List<ItemModel>>> getItems({
  Map<String, dynamic>? query,
}) => _apiHelper.getList<ItemModel>(
  '/path/to/items',
  host: ApiHost.core,
  queryParameters: query,
  itemParser: (j) => ItemModel.fromJson(Map<String, dynamic>.from(j)),
);
```

Repository:
```dart
final resp = await _remote.getItems(query: buildQueryFromVO(vo));
return resp
  .toEitherWithFallback('Failed to load items.')
  .mapLeft(_mapApiFailure)
  .map((list) => list.map((m) => m.toEntity()).toList(growable: false));
```

Notes
- `ApiResponse.meta` is preserved but not typed; use only when you truly don’t need pagination.
- If `meta.pagination` exists, migrate to `getPaginated` for typed pagination.

## Pattern — getPaginated (Typed Pagination)

Prefer this whenever `meta.pagination` exists (page‑ or offset‑based). Example: book reviews list.

Remote (VO‑driven):
```dart
Future<ApiResponse<ApiPaginatedResult<ReviewCommentModel>>> getBookReviews({
  required ReviewCommentsQuery query,
}) => _apiHelper.getPaginated<ReviewCommentModel>(
  DiscoverEndpoint.bookReviews(query.workId),
  host: ApiHost.core,
  queryParameters: bookReviewsQueryToMap(query),
  itemParser: (j) => ReviewCommentModel.fromJson(Map<String, dynamic>.from(j)),
);
```

Repository:
```dart
final resp = await _remote.getBookReviews(query: query);
return resp
  .toEitherWithFallback('Failed to load book reviews.')
  .mapLeft(_mapApiFailure)
  .map(bookReviewsResultToEntity); // model‑owned mapper
```

Pagination helpers
- `PaginationMetaX.offset` and `result.toDomainOffsetPagination()` avoid recomputing offsets.
- Use `result.additionalMeta` for feature extras (e.g., `workId`, `filters`).

## VO‑Driven Queries

Keep query inputs as domain VOs and provide a small mapper in `data/mapper/` to serialize to query params.
```dart
Map<String, dynamic> bookReviewsQueryToMap(ReviewCommentsQuery q) => {
  'limit': q.limit,
  'offset': q.offset,
  'sortBy': q.sortBy.toJson(),
  'sortOrder': q.sortOrder.toJson(),
  'visibility': q.visibility.toJson(),
  'status': q.status.toJson(),
};
```

## Error Handling

Map transport errors to feature failures consistently in the repository:
```dart
DiscoverFailure _mapApiFailure(ApiFailure f) {
  switch (f.statusCode) {
    case 400:
    case 422:
      final msg = (f.validationErrors?.isNotEmpty ?? false)
          ? f.validationErrors!.first.message
          : (f.message.isNotEmpty ? f.message : 'Invalid input');
      return DiscoverFailure.validation(msg);
    case 404: return const DiscoverFailure.notFound();
    case 429: return const DiscoverFailure.rateLimitExceeded();
    case 503: return const DiscoverFailure.serviceUnavailable();
    case 500: return const DiscoverFailure.serverError();
    case -1:  return const DiscoverFailure.network();
    default:  return DiscoverFailure.unexpected(message: f.message);
  }
}
```

## Advanced

- Connectivity: `checkConnectivity` guards offline calls; returns a network failure.
- Cancellation: pass a `CancelToken` to abort in‑flight requests.
- Headers: pass `headers` to override/add request headers.
- Options: use `options` to tweak Dio request options (timeouts, etc.).

## Anti‑Patterns

- Reading `resp.meta['pagination']` after `getPaginated` — it’s moved to `result.pagination` and removed from `additionalMeta`.
- Building pagination maps manually in repositories — rely on typed `PaginationMeta`.
- Passing raw query maps from repositories — serialize VO in the datasource (or a `mapper/`).
- Doing side effects in widget `build` — use `BlocListener` or a single‑subscription effects stream.

## Testing Tips

- Mapper tests (pure): VO → query, model → entity, paginated result → domain.
- Remote tests: path assembly + `itemParser` correctness.
- Repository tests: success/error mapping; 400/422 → validation; pagination mapping via typed helpers.
- Bloc/Cubit tests (presentation): list pagination guards, error messaging via `userMessage`.

## See Also

- api_usage_post.md — POST variants and patterns.
- api_usage_get_paginated.md — Deep dive on typed pagination and offset support.
- data_domain_guide.md — Layer responsibilities and canonical patterns.
- ui_state_architecture.md — State + effects patterns for presentation.
- api_pagination_offset_support.md — Offset‑aware pagination details.

