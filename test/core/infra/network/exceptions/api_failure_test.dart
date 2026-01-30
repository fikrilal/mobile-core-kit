import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';

void main() {
  group('ApiFailure.fromDioException', () {
    test('parses RFC7807 code + traceId and prefers title for message', () {
      final requestOptions = RequestOptions(path: '/v1/auth/password/login');
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 429,
        data: <String, dynamic>{
          'type': 'about:blank',
          'title': 'Too Many Requests',
          'status': 429,
          'detail': 'Rate limit exceeded. Please try again later.',
          'code': 'RATE_LIMITED',
          'traceId': 'trace-123',
        },
      );

      final dioException = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ApiFailure.fromDioException(dioException);

      expect(failure.statusCode, 429);
      expect(failure.code, 'RATE_LIMITED');
      expect(failure.traceId, 'trace-123');
      expect(failure.message, 'Too Many Requests');
    });
  });
}
