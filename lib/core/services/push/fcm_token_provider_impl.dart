import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/services/push/fcm_token_provider.dart';
import 'package:mobile_core_kit/core/services/push/push_permission_state.dart';

class FcmTokenProviderImpl implements FcmTokenProvider {
  FcmTokenProviderImpl({FirebaseMessaging? firebaseMessaging})
    : _firebaseMessagingOverride = firebaseMessaging;

  final String _tag = 'FcmTokenProviderImpl';
  final FirebaseMessaging? _firebaseMessagingOverride;

  late final FirebaseMessaging _firebaseMessaging =
      _firebaseMessagingOverride ?? FirebaseMessaging.instance;

  @override
  Stream<String> get onTokenRefresh {
    if (!_supportsFcm()) return const Stream<String>.empty();
    return _firebaseMessaging.onTokenRefresh;
  }

  @override
  Future<String?> getToken() async {
    if (!_supportsFcm()) return null;

    try {
      return await _firebaseMessaging.getToken();
    } catch (e, st) {
      Log.warning('Failed to read FCM token: $e', name: _tag);
      Log.debug('Stack trace: $st', name: _tag);
      return null;
    }
  }

  @override
  Future<PushPermissionState> requestPermission() async {
    if (!_supportsFcm()) return PushPermissionState.notSupported;

    try {
      final settings = await _firebaseMessaging.requestPermission();
      return switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized => PushPermissionState.granted,
        AuthorizationStatus.denied => PushPermissionState.denied,
        AuthorizationStatus.notDetermined => PushPermissionState.notDetermined,
        AuthorizationStatus.provisional => PushPermissionState.provisional,
      };
    } catch (e, st) {
      Log.warning('Failed to request notification permission: $e', name: _tag);
      Log.debug('Stack trace: $st', name: _tag);
      return PushPermissionState.notSupported;
    }
  }

  bool _supportsFcm() {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => false,
    };
  }
}
