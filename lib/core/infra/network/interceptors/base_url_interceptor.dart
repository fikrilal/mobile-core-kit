import 'package:dio/dio.dart';
import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/config/app_config.dart';

class BaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final host = options.extra['host'] as ApiHost?;
    if (host != null) {
      options.baseUrl = AppConfig.instance.url(host);
    }
    handler.next(options);
  }
}
