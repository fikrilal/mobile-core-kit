import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_paginated_result.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

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

void main() {
  setUpAll(() {
    registerFallbackValue(NetworkStatus.online);
  });

  test('preserves meta for {data, meta} success envelope', () async {
    final connectivity = _MockConnectivityService();
    when(() => connectivity.isConnected).thenReturn(true);
    when(() => connectivity.currentStatus).thenReturn(NetworkStatus.online);
    when(() => connectivity.networkStatusStream)
        .thenAnswer((_) => const Stream.empty());

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      expect(options.path, '/v1/test');
      return ResponseBody.fromString(
        jsonEncode({
          'data': {'foo': 'bar'},
          'meta': {'nextCursor': 'c1', 'limit': 10},
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'x-request-id': ['rid-1'],
        },
      );
    });

    final api = ApiHelper(dio, connectivity: connectivity);
    final response = await api.getOne<Map<String, dynamic>>(
      '/v1/test',
      host: ApiHost.core,
      requiresAuth: false,
      parser: (json) => json,
    );

    expect(response.isSuccess, true);
    expect(response.data, {'foo': 'bar'});
    expect(response.meta, {'nextCursor': 'c1', 'limit': 10});
    expect(response.traceId, 'rid-1');
  });

  test('maps cursor pagination fields from meta', () async {
    final connectivity = _MockConnectivityService();
    when(() => connectivity.isConnected).thenReturn(true);
    when(() => connectivity.currentStatus).thenReturn(NetworkStatus.online);
    when(() => connectivity.networkStatusStream)
        .thenAnswer((_) => const Stream.empty());

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      expect(options.path, '/v1/list');
      return ResponseBody.fromString(
        jsonEncode({
          'data': [
            {'id': 1},
          ],
          'meta': {'nextCursor': 'c2', 'limit': 25},
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'x-request-id': ['rid-2'],
        },
      );
    });

    final api = ApiHelper(dio, connectivity: connectivity);
    final response = await api.getPaginated<int>(
      '/v1/list',
      host: ApiHost.core,
      requiresAuth: false,
      itemParser: (json) => json['id'] as int,
    );

    expect(response.isSuccess, true);
    final ApiPaginatedResult<int> result = response.data!;
    expect(result.items, [1]);
    expect(result.nextCursor, 'c2');
    expect(result.limit, 25);
    expect(result.additionalMeta, null);
    expect(response.traceId, 'rid-2');
  });

  test('ApiFailure uses X-Request-Id header as traceId when absent in body', () {
    final requestOptions = RequestOptions(path: '/v1/whatever');
    final dioResponse = Response(
      requestOptions: requestOptions,
      statusCode: 401,
      data: {'title': 'Unauthorized', 'code': 'UNAUTHORIZED'},
      headers: Headers.fromMap({'x-request-id': ['rid-err']}),
    );

    final exception = DioException(
      requestOptions: requestOptions,
      response: dioResponse,
      type: DioExceptionType.badResponse,
    );

    final failure = ApiFailure.fromDioException(exception);
    expect(failure.code, 'UNAUTHORIZED');
    expect(failure.traceId, 'rid-err');
    expect(failure.message, 'Unauthorized');
  });
}

