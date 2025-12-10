import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/domain/entity/user_entity.dart';
import '../events/app_event.dart';
import '../events/app_event_bus.dart';
import '../utilities/log_utils.dart';
import 'session_repository.dart';

class SessionManager {
  SessionManager(
    this._repository, {
    required RefreshTokenUsecase refreshUsecase,
    required AppEventBus events,
  }) : _refreshTokenUsecase = refreshUsecase,
       _events = events;

  final SessionRepository _repository;
  final RefreshTokenUsecase _refreshTokenUsecase;
  final StreamController<UserEntity?> _userController =
      StreamController<UserEntity?>.broadcast();
  final ValueNotifier<UserEntity?> _userNotifier = ValueNotifier<UserEntity?>(
    null,
  );
  final AppEventBus _events;
  UserEntity? _currentUser;

  Future<void> init() async {
    _currentUser = await _repository.loadSession();
    Log.debug(
      'Session init: user loaded=${_currentUser != null}',
      name: 'SessionManager',
    );
    if (_currentUser != null) {
      Log.debug(
        'Loaded access(~5)=${_mask(_currentUser!.accessToken)} refresh(~5)=${_mask(_currentUser!.refreshToken)}',
        name: 'SessionManager',
      );
    }
    _userController.add(_currentUser);
    _userNotifier.value = _currentUser;
  }

  UserEntity? get user => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  Stream<UserEntity?> get stream => _userController.stream;
  String? get accessToken => _currentUser?.accessToken;
  ValueListenable<UserEntity?> get userNotifier => _userNotifier;

  void dispose() {
    _userController.close();
    _userNotifier.dispose();
  }

  Future<void> login(UserEntity user) async {
    Log.info('Login: saving session', name: 'SessionManager');
    await _repository.saveSession(user);
    _currentUser = user;
    Log.debug(
      'Login saved. access(~5)=${_mask(user.accessToken)} refresh(~5)=${_mask(user.refreshToken)}',
      name: 'SessionManager',
    );
    _userController.add(_currentUser);
    _userNotifier.value = _currentUser;
  }

  UserEntity _attachTokens(
    UserEntity user,
    String accessToken,
    String refreshToken,
    int expiresIn,
  ) => user.copyWith(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
  );

  Future<bool> refreshTokens() async {
    final current = _currentUser;
    if (current?.refreshToken == null) return false;
    Log.debug('Refreshing tokens…', name: 'SessionManager');
    Log.debug(
      'Using refresh(~5)=${_mask(current!.refreshToken)}',
      name: 'SessionManager',
    );
    final result = await _refreshTokenUsecase(
      RefreshRequestEntity(refreshToken: current.refreshToken!),
    );

    return result.match(
      (failure) async {
        Log.error(
          'Refresh failed – logging out',
          Exception('Token refresh failure: $failure'),
          StackTrace.current,
          true,
          'SessionManager',
        );
        _events.publish(const SessionExpired(reason: 'refresh_failed'));
        await logout(reason: 'refresh_failed');
        return false;
      },
      (tokens) async {
        Log.debug(
          'Refresh success. New access(~5)=${_mask(tokens.accessToken)} refresh(~5)=${_mask(tokens.refreshToken)}',
          name: 'SessionManager',
        );
        final updated = _attachTokens(
          current,
          tokens.accessToken!,
          tokens.refreshToken!,
          tokens.expiresIn!,
        );
        await _repository.saveSession(updated);
        Log.debug('Session persisted after refresh', name: 'SessionManager');
        _currentUser = updated;
        _userController.add(_currentUser);
        _userNotifier.value = _currentUser;
        return true;
      },
    );
  }

  Future<void> logout({String reason = 'manual_logout'}) async {
    Log.info('Logout: clearing session', name: 'SessionManager');
    await _repository.clearSession();
    _currentUser = null;
    _userController.add(_currentUser);
    _userNotifier.value = _currentUser;
    _events.publish(SessionCleared(reason: reason));
  }

  String _mask(String? token) {
    if (token == null || token.isEmpty) return 'null';
    final len = token.length;
    final start = token.substring(0, len >= 5 ? 5 : len);
    return '$start…($len)';
  }
}
