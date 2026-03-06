import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/user/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/cancel_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/pages/request_account_deletion_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
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

  group('RequestAccountDeletionPage', () {
    late _MockRequestAccountDeletionUseCase requestUseCase;
    late _MockCancelAccountDeletionUseCase cancelUseCase;
    late _MockUserContextService userContext;

    setUp(() {
      requestUseCase = _MockRequestAccountDeletionUseCase();
      cancelUseCase = _MockCancelAccountDeletionUseCase();
      userContext = _MockUserContextService();
    });

    testWidgets(
      'shows request confirmation and success snackbar for unscheduled account',
      (tester) async {
        final stateNotifier = ValueNotifier<CurrentUserState>(
          CurrentUserState(
            status: CurrentUserStatus.available,
            user: _baseUser(),
          ),
        );
        addTearDown(stateNotifier.dispose);

        when(() => userContext.stateListenable).thenReturn(stateNotifier);
        when(
          () => userContext.refreshUser(
            reason: any(named: 'reason'),
            logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
          ),
        ).thenAnswer((_) async => right(_baseUser()));
        when(() => requestUseCase(any())).thenAnswer((_) async => right(unit));
        when(() => cancelUseCase(any())).thenAnswer((_) async => right(unit));

        final cubit = RequestAccountDeletionCubit(
          requestUseCase,
          cancelUseCase,
          userContext,
        );
        addTearDown(cubit.close);

        await _pumpPage(tester, cubit: cubit, userContext: userContext);
        final l10n = _l10n(tester);

        expect(find.text(l10n.accountDeletionRequestCta), findsOneWidget);
        expect(find.text(l10n.accountDeletionCancelCta), findsNothing);

        await _pressAppButton(tester, l10n.accountDeletionRequestCta);

        expect(find.text(l10n.accountDeletionConfirmTitle), findsOneWidget);
        await _pressAppButton(tester, l10n.accountDeletionConfirmCta);

        verify(() => requestUseCase(any())).called(1);
        verifyNever(() => cancelUseCase(any()));
        expect(
          find.text(l10n.accountDeletionRequestSuccessMessage),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows cancel confirmation and success snackbar for scheduled account',
      (tester) async {
        final scheduledUser = _baseUser(
          accountDeletion: const AccountDeletionEntity(
            requestedAt: '2026-03-01T00:00:00Z',
            scheduledFor: '2026-03-31T00:00:00Z',
          ),
        );
        final stateNotifier = ValueNotifier<CurrentUserState>(
          CurrentUserState(
            status: CurrentUserStatus.available,
            user: scheduledUser,
          ),
        );
        addTearDown(stateNotifier.dispose);

        when(() => userContext.stateListenable).thenReturn(stateNotifier);
        when(
          () => userContext.refreshUser(
            reason: any(named: 'reason'),
            logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
          ),
        ).thenAnswer((_) async => right(scheduledUser));
        when(() => requestUseCase(any())).thenAnswer((_) async => right(unit));
        when(() => cancelUseCase(any())).thenAnswer((_) async => right(unit));

        final cubit = RequestAccountDeletionCubit(
          requestUseCase,
          cancelUseCase,
          userContext,
        );
        addTearDown(cubit.close);

        await _pumpPage(tester, cubit: cubit, userContext: userContext);
        final l10n = _l10n(tester);

        expect(find.text(l10n.accountDeletionCancelCta), findsOneWidget);
        expect(find.text(l10n.accountDeletionRequestCta), findsNothing);

        await _pressAppButton(tester, l10n.accountDeletionCancelCta);

        expect(
          find.text(l10n.accountDeletionCancelConfirmTitle),
          findsOneWidget,
        );
        await _pressAppButton(tester, l10n.accountDeletionCancelConfirmCta);

        verify(() => cancelUseCase(any())).called(1);
        verifyNever(() => requestUseCase(any()));
        expect(
          find.text(l10n.accountDeletionCancelSuccessMessage),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows localized error snackbar when cancel action fails', (
      tester,
    ) async {
      final scheduledUser = _baseUser(
        accountDeletion: const AccountDeletionEntity(
          requestedAt: '2026-03-01T00:00:00Z',
          scheduledFor: '2026-03-31T00:00:00Z',
        ),
      );
      final stateNotifier = ValueNotifier<CurrentUserState>(
        CurrentUserState(
          status: CurrentUserStatus.available,
          user: scheduledUser,
        ),
      );
      addTearDown(stateNotifier.dispose);

      when(() => userContext.stateListenable).thenReturn(stateNotifier);
      when(
        () => userContext.refreshUser(
          reason: any(named: 'reason'),
          logoutOnUnauthenticated: any(named: 'logoutOnUnauthenticated'),
        ),
      ).thenAnswer((_) async => right(scheduledUser));
      when(
        () => cancelUseCase(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      when(() => requestUseCase(any())).thenAnswer((_) async => right(unit));

      final cubit = RequestAccountDeletionCubit(
        requestUseCase,
        cancelUseCase,
        userContext,
      );
      addTearDown(cubit.close);

      await _pumpPage(tester, cubit: cubit, userContext: userContext);
      final l10n = _l10n(tester);

      await _pressAppButton(tester, l10n.accountDeletionCancelCta);
      await _pressAppButton(tester, l10n.accountDeletionCancelConfirmCta);

      expect(find.text(l10n.errorsOffline), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required RequestAccountDeletionCubit cubit,
  required UserContextService userContext,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdaptiveScope(
        navigationPolicy: const NavigationPolicy.none(),
        child: BlocProvider<RequestAccountDeletionCubit>.value(
          value: cubit,
          child: RequestAccountDeletionPage(userContext: userContext),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _l10n(WidgetTester tester) {
  final context = tester.element(find.byType(RequestAccountDeletionPage));
  return AppLocalizations.of(context);
}

Future<void> _pressAppButton(WidgetTester tester, String label) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is AppButton && widget.text == label,
  );
  expect(finder, findsOneWidget);
  final button = tester.widget<AppButton>(finder);
  expect(button.onPressed, isNotNull);
  button.onPressed!.call();
  await tester.pumpAndSettle();
}

UserEntity _baseUser({AccountDeletionEntity? accountDeletion}) {
  return UserEntity(
    id: 'u1',
    email: 'user@example.com',
    accountDeletion: accountDeletion,
  );
}
