import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/cancel_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';

class RequestAccountDeletionCubit extends Cubit<RequestAccountDeletionState> {
  RequestAccountDeletionCubit(
    this._requestAccountDeletion,
    this._cancelAccountDeletion,
    this._userContext,
  ) : super(RequestAccountDeletionState.initial());

  final RequestAccountDeletionUseCase _requestAccountDeletion;
  final CancelAccountDeletionUseCase _cancelAccountDeletion;
  final UserContextService _userContext;

  Future<void> request({String? idempotencyKey}) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.request,
        failure: null,
      ),
    );

    await _handleResult(
      action: AccountDeletionAction.request,
      reason: 'account_deletion_requested',
      resultFuture: _requestAccountDeletion(
        RequestAccountDeletionRequestEntity(idempotencyKey: idempotencyKey),
      ),
    );
  }

  Future<void> cancel({String? idempotencyKey}) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.cancel,
        failure: null,
      ),
    );

    await _handleResult(
      action: AccountDeletionAction.cancel,
      reason: 'account_deletion_canceled',
      resultFuture: _cancelAccountDeletion(
        CancelAccountDeletionRequestEntity(idempotencyKey: idempotencyKey),
      ),
    );
  }

  Future<void> _handleResult({
    required AccountDeletionAction action,
    required String reason,
    required Future<Either<AuthFailure, Unit>> resultFuture,
  }) async {
    final result = await resultFuture;

    await result.match(
      (failure) async {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: RequestAccountDeletionStatus.failure,
            action: action,
            failure: failure,
          ),
        );
      },
      (_) async {
        // Best-effort re-hydration to expose `user.accountDeletion` to UI.
        await _userContext.refreshUser(
          reason: reason,
          logoutOnUnauthenticated: false,
        );

        if (isClosed) return;
        emit(
          state.copyWith(
            status: RequestAccountDeletionStatus.success,
            action: action,
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
        action: null,
        failure: null,
      ),
    );
  }
}
