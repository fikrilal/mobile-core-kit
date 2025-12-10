# API Usage — getPaginated

This guide documents how to consume paginated list endpoints using `ApiHelper.getPaginated`, the
expected response shape, and the recommended patterns to map results into domain models.

## When To Use

- Use `getPaginated` when the backend returns a list under `data` and a `meta.pagination` object.
- Prefer `getPaginated` over `getList` for any endpoint that includes pagination metadata (
  page‑based or offset‑based).

## Expected Response Envelope

- Success (offset‑based example):

```json
{
  "status": "success",
  "data": [
    {
      /* item */
    }
  ],
  "meta": {
    "workId": "...",
    // additional metadata (feature‑specific)
    "pagination": {
      "total": 123,
      "limit": 20,
      "offset": 40,
      "hasNext": true,
      "hasPrev": true
    },
    "filters": {
      /* optional, feature‑specific */
    }
  }
}
```

- Success (page‑based example):

```json
{
  "status": "success",
  "data": [
    {
      /* item */
    }
  ],
  "meta": {
    "pagination": {
      "currentPage": 3,
      // or "page": 3
      "limit": 20,
      "total": 123,
      "totalPages": 7,
      "hasNext": true,
      "hasPrev": true
    }
  }
}
```

Notes:

- `getPaginated` parses the list and extracts typed pagination (`PaginationMeta`).
- `additionalMeta` is `meta` with `pagination` removed (use this for feature‑specific fields like
  `workId`, `filters`).
- Do not expect `resp.meta['pagination']` after `getPaginated` — pagination is moved into
  `result.pagination`.

## Core Types

- `ApiPaginatedResult<T>`: wraps `items`, `pagination: PaginationMeta`, and
  `additionalMeta: Map<String, dynamic>?`.
- `PaginationMeta` fields: `page`, `limit`, `total`, `totalPages`, `hasNext`, `hasPrev`.
- Offset support: `PaginationMeta.fromJson` is offset‑aware (derives `page` from `offset/limit` when
  page is missing). Use `PaginationMetaX.offset` to get a consistent offset.

## Calling getPaginated

```dart

final resp = await
_apiHelper.getPaginated<ItemModel>
('/path/to/items
'
,host: ApiHost.core,
queryParameters: params, // Map<String, dynamic>
itemParser: (json) => ItemModel.fromJson(Map<String, dynamic>.from(json))
,
);
```

Recommended patterns:

- Provide an item parser that calls the model `fromJson`.
- Build `queryParameters` from the feature VO (in a mapper function).

## Patterns & Best Practices

- VO‑driven datasource: let the datasource accept the VO, build the path from VO, and serialize VO →
  `queryParameters` internally.
- Repository orchestration only: convert `ApiResponse<T>` → `Either` (e.g.,
  `toEitherWithFallback()`), map failure to feature failure, success to domain via model‑owned
  mapping.
- Model‑owned mapping: put `model → entity` conversions inside the model file (extensions). For
  paginated results, add a helper like `resultToEntity(ApiPaginatedResult<Model>)` in that same
  model file.
- Pagination helpers: use `PaginationMetaX.offset` or `toDomainOffsetPagination()` (core) to avoid
  recomputing offset logic.
- Do not rebuild meta maps in repositories; rely on `ApiPaginatedResult.pagination` and
  `additionalMeta`.

## Load More (offset pattern)

- Use `pagination.hasNext` to decide if more can be loaded.
- Next offset usually equals `currentOffset + limit`. If your domain is offset‑first, derive offset
  from `page/limit`: `(page - 1) * limit` via `PaginationMetaX.offset`.

## Error Handling

- Datasources return `ApiResponse<ApiPaginatedResult<T>>`.
- Repository converts to `Either` with a fallback message and maps left to feature failure:

```dart
return resp
    .toEitherWithFallback('Failed to load items.')
    .mapLeft(_mapApiFailure
)
.
map
(
resultToEntity
);
```

## Migration From getList

- Switch remotes to `getPaginated` when `meta.pagination` exists.
- Replace manual meta normalization in repositories with typed `pagination` + `additionalMeta`
  mapping.
- Move any `model → entity` mapping into model files; keep mappers for VO → params only.

## Anti‑Patterns

- Building `pagination` maps in repositories (use typed `PaginationMeta`).
- Passing raw query maps from repositories (datasource should serialize VO internally).
- Using `resp.meta['pagination']` after `getPaginated` (it’s removed by design).

## Testing Tips

- Mapper tests:
    - VO → query map is pure and fast.
    - Model → entity (including paginated result → domain) is pure and fast.
- Repository tests:
    - Mock `ApiResponse<ApiPaginatedResult<Model>>` (success/error) to assert Either mapping and
      domain conversion.

## See Also

- `docs/engineering/data_domain_guide.md` — Layer responsibilities, canonical patterns.
- `docs/engineering/api_pagination_offset_support.md` — Offset‑aware pagination details and migration
  notes.
