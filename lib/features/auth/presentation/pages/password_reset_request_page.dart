import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/localization/validation_error_localizer.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/field/field.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class PasswordResetRequestPage extends StatelessWidget {
  const PasswordResetRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authPasswordResetRequestTitle),
      ),
      body: BlocListener<PasswordResetRequestCubit, PasswordResetRequestState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == PasswordResetRequestStatus.success) {
            AppSnackBar.showSuccess(
              context,
              message: context.l10n.authPasswordResetRequestSuccessTitle,
            );

            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
              return;
            }

            context.go(AuthRoutes.signIn);
            return;
          }

          if (state.status == PasswordResetRequestStatus.failure &&
              state.failure != null) {
            final shouldShowSnackBar = state.failure!.maybeWhen(
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
        child: const _PasswordResetRequestBody(),
      ),
    );
  }
}

class _PasswordResetRequestBody extends StatelessWidget {
  const _PasswordResetRequestBody();

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
              BlocBuilder<PasswordResetRequestCubit, PasswordResetRequestState>(
                builder: (context, state) => _buildForm(context, state),
              ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PasswordResetRequestState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText.bodyMedium(
          context.l10n.authPasswordResetRequestBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space24),
        AppTextField(
          fieldType: FieldType.email,
          labelText: context.l10n.commonEmail,
          errorText: !state.emailTouched || state.emailError == null
              ? null
              : messageForValidationError(state.emailError!, context.l10n),
          textInputAction: TextInputAction.done,
          onChanged: context.read<PasswordResetRequestCubit>().emailChanged,
        ),
        const SizedBox(height: AppSpacing.space24),
        AppButton.primary(
          text: context.l10n.authPasswordResetRequestCta,
          isExpanded: true,
          isLoading: state.isSubmitting,
          isDisabled: !state.canSubmit,
          semanticLabel: context.l10n.authPasswordResetRequestCta,
          onPressed: state.canSubmit
              ? () => context.read<PasswordResetRequestCubit>().submit()
              : null,
        ),
        const SizedBox(height: AppSpacing.space12),
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.go(AuthRoutes.signIn),
          child: AppText.bodyMedium(
            context.l10n.authSignIn,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
