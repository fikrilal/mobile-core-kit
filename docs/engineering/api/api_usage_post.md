# API Usage — POST (Typed, Flexible, and Paginated)

This guide standardizes how to call POST endpoints using `ApiHelper` and map results through the Data/Domain layers into presentation. It complements the pagination docs and the data/domain guide with concrete, end‑to‑end patterns.

## When To Use

- Use `post` for typical JSON POST endpoints that return a single object in the envelope `{ status, data, meta?, message? }`.
- Use `postFlexible` when the `data` payload can be a Map or List, or when you want to parse the raw `data` dynamically.
- Use `postPaginated` for POST endpoints that return a list under `data` and `meta.pagination` (e.g., filtered searches that POST a body).

## Expected Response Envelope

Success envelope (single item):
```json
{
  "status": "success",
  "data": { /* typed item */ },
  "message": "...",
  "meta": { /* optional */ }
}
```

Error envelope:
```json
{
  "status": "error",
  "message": "Human-readable error",
  "errors": [
    { "field": "rating", "message": "Must be 1..5", "code": "range" }
  ],
  "meta": { /* optional */ }
}
```

Notes:
- `ApiHelper` parses this envelope into `ApiResponse<T>`; on success it calls your `parser` to produce typed `T`.
- For paginated POSTs, prefer `postPaginated` which returns `ApiResponse<ApiPaginatedResult<T>>`.

## Core Types Recap

- `ApiResponse<T>`: status, data, message, meta, errors, statusCode.
- `ApiFailure`: exception used internally/optionally surfaced; includes `statusCode` and `validationErrors`.
- `ApiResponseEitherX.toEitherWithFallback(...)`: maps `ApiResponse<T>` → `Either<ApiFailure, T>`.
- `ApiPaginatedResult<T>`: typed list + `PaginationMeta` + `additionalMeta` (meta without `pagination`).

## Choosing the Right Method

- `post<T>`: Standard typed POST. Provide a `parser: (json) => T.fromJson(...)` when `data` is a JSON object.
- `postFlexible<T>`: When `data` might vary (Map or List), or you want to parse the raw `data` without forcing a Map cast.
- `postPaginated<T>`: When the POST endpoint returns a list plus pagination inside `meta.pagination`.

## Pattern — Data Layer (VO-driven, typed)

Request model (DTO) extends the domain request entity and serializes to JSON:
```dart
// data/model/remote/create_book_review_request_model.dart
class CreateBookReviewRequestModel extends CreateBookReviewRequestEntity {
  const CreateBookReviewRequestModel({
    required super.workId,
    required super.editionId,
    required super.rating,
    required super.reviewText,
    required super.visibility,
    required super.isSpoiler,
  });

  factory CreateBookReviewRequestModel.fromEntity(CreateBookReviewRequestEntity e) =>
      CreateBookReviewRequestModel(
        workId: e.workId,
        editionId: e.editionId,
        rating: e.rating,
        reviewText: e.reviewText,
        visibility: e.visibility,
        isSpoiler: e.isSpoiler,
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
  CreateBookReviewRequestEntity request,
) async {
  try {
    final model = CreateBookReviewRequestModel.fromEntity(request);
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

Use Value Objects (VOs) for client-side rules; the use case revalidates (final gate) before hitting the repository:
```dart
// domain/usecase/create_book_review_usecase.dart
Future<Either<DiscoverFailure, ReviewCommentEntity>> call(CreateBookReviewRequestEntity request) async {
  if (request.workId.trim().isEmpty) {
    return left(const DiscoverFailure.validation('Missing work identifier'));
  }
  if (request.editionId.trim().isEmpty) {
    return left(const DiscoverFailure.validation('Missing edition identifier'));
  }

  final r = ReviewRating.create(request.rating);
  final t = ReviewText.create(request.reviewText);
  final rErr = r.swap().toOption().toNullable();
  if (rErr != null) return left(DiscoverFailure.validation(rErr.userMessage));
  final tErr = t.swap().toOption().toNullable();
  if (tErr != null) return left(DiscoverFailure.validation(tErr.userMessage));

  return _repository.createBookReview(request);
}
```

## Pattern — Presentation (Forms with Cubit)

- Keep a single immutable state with a `FormStatus` enum (`idle`, `submitting`, `success`, `failure`).
- On field changes, call VO `create(...)`, store `errorText` in state; do not perform side effects in `build`.
- On submit, re-validate (VOs + required IDs), call the use case, and emit one-shot effects via a single-subscription `Stream<Effect>` or use `BlocListener` on status changes.

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

When a POST returns a list with `meta.pagination`, prefer `postPaginated<T>` to get a typed `ApiPaginatedResult<T>`:
```dart
final resp = await _apiHelper.postPaginated<ItemModel>(
  '/items/search',
  host: ApiHost.core,
  data: criteria.toJson(),
  itemParser: (j) => ItemModel.fromJson(Map<String, dynamic>.from(j)),
);
// resp.data!.pagination => PaginationMeta
// resp.data!.additionalMeta => meta minus pagination
```

## Validation & Error Handling

- Client (VOs): fast feedback in Cubit state; final gate in use case.
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
- Using broadcast streams for UI effects (can cause duplicate snackbars); prefer single-subscription stream or `BlocListener` on status.

## Testing Tips

- VO tests: assert happy/sad paths for `ReviewRating` and `ReviewText`.
- Datasource tests: assert path assembly, `itemParser` correctness (pure tests).
- Repository tests: mock `ApiResponse` success/error; assert Either mapping, 400/422 → validation.
- Use case tests: final-gate validation branches; ensure repository is not called on invalid inputs.
- Cubit tests: field errors set on change; `submit()` emits success/failure states and one effect.

## Migration Checklist

- Use VO-driven DTOs; keep model→entity mapping in model files.
- Replace manual error parsing with `toEitherWithFallback()` + failure mapping.
- Prefer `post` with typed `parser`. Use `postFlexible` only when payloads vary significantly.
- For lists with pagination, use `postPaginated` and consume `PaginationMeta`.

## See Also

- api_usage_get_paginated.md — Typed pagination usage for GET/POST lists.
- api_pagination_offset_support.md — Offset-aware pagination details.
- data_domain_guide.md — Layer responsibilities and canonical patterns.
- ui_state_architecture.md — State + effects patterns for presentation.
- validation_architecture.md — VO-driven validation and final gate.

