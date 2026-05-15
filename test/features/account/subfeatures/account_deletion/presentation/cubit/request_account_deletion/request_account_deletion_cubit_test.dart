import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/cancel_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestAccountDeletionUseCase extends Mock
    implements RequestAccountDeletionUseCase {}

class _MockCancelAccountDeletionUseCase extends Mock
    implements CancelAccountDeletionUseCase {}

class _MockUserContextService extends Mock implements UserContextService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RequestAccountDeletionRequestEntity());
    registerFallbackValue(const CancelAccountDeletionRequestEntity());
  });

  late _MockRequestAccountDeletionUseCase requestAccountDeletion;
  late _MockCancelAccountDeletionUseCase cancelAccountDeletion;
  late _MockUserContextService userContext;
  late List<RequestAccountDeletionEffect> effects;
  late StreamSubscription<RequestAccountDeletionEffect> effectSubscription;

  setUp(() {
    requestAccountDeletion = _MockRequestAccountDeletionUseCase();
    cancelAccountDeletion = _MockCancelAccountDeletionUseCase();
    userContext = _MockUserContextService();
    effects = [];
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
    'emits submitting then success and request effect when request succeeds',
    setUp: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => cancelAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
    },
    build: () {
      final cubit = RequestAccountDeletionCubit(
        requestAccountDeletion,
        cancelAccountDeletion,
        userContext,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.request,
      ),
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.success,
        action: AccountDeletionAction.request,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowAccountDeletionRequested>()]);
      await effectSubscription.cancel();

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
      verifyNever(() => cancelAccountDeletion(any()));
    },
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'emits submitting then success and cancel effect when cancel succeeds',
    setUp: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => cancelAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
    },
    build: () {
      final cubit = RequestAccountDeletionCubit(
        requestAccountDeletion,
        cancelAccountDeletion,
        userContext,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.cancel(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.cancel,
      ),
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.success,
        action: AccountDeletionAction.cancel,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowAccountDeletionCanceled>()]);
      await effectSubscription.cancel();

      final captured =
          verify(() => cancelAccountDeletion(captureAny())).captured.single
              as CancelAccountDeletionRequestEntity;
      expect(captured.idempotencyKey, isNull);
      verify(
        () => userContext.refreshUser(
          reason: 'account_deletion_canceled',
          logoutOnUnauthenticated: false,
        ),
      ).called(1);
      verifyNever(() => requestAccountDeletion(any()));
    },
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'emits submitting then failure and failure effect when request fails',
    setUp: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      when(
        () => cancelAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
    },
    build: () {
      final cubit = RequestAccountDeletionCubit(
        requestAccountDeletion,
        cancelAccountDeletion,
        userContext,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.request,
      ),
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.failure,
        action: AccountDeletionAction.request,
        failure: AuthFailure.network(),
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowRequestAccountDeletionFailure>()]);
      expect(
        (effects.single as ShowRequestAccountDeletionFailure).failure,
        const AuthFailure.network(),
      );
      await effectSubscription.cancel();

      verifyNever(
        () => userContext.refreshUser(
          reason: any(named: 'reason'),
          logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
        ),
      );
    },
  );

  blocTest<RequestAccountDeletionCubit, RequestAccountDeletionState>(
    'success and effect still emit even when refreshUser fails',
    build: () {
      when(
        () => requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => cancelAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => userContext.refreshUser(
          reason: any(named: 'reason'),
          logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
        ),
      ).thenAnswer((_) async => left(const SessionFailure.network()));
      final cubit = RequestAccountDeletionCubit(
        requestAccountDeletion,
        cancelAccountDeletion,
        userContext,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.request(),
    expect: () => const [
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.submitting,
        action: AccountDeletionAction.request,
      ),
      RequestAccountDeletionState(
        status: RequestAccountDeletionStatus.success,
        action: AccountDeletionAction.request,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowAccountDeletionRequested>()]);
      await effectSubscription.cancel();
    },
  );

  test('closes effects stream on close', () async {
    final cubit = RequestAccountDeletionCubit(
      requestAccountDeletion,
      cancelAccountDeletion,
      userContext,
    );
    final done = expectLater(cubit.effects, emitsDone);

    await cubit.close();

    await done;
  });
}
