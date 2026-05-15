import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class LoginEffect {
  const LoginEffect();
}

final class LoginFailureEffect extends LoginEffect {
  const LoginFailureEffect(this.failure);

  final AuthFailure failure;
}
