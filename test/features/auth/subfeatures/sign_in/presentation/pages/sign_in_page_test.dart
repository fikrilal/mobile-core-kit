import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_state.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/pages/sign_in_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

Widget _wrap(LoginCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
    home: AdaptiveScope(
      navigationPolicy: const NavigationPolicy.none(),
      child: BlocProvider<LoginCubit>.value(
        value: cubit,
        child: const SignInPage(),
      ),
    ),
  );
}

void main() {
  late _MockLoginCubit cubit;

  setUp(() {
    cubit = _MockLoginCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('renders sign in form with inputs and action buttons', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(LoginState.initial());

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('shows snackbar when login fails with AuthFailure', (
    tester,
  ) async {
    whenListen(
      cubit,
      Stream.fromIterable([
        LoginState.initial().copyWith(
          status: LoginStatus.submitting,
          submittingMethod: LoginSubmitMethod.emailPassword,
        ),
        LoginState.initial().copyWith(
          status: LoginStatus.failure,
          failure: const AuthFailure.invalidCredentials(),
        ),
      ]),
      initialState: LoginState.initial(),
    );

    await tester.pumpWidget(_wrap(cubit));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets(
    'does not show duplicate snackbar if state failure is unchanged',
    (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([
          LoginState.initial().copyWith(
            status: LoginStatus.failure,
            failure: const AuthFailure.invalidCredentials(),
          ),
          // Re-emitting failure state with identical failure
          LoginState.initial().copyWith(
            status: LoginStatus.failure,
            failure: const AuthFailure.invalidCredentials(),
          ),
        ]),
        initialState: LoginState.initial(),
      );

      await tester.pumpWidget(_wrap(cubit));
      await tester.pump();
      await tester.pumpAndSettle();

      // Should only have displayed one snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
