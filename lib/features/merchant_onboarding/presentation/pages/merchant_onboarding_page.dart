import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_effect.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_onboarding_step_shell.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/owners_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/review_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/settlement_step_widget.dart';

/// Route-owned page: loads reference data on entry and renders the four-step
/// wizard driven by the feature Cubit.
class MerchantOnboardingPage extends StatefulWidget {
  const MerchantOnboardingPage({super.key});

  @override
  State<MerchantOnboardingPage> createState() => _MerchantOnboardingPageState();
}

class _MerchantOnboardingPageState extends State<MerchantOnboardingPage> {
  final _focusRequests = <String, FocusNode>{};
  StreamSubscription<MerchantOnboardingEffect>? _effectsSub;
  bool _leaveRequested = false;
  bool _submissionFailureShown = false;

  @override
  void initState() {
    super.initState();
    _effectsSub = context.read<MerchantOnboardingCubit>().effects.listen(
      _handleEffect,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MerchantOnboardingCubit>().loadReferenceData();
      }
    });
  }

  @override
  void dispose() {
    unawaited(_effectsSub?.cancel());
    for (final node in _focusRequests.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Registers (or reuses) a [FocusNode] for a field path so focus effects
  /// can target it after a failed step preflight or submit.
  FocusNode registerFocus(String path) =>
      _focusRequests.putIfAbsent(path, FocusNode.new);

  void _handleEffect(MerchantOnboardingEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case MerchantFocusFieldEffect(:final path):
        final node = _focusRequests[path];
        if (node != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) node.requestFocus();
          });
        }
      case MerchantConfirmDiscardEffect():
        unawaited(_showDiscardDialog());
      case MerchantLeaveEffect():
        _leaveRequested = true;
        // PopScope canPop flips only after a rebuild; navigate after the
        // frame so the pop is not blocked and cannot recurse.
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      case MerchantSubmittedEffect(:final applicationId):
        AppSnackBar.showSuccess(
          context,
          message: context.l10n.merchantOnboardingSubmitSuccess(
            applicationId: applicationId,
          ),
        );
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
    }
  }

  void _handleSystemBack() {
    final cubit = context.read<MerchantOnboardingCubit>();
    if (cubit.state.isSubmitting) return;
    cubit.systemBackRequested();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _leaveRequested,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleSystemBack();
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

          // Surface repository-level submission failures the user can see.
          if (state.submissionFailure != null &&
              state.submissionStatus == MerchantSubmissionStatus.failure &&
              !_submissionFailureShown) {
            _submissionFailureShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                AppSnackBar.showError(
                  context,
                  message: context.l10n.merchantOnboardingSubmitFailure,
                );
              }
            });
          } else if (state.submissionFailure == null) {
            _submissionFailureShown = false;
          }

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
            body: MerchantOnboardingStepShell(
              step: step,
              currentStep: step.index + 1,
              totalSteps: MerchantOnboardingStep.values.length,
              isSubmitting: state.isSubmitting,
              canGoBack: step != MerchantOnboardingStep.business,
              canSubmit: state.canSubmit,
              isLastStep: step == MerchantOnboardingStep.review,
              onBack: cubit.backTapped,
              onNext: cubit.nextTapped,
              child: stepWidget,
            ),
          );
        },
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
