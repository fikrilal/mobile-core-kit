import 'api_host.dart';
import 'build_config.dart';

class AppConfig {
  final String accessToken;

  const AppConfig({required this.accessToken});

  static late AppConfig instance;

  static void init(AppConfig config) => instance = config;

  // Helpers that proxy to BuildConfig ----------------
  String url(ApiHost host) => BuildConfig.apiUrl(host);

  bool get enableLogging => BuildConfig.logEnabled;

  String get environment => BuildConfig.env.name;
}
