import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/collection/app_paginated_collection_view.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_state.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/widgets/me_session_card.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/widgets/skeleton/me_sessions_skeleton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MeSessionsPage extends StatelessWidget {
  const MeSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.profileActiveSessionsTitle),
      ),
      body: BlocListener<MeSessionsCubit, MeSessionsState>(
        listenWhen: (prev, curr) =>
            prev.revokeStatus != curr.revokeStatus ||
            prev.failure != curr.failure,
        listener: (context, state) {
          final cubit = context.read<MeSessionsCubit>();

          if (state.failure != null &&
              state.status != MeSessionsStatus.failure) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(state.failure!, context.l10n),
            );
            cubit.clearFailure();
            return;
          }

          if (state.revokeStatus == MeSessionRevokeStatus.failure &&
              state.revokeFailure != null) {
            AppSnackBar.showError(
              context,
              message: messageForAuthFailure(
                state.revokeFailure!,
                context.l10n,
              ),
            );
            cubit.resetRevokeStatus();
            return;
          }

          if (state.revokeStatus == MeSessionRevokeStatus.success &&
              state.lastRevokedSessionId != null) {
            AppSnackBar.showSuccess(
              context,
              message: context.l10n.meSessionsRevokeSuccessMessage,
            );
            cubit.resetRevokeStatus();
          }
        },
        child: SafeArea(
          top: false,
          child: AppPageContainer(
            surface: SurfaceKind.settings,
            safeArea: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText.bodyMedium(context.l10n.meSessionsPageBody),
                  const SizedBox(height: AppSpacing.space16),
                  Expanded(
                    child: BlocBuilder<MeSessionsCubit, MeSessionsState>(
                      builder: (context, state) {
                        final cubit = context.read<MeSessionsCubit>();

                        if ((state.status == MeSessionsStatus.initial ||
                                state.status == MeSessionsStatus.loading) &&
                            state.sessions.isEmpty) {
                          return const MeSessionsSkeleton();
                        }

                        return AppPaginatedCollectionView<MeSessionEntity>(
                          status: _toCollectionStatus(state),
                          items: state.sessions,
                          hasMore: state.hasMore,
                          isLoadingMore: state.isLoadingMore,
                          onRefresh: () => cubit.refresh(),
                          onLoadMore: () => cubit.loadMore(),
                          onRetry: () => cubit.load(),
                          retryLabel: context.l10n.meSessionsRetryCta,
                          emptyTitle: context.l10n.meSessionsEmptyTitle,
                          emptyDescription:
                              context.l10n.meSessionsEmptyDescription,
                          errorTitle: context.l10n.errorsUnexpected,
                          errorDescription: state.failure == null
                              ? null
                              : messageForAuthFailure(
                                  state.failure!,
                                  context.l10n,
                                ),
                          padding: EdgeInsets.zero,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.space12),
                          itemBuilder: (context, session, _) => MeSessionCard(
                            session: session,
                            isRevoking:
                                state.pendingRevokeSessionId == session.id &&
                                state.isRevokeSubmitting,
                            onRevoke: () => _confirmRevoke(context, session),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    MeSessionEntity session,
  ) async {
    if (session.current || session.status != MeSessionStatus.active) return;

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.meSessionsRevokeConfirmTitle,
      message: context.l10n.meSessionsRevokeConfirmBody(
        device: meSessionDisplayName(context, session),
      ),
      confirmLabel: context.l10n.meSessionsRevokeConfirmCta,
      cancelLabel: context.l10n.commonCancel,
      variant: AppConfirmationDialogVariant.standard,
      icon: Icon(
        PhosphorIconsRegular.trash,
        semanticLabel: context.l10n.meSessionsRevokeConfirmTitle,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<MeSessionsCubit>().revokeSession(session.id);
  }
}

AppCollectionStatus _toCollectionStatus(MeSessionsState state) {
  return switch (state.status) {
    MeSessionsStatus.initial => AppCollectionStatus.initialLoading,
    MeSessionsStatus.loading when state.sessions.isEmpty =>
      AppCollectionStatus.initialLoading,
    MeSessionsStatus.loading => AppCollectionStatus.refreshLoading,
    MeSessionsStatus.failure => AppCollectionStatus.failure,
    MeSessionsStatus.empty => AppCollectionStatus.empty,
    MeSessionsStatus.success ||
    MeSessionsStatus.loadingMore => AppCollectionStatus.success,
  };
}
