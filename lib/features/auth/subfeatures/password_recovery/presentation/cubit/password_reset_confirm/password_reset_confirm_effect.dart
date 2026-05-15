import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class PasswordResetConfirmEffect {
  const PasswordResetConfirmEffect();
}

final class PasswordResetConfirmFailureEffect
    extends PasswordResetConfirmEffect {
  const PasswordResetConfirmFailureEffect(this.failure);

  final AuthFailure failure;
}
