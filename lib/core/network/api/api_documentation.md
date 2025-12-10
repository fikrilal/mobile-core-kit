# Orymu API Helper Guide

> **Audience:** Backend integrators, data‑source authors, and anyone touching the network layer
>
> **Scope:** How to call the `ApiHelper`, parse responses, handle errors, and log/trace requests in a Clean‑Architecture + GetX Flutter codebase.

---

## 1. Why this helper exists

- **Single place** to enforce timeouts, headers, base‑url routing, connectivity checks, and Crashlytics logging.
- **Explicit contracts** (`getOne`, `getList`, `getPaginated`) remove guess‑work and type‑casts.
- **Backend aligned** - Matches your Express.js ResponseUtils structure perfectly.
- **Structured errors** - Field-level validation errors for form handling.

---

## 2. Key types at a glance

| Type                    | Purpose                                                                                           |
| ----------------------- | ------------------------------------------------------------------------------------------------- |
| `ApiHelper`             | Thin facade around Dio + interceptors. Provides the 6 public entry points below.                  |
| `ApiResponse<T>`        | Success / Error wrapper with structured validation errors and metadata.                           |
| `ValidationError`       | Field-specific error for form validation (field, message, code).                                  |
| `ApiPaginatedResult<T>` | Strongly‑typed container with boolean pagination flags (hasNext/hasPrev).                         |
| `PaginationMeta`        | Structured pagination info (page, limit, total, totalPages, hasNext, hasPrev).                    |
| `ItemParser<R>`         | `typedef ItemParser<R> = R Function(Map<String,dynamic> json)` – one raw JSON object → one model. |

---

## 3. Backend Response Structure

Your API responses follow this consistent envelope:

### Success Response

```json
{
  "status": "success",
  "data": {
    /* your actual data */
  },
  "message": "Optional success message",
  "meta": {
    "pagination": {
      /* for paginated responses */
    },
    "requestId": "req_123"
    /* any additional metadata */
  }
}
```

### Error Response

```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email is required",
      "code": "REQUIRED"
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters",
      "code": "MIN_LENGTH"
    }
  ]
}
```

### Paginated Response

```json
{
  "status": "success",
  "data": [
    /* array of items */
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 156,
      "totalPages": 8,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

---

## 4. Public API surface

### 4.1. `getOne<R>()`

Fetch a _single_ object.

```dart
final response = await _apiHelper.getOne<UserRemoteModel>(
  '/profile/me',
  parser: UserRemoteModel.fromJson,
  host: ApiHost.profile,
  // requiresAuth: true is the default
);

if (response.isSuccess) {
  final user = response.data!;          // UserRemoteModel
  final message = response.message;     // Optional success message
} else {
  // Handle errors (see section 5)
}
```

### 4.2. `getList<R>()`

Fetch a _plain array_.

```dart
final response = await _apiHelper.getList<BookRemoteModel>(
  '/books/my-library',
  itemParser: BookRemoteModel.fromJson,
  host: ApiHost.core,
  queryParameters: {'category': 'fiction'},
);

if (response.isSuccess) {
  final List<BookRemoteModel> books = response.data!;
}
```

### 4.3. `getPaginated<R>()`

Fetch a paginated list with metadata.

```dart
final response = await _apiHelper.getPaginated<HighlightRemoteModel>(
  '/books/book_123/highlights',
  itemParser: HighlightRemoteModel.fromJson,
  host: ApiHost.core,
  queryParameters: {'page': 2, 'limit': 20},
);

if (response.isSuccess) {
  final ApiPaginatedResult<HighlightRemoteModel> result = response.data!;

  print('Items: ${result.items.length}');        // 20
  print('Total: ${result.totalItems}');          // 156
  print('Has next: ${result.hasNext}');          // true
  print('Page range: ${result.itemRange}');      // "21-40 of 156"

  // Access pagination metadata
  final pagination = result.pagination;
  print('Current page: ${pagination.page}');     // 2
  print('Total pages: ${pagination.totalPages}'); // 8
}
```

### 4.4. `post/put/delete<T>()`

Create, update, or delete resources.

```dart
// Create a highlight
final response = await _apiHelper.post<HighlightRemoteModel>(
  '/highlights',
  data: {
    'book_id': 'book_123',
    'text': 'Amazing insight from the book',
    'page_number': 42,
  },
  parser: HighlightRemoteModel.fromJson,
  host: ApiHost.core,
);

