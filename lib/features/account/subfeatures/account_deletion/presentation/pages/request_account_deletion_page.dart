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
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_state.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/localization/account_deletion_failure_localizer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RequestAccountDeletionPage extends StatelessWidget {
  const RequestAccountDeletionPage({super.key, required this.userContext});

  final UserContextService userContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.profileDeleteAccountTitle),
      ),
      body:
          BlocListener<
            RequestAccountDeletionCubit,
            RequestAccountDeletionState
          >(
            listenWhen: (previous, current) {
              final failed =
                  current.status == RequestAccountDeletionStatus.failure &&
                  current.failure != null &&
                  (previous.status != RequestAccountDeletionStatus.failure ||
                      previous.failure != current.failure);
              final succeeded =
                  previous.status != RequestAccountDeletionStatus.success &&
                  current.status == RequestAccountDeletionStatus.success;
              return failed || succeeded;
            },
            listener: (context, state) {
              if (state.status == RequestAccountDeletionStatus.failure &&
                  state.failure != null) {
                AppSnackBar.showError(
                  context,
                  message: messageForAccountDeletionFailure(
                    state.failure!,
                    context.l10n,
                  ),
                );
              } else if (state.status == RequestAccountDeletionStatus.success) {
                final message = switch (state.action) {
                  AccountDeletionAction.cancel =>
                    context.l10n.accountDeletionCancelSuccessMessage,
                  AccountDeletionAction.request ||
                  null => context.l10n.accountDeletionRequestSuccessMessage,
                };
                AppSnackBar.showSuccess(context, message: message);
              }
            },
            child: SafeArea(
              top: false,
              child: AppPageContainer(
                surface: SurfaceKind.form,
                safeArea: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space16,
                  ),
                  child: ValueListenableBuilder<CurrentUserState>(
                    valueListenable: userContext.stateListenable,
                    builder: (context, userState, _) {
                      return BlocBuilder<
                        RequestAccountDeletionCubit,
                        RequestAccountDeletionState
                      >(
                        builder: (context, cubitState) {
                          final accountDeletion =
                              userState.user?.accountDeletion;
                          final scheduledDate =
                              AppDateUtils.tryFormatLongDateFromIso(
                                accountDeletion?.scheduledFor,
                                locale: Localizations.localeOf(
                                  context,
                                ).toLanguageTag(),
                              );
                          final isScheduled = accountDeletion != null;
                          final isSubmitting = cubitState.isSubmitting;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppSpacing.space24),
                              AppText.bodyMedium(
                                context.l10n.accountDeletionRequestBody,
                              ),
                              const SizedBox(height: AppSpacing.space16),
                              AppText.bodyMedium(
                                context.l10n.accountDeletionRequestWarning,
                              ),
                              if (isScheduled) ...[
                                const SizedBox(height: AppSpacing.space16),
                                AppText.bodyMedium(
                                  scheduledDate == null
                                      ? context
                                            .l10n
                                            .accountDeletionScheduledBody
                                      : context.l10n
                                            .accountDeletionScheduledBodyWithDate(
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
                                  loadingText: context
                                      .l10n
                                      .accountDeletionCancelSubmitting,
                                  semanticLabel:
                                      context.l10n.accountDeletionCancelCta,
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
                                  loadingText: context
                                      .l10n
                                      .accountDeletionRequestSubmitting,
                                  semanticLabel:
                                      context.l10n.accountDeletionRequestCta,
                                  onPressed: isSubmitting
                                      ? null
                                      : () => _confirmAndSubmit(context),
                                ),
                              const SizedBox(height: AppSpacing.space8),
                              AppButton.outline(
                                text: context.l10n.commonCancel,
                                isExpanded: true,
                                isDisabled: isSubmitting,
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.pop(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
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

    await context.read<RequestAccountDeletionCubit>().request();
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

    await context.read<RequestAccountDeletionCubit>().cancel();
  }
}
