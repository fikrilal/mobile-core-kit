import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/connectivity/network_status.dart';

class _FakeConnectivityService implements ConnectivityService {
  _FakeConnectivityService({required this.isConnected});

  @override
  final bool isConnected;

  @override
  NetworkStatus get currentStatus =>
      isConnected ? NetworkStatus.online : NetworkStatus.offline;

  @override
  Stream<NetworkStatus> get networkStatusStream =>
      Stream<NetworkStatus>.empty();

  @override
  Future<void> checkConnectivity() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}
}

void main() {
  group('ApiHelper error handling', () {
    test(
      'does not treat non-envelope {status: 401} payload as envelope',
      () async {
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{
                      'status': 401, // int, not our envelope string
                      'foo': 'bar',
                    },
                  ),
                );
              },
            ),
          );

        final api = ApiHelper(
          dio,
          connectivity: _FakeConnectivityService(isConnected: true),
        );

        final resp = await api.getOne<Map<String, dynamic>>(
          '/anything',
          parser: (json) => json,
          checkConnectivity: false,
        );

        expect(resp.isSuccess, true);
        expect(resp.data, isNotNull);
        expect(resp.data!['status'], 401);
        expect(resp.data!['foo'], 'bar');
      },
    );

    test(
      'preserves RFC7807 code/traceId when throwOnError=false and converts to Either',
      () async {
        const traceId = 'trace-456';

        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response<dynamic>(
                      requestOptions: options,
                      statusCode: 429,
                      data: <String, dynamic>{
                        'type': 'about:blank',
                        'title': 'Too Many Requests',
                        'status': 429,
                        'detail':
                            'Rate limit exceeded. Please try again later.',
                        'code': 'RATE_LIMITED',
                        'traceId': traceId,
                      },
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
              },
            ),
          );

        final api = ApiHelper(
          dio,
          connectivity: _FakeConnectivityService(isConnected: true),
        );

        final resp = await api.getOne<Map<String, dynamic>>(
          '/anything',
          parser: (json) => json,
          throwOnError: false,
          checkConnectivity: false,
        );

        expect(resp.isError, true);
        expect(resp.code, 'RATE_LIMITED');
        expect(resp.traceId, traceId);
        expect(resp.message, 'Too Many Requests');

        final Either<ApiFailure, Map<String, dynamic>> either = resp
            .toEitherWithFallback('fallback');
        final failure = either.match(
          (l) => l,
          (_) => throw StateError('Expected left'),
        );

        expect(failure.code, 'RATE_LIMITED');
        expect(failure.traceId, traceId);
      },
    );

    test(
      'throws ApiFailure for RFC7807 errors when throwOnError=true',
      () async {
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response<dynamic>(
                      requestOptions: options,
                      statusCode: 422,
                      data: <String, dynamic>{
                        'type': 'about:blank',
                        'title': 'Validation failed',
                        'status': 422,
                        'code': 'VALIDATION_FAILED',
                        'traceId': 'trace-789',
                      },
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
              },
            ),
          );

        final api = ApiHelper(
          dio,
          connectivity: _FakeConnectivityService(isConnected: true),
        );

        await expectLater(
          api.getOne<Map<String, dynamic>>(
            '/anything',
            parser: (json) => json,
            checkConnectivity: false,
            throwOnError: true,
          ),
          throwsA(
            isA<ApiFailure>()
                .having((f) => f.code, 'code', 'VALIDATION_FAILED')
                .having((f) => f.traceId, 'traceId', 'trace-789'),
          ),
        );
      },
    );
  });
}
