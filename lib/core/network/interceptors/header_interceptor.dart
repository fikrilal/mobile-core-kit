import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  final Map<String, String> _defaultHeaders = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(_defaultHeaders);

    // Check if we have specific headers for this endpoint
    for (final entry in _endpointSpecificHeaders.entries) {
      if (options.path.contains(entry.key)) {
        options.headers.addAll(entry.value);
        break;
      }
    }

    handler.next(options);
  }
}
