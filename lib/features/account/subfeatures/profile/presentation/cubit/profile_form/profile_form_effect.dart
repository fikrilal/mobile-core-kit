import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class ProfileFormEffect {
  const ProfileFormEffect();
}

final class ProfileFormFailureEffect extends ProfileFormEffect {
  const ProfileFormFailureEffect(this.failure);

  final AuthFailure failure;
}
