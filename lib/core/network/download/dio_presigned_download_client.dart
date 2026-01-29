import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:mobile_core_kit/core/network/download/presigned_download_client.dart';

/// Executes presigned download requests using a dedicated Dio client with no
/// interceptors.
///
/// This MUST NOT share the application's ApiClient Dio instance; otherwise we
/// risk adding auth/baseUrl/logging headers to object storage requests which can
/// break signatures and leak sensitive presigned URLs in logs.
final class DioPresignedDownloadClient implements PresignedDownloadClient {
  DioPresignedDownloadClient({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  final Dio _dio;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        responseType: ResponseType.bytes,
      ),
    );
  }

  @override
  Future<Uint8List> downloadBytes(Uri uri) async {
    try {
      final response = await _dio.getUri<dynamic>(
        uri,
        options: Options(
          responseType: ResponseType.bytes,

          // Always resolve so we can treat non-2xx as a typed failure without
          // Dio throwing a DioExceptionType.badResponse.
          validateStatus: (_) => true,
        ),
      );

      final statusCode = response.statusCode ?? -1;
      if (statusCode < 200 || statusCode >= 300) {
        throw PresignedDownloadFailure(
          statusCode: statusCode,
          message: 'Presigned download failed (status=$statusCode).',
        );
      }

      final data = response.data;
      if (data is Uint8List) return data;
      if (data is List<int>) return Uint8List.fromList(data);

      throw PresignedDownloadFailure(
        statusCode: statusCode,
        message: 'Presigned download returned invalid bytes.',
      );
    } on DioException catch (e) {
      // Network/timeouts are surfaced as DioException.
      // Map them to a stable failure type that higher layers can interpret.
      final statusCode =
          e.response?.statusCode ?? _statusCodeForDioException(e);
      throw PresignedDownloadFailure(
        statusCode: statusCode,
        message: e.message ?? 'Presigned download failed.',
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
