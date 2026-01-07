# API Pagination — Cursor Support

This template uses cursor-based pagination for list endpoints.

## Contract

Cursor endpoints return:

```json
{
  "data": [ /* items */ ],
  "meta": {
    "nextCursor": "cursor_or_null",
    "limit": 25
  }
}
```

- Omit `nextCursor` or set it to null/empty when there is no next page.
- `limit` is optional; include it if you want clients to display or reuse it.

## Client conventions (this repo)

- Use `ApiHelper.getPaginated` / `ApiHelper.postPaginated`.
- Consume pagination via `ApiPaginatedResult<T>`:
  - `items`
  - `nextCursor`
  - `limit`
  - `additionalMeta` (any other meta keys)
- For subsequent requests, pass the cursor back as a query param (commonly `cursor`):
  - `?cursor=<nextCursor>&limit=<limit>`

## Why cursor

- Stable under inserts/deletes compared to offset.
- Works well with infinite scroll (`hasNext` is derived from `nextCursor != null`).

