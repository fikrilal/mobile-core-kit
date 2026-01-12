import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/interceptors/header_interceptor.dart';

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
  test('omits Content-Type when request body is null', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final headerKeys = options.headers.keys
          .map((e) => e.toString().toLowerCase())
          .toList();
      expect(headerKeys.contains('content-type'), false);
      expect(options.headers['Accept'], 'application/json');
      return ResponseBody.fromString('', 204);
    });

    dio.interceptors.add(HeaderInterceptor());

    await dio.post('/auth/email/verification/resend');
  });

  test('keeps JSON defaults for requests with a body', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final headerKeys = options.headers.keys
          .map((e) => e.toString().toLowerCase())
          .toList();
      expect(headerKeys.contains('content-type'), true);
      expect(options.headers['Accept'], 'application/json');
      final contentTypeEntry = options.headers.entries.firstWhere(
        (e) => e.key.toString().toLowerCase() == 'content-type',
      );
      expect(contentTypeEntry.value.toString(), contains('application/json'));
      return ResponseBody.fromString('', 200);
    });

    dio.interceptors.add(HeaderInterceptor());

    await dio.post('/any', data: {'ok': true});
  });
}
