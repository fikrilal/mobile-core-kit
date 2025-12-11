import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../utilities/log_utils.dart';
import '../logging/net_log_mode.dart';
import '../logging/network_log_config.dart';
import '../logging/redactor.dart';

/// Enhanced network logging interceptor with configurable verbosity levels.
///
/// Supports multiple logging modes:
/// - [NetLogMode.off]: No logging
/// - [NetLogMode.summary]: One-line request/response summary
/// - [NetLogMode.smallBodies]: Summary + body for small/slow/error responses
/// - [NetLogMode.full]: Full headers and bodies
///
/// Features:
/// - Correlation IDs for request-response pairing
/// - Duration tracking and slow request detection
/// - Response size estimation and formatting
/// - Automatic body truncation for large payloads
/// - Sensitive data redaction (headers and body fields)
class LoggingInterceptor extends Interceptor {
  static const _extraStartKey = '__netlog_start';
  static const _extraCorrKey = '__netlog_corr';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cfg = NetworkLogConfig.instance;
    options.extra[_extraStartKey] = DateTime.now();
    options.extra[_extraCorrKey] = _newCorrelationId();

    if (cfg.mode != NetLogMode.off) {
      final corrId = options.extra[_extraCorrKey];
      final uri = options.uri; // baseUrl + path + query
      _log('REQUEST ${options.method.toUpperCase()} $uri [corrId=$corrId]');

      if (cfg.mode == NetLogMode.full) {
        // Request headers
        final hdrs = cfg.redact
            ? Redactor.redactHeaders(Map<String, dynamic>.from(options.headers))
            : Map<String, dynamic>.from(options.headers);
        _log('REQ HEADERS:\n${_prettyHeaders(hdrs)}');

        // Request body
        final data = options.data;
        if (data != null) {
          if (data is FormData) {
            final fields = {
              'fields': {for (final f in data.fields) f.key: f.value},
              'files': data.files
                  .map(
                    (e) => {
                      'key': e.key,
                      'filename': e.value.filename,
                      'contentType': e.value.contentType.toString(),
                      'length': e.value.length,
                    },
                  )
                  .toList(),
            };
            _log('REQ BODY:\n${_prettyJson(_safeJson(fields))}');
          } else {
            final redacted = cfg.redact ? _redactBody(data) : data;
            final encoded = _safeJson(redacted);
            final truncated = _truncateByBytes(encoded, cfg.bodyLimitBytes);
            _log('REQ BODY:\n${_prettyJson(truncated)}');
          }
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final cfg = NetworkLogConfig.instance;
    if (cfg.mode == NetLogMode.off) {
      handler.next(response);
      return;
    }

    final start = response.requestOptions.extra[_extraStartKey] as DateTime?;
    final corrId = response.requestOptions.extra[_extraCorrKey];
    final durationMs = start == null
        ? null
        : DateTime.now().difference(start).inMilliseconds;
    final status = response.statusCode ?? 0;
    final sizeBytes = _estimateSizeBytes(response.data);

    final isSlow = durationMs != null && durationMs > cfg.slowMs;
    final isError = status >= 400;
    final isSmall = sizeBytes <= cfg.bodyLimitBytes;

    final tags = <String>[
      response.requestOptions.method.toUpperCase(),
      if (isSlow) 'SLOW',
      if (isError) 'ERROR',
      if (isSmall && response.data != null) 'SMALL',
    ];

    final summary =
        '${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path} '
        '→ $status in ${durationMs ?? '-'} ms (${_fmtSize(sizeBytes)}) '
        '[${tags.join('][')}] [corrId=$corrId]';
    _log(summary);

    // Body logging based on mode
    if (cfg.mode == NetLogMode.summary || cfg.mode == NetLogMode.off) {
      handler.next(response);
      return;
    }

    if (cfg.mode == NetLogMode.full) {
      // Response headers
      final hdrs = cfg.redact
          ? Redactor.redactHeaders(
              Map<String, dynamic>.from(response.headers.map),
            )
          : Map<String, dynamic>.from(response.headers.map);
      _log('RESP HEADERS:\n${_prettyHeaders(hdrs)}');
    }

    if (response.data != null) {
      final redacted = cfg.redact ? _redactBody(response.data) : response.data;
      final encoded = _safeJson(redacted);
      final truncated = _truncateByBytes(encoded, cfg.bodyLimitBytes);

      if (cfg.mode == NetLogMode.smallBodies) {
        if (isError || isSlow || isSmall) {
          _log('BODY:\n${_prettyJson(truncated)}');
        }
      } else if (cfg.mode == NetLogMode.full) {
        _log('BODY:\n${_prettyJson(truncated)}');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final cfg = NetworkLogConfig.instance;
    if (cfg.mode == NetLogMode.off) {
      handler.next(err);
      return;
    }

    final start = err.requestOptions.extra[_extraStartKey] as DateTime?;
    final corrId = err.requestOptions.extra[_extraCorrKey];
    final durationMs = start == null
        ? null
        : DateTime.now().difference(start).inMilliseconds;
    final status = err.response?.statusCode ?? 0;
    final sizeBytes = _estimateSizeBytes(err.response?.data);

    final isSlow = durationMs != null && durationMs > cfg.slowMs;
    final isSmall = sizeBytes <= cfg.bodyLimitBytes;

    final tags = <String>[
      err.requestOptions.method.toUpperCase(),
      'ERROR',
      if (isSlow) 'SLOW',
      if (isSmall && err.response?.data != null) 'SMALL',
    ];

    final summary =
        '${err.requestOptions.method.toUpperCase()} ${err.requestOptions.path} '
        '→ $status in ${durationMs ?? '-'} ms (${_fmtSize(sizeBytes)}) '
        '[${tags.join('][')}] [corrId=$corrId]\n'
        'MESSAGE: ${err.message}';
    _log(summary, isError: true);

    if (cfg.mode == NetLogMode.full) {
      // Error response headers if available
      final respHeaders =
          err.response?.headers.map ?? const <String, List<String>>{};
      if (respHeaders.isNotEmpty) {
        final hdrs = cfg.redact
            ? Redactor.redactHeaders(Map<String, dynamic>.from(respHeaders))
            : Map<String, dynamic>.from(respHeaders);
        _log('RESP HEADERS:\n${_prettyHeaders(hdrs)}');
      }

      // Log request headers/body for failed calls
      final reqHdrs = cfg.redact
          ? Redactor.redactHeaders(
              Map<String, dynamic>.from(err.requestOptions.headers),
            )
          : Map<String, dynamic>.from(err.requestOptions.headers);
      _log('REQ HEADERS:\n${_prettyHeaders(reqHdrs)}');

      final data = err.requestOptions.data;
      if (data != null) {
        if (data is FormData) {
          final fields = {
            'fields': {for (final f in data.fields) f.key: f.value},
            'files': data.files
                .map(
                  (e) => {
                    'key': e.key,
                    'filename': e.value.filename,
                    'contentType': e.value.contentType.toString(),
                    'length': e.value.length,
                  },
                )
                .toList(),
          };
          _log('REQ BODY:\n${_prettyJson(_safeJson(fields))}');
        } else {
          final redacted = cfg.redact ? _redactBody(data) : data;
          final encoded = _safeJson(redacted);
          final truncated = _truncateByBytes(encoded, cfg.bodyLimitBytes);
          _log('REQ BODY:\n${_prettyJson(truncated)}');
        }
      }
    }

    if (cfg.mode != NetLogMode.off && err.response?.data != null) {
      final redacted = cfg.redact
          ? _redactBody(err.response!.data)
          : err.response!.data;
      final encoded = _safeJson(redacted);
      final truncated = _truncateByBytes(encoded, cfg.bodyLimitBytes);
      if (cfg.mode == NetLogMode.full ||
          (cfg.mode == NetLogMode.smallBodies && isSmall)) {
        _log('BODY:\n${_prettyJson(truncated)}');
      }
    }

    handler.next(err);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  void _log(String message, {bool isError = false}) {
    if (isError) {
      Log.error(message, null, null, false, 'network');
    } else {
      Log.debug(message, name: 'network');
    }
  }

  static String _newCorrelationId() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rnd = Random().nextInt(1 << 20).toRadixString(36);
    return '${now}_$rnd';
  }

  static int _estimateSizeBytes(dynamic data) {
    if (data == null) return 0;
    try {
      if (data is String) return utf8.encode(data).length;
      if (data is List || data is Map) {
        return utf8.encode(jsonEncode(data)).length;
      }
      return utf8.encode(data.toString()).length;
    } catch (_) {
      return data.toString().length;
    }
  }

  static String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  static dynamic _redactBody(dynamic body) {
    try {
      if (body is Map<String, dynamic>) return Redactor.redactMap(body);
      if (body is List) {
        return body
            .map((e) => e is Map<String, dynamic> ? Redactor.redactMap(e) : e)
            .toList();
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  static String _safeJson(dynamic body) {
    try {
      if (body is String) return body;
      return jsonEncode(body);
    } catch (_) {
      return body?.toString() ?? '';
    }
  }

  static String _prettyJson(String s) {
    try {
      final decoded = jsonDecode(s);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return s;
    }
  }

  static String _prettyHeaders(Map<String, dynamic> headers) {
    return headers.entries
        .map(
          (e) =>
              '  - ${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}',
        )
        .join('\n');
  }

  static String _truncateByBytes(String s, int maxBytes) {
    final bytes = utf8.encode(s);
    if (bytes.length <= maxBytes) return s;
    final truncated = bytes.sublist(0, maxBytes);
    return '${utf8.decode(truncated, allowMalformed: true)}… (truncated)';
  }
}
