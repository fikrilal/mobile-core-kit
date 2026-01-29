import 'dart:typed_data';

/// Downloads bytes from a presigned URL using a dedicated HTTP client.
///
/// This must not reuse the application's ApiClient instance; presigned URLs can
/// contain temporary credentials and must not be logged or modified by auth /
/// baseUrl interceptors.
abstract interface class PresignedDownloadClient {
  Future<Uint8List> downloadBytes(Uri uri);
}

class PresignedDownloadFailure implements Exception {
  const PresignedDownloadFailure({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'PresignedDownloadFailure(statusCode=$statusCode, message=$message)';
}

