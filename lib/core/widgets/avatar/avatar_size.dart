import 'package:mobile_core_kit/core/theme/tokens/sizing.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

extension AppAvatarSizeX on AppAvatarSize {
  double get diameter {
    switch (this) {
      case AppAvatarSize.xs:
        return AppSizing.avatarSizeExtraSmall;
      case AppAvatarSize.sm:
        return AppSizing.avatarSizeSmall;
      case AppAvatarSize.md:
        return AppSizing.avatarSizeMedium;
      case AppAvatarSize.lg:
        return AppSizing.avatarSizeLarge;
      case AppAvatarSize.xl:
        return AppSizing.avatarSizeExtraLarge;
    }
  }
}
