import 'package:dio/dio.dart';
import '../../configs/api_host.dart';
import '../../configs/app_config.dart';

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
