import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/collection/app_paginated_collection_view.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_state.dart';
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
                          itemBuilder: (context, session, _) => _MeSessionCard(
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
        device: _sessionDisplayName(context, session),
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

class _MeSessionCard extends StatelessWidget {
  const _MeSessionCard({
    required this.session,
    required this.isRevoking,
    required this.onRevoke,
  });

  final MeSessionEntity session;
  final bool isRevoking;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final canRevoke =
        session.status == MeSessionStatus.active && session.current == false;
    final userAgent = session.userAgent?.trim();
    final metadata = _buildMetadata(context, session);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.bgContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.radius12),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: PhosphorIcon(
                    session.current
                        ? PhosphorIconsRegular.userCircle
                        : PhosphorIconsRegular.shieldCheck,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyLarge(
                        _sessionDisplayName(context, session),
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                      ),
                      if (userAgent != null && userAgent.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.space4),
                        AppText.bodySmall(
                          userAgent,
                          color: context.textSecondary,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                _SessionStatusPill(session: session),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            AppText.bodySmall(
              metadata,
              maxLines: 3,
              color: context.textSecondary,
            ),
            if (canRevoke) ...[
              const SizedBox(height: AppSpacing.space12),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton.outline(
                  text: context.l10n.meSessionsRevokeCta,
                  loadingText: context.l10n.meSessionsRevokeSubmitting,
                  semanticLabel: context.l10n.meSessionsRevokeCta,
                  size: ButtonSize.small,
                  isLoading: isRevoking,
                  isDisabled: isRevoking,
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.trash,
                    size: AppSizing.iconSizeCompact,
                  ),
                  onPressed: isRevoking ? null : onRevoke,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionStatusPill extends StatelessWidget {
  const _SessionStatusPill({required this.session});

  final MeSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (session.status) {
      MeSessionStatus.active when session.current => (
        context.l10n.meSessionsStatusCurrentDevice,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      MeSessionStatus.active => (
        context.l10n.meSessionsStatusActive,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      MeSessionStatus.revoked => (
        context.l10n.meSessionsStatusRevoked,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      MeSessionStatus.expired => (
        context.l10n.meSessionsStatusExpired,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space4,
        ),
        child: AppText.labelSmall(
          label,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

String _buildMetadata(BuildContext context, MeSessionEntity session) {
  final entries = <String>[
    context.l10n.meSessionsLastSeenWithDate(
      date: _formatDateTime(context, session.lastSeenAt),
    ),
    context.l10n.meSessionsExpiresAtWithDate(
      date: _formatDateTime(context, session.expiresAt),
    ),
  ];

  final ip = session.ip?.trim();
  if (ip != null && ip.isNotEmpty) {
    entries.add(context.l10n.meSessionsIpAddress(ip: ip));
  }

  return entries.join(' • ');
}

String _sessionDisplayName(BuildContext context, MeSessionEntity session) {
  final deviceName = session.deviceName?.trim();
  if (deviceName != null && deviceName.isNotEmpty) return deviceName;

  final deviceId = session.deviceId?.trim();
  if (deviceId != null && deviceId.isNotEmpty) {
    return '${context.l10n.meSessionsSessionUnknownDevice} ($deviceId)';
  }

  return context.l10n.meSessionsSessionUnknownDevice;
}

String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
}
