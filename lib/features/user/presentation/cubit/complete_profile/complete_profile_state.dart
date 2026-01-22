import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'complete_profile_state.freezed.dart';

enum CompleteProfileStatus { initial, submitting, success, failure }

@freezed
abstract class CompleteProfileState with _$CompleteProfileState {
  const factory CompleteProfileState({
    @Default('') String givenName,
    @Default('') String familyName,
    ValidationError? givenNameError,
    ValidationError? familyNameError,
    AuthFailure? failure,
    @Default(CompleteProfileStatus.initial) CompleteProfileStatus status,
  }) = _CompleteProfileState;

  factory CompleteProfileState.initial() => const CompleteProfileState();
}

extension CompleteProfileStateX on CompleteProfileState {
  bool get isSubmitting => status == CompleteProfileStatus.submitting;

  bool get canSubmit {
    if (isSubmitting) return false;
    if (givenName.trim().isEmpty) return false;
    return givenNameError == null && familyNameError == null;
  }
}
