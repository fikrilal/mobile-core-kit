import 'package:dio/dio.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/connectivity/network_status.dart';

typedef HttpFetchHandler =
    Future<ResponseBody> Function(RequestOptions requestOptions);

class CallbackHttpClientAdapter implements HttpClientAdapter {
  CallbackHttpClientAdapter(this._onFetch);

  final HttpFetchHandler _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

class AlwaysOnlineConnectivityService implements ConnectivityService {
  @override
  bool get isConnected => true;

  @override
  NetworkStatus get currentStatus => NetworkStatus.online;

  @override
  Stream<NetworkStatus> get networkStatusStream =>
      const Stream<NetworkStatus>.empty();

  @override
  Future<void> checkConnectivity() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

ApiHelper createApiHelperForFixtureResponses(
  HttpFetchHandler onFetch, {
  String baseUrl = 'https://example.com',
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = CallbackHttpClientAdapter(onFetch);
  return ApiHelper(dio, connectivity: AlwaysOnlineConnectivityService());
}
