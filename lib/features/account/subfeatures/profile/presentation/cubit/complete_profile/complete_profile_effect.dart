import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class CompleteProfileEffect {
  const CompleteProfileEffect();
}

final class CompleteProfileFailureEffect extends CompleteProfileEffect {
  const CompleteProfileFailureEffect(this.failure);

  final AuthFailure failure;
}
