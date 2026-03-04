import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

part 'request_account_deletion_state.freezed.dart';

enum RequestAccountDeletionStatus { initial, submitting, success, failure }

@freezed
abstract class RequestAccountDeletionState with _$RequestAccountDeletionState {
  const factory RequestAccountDeletionState({
    @Default(RequestAccountDeletionStatus.initial)
    RequestAccountDeletionStatus status,
    AuthFailure? failure,
  }) = _RequestAccountDeletionState;

  const RequestAccountDeletionState._();

  bool get isSubmitting => status == RequestAccountDeletionStatus.submitting;

  factory RequestAccountDeletionState.initial() =>
      const RequestAccountDeletionState();
}
