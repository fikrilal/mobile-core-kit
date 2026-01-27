import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:mobile_core_kit/core/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/network/upload/presigned_upload_request.dart';

/// Executes presigned upload requests using a dedicated Dio client with no
/// interceptors.
///
/// This MUST NOT share the application's ApiClient Dio instance; otherwise we
/// risk adding auth/baseUrl/logging headers to object storage requests which can
/// break signature validation and leak sensitive presigned URLs in logs.
final class DioPresignedUploadClient implements PresignedUploadClient {
  DioPresignedUploadClient({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  final Dio _dio;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),

        // We do not expect to parse JSON; presigned failures are often plain text
        // or XML/HTML depending on the provider.
        responseType: ResponseType.plain,
      ),
    );
  }

  @override
  Future<void> uploadBytes(
    PresignedUploadRequest request, {
    required List<int> bytes,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.requestUri<String?>(
        request.uri,
        data: Uint8List.fromList(bytes),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          method: request.method.value,
          headers: Map<String, dynamic>.from(request.headers),

          // Always resolve so we can treat non-2xx as a typed failure without
          // Dio throwing a DioExceptionType.badResponse.
          validateStatus: (_) => true,
          responseType: ResponseType.plain,
        ),
      );

      final statusCode = response.statusCode ?? -1;
      if (statusCode < 200 || statusCode >= 300) {
        throw PresignedUploadFailure(
          statusCode: statusCode,
          message: 'Presigned upload failed (status=$statusCode).',
          responseBody: response.data,
          headers: response.headers.map,
        );
      }
    } on DioException catch (e) {
      // Network/timeouts/cancel are surfaced as DioException.
      // Map them to a stable failure type that higher layers can interpret.
      final statusCode = e.response?.statusCode ?? _statusCodeForDioException(e);
      final responseBody = e.response?.data;
      throw PresignedUploadFailure(
        statusCode: statusCode,
        message: e.message ?? 'Presigned upload failed.',
        responseBody: responseBody is String ? responseBody : null,
        headers: e.response?.headers.map,
      );
    }
  }

  int? _statusCodeForDioException(DioException e) {
    // Negative codes are used for client-side categorization when there is no
    // HTTP response.
    //
    // -1: network/unreachable (offline, DNS, connection refused)
    // -2: timeout with unknown outcome (request may have reached server)
    switch (e.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return -2;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return -1;
      case DioExceptionType.badResponse:
        return e.response?.statusCode;
    }
  }
}
