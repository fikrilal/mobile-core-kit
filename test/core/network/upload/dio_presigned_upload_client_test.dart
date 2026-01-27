import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/upload/dio_presigned_upload_client.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_request.dart';

final class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({required this.statusCode, this.responseBody});

  final int statusCode;
  final String? responseBody;

  RequestOptions? lastOptions;
  Uint8List? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;

    final chunks = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        chunks.addAll(chunk);
      }
    } else {
      final data = options.data;
      if (data is Uint8List) {
        chunks.addAll(data);
      } else if (data is List<int>) {
        chunks.addAll(data);
      }
    }

    if (chunks.isNotEmpty) {
      lastBody = Uint8List.fromList(chunks);
    }

    return ResponseBody.fromString(responseBody ?? '', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

bool _hasHeader(Map<String, dynamic> headers, String name) {
  final target = name.toLowerCase();
  return headers.keys.any((k) => k.toLowerCase() == target);
}

void main() {
  group('DioPresignedUploadClient', () {
    test('uploadBytes sends PUT to absolute URL with headers', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter(statusCode: 200);
      dio.httpClientAdapter = adapter;

      final client = DioPresignedUploadClient(dio: dio);
      final request = PresignedUploadRequest(
        method: PresignedUploadMethod.put,
        url: 'https://example.com/upload',
        headers: const {'Content-Type': 'image/webp'},
      );

      await client.uploadBytes(
        request,
        bytes: const [1, 2, 3],
        // Provide a callback so Dio builds a request stream.
        onSendProgress: (sent, total) {},
      );

      final options = adapter.lastOptions!;
      expect(options.method, 'PUT');
      expect(options.uri.toString(), 'https://example.com/upload');
      expect(_hasHeader(options.headers, 'Content-Type'), isTrue);

      // Safety: presigned uploads must not carry backend-only headers.
      expect(_hasHeader(options.headers, 'Authorization'), isFalse);
      expect(_hasHeader(options.headers, 'X-Request-Id'), isFalse);

      expect(adapter.lastBody, Uint8List.fromList(const [1, 2, 3]));
    });

    test('non-2xx surfaces as PresignedUploadFailure', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter(statusCode: 403, responseBody: 'Forbidden');
      dio.httpClientAdapter = adapter;

      final client = DioPresignedUploadClient(dio: dio);
      final request = PresignedUploadRequest(
        method: PresignedUploadMethod.put,
        url: 'https://example.com/upload',
        headers: const {'Content-Type': 'image/webp'},
      );

      await expectLater(
        () => client.uploadBytes(request, bytes: const [1, 2, 3]),
        throwsA(
          isA<PresignedUploadFailure>().having(
            (e) => e.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    });

    test('PresignedUploadRequest rejects non-absolute URLs', () {
      expect(
        () => PresignedUploadRequest(
          method: PresignedUploadMethod.put,
          url: '/relative',
        ),
        throwsArgumentError,
      );
    });
  });
}
