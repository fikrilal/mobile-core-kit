import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_state.freezed.dart';

enum LogoutStatus { initial, submitting }

@freezed
abstract class LogoutState with _$LogoutState {
  const factory LogoutState({
    @Default(LogoutStatus.initial) LogoutStatus status,
    String? errorMessage,
  }) = _LogoutState;

  const LogoutState._();

  bool get isSubmitting => status == LogoutStatus.submitting;

  factory LogoutState.initial() => const LogoutState();
}
