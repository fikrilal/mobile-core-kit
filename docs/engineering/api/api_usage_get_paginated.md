# API Usage — getPaginated (Cursor)

This guide documents how to consume cursor-paginated list endpoints using `ApiHelper.getPaginated`,
the expected response shape, and the recommended patterns to map results into domain models.

## When To Use

- Use `getPaginated` when the backend returns a list under `data` and cursor metadata in `meta`.
- Prefer `getPaginated` over `getList` for any endpoint that includes `meta.nextCursor`.

## Expected Response Envelope

```json
{
  "data": [
    { /* item */ }
  ],
  "meta": {
    "nextCursor": "cursor_or_null",
    "limit": 25,
    "filters": { /* optional, feature-specific */ }
  }
}
```

Notes:
- `getPaginated` extracts `nextCursor` and `limit` into `ApiPaginatedResult<T>`.
- `additionalMeta` is `meta` with `nextCursor`/`limit` removed (use it for feature-specific fields).

## Core Types

- `ApiResponse<ApiPaginatedResult<T>>` — response wrapper (success/error) + preserved `meta`.
- `ApiPaginatedResult<T>` — `{ items, nextCursor, limit, additionalMeta? }`.

## Calling getPaginated

Remote datasource:
```dart
Future<ApiResponse<ApiPaginatedResult<ItemModel>>> getItems({
  required ItemsQuery query,
}) => _apiHelper.getPaginated<ItemModel>(
  '/v1/items',
  host: ApiHost.core,
  queryParameters: itemsQueryToMap(query), // includes cursor/limit when present
  itemParser: (json) => ItemModel.fromJson(Map<String, dynamic>.from(json)),
);
```

Repository:
```dart
final resp = await _remote.getItems(query: query);
return resp
  .toEitherWithFallback('Failed to load items.')
  .mapLeft(_mapApiFailure)
  .map((result) => mapPaginatedResult(
        result: result,
        itemMapper: (m) => m.toEntity(),
      ));
```

## Load More (cursor pattern)

- Use `result.hasNext` / `result.nextCursor` to decide if more can be loaded.
- When requesting the next page, pass the cursor back to the datasource:
  - `?cursor=<result.nextCursor>&limit=<same_limit>`

