import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/theme/responsive/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/field/field.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.titleMedium('Create Account')),
      body: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == RegisterStatus.failure &&
              state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.space24),
                  AppTextField(
                    fieldType: FieldType.text,
                    labelText: 'First Name',
                    errorText: state.firstNameError,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    onChanged: context.read<RegisterCubit>().firstNameChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  AppTextField(
                    fieldType: FieldType.text,
                    labelText: 'Last Name',
                    errorText: state.lastNameError,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    onChanged: context.read<RegisterCubit>().lastNameChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  AppTextField(
                    fieldType: FieldType.email,
                    labelText: 'Email',
                    errorText: state.emailError,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onChanged: context.read<RegisterCubit>().emailChanged,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  AppTextField(
                    fieldType: FieldType.password,
                    labelText: 'Password',
                    errorText: state.passwordError,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onChanged: context.read<RegisterCubit>().passwordChanged,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton.primary(
                    text: 'Create Account',
                    isExpanded: true,
                    isLoading: state.isSubmitting,
                    isDisabled: !state.canSubmit,
                    semanticLabel: 'Create a new account',
                    onPressed: state.canSubmit
                        ? () => context.read<RegisterCubit>().submit()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.go(AuthRoutes.signIn),
                    child: const AppText.bodyMedium(
                      'Already have an account? Sign in',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
