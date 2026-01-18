import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogoutFlowUseCase extends Mock implements LogoutFlowUseCase {}

void main() {
  group('LogoutCubit', () {
    test('emits submitting -> success when logout completes', () async {
      final logoutFlow = _MockLogoutFlowUseCase();
      when(
        () => logoutFlow(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final cubit = LogoutCubit(logoutFlow);
      final emitted = <LogoutState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.logout(reason: 'manual_logout');
      await pumpEventQueue();

      expect(emitted.length, 2);
      expect(emitted[0].status, LogoutStatus.submitting);
      expect(emitted[1].status, LogoutStatus.initial);

      verify(() => logoutFlow(reason: 'manual_logout')).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test('emits submitting -> failure when logout throws', () async {
      final logoutFlow = _MockLogoutFlowUseCase();
      when(
        () => logoutFlow(reason: any(named: 'reason')),
      ).thenThrow(StateError('boom'));

      final cubit = LogoutCubit(logoutFlow);
      final emitted = <LogoutState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.logout(reason: 'manual_logout');
      await pumpEventQueue();

      expect(emitted.length, 2);
      expect(emitted[0].status, LogoutStatus.submitting);
      expect(emitted[1].status, LogoutStatus.initial);
      expect(emitted[1].failure, LogoutFailure.failed);

      verify(() => logoutFlow(reason: 'manual_logout')).called(1);

      await sub.cancel();
      await cubit.close();
    });
  });
}
