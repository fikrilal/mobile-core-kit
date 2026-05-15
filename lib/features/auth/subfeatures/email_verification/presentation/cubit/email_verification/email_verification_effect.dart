import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class EmailVerificationEffect {
  const EmailVerificationEffect();
}

final class EmailVerificationFailureEffect extends EmailVerificationEffect {
  const EmailVerificationFailureEffect(this.failure);

  final AuthFailure failure;
}
