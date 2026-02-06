import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_state.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.profileCompleteTitle),
      ),
      body: BlocListener<CompleteProfileCubit, CompleteProfileState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == CompleteProfileStatus.failure &&
              state.failure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
          }
        },
        child: const _CompleteProfileForm(),
      ),
    );
  }
}

class _CompleteProfileForm extends StatelessWidget {
  const _CompleteProfileForm();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
            builder: (context, state) {
              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space24),
                    AppText.bodyMedium(context.l10n.profileCompleteBody),
                    const SizedBox(height: AppSpacing.space24),
                    AppTextField(
                      labelText: context.l10n.commonFirstName,
                      errorText: state.givenNameError == null
                          ? null
                          : messageForValidationError(
                              state.givenNameError!,
                              context.l10n,
                            ),
                      textInputAction: TextInputAction.next,
                      onChanged: context
                          .read<CompleteProfileCubit>()
                          .givenNameChanged,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppTextField(
                      labelText: context.l10n.commonLastName,
                      errorText: state.familyNameError == null
                          ? null
                          : messageForValidationError(
                              state.familyNameError!,
                              context.l10n,
                            ),
                      textInputAction: TextInputAction.done,
                      onChanged: context
                          .read<CompleteProfileCubit>()
                          .familyNameChanged,
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    AppButton.primary(
                      text: context.l10n.commonContinue,
                      isExpanded: true,
                      isLoading: state.isSubmitting,
                      isDisabled: !state.canSubmit,
                      semanticLabel: context.l10n.commonContinue,
                      onPressed: state.canSubmit
                          ? () => context.read<CompleteProfileCubit>().submit()
                          : null,
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
