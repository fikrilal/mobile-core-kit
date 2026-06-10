import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';

part 'profile_form_state.freezed.dart';

enum ProfileFormStatus { initial, submitting, success, failure }

@freezed
abstract class ProfileFormState with _$ProfileFormState {
  const factory ProfileFormState({
    @Default('') String givenName,
    @Default('') String familyName,
    ValidationError? givenNameError,
    ValidationError? familyNameError,
    AuthFailure? failure,
    @Default(ProfileFormStatus.initial) ProfileFormStatus status,
  }) = _ProfileFormState;

  factory ProfileFormState.initial() => const ProfileFormState();
}

extension ProfileFormStateX on ProfileFormState {
  bool get isSubmitting => status == ProfileFormStatus.submitting;

  bool get canSubmit {
    if (isSubmitting) return false;
    if (status == ProfileFormStatus.success) return false;
    if (givenName.trim().isEmpty) return false;
    return givenNameError == null && familyNameError == null;
  }
}
