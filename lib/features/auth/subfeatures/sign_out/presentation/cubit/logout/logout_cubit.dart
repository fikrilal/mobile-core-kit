import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logoutFlow) : super(LogoutState.initial());

  final LogoutFlowUseCase _logoutFlow;
  final _effects = StreamController<LogoutEffect>.broadcast();

  Stream<LogoutEffect> get effects => _effects.stream;

  Future<void> logout({String reason = 'manual_logout'}) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: LogoutStatus.submitting));

    try {
      await _logoutFlow(reason: reason);
      // Navigation is handled by the global router gate when the session clears.
      emit(state.copyWith(status: LogoutStatus.initial));
    } catch (e, st) {
      Log.error('Logout failed', e, st, true, 'LogoutCubit');
      _effects.add(const LogoutFailureEffect(LogoutFailure.failed));
      emit(state.copyWith(status: LogoutStatus.initial));
    }
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
