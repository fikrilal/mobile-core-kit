import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/request_id_interceptor.dart';

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

Iterable<MapEntry<String, dynamic>> _getHeaderEntries(
  Map<String, dynamic> headers,
  String name,
) {
  final target = name.toLowerCase();
  return headers.entries.where((e) => e.key.toLowerCase() == target);
}

void main() {
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  test('adds X-Request-Id when missing', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final entries = _getHeaderEntries(
        options.headers.cast<String, dynamic>(),
        RequestIdInterceptor.headerName,
      ).toList();
      expect(entries.length, 1);

      final value = entries.single.value.toString();
      expect(value.trim().isNotEmpty, true);
      expect(uuidV4.hasMatch(value), true);
      return ResponseBody.fromString('', 200);
    });

    dio.interceptors.add(RequestIdInterceptor());
    await dio.get('/any');
  });

  test('does not override existing X-Request-Id (case-insensitive)', () async {
    const existing = 'abc-123';

    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final entries = _getHeaderEntries(
        options.headers.cast<String, dynamic>(),
        RequestIdInterceptor.headerName,
      ).toList();
      expect(entries.length, 1);
      expect(entries.single.value, existing);
      return ResponseBody.fromString('', 200);
    });

    dio.interceptors.add(RequestIdInterceptor());
    await dio.get(
      '/any',
      options: Options(headers: {'x-request-id': existing}),
    );
  });

  test('fills blank X-Request-Id without duplicating header keys', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final entries = _getHeaderEntries(
        options.headers.cast<String, dynamic>(),
        RequestIdInterceptor.headerName,
      ).toList();
      expect(entries.length, 1);

      final value = entries.single.value.toString();
      expect(value.trim().isNotEmpty, true);
      expect(uuidV4.hasMatch(value), true);
      return ResponseBody.fromString('', 200);
    });

    dio.interceptors.add(RequestIdInterceptor());
    await dio.get('/any', options: Options(headers: {'x-request-id': '  '}));
  });
}
