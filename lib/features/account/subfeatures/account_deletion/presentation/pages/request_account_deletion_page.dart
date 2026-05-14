import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/foundation/utilities/date_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/localization/account_deletion_failure_localizer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RequestAccountDeletionPage extends StatefulWidget {
  const RequestAccountDeletionPage({super.key, required this.userContext});

  final UserContextService userContext;

  @override
  State<RequestAccountDeletionPage> createState() =>
      _RequestAccountDeletionPageState();
}

class _RequestAccountDeletionPageState
    extends State<RequestAccountDeletionPage> {
  StreamSubscription<RequestAccountDeletionEffect>? _effectSubscription;
  RequestAccountDeletionCubit? _effectCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<RequestAccountDeletionCubit>();
    if (identical(_effectCubit, cubit)) return;

    _effectSubscription?.cancel();
    _effectCubit = cubit;
    _effectSubscription = cubit.effects.listen(_onEffect);
  }

  @override
  void dispose() {
    _effectSubscription?.cancel();
    super.dispose();
  }

  void _onEffect(RequestAccountDeletionEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case ShowRequestAccountDeletionFailure(:final failure):
        AppSnackBar.showError(
          context,
          message: messageForAccountDeletionFailure(failure, context.l10n),
        );
      case ShowAccountDeletionRequested():
        AppSnackBar.showSuccess(
          context,
          message: context.l10n.accountDeletionRequestSuccessMessage,
        );
      case ShowAccountDeletionCanceled():
        AppSnackBar.showSuccess(
          context,
          message: context.l10n.accountDeletionCancelSuccessMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.profileDeleteAccountTitle),
      ),
      body: SafeArea(
        top: false,
        child: AppPageContainer(
          surface: SurfaceKind.form,
          safeArea: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
            child: ValueListenableBuilder<CurrentUserState>(
              valueListenable: widget.userContext.stateListenable,
              builder: (context, userState, _) {
                final cubitState = context
                    .watch<RequestAccountDeletionCubit>()
                    .state;
                final accountDeletion = userState.user?.accountDeletion;
                final scheduledDate = AppDateUtils.tryFormatLongDateFromIso(
                  accountDeletion?.scheduledFor,
                  locale: Localizations.localeOf(context).toLanguageTag(),
                );
                final isScheduled = accountDeletion != null;
                final isSubmitting = cubitState.isSubmitting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space24),
                    AppText.bodyMedium(context.l10n.accountDeletionRequestBody),
                    const SizedBox(height: AppSpacing.space16),
                    AppText.bodyMedium(
                      context.l10n.accountDeletionRequestWarning,
                    ),
                    if (isScheduled) ...[
                      const SizedBox(height: AppSpacing.space16),
                      AppText.bodyMedium(
                        scheduledDate == null
                            ? context.l10n.accountDeletionScheduledBody
                            : context.l10n.accountDeletionScheduledBodyWithDate(
                                date: scheduledDate,
                              ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.space24),
                    if (isScheduled)
                      AppButton.outline(
                        text: context.l10n.accountDeletionCancelCta,
                        isExpanded: true,
                        isLoading: isSubmitting,
                        isDisabled: isSubmitting,
                        loadingText:
                            context.l10n.accountDeletionCancelSubmitting,
                        semanticLabel: context.l10n.accountDeletionCancelCta,
                        onPressed: isSubmitting
                            ? null
                            : () => _confirmAndCancel(context),
                      )
                    else
                      AppButton.danger(
                        text: context.l10n.accountDeletionRequestCta,
                        isExpanded: true,
                        isLoading: isSubmitting,
                        isDisabled: isSubmitting,
                        loadingText:
                            context.l10n.accountDeletionRequestSubmitting,
                        semanticLabel: context.l10n.accountDeletionRequestCta,
                        onPressed: isSubmitting
                            ? null
                            : () => _confirmAndSubmit(context),
                      ),
                    const SizedBox(height: AppSpacing.space8),
                    AppButton.outline(
                      text: context.l10n.commonCancel,
                      isExpanded: true,
                      isDisabled: isSubmitting,
                      onPressed: isSubmitting ? null : () => context.pop(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndSubmit(BuildContext context) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.accountDeletionConfirmTitle,
      message: context.l10n.accountDeletionConfirmBody,
      confirmLabel: context.l10n.accountDeletionConfirmCta,
      cancelLabel: context.l10n.commonCancel,
      variant: AppConfirmationDialogVariant.featured,
      icon: Icon(
        PhosphorIconsBold.warningCircle,
        semanticLabel: context.l10n.accountDeletionConfirmTitle,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<RequestAccountDeletionCubit>().request(
      idempotencyKey: IdempotencyKeyUtils.generate(),
    );
  }

  Future<void> _confirmAndCancel(BuildContext context) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.accountDeletionCancelConfirmTitle,
      message: context.l10n.accountDeletionCancelConfirmBody,
      confirmLabel: context.l10n.accountDeletionCancelConfirmCta,
      cancelLabel: context.l10n.commonCancel,
      variant: AppConfirmationDialogVariant.featured,
      icon: Icon(
        PhosphorIconsBold.arrowCounterClockwise,
        semanticLabel: context.l10n.accountDeletionCancelConfirmTitle,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<RequestAccountDeletionCubit>().cancel(
      idempotencyKey: IdempotencyKeyUtils.generate(),
    );
  }
}
