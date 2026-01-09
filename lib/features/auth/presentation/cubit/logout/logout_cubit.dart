import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utilities/log_utils.dart';
import '../../../domain/usecase/logout_flow_usecase.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logoutFlow) : super(LogoutState.initial());

  final LogoutFlowUseCase _logoutFlow;

  Future<void> logout({String reason = 'manual_logout'}) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: LogoutStatus.submitting, errorMessage: null));

    try {
      await _logoutFlow(reason: reason);
      // Navigation is handled by the global router gate when the session clears.
      emit(state.copyWith(status: LogoutStatus.initial, errorMessage: null));
    } catch (e, st) {
      Log.error('Logout failed', e, st, true, 'LogoutCubit');
      emit(
        state.copyWith(
          status: LogoutStatus.initial,
          errorMessage: 'Failed to log out. Please try again.',
        ),
      );
    }
  }
}
