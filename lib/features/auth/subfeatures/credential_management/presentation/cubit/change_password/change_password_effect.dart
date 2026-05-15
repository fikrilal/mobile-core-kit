import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class ChangePasswordEffect {
  const ChangePasswordEffect();
}

final class ChangePasswordSuccessEffect extends ChangePasswordEffect {
  const ChangePasswordSuccessEffect();
}

final class ChangePasswordFailureEffect extends ChangePasswordEffect {
  const ChangePasswordFailureEffect(this.failure);

  final AuthFailure failure;
}
