import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/connectivity/network_status.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  NetworkStatus _currentStatus = NetworkStatus.online;

  ConnectivityServiceImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;

  @override
  bool get isConnected => _currentStatus == NetworkStatus.online;

  @override
  Future<void> initialize() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    await checkConnectivity();
  }

  @override
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    NetworkStatus status;
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      status = NetworkStatus.offline;
    } else {
      status = NetworkStatus.online;
    }

    if (_currentStatus != status) {
      _currentStatus = status;
      _networkStatusController.add(status);
    }
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _networkStatusController.close();
  }
}
