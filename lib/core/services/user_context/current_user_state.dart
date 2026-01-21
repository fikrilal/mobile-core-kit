import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';

enum CurrentUserStatus { signedOut, authPending, available }

@immutable
class CurrentUserState {
  const CurrentUserState({
    required this.status,
    this.user,
    this.isRefreshing = false,
    this.lastFailure,
    this.lastRefreshedAt,
  });

  const CurrentUserState.signedOut()
    : status = CurrentUserStatus.signedOut,
      user = null,
      isRefreshing = false,
      lastFailure = null,
      lastRefreshedAt = null;

  final CurrentUserStatus status;
  final UserEntity? user;
  final bool isRefreshing;
  final SessionFailure? lastFailure;
  final DateTime? lastRefreshedAt;

  bool get isAuthenticated => status != CurrentUserStatus.signedOut;
  bool get isAuthPending => status == CurrentUserStatus.authPending;
  bool get hasUser => user != null;

  CurrentUserState copyWith({
    CurrentUserStatus? status,
    UserEntity? user,
    bool userIsSet = false,
    bool? isRefreshing,
    SessionFailure? lastFailure,
    bool lastFailureIsSet = false,
    DateTime? lastRefreshedAt,
    bool lastRefreshedAtIsSet = false,
  }) {
    return CurrentUserState(
      status: status ?? this.status,
      user: userIsSet ? user : this.user,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastFailure: lastFailureIsSet ? lastFailure : this.lastFailure,
      lastRefreshedAt:
          lastRefreshedAtIsSet ? lastRefreshedAt : this.lastRefreshedAt,
    );
  }
}

