import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';

class AuthTokenInterceptor extends dio.Interceptor {
  AuthTokenInterceptor({
    required SessionManager Function() sessionManagerProvider,
    required dio.Dio client,
  }) : _sessionManagerProvider = sessionManagerProvider,
       _client = client;

  final SessionManager Function() _sessionManagerProvider;
  final dio.Dio _client;
  Completer<bool>? _refreshCompleter;
  static const String _requiresAuthKey = 'requiresAuth';
  static const String _allowAuthRetryKey = 'allowAuthRetry';
  static const String _retriedKey = 'retried';
  static const String _idempotencyKeyHeader = 'idempotency-key';

  SessionManager? get _sessionOrNull {
    try {
      return _sessionManagerProvider();
    } catch (_) {
      return null;
    }
  }

  bool _requiresAuth(dio.RequestOptions options) {
    final value = options.extra[_requiresAuthKey];
    if (value is bool) return value;
    // Default: requests require auth unless explicitly marked public.
    return true;
  }

  bool _allowAuthRetry(dio.RequestOptions options) {
    final value = options.extra[_allowAuthRetryKey];
    // Explicit opt-out always wins.
    if (value is bool && value == false) return false;

    // Default retry policy (aligned with backend-core-kit contract):
    // - Reads (GET/HEAD) can be retried after refresh.
    // - Writes (POST/PUT/PATCH/DELETE) must have an Idempotency-Key to be retried.
    final method = options.method.toUpperCase();
    if (method == 'GET' || method == 'HEAD') return true;

    return _hasIdempotencyKey(options);
  }

  bool _hasIdempotencyKey(dio.RequestOptions options) {
    for (final entry in options.headers.entries) {
      if (entry.key.toLowerCase() != _idempotencyKeyHeader) continue;
      final value = entry.value;
      if (value == null) return false;
      if (value is String) return value.trim().isNotEmpty;
      return value.toString().trim().isNotEmpty;
    }
    return false;
  }

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    final session = _sessionOrNull;
    if (session == null) return handler.next(options);

    if (_requiresAuth(options)) {
      if (options.extra[_retriedKey] != true &&
          session.isAccessTokenExpiringSoon) {
        try {
          await _refreshOnce();
        } catch (_) {
          // Best-effort preflight refresh; fall back to existing token.
        }
      }

      final token = session.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<bool> _refreshOnce() async {
    final session = _sessionOrNull;
    if (session == null) return false;

    // Ensure single refresh in flight for both preflight and 401 refresh paths.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final ok = await session.refreshTokens();
      if (!(_refreshCompleter!.isCompleted)) {
        _refreshCompleter!.complete(ok);
      }
    } catch (_) {
      if (!(_refreshCompleter!.isCompleted)) {
        _refreshCompleter!.complete(false);
      }
    }

    final result = await _refreshCompleter!.future;
    _refreshCompleter = null;
    return result;
  }

  @override
  void onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode ?? -1;

    if (statusCode == 401 &&
        _requiresAuth(err.requestOptions) &&
        err.requestOptions.extra[_retriedKey] != true &&
        _allowAuthRetry(err.requestOptions)) {
      final session = _sessionOrNull;
      if (session == null) return handler.next(err);

      try {
        final refreshResult = await _refreshOnce();

        if (refreshResult) {
          // clone original request with new token
          final dio.RequestOptions opts = err.requestOptions;
          opts.extra[_retriedKey] = true;
          opts.headers['Authorization'] = 'Bearer ${session.accessToken}';
          try {
            final dio.Response<dynamic> response = await _client.fetch(opts);
            return handler.resolve(response);
          } on dio.DioException catch (retryErr) {
            // Surface the *retried request* error (not the original 401).
            return handler.next(retryErr);
          } catch (e) {
            return handler.next(
              dio.DioException(
                requestOptions: opts,
                error: e,
                type: dio.DioExceptionType.unknown,
              ),
            );
          }
        } else {
          return handler.next(err);
        }
      } catch (e, st) {
        Log.error('AuthTokenInterceptor refresh failed: $e', st);
        return handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
