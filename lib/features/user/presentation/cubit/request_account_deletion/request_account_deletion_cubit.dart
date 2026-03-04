import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';

class RequestAccountDeletionCubit extends Cubit<RequestAccountDeletionState> {
  RequestAccountDeletionCubit(this._requestAccountDeletion, this._userContext)
    : super(RequestAccountDeletionState.initial());

  final RequestAccountDeletionUseCase _requestAccountDeletion;
  final UserContextService _userContext;

  Future<void> request({String? idempotencyKey}) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: RequestAccountDeletionStatus.submitting,
        failure: null,
      ),
    );

    final result = await _requestAccountDeletion(
      RequestAccountDeletionRequestEntity(idempotencyKey: idempotencyKey),
    );

    await result.match(
      (failure) async {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: RequestAccountDeletionStatus.failure,
            failure: failure,
          ),
        );
      },
      (_) async {
        // Best-effort re-hydration to expose `user.accountDeletion` to UI.
        await _userContext.refreshUser(
          reason: 'account_deletion_requested',
          logoutOnUnauthenticated: false,
        );

        if (isClosed) return;
        emit(
          state.copyWith(
            status: RequestAccountDeletionStatus.success,
            failure: null,
          ),
        );
      },
    );
  }

  void resetStatus() {
    if (state.status == RequestAccountDeletionStatus.initial) return;
    emit(
      state.copyWith(
        status: RequestAccountDeletionStatus.initial,
        failure: null,
      ),
    );
  }
}
