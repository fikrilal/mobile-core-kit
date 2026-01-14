import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/field/field.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.titleMedium('Sign In')),
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == LoginStatus.failure &&
              state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
          }
        },
        child: const _SignInForm(),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTextField(
                    fieldType: FieldType.email,
                    labelText: 'Email',
                    errorText: state.emailError,
                    onChanged: context.read<LoginCubit>().emailChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  AppTextField(
                    fieldType: FieldType.password,
                    labelText: 'Password',
                    errorText: state.passwordError,
                    onChanged: context.read<LoginCubit>().passwordChanged,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    text: 'Sign In',
                    isExpanded: true,
                    isLoading: state.isSubmittingEmailPassword,
                    isDisabled: !state.canSubmit,
                    semanticLabel: 'Sign in to your account',
                    onPressed: state.canSubmit
                        ? () => context.read<LoginCubit>().submit()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  AppButton.outline(
                    text: 'Continue with Google',
                    isExpanded: true,
                    isLoading: state.isSubmittingGoogle,
                    isDisabled: state.isSubmitting,
                    semanticLabel: 'Continue with Google',
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<LoginCubit>().signInWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.go(AuthRoutes.register),
                    child: const AppText.bodyMedium(
                      'Don’t have an account? Create one',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
