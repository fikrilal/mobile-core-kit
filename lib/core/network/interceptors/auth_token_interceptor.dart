import 'dart:async';
import 'package:dio/dio.dart' as dio;
import '../../di/service_locator.dart';
import '../../session/session_manager.dart';
import '../../utilities/log_utils.dart';
import '../api/api_client.dart';

class AuthTokenInterceptor extends dio.Interceptor {
  AuthTokenInterceptor();

  SessionManager get _session => getIt<SessionManager>();
  Completer<bool>? _refreshCompleter;
  static const String _requiresAuthKey = 'requiresAuth';

  bool _requiresAuth(dio.RequestOptions options) {
    final value = options.extra[_requiresAuthKey];
    if (value is bool) return value;
    // Default: requests require auth unless explicitly marked public.
    return true;
  }

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    if (_requiresAuth(options)) {
      if (options.extra['retried'] != true && _session.isAccessTokenExpiringSoon) {
        try {
          await _refreshOnce();
        } catch (_) {
          // Best-effort preflight refresh; fall back to existing token.
        }
      }

      final token = _session.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<bool> _refreshOnce() async {
    // Ensure single refresh in flight for both preflight and 401 refresh paths.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final ok = await _session.refreshTokens();
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
        err.requestOptions.extra['retried'] != true) {
      try {
        final refreshResult = await _refreshOnce();

        if (refreshResult) {
          // clone original request with new token
          final dio.RequestOptions opts = err.requestOptions;
          opts.extra['retried'] = true;
          opts.headers['Authorization'] = 'Bearer ${_session.accessToken}';
          final dio.Dio client = getIt<ApiClient>().dio;
          try {
            final dio.Response<dynamic> response = await client.fetch(opts);
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
