import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class RegisterEffect {
  const RegisterEffect();
}

final class RegisterFailureEffect extends RegisterEffect {
  const RegisterFailureEffect(this.failure);

  final AuthFailure failure;
}
