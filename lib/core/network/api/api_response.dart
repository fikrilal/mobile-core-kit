import 'no_data.dart';
import '../../validation/validation_error.dart';

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

  factory ApiResponse.loading() => ApiResponse._(status: 'loading');

  // Factory constructor from JSON (matching backend structure)
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
    int? statusCode,
  }) {
    final status = json['status'] as String;
    final code = json['code'] as String?;
    final traceId = json['traceId'] as String?;

    if (status == 'success') {
      final rawData = json['data'];
      if (rawData == null) {
        // Allow success without data only for ApiNoData responses (e.g., logout)
        if (T == ApiNoData) {
          return ApiResponse.success(
            data: const ApiNoData() as T,
            message: json['message'],
            code: code,
            traceId: traceId,
            meta: json['meta'] as Map<String, dynamic>?,
            statusCode: statusCode,
          );
        }
        return ApiResponse.error(
          message: 'No data received in successful response',
          code: code,
          traceId: traceId,
          statusCode: statusCode,
        );
      }

      final parsedData = dataParser != null
          ? dataParser(rawData)
          : rawData as T?;

      if (parsedData == null) {
        return ApiResponse.error(
          message: 'Failed to parse response data',
          code: code,
          traceId: traceId,
          statusCode: statusCode,
        );
      }

      return ApiResponse.success(
        data: parsedData as T,
        message: json['message'],
        code: code,
        traceId: traceId,
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
        code: code,
        traceId: traceId,
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
