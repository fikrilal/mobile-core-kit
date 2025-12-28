import 'package:dio/dio.dart';
import '../../configs/api_host.dart';
import '../../configs/app_config.dart';
import '../interceptors/auth_token_interceptor.dart';
import '../interceptors/base_url_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/header_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../logging/net_log_mode.dart';
import '../logging/network_log_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  late HeaderInterceptor _headerInterceptor;

  Dio get dio => _dio;
  HeaderInterceptor get headerInterceptor => _headerInterceptor;

  void init() {
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
    // 2) HeaderInterceptor - adds common headers
    // 3) AuthTokenInterceptor - attaches auth token and handles refresh/retry
    // 4) LoggingInterceptor - logs request/response (if enabled)
    // 5) ErrorInterceptor - handles and transforms errors
    _dio.interceptors.addAll([
      BaseUrlInterceptor(),
      _headerInterceptor,
      AuthTokenInterceptor(),
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
