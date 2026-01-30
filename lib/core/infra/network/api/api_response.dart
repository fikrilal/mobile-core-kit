import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';

class ApiResponse<T> {
  final String status; // "success" | "error"
  final T? data;
  final String? message;
  final String? code;
  final String? traceId;
  final Map<String, dynamic>? meta;
  final List<ValidationError>? errors;
  final int? statusCode; // HTTP status code for client-side tracking

  ApiResponse._({
    required this.status,
    this.data,
    this.message,
    this.code,
    this.traceId,
    this.meta,
    this.errors,
    this.statusCode,
  });

  // Factory constructors
  factory ApiResponse.success({
    required T data,
    String? message,
    String? code,
    String? traceId,
    Map<String, dynamic>? meta,
    int? statusCode,
  }) => ApiResponse._(
    status: 'success',
    data: data,
    message: message,
    code: code,
    traceId: traceId,
    meta: meta,
    statusCode: statusCode,
  );

  factory ApiResponse.error({
    String? message,
    String? code,
    String? traceId,
    List<ValidationError>? errors,
    Map<String, dynamic>? meta,
    int? statusCode,
  }) => ApiResponse._(
    status: 'error',
    message: message ?? 'An unexpected error occurred',
    code: code,
    traceId: traceId,
    errors: errors,
    meta: meta,
    statusCode: statusCode,
  );

  // Convenience getters
  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  // Get first validation error for a specific field
  ValidationError? getFieldError(String field) {
    final list = errors;
    if (list == null) return null;
    for (final error in list) {
      if (error.field == field) return error;
    }
    return null;
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
        'code: $code, traceId: $traceId, meta: $meta, errors: $errors, statusCode: $statusCode)';
  }
}
