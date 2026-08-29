# API Usage — POST (Typed, Flexible, and Paginated)

This guide standardizes how to call POST endpoints using `ApiHelper` and map results through the Data/Domain layers into presentation. It complements the pagination docs and the data/domain guide with concrete, end‑to‑end patterns.

## When To Use

- Use `post` for typical JSON POST endpoints that return a single object in the success envelope `{ data, meta? }`.
- Use `postFlexible` when the `data` payload can be a Map or List, or when you want to parse the raw `data` dynamically.
- Use `postPaginated` for POST endpoints that return a list under `data` and cursor pagination in `meta.nextCursor` (e.g., filtered searches that POST a body).

## Expected Response Envelope

Success envelope (single item):
```json
{
  "data": { /* typed item */ },
  "meta": { /* optional */ }
}
```

Error (RFC7807 `application/problem+json`):
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

Notes:
- `ApiHelper` parses the success envelope into `ApiResponse<T>` and preserves `meta`.
- For HTTP errors, Dio throws; with `throwOnError: false`, `ApiHelper` returns an `ApiResponse.error(...)` synthesized from RFC7807.
- For paginated POSTs, prefer `postPaginated` which returns `ApiResponse<ApiPaginatedResult<T>>`.

## Core Types Recap

- `ApiResponse<T>`: data, meta, traceId, statusCode (and error fields when `throwOnError: false`).
- `ApiFailure`: exception used internally/optionally surfaced; includes `statusCode` and `validationErrors`.
- `ApiResponseEitherX.toEitherWithFallback(...)`: maps `ApiResponse<T>` → `Either<ApiFailure, T>`.
- `ApiPaginatedResult<T>`: typed list + cursor pagination (`nextCursor`, `limit`) + `additionalMeta` (meta without cursor keys).

## Choosing the Right Method

- `post<T>`: Standard typed POST. Provide a `parser: (json) => T.fromJson(...)` when `data` is a JSON object.
- `postFlexible<T>`: When `data` might vary (Map or List), or you want to parse the raw `data` without forcing a Map cast.
- `postPaginated<T>`: When the POST endpoint returns a list plus cursor pagination inside `meta.nextCursor`.

## Pattern — Data Layer (VO-driven, typed)

For a validated form, the request model maps from a validated domain aggregate.
It does not extend the aggregate and remains the sole owner of JSON:
```dart
// data/model/remote/create_book_review_request_model.dart
class CreateBookReviewRequestModel {
  const CreateBookReviewRequestModel({
    required this.workId,
    required this.editionId,
    required this.rating,
    required this.reviewText,
    required this.visibility,
    required this.isSpoiler,
  });

  final String workId;
  final String editionId;
  final int rating;
  final String reviewText;
  final ReviewVisibility visibility;
  final bool isSpoiler;

  factory CreateBookReviewRequestModel.fromSubmission(
    BookReviewSubmission submission,
  ) =>
      CreateBookReviewRequestModel(
        workId: submission.workId.value,
        editionId: submission.editionId.value,
        rating: submission.rating.value,
        reviewText: submission.reviewText.value,
        visibility: submission.visibility,
        isSpoiler: submission.isSpoiler,
      );

  Map<String, dynamic> toJson() => {
    'editionId': editionId,
    'rating': rating,
    'reviewText': reviewText,
    'visibility': visibility.toJson(),
    'isSpoiler': isSpoiler,
  };
}
```

Remote datasource calls `ApiHelper.post` with an item parser:
```dart
// data/datasource/remote/review_remote_datasource.dart
Future<ApiResponse<ReviewCommentModel>> createBookReview({
  required CreateBookReviewRequestModel requestModel,
}) {
  return _apiHelper.post<ReviewCommentModel>(
    DiscoverEndpoint.bookReviews(requestModel.workId), // workId in path
    host: ApiHost.core,
    data: requestModel.toJson(),
    parser: (json) => ReviewCommentModel.fromJson(Map<String, dynamic>.from(json)),
  );
}
```

Repository orchestrates, maps `ApiResponse` → `Either`, and converts DTO → Entity:
```dart
// data/repository/review_repository_impl.dart
Future<Either<DiscoverFailure, ReviewCommentEntity>> createBookReview(
  BookReviewSubmission submission,
) async {
  try {
    final model = CreateBookReviewRequestModel.fromSubmission(submission);
    final resp = await _remote.createBookReview(requestModel: model);

    final either = resp
      .toEitherWithFallback('Failed to create book review.')
      .mapLeft(_mapApiFailure); // include 400/422 => validation

    return either.map((m) => m.toEntity());
  } on ApiFailure catch (f) {
    return left(_mapApiFailure(f));
  } on TypeError catch (e) {
    return left(DiscoverFailure.unexpected(message: 'Invalid response format (create review): ${e.toString()}'));
  } on FormatException catch (e) {
    return left(DiscoverFailure.unexpected(message: 'Malformed data (create review): ${e.message}'));
  } catch (_) {
    return left(const DiscoverFailure.unexpected(message: 'Unexpected error while creating book review.'));
  }
}
```

Error mapping example (validation):
```dart
// in _mapApiFailure(ApiFailure f)
switch (f.statusCode) {
  case 400:
  case 422:
    final msg = (f.validationErrors?.isNotEmpty ?? false)
        ? f.validationErrors!.first.message
        : (f.message.isNotEmpty ? f.message : 'Invalid input');
    return DiscoverFailure.validation(msg);
  // ... other mappings
}
```

## Pattern — Domain Layer (Final Gate)

