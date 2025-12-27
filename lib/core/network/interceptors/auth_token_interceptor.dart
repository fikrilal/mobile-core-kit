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
  ) {
    if (_requiresAuth(options)) {
      final token = _session.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
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
        // ensure single refresh in flight
        if (_refreshCompleter == null) {
          _refreshCompleter = Completer<bool>();
          try {
            final ok = await _session.refreshTokens();
            _refreshCompleter!.complete(ok);
          } catch (e) {
            // propagate failure to all awaiters
            if (!(_refreshCompleter!.isCompleted)) {
              _refreshCompleter!.complete(false);
            }
          }
        }
        final refreshResult = await _refreshCompleter!.future;
        _refreshCompleter = null;

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
