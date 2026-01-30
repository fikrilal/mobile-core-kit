import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  static const String _acceptHeader = 'Accept';
  static const String _contentTypeHeader = 'Content-Type';
  static const String _defaultAccept = 'application/json';

  final Map<String, Map<String, String>> _endpointSpecificHeaders = {};

  // Register endpoint-specific headers
  void registerEndpointHeaders(String endpoint, Map<String, String> headers) {
    _endpointSpecificHeaders[endpoint] = headers;
  }

  // Clear endpoint-specific headers
  void clearEndpointHeaders(String endpoint) {
    _endpointSpecificHeaders.remove(endpoint);
  }

  // Clear all endpoint-specific headers
  void clearAllEndpointHeaders() {
    _endpointSpecificHeaders.clear();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Default Accept header, but allow callers to override.
    options.headers.putIfAbsent(_acceptHeader, () => _defaultAccept);

    // Check if we have specific headers for this endpoint
    for (final entry in _endpointSpecificHeaders.entries) {
      if (options.path.contains(entry.key)) {
        options.headers.addAll(entry.value);
        break;
      }
    }

    // Template note:
    // Some backends/frameworks validate the request body based on `Content-Type`.
    // Fastify, for example, returns 400 when `Content-Type: application/json`
    // is present but the body is empty (FST_ERR_CTP_INVALID_JSON_BODY).
    //
    // For bodyless POST/PUT/PATCH endpoints (e.g. `/auth/email/verification/resend`), we
    // omit the header entirely to avoid server-side "empty JSON body" errors.
    //
    // If your backend *requires* `Content-Type` even for empty bodies, remove
    // this block or send an explicit empty JSON object `{}` from the call site.
    if (options.data == null) {
      _removeHeaderCaseInsensitive(options.headers, _contentTypeHeader);
      options.contentType = null;
    }

    handler.next(options);
  }

  void _removeHeaderCaseInsensitive(Map<String, dynamic> headers, String name) {
    final toRemove = headers.keys
        .where((k) => k.toString().toLowerCase() == name.toLowerCase())
        .toList(growable: false);
    for (final key in toRemove) {
      headers.remove(key);
    }
  }
}
