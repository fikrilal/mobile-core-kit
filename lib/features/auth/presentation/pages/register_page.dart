import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/design_system/localization/l10n.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_state.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authCreateAccount),
      ),
      body: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == RegisterStatus.failure && state.failure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
          }
        },
        child: const _RegisterForm(),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space24),
                    AppTextField(
                      fieldType: FieldType.email,
                      labelText: context.l10n.commonEmail,
                      errorText: state.emailError == null
                          ? null
                          : messageForAuthFieldError(
                              state.emailError!,
                              context.l10n,
                            ),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onChanged: context.read<RegisterCubit>().emailChanged,
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: context.read<RegisterCubit>().passwordChanged,
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    AppButton.primary(
                      text: context.l10n.authCreateAccount,
                      isExpanded: true,
                      isLoading: state.isSubmitting,
                      isDisabled: !state.canSubmit,
                      semanticLabel: context.l10n.authSemanticCreateAccount,
                      onPressed: state.canSubmit
                          ? () => context.read<RegisterCubit>().submit()
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.go(AuthRoutes.signIn),
                      child: AppText.bodyMedium(
                        context.l10n.authHaveAccountCta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