// Update user profile
final updateResponse = await _apiHelper.put<UserRemoteModel>(
  '/profile/me',
  data: {'name': 'New Name'},
  parser: UserRemoteModel.fromJson,
  host: ApiHost.profile,
);

// Logout (no response body expected)
final logoutResponse = await _apiHelper.post<void>(
  '/auth/logout',
  host: ApiHost.auth,
  // No parser needed for void response
);
```

---

## 5. Error handling patterns

### 5.1. Basic Error Handling

```dart
final response = await _apiHelper.getOne<UserRemoteModel>(...);

if (response.isError) {
  print('Error: ${response.message}');
  print('Status Code: ${response.statusCode}');

  // Handle specific error codes
  switch (response.statusCode) {
    case 401:
      // Unauthorized - redirect to login
      Get.offAllNamed('/login');
      break;
    case 404:
      // Not found
      showSnackbar('User not found');
      break;
    case -1:
      // No internet connection
      showSnackbar('No internet connection');
      break;
    default:
      showSnackbar(response.message ?? 'Unknown error');
  }
}
```

### 5.2. Form Validation Error Handling

```dart
final response = await _apiHelper.post<AuthResponseModel>(
  '/auth/login',
  data: {'email': email, 'password': password},
  parser: AuthResponseModel.fromJson,
  requiresAuth: false, // public endpoint: no Authorization header, no refresh
);

if (response.isError && response.errors != null) {
  // Clear previous errors
  emailError.value = null;
  passwordError.value = null;

  // Handle field-specific errors
  for (final error in response.errors!) {
    switch (error.field) {
      case 'email':
        emailError.value = error.message;
        break;
      case 'password':
        passwordError.value = error.message;
        break;
      case null:
        // General error without specific field
        generalError.value = error.message;
        break;
    }
  }

  // Or use convenience methods
  final emailError = response.getFieldError('email');
  if (emailError != null) {
    print('Email error: ${emailError.message}');
  }

  // Get all errors for a field
  final passwordErrors = response.getFieldErrors('password');

  // Get general errors (no specific field)
  final generalErrors = response.generalErrors;
}
```

### 5.3. Repository Error Handling

```dart
class BookRepositoryImpl implements BookRepository {
  @override
  Future<List<BookEntity>> getUserBooks() async {
    final response = await _remoteDataSource.getUserBooks();

    if (response.isSuccess) {
      final books = response.data!.map((model) => model.toEntity()).toList();
      return books;
    }

    // Throw specific exceptions based on error type
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(response.message ?? 'Unauthorized access');
      case 404:
        throw NotFoundException(response.message ?? 'Books not found');
      case -1:
        throw NoConnectionException(response.message ?? 'No internet connection');
      default:
        throw ServerException(response.message ?? 'Unknown server error');
    }
  }
}
```

### 5.4. Using Repository with Exception Handling

```dart
class BookController extends GetxController {
  final BookRepository _bookRepository;

