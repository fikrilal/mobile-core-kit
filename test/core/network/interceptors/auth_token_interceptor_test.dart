import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/network/api/api_client.dart';
import 'package:mobile_core_kit/core/network/interceptors/auth_token_interceptor.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';

class _MockSessionManager extends Mock implements SessionManager {}

class _MockApiClient extends Mock implements ApiClient {}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._onFetch);

  final Future<ResponseBody> Function(RequestOptions options) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => _onFetch(options);

  @override
  void close({bool force = false}) {}
}

class _RecordingErrorInterceptor extends Interceptor {
  _RecordingErrorInterceptor(this._onError);
  final void Function(DioException err) _onError;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _onError(err);
    handler.next(err);
  }
}

void main() {
  setUp(() async {
    await locator.reset();
  });

  tearDown(() async {
    await locator.reset();
  });

  test(
    'surfaces retry error when refresh succeeds but retried request fails',
    () async {
      final session = _MockSessionManager();
      when(() => session.refreshTokens()).thenAnswer((_) async => true);
      when(() => session.accessToken).thenReturn('access_new');
      when(() => session.isAccessTokenExpiringSoon).thenReturn(false);

      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      var calls = 0;
      dio.httpClientAdapter = _FakeAdapter((options) async {
        calls += 1;
        final statusCode = calls == 1 ? 401 : 500;
        final body = jsonEncode({
          'message': statusCode == 401 ? 'Unauthorized' : 'Server error',
        });
        return ResponseBody.fromString(
          body,
          statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final apiClient = _MockApiClient();
      when(() => apiClient.dio).thenReturn(dio);

      locator.registerSingleton<SessionManager>(session);
      locator.registerSingleton<ApiClient>(apiClient);

      dio.interceptors.add(AuthTokenInterceptor());

      await expectLater(
        dio.get('/protected'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            500,
          ),
        ),
      );

      verify(() => session.refreshTokens()).called(1);
      expect(calls, 2);
    },
  );

  test('preflight refreshes when access token is expiring soon', () async {
    final session = _MockSessionManager();
    var token = 'access_old';
    when(() => session.accessToken).thenAnswer((_) => token);
    when(() => session.isAccessTokenExpiringSoon).thenReturn(true);
    when(() => session.refreshTokens()).thenAnswer((_) async {
      token = 'access_new';
      return true;
    });

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      expect(options.headers['Authorization'], 'Bearer access_new');
      return ResponseBody.fromString(
        jsonEncode({'ok': true}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);

    locator.registerSingleton<SessionManager>(session);
    locator.registerSingleton<ApiClient>(apiClient);

    dio.interceptors.add(AuthTokenInterceptor());

    final response = await dio.get('/protected');
    expect(response.statusCode, 200);

    verify(() => session.refreshTokens()).called(1);
  });

  test('does not refresh/retry POST on 401 by default', () async {
    final session = _MockSessionManager();
    when(() => session.accessToken).thenReturn('access_old');
    when(() => session.isAccessTokenExpiringSoon).thenReturn(false);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    var calls = 0;
    dio.httpClientAdapter = _FakeAdapter((options) async {
      calls += 1;
      return ResponseBody.fromString(
        jsonEncode({'message': 'Unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);

    locator.registerSingleton<SessionManager>(session);
    locator.registerSingleton<ApiClient>(apiClient);

    dio.interceptors.add(AuthTokenInterceptor());

    await expectLater(
      dio.post('/protected', data: {'x': 1}),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    verifyNever(() => session.refreshTokens());
    expect(calls, 1);
  });

  test('retries POST on 401 when allowAuthRetry is true', () async {
    final session = _MockSessionManager();
    when(() => session.refreshTokens()).thenAnswer((_) async => true);
    when(() => session.accessToken).thenReturn('access_new');
    when(() => session.isAccessTokenExpiringSoon).thenReturn(false);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    var calls = 0;
    dio.httpClientAdapter = _FakeAdapter((options) async {
      calls += 1;
      final statusCode = calls == 1 ? 401 : 200;
      return ResponseBody.fromString(
        jsonEncode({'ok': true}),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);

    locator.registerSingleton<SessionManager>(session);
    locator.registerSingleton<ApiClient>(apiClient);

    dio.interceptors.add(AuthTokenInterceptor());

    final response = await dio.post(
      '/protected',
      data: {'x': 1},
      options: Options(extra: {'allowAuthRetry': true}),
    );

    expect(response.statusCode, 200);
    verify(() => session.refreshTokens()).called(1);
    expect(calls, 2);
  });

  test(
    'does not propagate recovered 401 to later error interceptors',
    () async {
      final session = _MockSessionManager();
      when(() => session.refreshTokens()).thenAnswer((_) async => true);
      when(() => session.accessToken).thenReturn('access_new');
      when(() => session.isAccessTokenExpiringSoon).thenReturn(false);

      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      var calls = 0;
      dio.httpClientAdapter = _FakeAdapter((options) async {
        calls += 1;
        final statusCode = calls == 1 ? 401 : 200;
        return ResponseBody.fromString(
          jsonEncode({'ok': true}),
          statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final apiClient = _MockApiClient();
      when(() => apiClient.dio).thenReturn(dio);

      locator.registerSingleton<SessionManager>(session);
      locator.registerSingleton<ApiClient>(apiClient);

      var errorCalls = 0;
      dio.interceptors.add(AuthTokenInterceptor());
      dio.interceptors.add(
        _RecordingErrorInterceptor((err) {
          if (err.response?.statusCode == 401) errorCalls += 1;
        }),
      );

      final response = await dio.get('/protected');
      expect(response.statusCode, 200);
      expect(errorCalls, 0);
    },
  );
}
