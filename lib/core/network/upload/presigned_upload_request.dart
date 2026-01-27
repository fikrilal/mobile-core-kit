/// A backend-generated presigned upload plan request.
///
/// The client MUST treat the URL and headers as authoritative and opaque:
/// - Do not attach backend auth headers.
/// - Do not inject request correlation headers.
/// - Do not rewrite the base URL.
///
/// Backend returns an absolute URL (e.g., S3/R2 presigned PUT URL) plus a set of
/// required headers (typically `Content-Type`).
enum PresignedUploadMethod { put, post }

extension PresignedUploadMethodX on PresignedUploadMethod {
  String get value => switch (this) {
    PresignedUploadMethod.put => 'PUT',
    PresignedUploadMethod.post => 'POST',
  };
}

final class PresignedUploadRequest {
  factory PresignedUploadRequest({
    required PresignedUploadMethod method,
    required String url,
    Map<String, String> headers = const {},
  }) {
    return PresignedUploadRequest._(
      method: method,
      uri: _parseAbsoluteUri(url),
      headers: Map<String, String>.unmodifiable(headers),
    );
  }

  const PresignedUploadRequest._({
    required this.method,
    required this.uri,
    required this.headers,
  });

  final PresignedUploadMethod method;
  final Uri uri;
  final Map<String, String> headers;

  static Uri _parseAbsoluteUri(String raw) {
    final uri = Uri.parse(raw);
    if (!uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError.value(raw, 'url', 'Must be an absolute URL.');
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      throw ArgumentError.value(raw, 'url', 'Unsupported URL scheme: $scheme');
    }

    return uri;
  }
}

