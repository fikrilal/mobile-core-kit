import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestAccountDeletionUseCase extends Mock
    implements RequestAccountDeletionUseCase {}

class _MockUserContextService extends Mock implements UserContextService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RequestAccountDeletionRequestEntity());
  });

  late _MockRequestAccountDeletionUseCase requestAccountDeletion;
  late _MockUserContextService userContext;

  setUp(() {
    requestAccountDeletion = _MockRequestAccountDeletionUseCase();
    userContext = _MockUserContextService();
    when(
      () => userContext.refreshUser(
        reason: any(named: 'reason'),
        logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
      ),
    ).thenAnswer(
      (_) async => right(const UserEntity(id: 'u1', email: 'u@x.t')),
    );
  });

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'emits submitting then success when request succeeds',
    build: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      return RequestAccountDeletionCubit(requestAccountDeletion, userContext);
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
      ),
      RequestAccountDeletionState(status: RequestAccountDeletionStatus.success),
    ],
    verify: (_) {
      final captured =
          verify(() => requestAccountDeletion(captureAny())).captured.single
              as RequestAccountDeletionRequestEntity;
      expect(captured.idempotencyKey, isNull);
      verify(
        () => userContext.refreshUser(
          reason: 'account_deletion_requested',
          logoutOnUnauthenticated: false,
        ),
      ).called(1);
    },
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'emits submitting then failure when request fails',
    build: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      return RequestAccountDeletionCubit(requestAccountDeletion, userContext);
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
      ),
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.failure,
        failure: AuthFailure.network(),
      ),
    ],
    verify: (_) {
      verifyNever(
        () => userContext.refreshUser(
          reason: any(named: 'reason'),
          logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
        ),
      );
    },
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'success still emits even when refreshUser fails',
    build: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => userContext.refreshUser(
          reason: any(named: 'reason'),
          logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
        ),
      ).thenAnswer((_) async => left(const SessionFailure.network()));
      return RequestAccountDeletionCubit(requestAccountDeletion, userContext);
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
      ),
      RequestAccountDeletionState(status: RequestAccountDeletionStatus.success),
    ],
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'resetStatus clears success/failure back to initial',
    build: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      return RequestAccountDeletionCubit(requestAccountDeletion, userContext);
    },
    act: (cubit) async {
      await cubit.request();
      cubit.resetStatus();
    },
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
      ),
      RequestAccountDeletionState(status: RequestAccountDeletionStatus.success),
      RequestAccountDeletionState(status: RequestAccountDeletionStatus.initial),
    ],
  );
}
