import 'package:dio/dio.dart';
import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/config/app_config.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/auth_token_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/base_url_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/error_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/header_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/logging_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/interceptors/request_id_interceptor.dart';
import 'package:mobile_core_kit/core/infra/network/logging/net_log_mode.dart';
import 'package:mobile_core_kit/core/infra/network/logging/network_log_config.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  late HeaderInterceptor _headerInterceptor;

  Dio get dio => _dio;
  HeaderInterceptor get headerInterceptor => _headerInterceptor;

  void init({required SessionManager Function() sessionManagerProvider}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.url(ApiHost.core),
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
      ),
    );

    // Initialize and add interceptors
    _headerInterceptor = HeaderInterceptor();

    // Order matters:
    // 1) BaseUrlInterceptor - sets correct host URL
    // 2) RequestIdInterceptor - attaches request correlation ID header
    // 3) HeaderInterceptor - adds common headers
    // 4) AuthTokenInterceptor - attaches auth token and handles refresh/retry
    // 5) LoggingInterceptor - logs request/response (if enabled)
    // 6) ErrorInterceptor - handles and transforms errors
    _dio.interceptors.addAll([
      BaseUrlInterceptor(),
      RequestIdInterceptor(),
      _headerInterceptor,
      AuthTokenInterceptor(
        sessionManagerProvider: sessionManagerProvider,
        client: _dio,
      ),
      if (NetworkLogConfig.instance.mode != NetLogMode.off)
        LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // Convenience method to register headers for a specific endpoint
  void registerEndpointHeaders(String endpoint, Map<String, String> headers) {
    _headerInterceptor.registerEndpointHeaders(endpoint, headers);
  }
}
