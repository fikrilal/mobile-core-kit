import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';

class RequestAccountDeletionCubit extends Cubit<RequestAccountDeletionState> {
  RequestAccountDeletionCubit(
    this._accountDeletion,
    this._userContext,
  ) : super(RequestAccountDeletionState.initial());

  final AccountDeletionUseCase _accountDeletion;
  final UserContextService _userContext;
  final _effects = StreamController<RequestAccountDeletionEffect>();

  Stream<RequestAccountDeletionEffect> get effects => _effects.stream;

  Future<void> request() async {
    await _submit(
      action: AccountDeletionAction.request,
      reason: 'account_deletion_requested',
    );
  }

  Future<void> cancel() async {
    await _submit(
      action: AccountDeletionAction.cancel,
      reason: 'account_deletion_canceled',
    );
  }

  Future<void> _submit({
    required AccountDeletionAction action,
    required String reason,
  }) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: RequestAccountDeletionStatus.submitting,
        action: action,
        failure: null,
      ),
    );

    await _handleResult(
      action: action,
      reason: reason,
      resultFuture: _accountDeletion(action),
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
        _effects.add(ShowRequestAccountDeletionFailure(failure));
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
        _effects.add(switch (action) {
          AccountDeletionAction.request => const ShowAccountDeletionRequested(),
          AccountDeletionAction.cancel => const ShowAccountDeletionCanceled(),
        });
      },
    );
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
