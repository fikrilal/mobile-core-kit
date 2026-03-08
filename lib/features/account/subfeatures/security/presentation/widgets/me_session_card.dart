import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/foundation/utilities/date_utils.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/widgets/me_session_status_pill.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MeSessionCard extends StatelessWidget {
  const MeSessionCard({
    super.key,
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
                        meSessionDisplayName(context, session),
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
                MeSessionStatusPill(session: session),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            AppText.bodySmall(
              _buildMetadata(context, session),
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

String meSessionDisplayName(BuildContext context, MeSessionEntity session) {
  final deviceName = session.deviceName?.trim();
  if (deviceName != null && deviceName.isNotEmpty) return deviceName;

  final deviceId = session.deviceId?.trim();
  if (deviceId != null && deviceId.isNotEmpty) {
    return '${context.l10n.meSessionsSessionUnknownDevice} ($deviceId)';
  }

  return context.l10n.meSessionsSessionUnknownDevice;
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

String _formatDateTime(BuildContext context, DateTime value) {
  return AppDateUtils.formatShortDateTime(
    value.toLocal(),
    locale: Localizations.localeOf(context).toLanguageTag(),
  );
}
