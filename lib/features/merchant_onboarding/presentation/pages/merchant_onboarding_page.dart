import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_onboarding_step_shell.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/owners_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/review_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/settlement_step_widget.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';

class MerchantOnboardingPage extends StatefulWidget {
  const MerchantOnboardingPage({super.key});

  @override
  State<MerchantOnboardingPage> createState() => _MerchantOnboardingPageState();
}

class _MerchantOnboardingPageState extends State<MerchantOnboardingPage> {
  final _focusRequests = <String, FocusNode>{};
  bool _leaveRequested = false;

  @override
  void dispose() {
    for (final node in _focusRequests.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode registerFocus(String path) =>
      _focusRequests.putIfAbsent(path, FocusNode.new);

  void _navigateBackOrHome() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _showDiscardDialog() async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.merchantOnboardingDiscardTitle,
      message: l10n.merchantOnboardingDiscardMessage,
      confirmLabel: l10n.commonOk,
      cancelLabel: l10n.commonCancel,
    );

    if (confirmed == true && mounted) {
      context.read<MerchantOnboardingCubit>().discardConfirmed();
      _leaveRequested = true;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateBackOrHome();
      });
    }
  }

  void _handleLeaveOrDiscard(MerchantOnboardingState state) {
    if (state.isMateriallyEdited &&
        state.submissionStatus != MerchantSubmissionStatus.success) {
      unawaited(_showDiscardDialog());
    } else {
      _leaveRequested = true;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateBackOrHome();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _leaveRequested,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          final cubit = context.read<MerchantOnboardingCubit>();
          final state = cubit.state;
          if (state.isSubmitting) return;
          if (state.step != MerchantOnboardingStep.business) {
            cubit.backTapped();
            return;
          }
          _handleLeaveOrDiscard(state);
        }
      },
      child: BlocListener<MerchantOnboardingCubit, MerchantOnboardingState>(
        listenWhen: (previous, current) {
          final submitFailed =
              current.submissionStatus == MerchantSubmissionStatus.failure &&
              previous.submissionStatus != MerchantSubmissionStatus.failure &&
              current.submissionFailure != null;
          final submitSucceeded =
              current.submissionStatus == MerchantSubmissionStatus.success &&
              previous.submissionStatus != MerchantSubmissionStatus.success;
          final focusChanged =
              previous.localFailures != current.localFailures &&
              current.localFailures.isNotEmpty;
          return submitFailed || submitSucceeded || focusChanged;
        },
        listener: (context, state) {
          if (state.submissionStatus == MerchantSubmissionStatus.failure &&
              state.submissionFailure != null) {
            AppSnackBar.showError(
              context,
              message: context.l10n.merchantOnboardingSubmitFailure,
            );
          }

          if (state.submissionStatus == MerchantSubmissionStatus.success) {
            final applicationId = state.submittedApplicationId;
            if (applicationId != null) {
              AppSnackBar.showSuccess(
                context,
                message: context.l10n.merchantOnboardingSubmitSuccess(
                  applicationId: applicationId,
                ),
              );
            }
            _leaveRequested = true;
            setState(() {});
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _navigateBackOrHome();
            });
          }

          if (state.localFailures.isNotEmpty) {
            final first = state.localFailures.firstOrNull;
            if (first != null) {
              final path = first.path ?? first.code;
              final node = _focusRequests[path];
              if (node != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) node.requestFocus();
                });
              }
            }
          }
        },
        child: BlocBuilder<MerchantOnboardingCubit, MerchantOnboardingState>(
          builder: (context, state) {
            final cubit = context.read<MerchantOnboardingCubit>();

            if (state.referenceStatus != MerchantReferenceStatus.ready) {
              return _buildReferenceGate(state, cubit);
            }

            final reference = state.referenceData!;
            final step = state.step;
            final failures = state.localFailures;
            final l10n = context.l10n;
            final totalSteps = MerchantOnboardingStep.values.length;
            final currentStep = step.index + 1;

            final Widget stepWidget = switch (step) {
              MerchantOnboardingStep.business => BusinessStepWidget(
                input: state.input.business,
                reference: reference,
                cubit: cubit,
                failures: failures,
                registerFocus: registerFocus,
              ),
              MerchantOnboardingStep.owners => OwnersStepWidget(
                owners: state.input.owners,
                reference: reference,
                cubit: cubit,
                failures: failures,
                registerFocus: registerFocus,
              ),
              MerchantOnboardingStep.settlement => SettlementStepWidget(
                input: state.input.settlement,
                owners: state.input.owners,
                reference: reference,
                cubit: cubit,
                failures: failures,
                registerFocus: registerFocus,
              ),
              MerchantOnboardingStep.review => ReviewStepWidget(
                input: state.input,
                reference: reference,
                cubit: cubit,
                failures: failures,
                registerFocus: registerFocus,
              ),
            };

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.merchantOnboardingTitle),
                leading: IconButton(
                  icon: Icon(
                    step == MerchantOnboardingStep.business
                        ? Icons.close_rounded
                        : Icons.arrow_back_rounded,
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          if (step == MerchantOnboardingStep.business) {
                            _handleLeaveOrDiscard(state);
                          } else {
                            cubit.backTapped();
                          }
                        },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: currentStep / totalSteps,
                    minHeight: 3,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              body: MerchantOnboardingStepShell(
                step: step,
                currentStep: currentStep,
                totalSteps: totalSteps,
                isSubmitting: state.isSubmitting,
                canGoBack: step != MerchantOnboardingStep.business,
                canSubmit: state.canSubmit,
                isLastStep: step == MerchantOnboardingStep.review,
                onBack: cubit.backTapped,
                onNext: cubit.nextTapped,
                child: AnimatedSwitcher(
                  duration: MotionDurations.medium,
                  child: KeyedSubtree(key: ValueKey(step), child: stepWidget),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReferenceGate(
    MerchantOnboardingState state,
    MerchantOnboardingCubit cubit,
  ) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.merchantOnboardingTitle)),
      body: Center(
        child: switch (state.referenceStatus) {
          MerchantReferenceStatus.loading => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.space16),
              Text(l10n.merchantOnboardingLoadingReference),
            ],
          ),
          MerchantReferenceStatus.failure => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.merchantOnboardingReferenceFailure),
              const SizedBox(height: AppSpacing.space16),
              OutlinedButton(
                onPressed: cubit.loadReferenceData,
                child: Text(l10n.merchantOnboardingActionRetry),
              ),
            ],
          ),
          MerchantReferenceStatus.ready => const SizedBox.shrink(),
        },
      ),
    );
  }
}
