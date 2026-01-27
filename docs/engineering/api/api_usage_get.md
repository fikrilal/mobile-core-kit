# API Usage — GET (One, List, Paginated)

This guide standardizes how to call GET endpoints via `ApiHelper` and map results across Data → Domain → Presentation. It complements `api_usage_post.md` and `api_usage_get_paginated.md` with a consolidated, copy‑ready reference.

## When To Use

- `getOne<T>` — The endpoint returns a single item under `data` (object envelope).
- `getList<T>` — The endpoint returns a plain array under `data` and may include non‑pagination `meta`.
- `getPaginated<T>` — The endpoint returns an array under `data` with cursor pagination in `meta.nextCursor` (and optionally `meta.limit`). Prefer this whenever cursor pagination is present.

## Expected Envelopes

Success — single item (getOne):
```json
{ "data": { /* item */ }, "meta": { /* optional */ } }
```

Success — list (getList/getPaginated):
```json
{ "data": [ { /* item */ } ], "meta": { /* optional */ } }
```

Error (any, RFC7807 `application/problem+json`):
```json
{
  "type": "about:blank",
  "title": "Validation failed",
  "status": 422,
  "detail": "Optional detail",
  "code": "VALIDATION_FAILED",
  "traceId": "req_123"
}
```

Notes
- `ApiHelper` parses the success envelope into `ApiResponse<T>` with `data`, optional `meta`, and `traceId` (from `X-Request-Id`).
- For HTTP errors, Dio throws; with `throwOnError: false`, `ApiHelper` returns an `ApiResponse.error(...)` synthesized from RFC7807.
- `getPaginated` transforms cursor meta into `ApiResponse<ApiPaginatedResult<T>>` (`nextCursor`, `limit`, `additionalMeta`).

## Core Types

- `ApiResponse<T>` — Success/error wrapper used across the Data layer.
- `ApiPaginatedResult<T>` — Items + cursor pagination (`nextCursor`, `limit`) + `additionalMeta`.
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

Use when the endpoint returns an array under `data` with no cursor pagination (`meta.nextCursor`).

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
- If cursor pagination exists (`meta.nextCursor`), migrate to `getPaginated` for typed pagination.

## Pattern — getPaginated (Typed Pagination)

Prefer this whenever cursor pagination exists (`meta.nextCursor`). Example: cursor-based lists.

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
- Use `result.nextCursor` as the cursor for the next request.
- Use `result.additionalMeta` for feature extras (e.g., `workId`, `filters`).

## VO‑Driven Queries

Keep query inputs as domain VOs and provide a small mapper in `data/mapper/` to serialize to query params.
```dart
Map<String, dynamic> bookReviewsQueryToMap(ReviewCommentsQuery q) => {
  'limit': q.limit,
  'cursor': q.cursor,
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

- Reading cursor pagination from `resp.meta` after `getPaginated` — use `result.nextCursor` / `result.limit`.
- Building pagination maps manually in repositories — rely on `ApiPaginatedResult` fields.
- Passing raw query maps from repositories — serialize VO in the datasource (or a `mapper/`).
- Doing side effects in widget `build` — use `BlocListener` or a single‑subscription effects stream.

## Testing Tips

- Mapper tests (pure): VO → query, model → entity, paginated result → domain.
- Remote tests: path assembly + `itemParser` correctness.
- Repository tests: success/error mapping; 400/422 → validation; pagination mapping via typed helpers.
- Bloc/Cubit tests (presentation): list pagination guards, error messaging via `userMessage`.

## See Also

- `docs/engineering/api/api_usage_post.md` — POST variants and patterns.
- `docs/engineering/api/api_usage_get_paginated.md` — Deep dive on cursor pagination.
- `docs/engineering/data_domain_guide.md` — Layer responsibilities and canonical patterns.
- `docs/engineering/ui_state_architecture.md` — State + effects patterns for presentation.
- `docs/engineering/api/api_pagination_cursor_support.md` — Cursor pagination details.
