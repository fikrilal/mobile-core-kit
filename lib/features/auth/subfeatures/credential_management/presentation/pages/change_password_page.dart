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
import 'package:mobile_core_kit/core/presentation/localization/validation_error_localizer.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_state.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  StreamSubscription<ChangePasswordEffect>? _effectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectSubscription ??= context.read<ChangePasswordCubit>().effects.listen(
      _handleEffect,
    );
  }

  void _handleEffect(ChangePasswordEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case ChangePasswordSuccessEffect():
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
      case ChangePasswordFailureEffect(:final failure):
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
        title: AppText.titleMedium(context.l10n.authChangePasswordTitle),
      ),
      body: const _ChangePasswordBody(),
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
                  !state.currentPasswordTouched ||
                      state.currentPasswordError == null
                  ? null
                  : messageForValidationError(
                      state.currentPasswordError!,
                      context.l10n,
                    ),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              onChanged: context
                  .read<ChangePasswordCubit>()
                  .currentPasswordChanged,
            ),
            const SizedBox(height: AppSpacing.space16),
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
              onChanged: context.read<ChangePasswordCubit>().newPasswordChanged,
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
                  .read<ChangePasswordCubit>()
                  .confirmNewPasswordChanged,
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
}
