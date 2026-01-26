import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key, required this.canResendVerificationEmail});

  final bool canResendVerificationEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authVerifyEmailTitle),
      ),
      body: BlocListener<EmailVerificationCubit, EmailVerificationState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == EmailVerificationStatus.failure &&
              state.failure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
          }
        },
        child: _VerifyEmailBody(
          canResendVerificationEmail: canResendVerificationEmail,
        ),
      ),
    );
  }
}

class _VerifyEmailBody extends StatelessWidget {
  const _VerifyEmailBody({required this.canResendVerificationEmail});

  final bool canResendVerificationEmail;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<EmailVerificationCubit, EmailVerificationState>(
            builder: (context, state) {
              final hasTokenInputError =
                  state.status == EmailVerificationStatus.initial &&
                  state.tokenError != null;

              if (state.status == EmailVerificationStatus.submitting) {
                return _buildSubmitting(context, state);
              }

              if (state.status == EmailVerificationStatus.success) {
                return _buildSuccess(context, state);
              }

              if (state.status == EmailVerificationStatus.failure ||
                  hasTokenInputError) {
                return _buildFailure(context, state);
              }

              // Idle state: usually transient (before verification kicks off).
              return _buildSubmitting(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitting(BuildContext context, EmailVerificationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppSpacing.space24),
        AppText.bodyMedium(
          context.l10n.authVerifyEmailVerifyingBody,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context, EmailVerificationState state) {
    final (title, body) = switch (state.lastAction) {
      EmailVerificationAction.resend => (
        context.l10n.authVerifyEmailResentTitle,
        context.l10n.authVerifyEmailResentBody,
      ),
      _ => (
        context.l10n.authVerifyEmailSuccessTitle,
        context.l10n.authVerifyEmailSuccessBody,
      ),
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(title, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodyMedium(body, textAlign: TextAlign.center),
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

  Widget _buildFailure(BuildContext context, EmailVerificationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(
          context.l10n.authVerifyEmailFailureTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodyMedium(
          context.l10n.authVerifyEmailFailureBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space24),
        if (canResendVerificationEmail)
          AppButton.primary(
            text: context.l10n.authVerifyEmailResendCta,
            isExpanded: true,
            isLoading: state.isResending,
            isDisabled: state.isSubmitting,
            semanticLabel: context.l10n.authVerifyEmailResendCta,
            onPressed: state.isSubmitting
                ? null
                : () => context
                      .read<EmailVerificationCubit>()
                      .resendVerificationEmail(),
          )
        else
          AppButton.primary(
            text: context.l10n.authVerifyEmailSignInCta,
            isExpanded: true,
            semanticLabel: context.l10n.authVerifyEmailSignInCta,
            onPressed: () => context.go(AuthRoutes.signIn),
          ),
      ],
    );
  }
}
