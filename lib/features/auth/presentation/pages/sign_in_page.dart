import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/field/field.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';
import '../localization/auth_failure_localizer.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppText.titleMedium(context.l10n.authSignIn)),
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == LoginStatus.failure && state.failure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
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
                    labelText: context.l10n.commonEmail,
                    errorText: state.emailError == null
                        ? null
                        : messageForAuthFieldError(
                            state.emailError!,
                            context.l10n,
                          ),
                    onChanged: context.read<LoginCubit>().emailChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  AppTextField(
                    fieldType: FieldType.password,
                    labelText: context.l10n.commonPassword,
                    errorText: state.passwordError == null
                        ? null
                        : messageForAuthFieldError(
                            state.passwordError!,
                            context.l10n,
                          ),
                    onChanged: context.read<LoginCubit>().passwordChanged,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    text: context.l10n.authSignIn,
                    isExpanded: true,
                    isLoading: state.isSubmittingEmailPassword,
                    isDisabled: !state.canSubmit,
                    semanticLabel: context.l10n.authSemanticSignIn,
                    onPressed: state.canSubmit
                        ? () => context.read<LoginCubit>().submit()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  AppButton.outline(
                    text: context.l10n.authContinueWithGoogle,
                    isExpanded: true,
                    isLoading: state.isSubmittingGoogle,
                    isDisabled: state.isSubmitting,
                    semanticLabel: context.l10n.authContinueWithGoogle,
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<LoginCubit>().signInWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.go(AuthRoutes.register),
                    child: AppText.bodyMedium(
                      context.l10n.authNoAccountCta,
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