Use Value Objects (VOs) for client-side rules. The use case converts raw form
input into a validated aggregate as the final gate before the repository:
```dart
// domain/usecase/create_book_review_usecase.dart
Future<Either<DiscoverFailure, ReviewCommentEntity>> call(
  CreateBookReviewInput input,
) async {
  final submission = BookReviewSubmission.create(
    workId: input.workId,
    editionId: input.editionId,
    rating: input.rating,
    reviewText: input.reviewText,
    visibility: input.visibility,
    isSpoiler: input.isSpoiler,
  );

  return submission.match(
    (errors) async => left(mapReviewValidationFailure(errors)),
    _repository.createBookReview,
  );
}
```

`CreateBookReviewInput` may be invalid. `BookReviewSubmission` has a private
constructor, contains the field VOs, and collects deterministic field errors.
The repository contract accepts only `BookReviewSubmission`.

## Pattern — Presentation (Forms with Cubit)

- Keep a single immutable state with a `FormStatus` enum (`idle`, `submitting`, `success`, `failure`).
- On field changes, call VO `create(...)`, store a stable field error in state,
  and localize it in presentation; do not perform side effects in `build`.
- On submit, perform presentation pre-flight validation, pass the unchanged raw
  input to the use case, and emit one-shot effects through `Stream<Effect>`.

```dart
// presentation/cubit/create_book_review_cubit.dart
void ratingChanged(int rating) {
  final res = ReviewRating.create(rating);
  emit(state.copyWith(
    rating: rating,
    ratingError: res.fold((f) => f.userMessage, (_) => null),
    clearError: true,
  ));
}

Future<void> submit() async {
  // revalidate with VOs; guard required ids
  // on success -> success status + CreateBookReviewSuccess(review) effect
  // on failure -> failure status + CreateBookReviewFailure(message) effect
}
```

## When To Use `postFlexible`

Use `postFlexible` if the backend returns a variable `data` shape:
- Sometimes `data` is a Map, sometimes a List
- You need to parse a polymorphic payload without `Map<String, dynamic>` cast

Example:
```dart
final resp = await _apiHelper.postFlexible<ReviewCommentModel>(
  '/reviews',
  host: ApiHost.core,
  data: body,
  parser: (raw) {
    if (raw is Map<String, dynamic>) {
      return ReviewCommentModel.fromJson(raw);
    }
    throw Exception('Unexpected payload for create review');
  },
);
```

## POST + Pagination (`postPaginated`)

When a POST returns a list with cursor pagination (`meta.nextCursor`), prefer `postPaginated<T>` to get a typed `ApiPaginatedResult<T>`:
```dart
final resp = await _apiHelper.postPaginated<ItemModel>(
  '/items/search',
  host: ApiHost.core,
  data: criteria.toJson(),
  itemParser: (j) => ItemModel.fromJson(Map<String, dynamic>.from(j)),
);
// resp.data!.nextCursor => cursor for next request (or null)
// resp.data!.limit => server limit (if provided)
// resp.data!.additionalMeta => meta minus cursor fields
```

## Validation & Error Handling

- Client: field VOs provide fast Cubit feedback; the use case creates a
  validated aggregate as the final deterministic gate.
- Server: map 400/422 to `DiscoverFailure.validation(message)`; prefer specific field messages where available.
- Generic failures: map -1 → network, 404 → notFound, 429 → rate limit, 5xx → server/service.

Surfacing field errors (optional): if you need per-field surfacing, adapt the failure to carry a list of field errors or inspect `ApiFailure.validationErrors` earlier and translate them in the repository/use case.

## Advanced Topics

- Multipart/attachments: pass `Options(contentType: 'multipart/form-data')` and use `FormData` with `ApiHelper.post`.
- Progress callbacks: `onSendProgress`, `onReceiveProgress` params are available in `post`/`postFlexible`.
- Connectivity: `checkConnectivity` prevents calls when offline; return a network failure message.
- Headers: pass additional headers via the `headers` parameter; caller headers override duplicates.

## Anti‑Patterns

- Parsing response envelopes manually in repositories (use `ApiHelper` + typed parsers).
- Returning raw backend messages to UI without mapping to domain failures.
- Duplicating validation logic in widgets instead of using VOs.
- Using broadcast streams for UI effects (can cause duplicate snackbars); prefer a single-subscription effect stream for mutation commands.

## Testing Tips

- VO tests: assert happy/sad paths for `ReviewRating` and `ReviewText`.
- Datasource tests: assert path assembly, `itemParser` correctness (pure tests).
- Repository tests: mock `ApiResponse` success/error; assert Either mapping, 400/422 → validation.
- Use case tests: final-gate validation branches; ensure repository is not called on invalid inputs.
- Cubit tests: field errors set on change; `submit()` emits success/failure states and one effect.

## Migration Checklist

- For validated forms, map a domain aggregate into the request model and keep
  JSON ownership in the data layer.
- Replace manual error parsing with `toEitherWithFallback()` + failure mapping.
- Prefer `post` with typed `parser`. Use `postFlexible` only when payloads vary significantly.
- For lists with cursor pagination, use `postPaginated` and consume `nextCursor` / `limit`.

## See Also

- api_usage_get_paginated.md — Typed pagination usage for GET/POST lists.
- api_pagination_cursor_support.md — Cursor pagination details.
- data_domain_guide.md — Layer responsibilities and canonical patterns.
- ui_state_architecture.md — State + effects patterns for presentation.
- validation_architecture.md — VO-driven validation and final gate.
- [ADR 0016](../../../ADR/records/0016-validated-form-boundaries.md) — Applicability and trade-offs for validated form repository boundaries.
