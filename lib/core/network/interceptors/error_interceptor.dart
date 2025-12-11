import 'package:dio/dio.dart';

import '../../utilities/log_utils.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.error('ErrorInterceptor: ${err.toString()}');

    // Get error information
    final int? statusCode = err.response?.statusCode;
    final dynamic errorData = err.response?.data;

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

    if (errorData is Map && errorData.containsKey('message')) {
      message = errorData['message'];
    }

    Log.error('Unauthorized: $message');

    // Note: Auth token refresh is handled in AuthInterceptor
  }

  void _handleForbiddenError(DioException err, dynamic errorData) {
    // Access forbidden
    String message = 'Access forbidden';

    if (errorData is Map && errorData.containsKey('message')) {
      message = errorData['message'];
    }

    Log.error('Forbidden: $message');
  }

  void _handleNotFoundError(DioException err, dynamic errorData) {
    // Resource not found
    String message = 'Resource not found';

    if (errorData is Map && errorData.containsKey('message')) {
      message = errorData['message'];
    }

    Log.error('Not Found: $message');
  }

  void _handleServerError(DioException err, dynamic errorData) {
    // Server errors
    String message = 'Server error';

    if (errorData is Map && errorData.containsKey('message')) {
      message = errorData['message'];
    }

    Log.error('Server Error: $message');
  }
}
