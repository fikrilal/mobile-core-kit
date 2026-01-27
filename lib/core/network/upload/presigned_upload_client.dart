import 'package:dio/dio.dart';

import 'package:mobile_core_kit/core/network/upload/presigned_upload_request.dart';

abstract interface class PresignedUploadClient {
  /// Uploads raw bytes to an object storage presigned URL.
  ///
  /// Important:
  /// - This should bypass our normal API interceptors (auth/baseUrl/logging).
  /// - Non-2xx responses must be treated as failures.
  Future<void> uploadBytes(
    PresignedUploadRequest request, {
    required List<int> bytes,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  });
}

class PresignedUploadFailure implements Exception {
  PresignedUploadFailure({
    required this.message,
    this.statusCode,
    this.responseBody,
    this.headers,
  });

  final String message;
  final int? statusCode;
  final String? responseBody;
  final Map<String, List<String>>? headers;

  @override
  String toString() =>
      'PresignedUploadFailure(statusCode: $statusCode, message: $message)';
}

