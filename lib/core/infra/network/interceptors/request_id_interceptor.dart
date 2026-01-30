import 'package:dio/dio.dart';
import 'package:mobile_core_kit/core/foundation/utilities/uuid_v4_utils.dart';

abstract interface class RequestIdGenerator {
  String generate();
}

final class UuidV4RequestIdGenerator implements RequestIdGenerator {
  const UuidV4RequestIdGenerator();

  @override
  String generate() => UuidV4Utils.generate();
}

/// Adds a request-scoped correlation ID header to all requests.
///
/// Backend contract:
/// - The backend accepts `X-Request-Id` (case-insensitive).
/// - The value is treated as an opaque string and echoed back as `traceId`
///   in error responses.
///
/// Template note:
/// - This interceptor MUST NOT overwrite an existing `X-Request-Id`, so the same
///   ID is preserved across auth refresh retries (which re-run interceptors).
class RequestIdInterceptor extends Interceptor {
  RequestIdInterceptor({RequestIdGenerator? generator})
    : _generator = generator ?? const UuidV4RequestIdGenerator();

  static const String headerName = 'X-Request-Id';
  final RequestIdGenerator _generator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _ensureRequestId(options.headers);
    handler.next(options);
  }

  void _ensureRequestId(Map<String, dynamic> headers) {
    final existingKey = _findHeaderKey(headers, headerName);
    if (existingKey == null) {
      headers[headerName] = _generator.generate();
      return;
    }

    final value = headers[existingKey];
    if (_isNonEmpty(value)) {
      return;
    }

    headers[existingKey] = _generator.generate();
  }

  String? _findHeaderKey(Map<String, dynamic> headers, String name) {
    final target = name.toLowerCase();
    for (final key in headers.keys) {
      if (key.toLowerCase() == target) {
        return key;
      }
    }
    return null;
  }

  bool _isNonEmpty(dynamic value) {
    if (value == null) return false;
    final str = value is String ? value : value.toString();
    return str.trim().isNotEmpty;
  }
}
