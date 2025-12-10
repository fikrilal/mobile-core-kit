import 'no_data.dart';

class ValidationError {
  final String? field;
  final String message;
  final String? code;

  const ValidationError({this.field, required this.message, this.code});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'],
      message: json['message'] ?? 'Unknown error',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (field != null) 'field': field,
      'message': message,
      if (code != null) 'code': code,
    };
  }

  @override
  String toString() =>
      'ValidationError(field: $field, message: $message, code: $code)';
}

class ApiResponse<T> {
  final String status; // "success" | "error"
  final T? data;
  final String? message;
  final Map<String, dynamic>? meta;
  final List<ValidationError>? errors;
  final int? statusCode; // HTTP status code for client-side tracking

  ApiResponse._({
    required this.status,
    this.data,
    this.message,
    this.meta,
    this.errors,
    this.statusCode,
  });

  // Factory constructors
  factory ApiResponse.success({
    required T data,
    String? message,
    Map<String, dynamic>? meta,
    int? statusCode,
  }) => ApiResponse._(
    status: 'success',
    data: data,
    message: message,
    meta: meta,
    statusCode: statusCode,
  );

  factory ApiResponse.error({
    String? message,
    List<ValidationError>? errors,
    Map<String, dynamic>? meta,
    int? statusCode,
  }) => ApiResponse._(
    status: 'error',
    message: message ?? 'An unexpected error occurred',
    errors: errors,
    meta: meta,
    statusCode: statusCode,
  );

  factory ApiResponse.loading() => ApiResponse._(status: 'loading');

  // Factory constructor from JSON (matching backend structure)
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
    int? statusCode,
  }) {
    final status = json['status'] as String;

    if (status == 'success') {
      final rawData = json['data'];
      if (rawData == null) {
        // Allow success without data only for ApiNoData responses (e.g., logout)
        if (T == ApiNoData) {
          return ApiResponse.success(
            data: const ApiNoData() as T,
            message: json['message'],
            meta: json['meta'] as Map<String, dynamic>?,
            statusCode: statusCode,
          );
        }
        return ApiResponse.error(
          message: 'No data received in successful response',
          statusCode: statusCode,
        );
      }

      final parsedData = dataParser != null
          ? dataParser(rawData)
          : rawData as T?;

      if (parsedData == null) {
        return ApiResponse.error(
          message: 'Failed to parse response data',
          statusCode: statusCode,
        );
      }

      return ApiResponse.success(
        data: parsedData as T,
        message: json['message'],
        meta: json['meta'] as Map<String, dynamic>?,
        statusCode: statusCode,
      );
    } else {
      // Parse validation errors if present
      List<ValidationError>? validationErrors;
      if (json['errors'] != null) {
        validationErrors = (json['errors'] as List)
            .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.error(
        message: json['message'],
        errors: validationErrors,
        meta: json['meta'] as Map<String, dynamic>?,
        statusCode: statusCode,
      );
    }
  }

  // Convenience getters
  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
  bool get isLoading => status == 'loading';

  // Get first validation error for a specific field
  ValidationError? getFieldError(String field) {
    return errors?.firstWhere(
      (error) => error.field == field,
      orElse: () => ValidationError(message: ''),
    );
  }

  // Get all validation errors for a specific field
  List<ValidationError> getFieldErrors(String field) {
    return errors?.where((error) => error.field == field).toList() ?? [];
  }

  // Get general errors (without specific field)
  List<ValidationError> get generalErrors {
    return errors?.where((error) => error.field == null).toList() ?? [];
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, data: $data, message: $message, '
        'meta: $meta, errors: $errors, statusCode: $statusCode)';
  }
}