  final books = <BookEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadBooks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final bookList = await _bookRepository.getUserBooks();
      books.value = bookList;

    } on UnauthorizedException {
      // Redirect to login
      Get.offAllNamed('/login');
      errorMessage.value = 'Please log in to continue';

    } on NoConnectionException {
      // Show offline message
      errorMessage.value = 'No internet connection. Please try again.';

    } on NotFoundException {
      // Handle not found
      errorMessage.value = 'No books found';

    } on ServerException catch (e) {
      // Handle server errors
      errorMessage.value = e.message;

    } catch (e) {
      // Handle unexpected errors
      errorMessage.value = 'An unexpected error occurred';

    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## 6. Writing data models

### 6.1. Basic Model

```dart
class UserRemoteModel {
  final String id;
  final String email;
  final String name;
  final DateTime? lastLoginAt;

  UserRemoteModel({
    required this.id,
    required this.email,
    required this.name,
    this.lastLoginAt,
  });

  factory UserRemoteModel.fromJson(Map<String, dynamic> json) {
    return UserRemoteModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  // Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      lastLoginAt: lastLoginAt,
    );
  }
}
```

### 6.2. Model with Nested Objects

```dart
class BookRemoteModel {
  final String id;
  final String title;
  final String author;
  final BookMetadata metadata;

  factory BookRemoteModel.fromJson(Map<String, dynamic> json) {
    return BookRemoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      metadata: BookMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }
}

class BookMetadata {
  final int pageCount;
  final String isbn;
  final DateTime publishedAt;

  factory BookMetadata.fromJson(Map<String, dynamic> json) {
    return BookMetadata(
      pageCount: json['page_count'] as int,
      isbn: json['isbn'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}
```

**Important Notes:**

- **Do not** unwrap the envelope (`status`, `data`) - the helper handles this automatically
- Focus on parsing the _inner_ data structure only
- Handle null values gracefully with null-aware operators
- Convert to domain entities in your models, not in datasources

---

## 7. Method selection guide

| Scenario                       | Method                    | Example                          |
| ------------------------------ | ------------------------- | -------------------------------- |
| Get single user profile        | `getOne<User>`            | `parser: User.fromJson`          |
| Get list of user's books       | `getList<Book>`           | `itemParser: Book.fromJson`      |
| Get highlights with pagination | `getPaginated<Highlight>` | `itemParser: Highlight.fromJson` |
| Create new highlight           | `post<Highlight>`         | `parser: Highlight.fromJson`     |
| Update user profile            | `put<User>`               | `parser: User.fromJson`          |
| Delete highlight               | `delete<void>`            | No parser needed                 |
| Login/Register                 | `post<AuthResponse>`      | `parser: AuthResponse.fromJson`  |
| Logout                         | `post<void>`              | No parser needed                 |

---

## 8. Advanced features

### 8.1. Custom Headers per Endpoint

```dart
// Register headers for specific endpoints
ApiClient().registerEndpointHeaders('/ai/chat', {
  'X-AI-Model': 'gpt-4',
  'X-Max-Tokens': '1000',
});

// Use in datasource
final response = await _apiHelper.post<ChatResponseModel>(
  '/ai/chat',  // Headers automatically applied
  data: {'message': 'Explain this highlight'},
  parser: ChatResponseModel.fromJson,
);
```

### 8.2. Request Cancellation

```dart
class HighlightController extends GetxController {
  CancelToken? _cancelToken;

  Future<void> searchHighlights(String query) async {
    // Cancel previous request
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final response = await _apiHelper.getList<HighlightRemoteModel>(
      '/highlights/search',
      itemParser: HighlightRemoteModel.fromJson,
      queryParameters: {'q': query},
      cancelToken: _cancelToken,
    );

    if (!_cancelToken!.isCancelled && response.isSuccess) {
      // Handle results
    }
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }
}
```

### 8.3. File Upload with Progress

```dart
Future<ApiResponse<UploadResponseModel>> uploadBookCover(
  String bookId,
  File imageFile,
) async {
  final formData = FormData.fromMap({
    'book_id': bookId,
    'cover': await MultipartFile.fromFile(
      imageFile.path,
      filename: 'cover.jpg',
    ),
  });

  return await _apiHelper.post<UploadResponseModel>(
    '/books/upload-cover',
    data: formData,
    parser: UploadResponseModel.fromJson,
    onSendProgress: (sent, total) {
      final progress = (sent / total * 100).round();
      print('Upload progress: $progress%');
    },
  );
}
```

---

## 9. Connectivity & retry strategy

### 9.1. Automatic Connectivity Check

```dart
// Connectivity is checked automatically by default
final response = await _apiHelper.getOne<UserRemoteModel>(
  '/profile/me',
  parser: UserRemoteModel.fromJson,
  checkConnectivity: true, // Default: true
);

if (response.statusCode == -1) {
  // No internet connection
  showOfflineMessage();
}
```

### 9.2. Manual Retry Logic

```dart
class ApiRetryService {
  static Future<ApiResponse<T>> withRetry<T>(
    Future<ApiResponse<T>> Function() apiCall, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final response = await apiCall();

      if (response.isSuccess || response.statusCode != -1) {
        return response; // Success or non-connectivity error
      }

      if (attempt < maxRetries) {
        await Future.delayed(delay * attempt); // Exponential backoff
      }
    }

    return ApiResponse.error(
      message: 'Failed after $maxRetries attempts',
      statusCode: -1,
    );
  }
}

// Usage in repository
final response = await ApiRetryService.withRetry(() =>
  _apiHelper.getOne<UserRemoteModel>('/profile/me', parser: UserRemoteModel.fromJson)
);
```

---

## 10. Logging conventions

- **DEBUG** for request/response bodies (enabled only in DEV builds)
- **INFO** for high‑level API operations
- **ERROR** for caught exceptions with Crashlytics reporting

### Example in Datasource

```dart
class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  @override
  Future<ApiResponse<List<BookRemoteModel>>> getUserBooks() async {
    Log.info('📚 Fetching user books', name: 'BookDataSource');

    final response = await _apiHelper.getList<BookRemoteModel>(
      '/books/my-library',
      itemParser: BookRemoteModel.fromJson,
    );

    if (response.isSuccess) {
      Log.info('📚 Successfully loaded ${response.data!.length} books', name: 'BookDataSource');
    } else {
      Log.error('📚 Failed to load books: ${response.message}', name: 'BookDataSource');
    }

    return response;
  }
}
```

---

## 11. FAQ

### Q: How do I handle validation errors in forms?

Use the `ValidationError` helpers:

```dart
// Get specific field error
final emailError = response.getFieldError('email');
if (emailError != null) {
  emailController.setError(emailError.message);
}

// Get all errors for a field (multiple validation rules)
final passwordErrors = response.getFieldErrors('password');

// Get general errors (no specific field)
final generalErrors = response.generalErrors;
```

### Q: How do I access pagination metadata?

```dart
final result = response.data!; // ApiPaginatedResult<T>
print('Page ${result.currentPage} of ${result.totalPages}');
print('Showing ${result.itemRange}'); // "1-20 of 156"

if (result.hasNext) {
  // Load next page
}
```

### Q: How do I handle different API hosts?

```dart
// Specify host for each request
await _apiHelper.getOne<UserModel>('/me',
  parser: UserModel.fromJson,
  host: ApiHost.profile, // Different service
);

await _apiHelper.post<ChatResponse>('/chat',
  data: {'message': 'Hello'},
  parser: ChatResponse.fromJson,
  host: ApiHost.ai, // AI service
);
```

### Q: How do I handle file downloads?

```dart
final response = await _apiHelper.get<Uint8List>(
  '/books/book_123/export/pdf',
  parser: (data) => data as Uint8List,
  options: Options(responseType: ResponseType.bytes),
);

if (response.isSuccess) {
  final bytes = response.data!;
  // Save to file
}
```

---

## 12. Custom Exception Definitions

Create these custom exceptions for structured error handling:

```dart
// lib/core/network/exceptions/api_exceptions.dart

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException(this.message);

  @override
  String toString() => 'NoConnectionException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class ValidationException implements Exception {
  final String message;
  final List<ValidationError> errors;

  ValidationException(this.message, this.errors);

  @override
  String toString() => 'ValidationException: $message';
}
```

---

## 13. Contributing

- Keep **datasources** focused on API calls only - no business logic
- Use **repositories** for caching, offline handling, and domain mapping
- Add **unit tests** for datasources - mock the ApiHelper
- Update this documentation when adding new patterns
- Follow the established error handling patterns for consistency

---

## 14. Best Practices

### ✅ Do

- Always check `response.isSuccess` before accessing `response.data`
- Use specific exception handling for different error types
- Leverage `ValidationError` for form validation
- Map API models to domain entities in your models
- Use appropriate method (`getOne`, `getList`, `getPaginated`) for your use case
- Handle connectivity issues gracefully
- Use try-catch blocks with specific exception types
- Provide meaningful error messages to users

### ❌ Don't

- Access `response.data` without checking success first
- Parse the response envelope manually (helper handles this)
- Put business logic in datasources
- Ignore validation errors - they're there for a reason
- Use generic error handling for all cases
- Forget to handle offline scenarios
- Catch all exceptions without specific handling
- Let exceptions bubble up to UI without proper handling

Your network layer is now perfectly aligned with your backend structure! 🚀
