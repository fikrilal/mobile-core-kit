import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_state.dart';

sealed class LogoutEffect {
  const LogoutEffect();
}

final class LogoutFailureEffect extends LogoutEffect {
  const LogoutFailureEffect(this.failure);

  final LogoutFailure failure;
}
