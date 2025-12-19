import 'package:dio/dio.dart';

import '../../utilities/log_utils.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.error('ErrorInterceptor: ${err.toString()}');

    // Get error information
    final int? statusCode = err.response?.statusCode;
    final dynamic errorData = err.response?.data;
    final resolvedMessage = _resolveMessage(errorData) ?? err.message ?? '';
    final traceId = _resolveString(errorData, 'traceId');
    if (resolvedMessage.isNotEmpty) {
      Log.error(
        'HTTP $statusCode error: $resolvedMessage${traceId == null ? '' : ' (traceId=$traceId)'}',
      );
    }

    // Handle specific error cases
    switch (statusCode) {
      case 400:
        _handleBadRequestError(err, errorData);
        break;
      case 401:
        _handleUnauthorizedError(err, errorData);
        break;
      case 403:
        _handleForbiddenError(err, errorData);
        break;
      case 404:
        _handleNotFoundError(err, errorData);
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        _handleServerError(err, errorData);
        break;
    }

    handler.next(err);
  }

  void _handleBadRequestError(DioException err, dynamic errorData) {
    // Handle validation errors, etc.
    String message = 'Bad request';

    if (errorData is Map && errorData.containsKey('message')) {
      message = errorData['message'];
    }

    Log.error('Bad Request: $message');
  }

  void _handleUnauthorizedError(DioException err, dynamic errorData) {
    // Token expired, invalid credentials, etc.
    String message = 'Unauthorized';

    message = _resolveMessage(errorData) ?? message;

    Log.error('Unauthorized: $message');

    // Note: Auth token refresh is handled in AuthInterceptor
  }

  void _handleForbiddenError(DioException err, dynamic errorData) {
    // Access forbidden
    String message = 'Access forbidden';

    message = _resolveMessage(errorData) ?? message;

    Log.error('Forbidden: $message');
  }

  void _handleNotFoundError(DioException err, dynamic errorData) {
    // Resource not found
    String message = 'Resource not found';

    message = _resolveMessage(errorData) ?? message;

    Log.error('Not Found: $message');
  }

  void _handleServerError(DioException err, dynamic errorData) {
    // Server errors
    String message = 'Server error';

    message = _resolveMessage(errorData) ?? message;

    Log.error('Server Error: $message');
  }

  String? _resolveMessage(dynamic errorData) {
    if (errorData is! Map) return null;
    final title = _resolveString(errorData, 'title');
    if (title != null) return title;
    final detail = _resolveString(errorData, 'detail');
    if (detail != null) return detail;
    final message = _resolveString(errorData, 'message');
    if (message != null) return message;
    final errorMessage = _resolveString(errorData, 'error_message');
    if (errorMessage != null) return errorMessage;
    return null;
  }

  String? _resolveString(dynamic errorData, String key) {
    if (errorData is! Map) return null;
    final value = errorData[key];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }
}
