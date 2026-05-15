import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class MeSessionsEffect {
  const MeSessionsEffect();
}

class ShowRevokeSessionFailure extends MeSessionsEffect {
  const ShowRevokeSessionFailure(this.failure);

  final AuthFailure failure;
}

class ShowRevokeSessionSuccess extends MeSessionsEffect {
  const ShowRevokeSessionSuccess(this.sessionId);

  final String sessionId;
}

class ShowMeSessionsLoadMoreFailure extends MeSessionsEffect {
  const ShowMeSessionsLoadMoreFailure(this.failure);

  final AuthFailure failure;
}
