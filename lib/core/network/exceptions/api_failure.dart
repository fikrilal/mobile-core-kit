import 'package:dio/dio.dart';
import '../api/api_response.dart';

class ApiFailure implements Exception {
  final String message;
  final int? statusCode;
  final List<ValidationError>? validationErrors;

  ApiFailure({required this.message, this.statusCode, this.validationErrors});

  factory ApiFailure.fromApiResponse(ApiResponse<dynamic> response) {
    return ApiFailure(
      message: response.message ?? 'Unknown error',
      statusCode: response.statusCode,
      validationErrors: response.errors,
    );
  }

  factory ApiFailure.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    String message = response?.statusMessage ?? e.message ?? 'Unknown error';

    List<ValidationError>? validationErrors;
    if (data is Map && data['errors'] is List) {
      validationErrors = (data['errors'] as List)
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map &&
        (data['error_message'] != null || data['message'] != null)) {
      message = data['error_message'] ?? data['message'];
    }

    return ApiFailure(
      message: message,
      statusCode: statusCode,
      validationErrors: validationErrors,
    );
  }

  @override
  String toString() => 'ApiFailure(statusCode: $statusCode, message: $message)';
}
