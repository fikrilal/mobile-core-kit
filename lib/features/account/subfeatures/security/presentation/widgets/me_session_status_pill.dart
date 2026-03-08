import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';

class MeSessionStatusPill extends StatelessWidget {
  const MeSessionStatusPill({super.key, required this.session});

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
