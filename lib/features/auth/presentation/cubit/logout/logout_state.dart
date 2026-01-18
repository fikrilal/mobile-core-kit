import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_state.freezed.dart';

enum LogoutStatus { initial, submitting }

enum LogoutFailure { failed }

@freezed
abstract class LogoutState with _$LogoutState {
  const factory LogoutState({
    @Default(LogoutStatus.initial) LogoutStatus status,
    LogoutFailure? failure,
  }) = _LogoutState;

  const LogoutState._();

  bool get isSubmitting => status == LogoutStatus.submitting;

  factory LogoutState.initial() => const LogoutState();
}
