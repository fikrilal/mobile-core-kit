import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/avatar/avatar.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

class AccountHeaderSection extends StatelessWidget {
  const AccountHeaderSection({
    super.key,
    required this.displayName,
    required this.email,
    required this.isAuthPending,
    required this.avatarProvider,
    required this.onChangePhoto,
  });

  final String? displayName;
  final String? email;
  final bool isAuthPending;
  final ImageProvider<Object>? avatarProvider;
  final Future<void> Function() onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final hasDisplayName =
        displayName != null && displayName!.trim().isNotEmpty;
    final hasEmail = email != null && email!.trim().isNotEmpty;
    final showEmail =
        hasDisplayName && hasEmail && email!.trim() != displayName!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.space16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAvatar(
              imageProvider: avatarProvider,
              displayName: displayName ?? email,
              onChangePhoto: onChangePhoto,
              size: AppAvatarSize.xl,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),
        if (hasDisplayName) AppText.headlineMedium(displayName!),
        if (showEmail) ...[
          const SizedBox(height: AppSpacing.space4),
          AppText.bodyMedium(email!),
        ] else if (!hasDisplayName && hasEmail)
          AppText.headlineMedium(email!),
        if (isAuthPending) ...[
          const SizedBox(height: AppSpacing.space4),
          AppText.bodySmall(context.l10n.commonLoading),
        ],
      ],
    );
  }
}
