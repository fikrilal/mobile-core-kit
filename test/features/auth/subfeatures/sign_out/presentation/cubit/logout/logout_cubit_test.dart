import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_state.dart';
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
      final effects = <LogoutEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      await cubit.logout(reason: 'manual_logout');
      await pumpEventQueue();

      expect(emitted.length, 2);
      expect(emitted[0].status, LogoutStatus.submitting);
      expect(emitted[1].status, LogoutStatus.initial);
      expect(effects, isEmpty);

      verify(() => logoutFlow(reason: 'manual_logout')).called(1);

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test(
      'emits submitting -> initial and failure effect when logout throws',
      () async {
        final logoutFlow = _MockLogoutFlowUseCase();
        when(
          () => logoutFlow(reason: any(named: 'reason')),
        ).thenThrow(StateError('boom'));

        final cubit = LogoutCubit(logoutFlow);
        final emitted = <LogoutState>[];
        final effects = <LogoutEffect>[];
        final sub = cubit.stream.listen(emitted.add);
        final effectSub = cubit.effects.listen(effects.add);

        await cubit.logout(reason: 'manual_logout');
        await pumpEventQueue();

        expect(emitted.length, 2);
        expect(emitted[0].status, LogoutStatus.submitting);
        expect(emitted[1].status, LogoutStatus.initial);
        expect(effects, hasLength(1));
        expect(effects.single, isA<LogoutFailureEffect>());

        verify(() => logoutFlow(reason: 'manual_logout')).called(1);

        await sub.cancel();
        await effectSub.cancel();
        await cubit.close();
      },
    );
  });
}
