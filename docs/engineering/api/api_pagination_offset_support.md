# API Pagination: Offset-aware getPaginated

This document explains the change to make `ApiHelper.getPaginated` compatible with endpoints that return offset-based pagination and how to adopt it across the codebase. It also outlines next steps for page-based endpoints and migration guidelines.

## Summary

- We extended `PaginationMeta.fromJson` to support payloads that use `offset` instead of `page`/`currentPage`.
- Review module now uses `getPaginated` for fetching book reviews and composes domain meta from the typed `PaginationMeta` plus any additional metadata.
- This keeps a single typed path (`ApiPaginatedResult<T>`) regardless of whether a backend endpoint is offset- or page-based.

## Why

Many endpoints return:

- `data`: an array of items
- `meta.pagination`: an object with either page-based keys (`currentPage` or `page`) or offset-based keys (`offset`, `limit`, `total`, `hasNext`, `hasPrev`)

Previously, `getList` preserved meta but did not type pagination; `getPaginated` required page/currentPage. We now bridge the gap so both schemas work with `getPaginated`.

## Implementation

File: `lib/core/network/api/api_paginated_result.dart:18`

- Behavior changes in `PaginationMeta.fromJson`:
  - Prefer `currentPage`/`page` when present.
  - If missing, derive `page` from `offset` and `limit`: `page = (offset ~/ limit) + 1`.
  - Derive `totalPages` if missing: `ceil(total / limit)`.
  - If `hasNext`/`hasPrev` missing, compute from page/limit/total or offset.

This keeps existing page-based endpoints intact and adds support for offset-based ones.

## Review Module Changes (Example)

1) Remote datasource: switch to `getPaginated` and serialize query internally

File: `lib/features/review/data/datasource/remote/review_remote_datasource.dart`

```
Future<ApiResponse<ApiPaginatedResult<ReviewCommentModel>>> getBookReviews({
  required String workId,
  Map<String, dynamic>? queryParameters,
  required ReviewCommentsQuery query,
}) {
  return _apiHelper.getPaginated<ReviewCommentModel>(
    DiscoverEndpoint.bookReviews(workId),
    host: ApiHost.core,
    queryParameters: bookReviewsQueryToMap(query),
    itemParser: (json) => ReviewCommentModel.fromJson(Map<String, dynamic>.from(json)),
  );
}
```

2) Repository: consume typed `ApiPaginatedResult` and map directly to domain (no meta rebuild)

File: `lib/features/review/data/repository/review_repository_impl.dart`

```
return right(mapBookReviewsPaginated(result));
```

> Note: `ApiHelper.getPaginated` returns `additionalMeta` which is `meta` without `pagination`. Always read pagination from `result.pagination`, not from `resp.meta`.

## When to Use `getPaginated` vs `getList`

- Use `getPaginated` when the backend returns `meta.pagination` with paging information, regardless of page- or offset-based schema.
- Use `getList` only for plain lists without `meta.pagination`, or when you expressly don’t need typed pagination.

## Guidelines for Other Endpoints

For endpoints returning page/currentPage:

- No change is required. `PaginationMeta.fromJson` still prefers `currentPage`/`page` and works as before.
- Migrate remotes to `getPaginated` for typed pagination:
  - Remote: `getPaginated` with `itemParser`
  - Repository: use `resp.data.pagination` and `resp.data.additionalMeta` (do not rely on `resp.meta` for pagination)

For endpoints returning offset only:

- After this change, you can safely switch to `getPaginated`.
- If the domain layer expects offset (as in Review), derive offset from page/limit using `(page - 1) * limit` when rebuilding domain meta.

## Migration Checklist

1. Remote datasource
   - Replace `getList<T>` with `getPaginated<T>`
   - Keep `itemParser` the same

2. Repository
   - Treat `resp.data` as `ApiPaginatedResult<T>`
   - Prefer a feature-level mapper (e.g., `mapBookReviewsPaginated`) to build domain entities directly
   - Avoid manual map composition for meta; rely on `PaginationMeta` and any additional meta

3. Domain and UI
   - No changes if domain already models limit/offset/hasNext
   - BLoC/UI logic for load-more remains the same (offset += limit)

## Edge Cases & Notes

- limit == 0: the parser guards division by zero; page fallback uses `limit == 0 ? 1 : limit`.
- Backend returns both page and offset: page takes precedence; offset is used only if page/currentPage is absent.
- `getPaginated` removes `pagination` from the raw `meta` and exposes it as `additionalMeta`. Do not expect `meta['pagination']` to exist anymore when using `getPaginated`.

## Future Work

- Unify Discover feature remotes that return lists with pagination to use `getPaginated` for consistency.
- Add a small mapper/util to convert `PaginationMeta` <-> offset triplet to reduce repetition in repositories.
- Consider adding a convenience `offset` getter on `PaginationMeta` to simplify conversion in offset-first domains:
  - `int get offset => (page - 1) * limit;`
