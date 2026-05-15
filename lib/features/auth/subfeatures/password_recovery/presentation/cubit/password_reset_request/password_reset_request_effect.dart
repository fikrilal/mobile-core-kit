import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class PasswordResetRequestEffect {
  const PasswordResetRequestEffect();
}

final class PasswordResetRequestSuccessEffect
    extends PasswordResetRequestEffect {
  const PasswordResetRequestSuccessEffect();
}

final class PasswordResetRequestFailureEffect
    extends PasswordResetRequestEffect {
  const PasswordResetRequestFailureEffect(this.failure);

  final AuthFailure failure;
}
