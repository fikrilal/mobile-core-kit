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
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/presentation/localization/validation_error_localizer.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_state.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  State<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  StreamSubscription<PasswordResetRequestEffect>? _effectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectSubscription ??= context
        .read<PasswordResetRequestCubit>()
        .effects
        .listen(_handleEffect);
  }

  void _handleEffect(PasswordResetRequestEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case PasswordResetRequestSuccessEffect():
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
      case PasswordResetRequestFailureEffect(:final failure):
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
        title: AppText.titleMedium(context.l10n.authPasswordResetRequestTitle),
      ),
      body: const _PasswordResetRequestBody(),
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
                builder: (context, state) {
                  return AppAsyncStateView<PasswordResetRequestState>(
                    status: _mapStatusToViewState(state),
                    failure: state,
                    treatInitialAsLoading: false,
                    initialBuilder: (_) => _buildForm(context, state),
                    loadingBuilder: (_) => _buildForm(context, state),
                    successBuilder: (_) => _buildForm(context, state),
                    emptyBuilder: (_) => _buildForm(context, state),
                    failureBuilder: (context, failedState) =>
                        _buildForm(context, failedState ?? state),
                  );
                },
              ),
        ),
      ),
    );
  }

  AppAsyncStatus _mapStatusToViewState(PasswordResetRequestState state) {
    return switch (state.status) {
      PasswordResetRequestStatus.initial => AppAsyncStatus.initial,
      PasswordResetRequestStatus.submitting => AppAsyncStatus.loading,
      PasswordResetRequestStatus.success => AppAsyncStatus.success,
      PasswordResetRequestStatus.failure => AppAsyncStatus.failure,
    };
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
