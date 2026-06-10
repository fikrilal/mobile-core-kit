import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/presentation/localization/validation_error_localizer.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_state.dart';

class ProfileForm<C extends ProfileFormCubit> extends StatefulWidget {
  const ProfileForm({
    required this.submitText,
    this.submitSemanticIdentifier,
    this.body,
    super.key,
  });

  final String submitText;
  final String? submitSemanticIdentifier;
  final Widget? body;

  @override
  State<ProfileForm<C>> createState() => _ProfileFormState<C>();
}

class _ProfileFormState<C extends ProfileFormCubit>
    extends State<ProfileForm<C>> {
  late final TextEditingController _givenNameController;
  late final TextEditingController _familyNameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<C>().state;
    _givenNameController = TextEditingController(text: state.givenName);
    _familyNameController = TextEditingController(text: state.familyName);
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppPageContainer(
        surface: SurfaceKind.form,
        safeArea: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          child: BlocBuilder<C, ProfileFormState>(
            builder: (context, state) {
              final cubit = context.read<C>();
              _syncController(_givenNameController, state.givenName);
              _syncController(_familyNameController, state.familyName);

              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space24),
                    if (widget.body case final body?) ...[
                      body,
                      const SizedBox(height: AppSpacing.space24),
                    ],
                    AppTextField(
                      controller: _givenNameController,
                      labelText: context.l10n.commonFirstName,
                      semanticIdentifier: 'profile_given_name',
                      errorText: state.givenNameError == null
                          ? null
                          : messageForValidationError(
                              state.givenNameError!,
                              context.l10n,
                            ),
                      textInputAction: TextInputAction.next,
                      onChanged: cubit.givenNameChanged,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppTextField(
                      controller: _familyNameController,
                      labelText: context.l10n.commonLastName,
                      semanticIdentifier: 'profile_family_name',
                      errorText: state.familyNameError == null
                          ? null
                          : messageForValidationError(
                              state.familyNameError!,
                              context.l10n,
                            ),
                      textInputAction: TextInputAction.done,
                      onChanged: cubit.familyNameChanged,
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    AppButton.primary(
                      text: widget.submitText,
                      isExpanded: true,
                      isLoading: state.isSubmitting,
                      isDisabled: !state.canSubmit,
                      semanticLabel: widget.submitText,
                      semanticIdentifier: widget.submitSemanticIdentifier,
                      onPressed: state.canSubmit ? cubit.submit : null,
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

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}
