import 'network_status.dart';

/// Abstraction for connectivity so it can be mocked and swapped in tests.
abstract class ConnectivityService {
  NetworkStatus get currentStatus;

  Stream<NetworkStatus> get networkStatusStream;

  bool get isConnected;

  Future<void> initialize();

  Future<void> checkConnectivity();

  Future<void> dispose();
}