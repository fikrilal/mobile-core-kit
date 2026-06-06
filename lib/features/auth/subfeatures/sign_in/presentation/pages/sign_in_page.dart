import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_state.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  StreamSubscription<LoginEffect>? _effectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectSubscription ??= context.read<LoginCubit>().effects.listen(
      _handleEffect,
    );
  }

  void _handleEffect(LoginEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case LoginFailureEffect(:final failure):
        AppSnackBar.showError(
          context,
          message: messageForAuthFailure(failure, context.l10n),
        );
    }
  }

  @override
  void dispose() {
    unawaited(_effectSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppText.titleMedium(context.l10n.authSignIn)),
      body: const _SignInForm(),
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
                  const SizedBox(height: AppSpacing.space8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.go(AuthRoutes.passwordResetRequest),
                      child: AppText.bodyMedium(
                        context.l10n.authForgotPasswordCta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    text: context.l10n.authSignIn,
                    isExpanded: true,
                    isLoading: state.isSubmittingEmailPassword,
                    isDisabled: !state.canSubmit,
                    semanticLabel: context.l10n.authSemanticSignIn,
                    semanticIdentifier: 'auth_sign_in_submit',
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
