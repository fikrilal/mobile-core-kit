import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkException({required this.message, this.statusCode, this.data});

  factory NetworkException.fromDioError(DioException error) {
    String message = 'Unknown error occurred';
    int? statusCode = error.response?.statusCode;
    dynamic data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        // Try to extract error message from response if possible
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else {
          message =
              'Bad response: ${error.response?.statusMessage ?? "Unknown"}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.unknown:
        if (error.message != null) {
          message = error.message!;
        }
        break;
    }

    return NetworkException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => 'NetworkException: $message (Status Code: $statusCode)';
}
