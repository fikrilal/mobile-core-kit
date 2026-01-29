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
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class PasswordResetConfirmPage extends StatelessWidget {
  const PasswordResetConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authPasswordResetConfirmTitle),
      ),
      body: BlocListener<PasswordResetConfirmCubit, PasswordResetConfirmState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == PasswordResetConfirmStatus.failure &&
              state.failure != null) {
            final AuthFailure failure = state.failure!;
            final shouldShowSnackBar = failure.maybeWhen(
              validation: (_) => false,
              orElse: () => true,
            );

            if (shouldShowSnackBar) {
              AppSnackBar.showError(
                context,
                message: messageForAuthFailure(state.failure!, context.l10n),
              );
            }
          }
        },
        child: const _PasswordResetConfirmBody(),
      ),
    );
  }
}

class _PasswordResetConfirmBody extends StatelessWidget {
  const _PasswordResetConfirmBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child:
              BlocBuilder<PasswordResetConfirmCubit, PasswordResetConfirmState>(
                builder: (context, state) {
                  final hasTokenInputError =
                      state.status == PasswordResetConfirmStatus.initial &&
                      state.tokenError != null;

                  if (state.status == PasswordResetConfirmStatus.submitting) {
                    return _buildSubmitting(context);
                  }

                  if (state.status == PasswordResetConfirmStatus.success) {
                    return _buildSuccess(context);
                  }

                  if (state.tokenError != null &&
                      (state.status == PasswordResetConfirmStatus.failure ||
                          hasTokenInputError)) {
                    return _buildTokenFailure(context, state);
                  }

                  return _buildForm(context, state);
                },
              ),
        ),
      ),
    );
  }

  Widget _buildSubmitting(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppSpacing.space24),
        AppText.bodyMedium(
          context.l10n.authPasswordResetConfirmSubmittingBody,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(
          context.l10n.authPasswordResetConfirmSuccessTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodyMedium(
          context.l10n.authPasswordResetConfirmSuccessBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space24),
        AppButton.primary(
          text: context.l10n.commonContinue,
          isExpanded: true,
          semanticLabel: context.l10n.commonContinue,
          onPressed: () => context.go(AppRoutes.root),
        ),
      ],
    );
  }

  Widget _buildTokenFailure(
    BuildContext context,
    PasswordResetConfirmState state,
  ) {
    final message = state.tokenError == null
        ? context.l10n.authPasswordResetConfirmFailureBody
        : messageForValidationError(state.tokenError!, context.l10n);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(
          context.l10n.authPasswordResetConfirmFailureTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodyMedium(message, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.space24),
        AppButton.primary(
          text: context.l10n.authPasswordResetRequestCta,
          isExpanded: true,
          semanticLabel: context.l10n.authPasswordResetRequestCta,
          onPressed: () => context.go(AuthRoutes.passwordResetRequest),
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.outline(
          text: context.l10n.authSignIn,
          isExpanded: true,
          semanticLabel: context.l10n.authSignIn,
          onPressed: () => context.go(AuthRoutes.signIn),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, PasswordResetConfirmState state) {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.bodyMedium(
              context.l10n.authPasswordResetConfirmBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppTextField(
              fieldType: FieldType.password,
              labelText: context.l10n.authNewPassword,
              errorText:
                  !state.newPasswordTouched || state.newPasswordError == null
                  ? null
                  : messageForValidationError(
                      state.newPasswordError!,
                      context.l10n,
                    ),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: context
                  .read<PasswordResetConfirmCubit>()
                  .newPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              fieldType: FieldType.password,
              labelText: context.l10n.authConfirmNewPassword,
              errorText:
                  !state.confirmNewPasswordTouched ||
                      state.confirmNewPasswordError == null
                  ? null
                  : messageForValidationError(
                      state.confirmNewPasswordError!,
                      context.l10n,
                    ),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: context
                  .read<PasswordResetConfirmCubit>()
                  .confirmNewPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton.primary(
              text: context.l10n.authPasswordResetConfirmCta,
              isExpanded: true,
              isLoading: state.isSubmitting,
              isDisabled: !state.canSubmit,
              semanticLabel: context.l10n.authPasswordResetConfirmCta,
              onPressed: state.canSubmit
                  ? () => context.read<PasswordResetConfirmCubit>().submit()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
