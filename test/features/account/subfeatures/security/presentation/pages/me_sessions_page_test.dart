import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/revoke_me_session_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/list_me_sessions_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/revoke_me_session_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/pages/me_sessions_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListMeSessionsUseCase extends Mock
    implements ListMeSessionsUseCase {}

class _MockRevokeMeSessionUseCase extends Mock
    implements RevokeMeSessionUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ListMeSessionsRequestEntity());
    registerFallbackValue(
      const RevokeMeSessionRequestEntity(sessionId: 'session-fallback'),
    );
  });

  group('MeSessionsPage', () {
    late _MockListMeSessionsUseCase listMeSessions;
    late _MockRevokeMeSessionUseCase revokeMeSession;

    final activeOtherSession = MeSessionEntity(
      id: 's-other',
      deviceName: 'iPhone 14',
      ip: '203.0.113.5',
      userAgent: 'Mobile Safari',
      createdAt: DateTime.utc(2026, 3, 1, 10),
      lastSeenAt: DateTime.utc(2026, 3, 5, 10),
      expiresAt: DateTime.utc(2026, 4, 1, 10),
      current: false,
      status: MeSessionStatus.active,
    );

    final currentSession = MeSessionEntity(
      id: 's-current',
      deviceName: 'Pixel 9',
      ip: '198.51.100.1',
      userAgent: 'Chrome',
      createdAt: DateTime.utc(2026, 3, 1, 11),
      lastSeenAt: DateTime.utc(2026, 3, 5, 11),
      expiresAt: DateTime.utc(2026, 4, 1, 11),
      current: true,
      status: MeSessionStatus.active,
    );

    setUp(() {
      listMeSessions = _MockListMeSessionsUseCase();
      revokeMeSession = _MockRevokeMeSessionUseCase();
    });

    testWidgets('shows revoke confirmation and success snackbar', (
      tester,
    ) async {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async => right(
          MeSessionsPageEntity(items: [activeOtherSession], hasMore: false),
        ),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));

      final cubit = MeSessionsCubit(listMeSessions, revokeMeSession);
      addTearDown(cubit.close);

      await _pumpPage(tester, cubit);
      final l10n = _l10n(tester);

      expect(find.text('iPhone 14'), findsOneWidget);

      await _pressAppButton(tester, l10n.meSessionsRevokeCta);
      expect(find.text(l10n.meSessionsRevokeConfirmTitle), findsOneWidget);

      await _pressAppButton(tester, l10n.meSessionsRevokeConfirmCta);

      verify(() => revokeMeSession(any())).called(1);
      expect(find.text(l10n.meSessionsRevokeSuccessMessage), findsOneWidget);
    });

    testWidgets('does not show revoke button for current device session', (
      tester,
    ) async {
      when(() => listMeSessions(any())).thenAnswer(
        (_) async => right(
          MeSessionsPageEntity(items: [currentSession], hasMore: false),
        ),
      );
      when(() => revokeMeSession(any())).thenAnswer((_) async => right(unit));

      final cubit = MeSessionsCubit(listMeSessions, revokeMeSession);
      addTearDown(cubit.close);

      await _pumpPage(tester, cubit);
      final l10n = _l10n(tester);

      expect(find.text(l10n.meSessionsStatusCurrentDevice), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton && widget.text == l10n.meSessionsRevokeCta,
        ),
        findsNothing,
      );
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, MeSessionsCubit cubit) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdaptiveScope(
        navigationPolicy: const NavigationPolicy.none(),
        child: BlocProvider<MeSessionsCubit>.value(
          value: cubit..load(),
          child: const MeSessionsPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _l10n(WidgetTester tester) {
  final context = tester.element(find.byType(MeSessionsPage));
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
