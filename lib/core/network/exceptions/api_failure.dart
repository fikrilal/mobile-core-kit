import 'package:dio/dio.dart';
import '../api/api_response.dart';
import '../../validation/validation_error.dart';

class ApiFailure implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final String? traceId;
  final List<ValidationError>? validationErrors;

  ApiFailure({
    required this.message,
    this.statusCode,
    this.code,
    this.traceId,
    this.validationErrors,
  });

  factory ApiFailure.fromApiResponse(ApiResponse<dynamic> response) {
    return ApiFailure(
      message: response.message ?? 'Unknown error',
      statusCode: response.statusCode,
      code: response.code,
      traceId: response.traceId,
      validationErrors: response.errors,
    );
  }

  factory ApiFailure.fromDioException(DioException e) {
    final response = e.response;
    int? statusCode = response?.statusCode;
    statusCode ??= _statusCodeForDioException(e);
    final data = response?.data;
    String message = response?.statusMessage ?? e.message ?? 'Unknown error';
    String? code;
    String? traceId =
        response?.headers.value('x-request-id') ??
        response?.headers.value('X-Request-Id');

    List<ValidationError>? validationErrors;
    if (data is Map && data['errors'] is List) {
      validationErrors = (data['errors'] as List)
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map) {
      // Support both custom error bodies and RFC7807-style problem details.
      //
      // Example:
      // {
      //   "type": "about:blank",
      //   "title": "Invalid credentials",
      //   "status": 401,
      //   "code": "UNAUTHORIZED",
      //   "traceId": "..."
      // }
      final dynamic rawStatus = data['status'];
      final dynamic rawCode = data['code'];
      final dynamic rawTraceId = data['traceId'];

      if (rawStatus is int && rawStatus > 0) {
        // Prefer server-reported status if present.
        // (Some backends include it even when proxies strip HTTP status text.)
        // Keep HTTP statusCode as-is if rawStatus is absent.
      }
      if (rawCode is String && rawCode.isNotEmpty) code = rawCode;
      if (rawTraceId is String && rawTraceId.isNotEmpty) traceId = rawTraceId;

      final dynamic title = data['title'];
      final dynamic detail = data['detail'];
      final dynamic errorMessage = data['error_message'];
      final dynamic msg = data['message'];

      final resolved = (title is String && title.isNotEmpty)
          ? title
          : (detail is String && detail.isNotEmpty)
          ? detail
          : (errorMessage is String && errorMessage.isNotEmpty)
          ? errorMessage
          : (msg is String && msg.isNotEmpty)
          ? msg
          : null;

      if (resolved != null) {
        message = resolved;
      }
    }

    return ApiFailure(
      message: message,
      statusCode: statusCode,
      code: code,
      traceId: traceId,
      validationErrors: validationErrors,
    );
  }

  static int? _statusCodeForDioException(DioException e) {
    // Negative codes are used for client-side categorization when there is no
    // HTTP response.
    //
    // -1: network/unreachable (offline, DNS, connection refused)
    // -2: timeout with unknown outcome (request may have reached server)
    switch (e.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return -2;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return -1;
      case DioExceptionType.badResponse:
        return e.response?.statusCode;
    }
  }

  @override
  String toString() =>
      'ApiFailure(statusCode: $statusCode, code: $code, traceId: $traceId, message: $message)';
}
