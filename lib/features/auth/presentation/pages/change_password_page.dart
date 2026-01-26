import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/validation/validation_error_localizer.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/field/field.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/change_password/change_password_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authChangePasswordTitle),
      ),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == ChangePasswordStatus.success) {
            AppSnackBar.showSuccess(
              context,
              message: context.l10n.authChangePasswordSuccessTitle,
            );

            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
              return;
            }

            context.go(AppRoutes.home);
            return;
          }

          if (state.status == ChangePasswordStatus.failure &&
              state.failure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
          }
        },
        child: const _ChangePasswordBody(),
      ),
    );
  }
}

class _ChangePasswordBody extends StatelessWidget {
  const _ChangePasswordBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
            builder: (context, state) {
              return _buildForm(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ChangePasswordState state) {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.space24),
            AppTextField(
              fieldType: FieldType.password,
              labelText: context.l10n.authCurrentPassword,
              errorText:
                  !state.currentPasswordTouched || state.currentPasswordError == null
                      ? null
                      : messageForValidationError(
                          state.currentPasswordError!,
                          context.l10n,
                        ),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              onChanged: context.read<ChangePasswordCubit>().currentPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              fieldType: FieldType.password,
              labelText: context.l10n.authNewPassword,
              errorText: !state.newPasswordTouched || state.newPasswordError == null
                  ? null
                  : messageForValidationError(
                      state.newPasswordError!,
                      context.l10n,
                    ),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: context.read<ChangePasswordCubit>().newPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              fieldType: FieldType.password,
              labelText: context.l10n.authConfirmNewPassword,
              errorText: !state.confirmNewPasswordTouched ||
                      state.confirmNewPasswordError == null
                  ? null
                  : messageForValidationError(
                      state.confirmNewPasswordError!,
                      context.l10n,
                    ),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onChanged:
                  context.read<ChangePasswordCubit>().confirmNewPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              text: context.l10n.authChangePasswordCta,
              isExpanded: true,
              isLoading: state.isSubmitting,
              isDisabled: !state.canSubmit,
              semanticLabel: context.l10n.authChangePasswordCta,
              onPressed: state.canSubmit
                  ? () => context.read<ChangePasswordCubit>().submit()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Success is handled via BlocListener: show snackbar + pop route.
}
