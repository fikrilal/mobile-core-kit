import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/async_state/async_state.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/design_system/widgets/state_message/state_message.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_state.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.canResendVerificationEmail});

  final bool canResendVerificationEmail;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  StreamSubscription<EmailVerificationEffect>? _effectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectSubscription ??= context
        .read<EmailVerificationCubit>()
        .effects
        .listen(_handleEffect);
  }

  void _handleEffect(EmailVerificationEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case EmailVerificationFailureEffect(:final failure):
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
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.authVerifyEmailTitle),
      ),
      body: _VerifyEmailBody(
        canResendVerificationEmail: widget.canResendVerificationEmail,
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
              return AppAsyncStateView<EmailVerificationState>(
                status: _mapStatusToViewState(state),
                failure: state,
                successBuilder: (_) => _buildSuccess(context, state),
                loadingBuilder: (_) => _buildSubmitting(context, state),
                failureBuilder: (context, failedState) =>
                    _buildFailure(context, failedState ?? state),
              );
            },
          ),
        ),
      ),
    );
  }

  AppAsyncStatus _mapStatusToViewState(EmailVerificationState state) {
    final hasTokenInputError =
        state.status == EmailVerificationStatus.initial &&
        state.tokenError != null;

    if (hasTokenInputError) {
      return AppAsyncStatus.failure;
    }

    return switch (state.status) {
      EmailVerificationStatus.initial => AppAsyncStatus.initial,
      EmailVerificationStatus.submitting => AppAsyncStatus.loading,
      EmailVerificationStatus.success => AppAsyncStatus.success,
      EmailVerificationStatus.failure => AppAsyncStatus.failure,
    };
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

    return AppStateMessagePanel(
      title: title,
      description: body,
      actions: [
        AppButton.primary(
          text: context.l10n.commonContinue,
          isExpanded: true,
          semanticLabel: context.l10n.commonContinue,
          onPressed: () => context.go(AppRoutes.root),
        ),
      ],
    );
  }

  List<Widget> _buildFailureActions(
    BuildContext context,
    EmailVerificationState state,
  ) {
    if (canResendVerificationEmail) {
      return [
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
        ),
      ];
    }

    return [
      AppButton.primary(
        text: context.l10n.authVerifyEmailSignInCta,
        isExpanded: true,
        semanticLabel: context.l10n.authVerifyEmailSignInCta,
        onPressed: () => context.go(AuthRoutes.signIn),
      ),
    ];
  }

  Widget _buildFailure(BuildContext context, EmailVerificationState state) {
    return AppStateMessagePanel(
      title: context.l10n.authVerifyEmailFailureTitle,
      description: context.l10n.authVerifyEmailFailureBody,
      actions: _buildFailureActions(context, state),
    );
  }
}
