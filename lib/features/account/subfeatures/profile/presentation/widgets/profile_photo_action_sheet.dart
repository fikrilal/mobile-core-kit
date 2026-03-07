import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum ProfilePhotoActionSheetOption { gallery, camera, remove }

class ProfilePhotoActionSheet extends StatelessWidget {
  const ProfilePhotoActionSheet({super.key, required this.canRemove});

  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    void select(ProfilePhotoActionSheetOption action) =>
        Navigator.of(context).pop(action);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleLarge(context.l10n.commonChangeProfilePhoto),
          const SizedBox(height: AppSpacing.space8),
          AppListTile(
            leading: AppIconBadge(
              icon: PhosphorIcon(
                PhosphorIconsRegular.image,
                size: AppSizing.iconSizeMedium,
              ),
            ),
            title: context.l10n.commonChooseFromGallery,
            showChevron: false,
            onTap: () => select(ProfilePhotoActionSheetOption.gallery),
          ),
          AppListTile(
            leading: AppIconBadge(
              icon: PhosphorIcon(
                PhosphorIconsRegular.camera,
                size: AppSizing.iconSizeMedium,
              ),
            ),
            title: context.l10n.commonTakePhoto,
            showChevron: false,
            onTap: () => select(ProfilePhotoActionSheetOption.camera),
          ),
          if (canRemove)
            AppListTile(
              leading: AppIconBadge(
                icon: PhosphorIcon(
                  PhosphorIconsRegular.trash,
                  size: AppSizing.iconSizeMedium,
                ),
                iconColor: Theme.of(context).colorScheme.error,
              ),
              title: context.l10n.commonRemovePhoto,
              showChevron: false,
              onTap: () => select(ProfilePhotoActionSheetOption.remove),
            ),
        ],
      ),
    );
  }
}
