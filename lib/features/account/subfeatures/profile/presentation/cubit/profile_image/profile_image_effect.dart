import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class ProfileImageEffect {
  const ProfileImageEffect();
}

class ShowProfileImageFailure extends ProfileImageEffect {
  const ShowProfileImageFailure(this.failure);

  final AuthFailure failure;
}

class ShowProfileImageUpdated extends ProfileImageEffect {
  const ShowProfileImageUpdated();
}

class ShowProfileImageRemoved extends ProfileImageEffect {
  const ShowProfileImageRemoved();
}
