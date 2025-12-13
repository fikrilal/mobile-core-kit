import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/snackbar.dart';

import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == LoginStatus.failure &&
              state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
          }

          if (state.status == LoginStatus.success) {
            // TODO: Navigate to main shell route, e.g. context.go('/main');
          }
        },
        child: const _SignInForm(),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: state.emailError,
                ),
                onChanged: context.read<LoginCubit>().emailChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: state.passwordError,
                ),
                onChanged: context.read<LoginCubit>().passwordChanged,
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'Sign In',
                isExpanded: true,
                isLoading: state.isSubmitting,
                isDisabled: !state.canSubmit,
                semanticLabel: 'Sign in to your account',
                onPressed: state.canSubmit
                    ? () => context.read<LoginCubit>().submit()
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
