import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/navigation/user/user_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key, required this.userContext});

  final UserContextService userContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium(context.l10n.profileSecurityAndPrivacy),
      ),
      body: SafeArea(
        top: false,
        child: AppPageContainer(
          surface: SurfaceKind.settings,
          safeArea: false,
          child: ValueListenableBuilder<CurrentUserState>(
            valueListenable: userContext.stateListenable,
            builder: (context, state, _) {
              final scheduledFor = state.user?.accountDeletion?.scheduledFor;
              final scheduledDate = _formatDate(context, scheduledFor);
              final deletionSubtitle = scheduledDate == null
                  ? context.l10n.profileDeleteAccountSubtitle
                  : context.l10n.profileDeleteAccountScheduledSubtitle(
                      date: scheduledDate,
                    );

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space16),
                    AppText.bodyMedium(
                      context.l10n.profileSecurityAndPrivacyBody,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppListTile(
                      leading: AppIconBadge(
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.key,
                          size: AppSizing.iconSizeMedium,
                        ),
                      ),
                      title: context.l10n.authChangePasswordTitle,
                      subtitle: context.l10n.profileChangePasswordSubtitle,
                      onTap: () => context.push(UserRoutes.changePassword),
                    ),
                    AppListTile(
                      leading: AppIconBadge(
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.userCircle,
                          size: AppSizing.iconSizeMedium,
                        ),
                      ),
                      title: context.l10n.profileActiveSessionsTitle,
                      subtitle: context.l10n.profileActiveSessionsSubtitle,
                      onTap: () => context.push(UserRoutes.meSessions),
                    ),
                    AppListTile(
                      leading: AppIconBadge(
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.userMinus,
                          size: AppSizing.iconSizeMedium,
                        ),
                        iconColor: Theme.of(context).colorScheme.error,
                      ),
                      title: context.l10n.profileDeleteAccountTitle,
                      subtitle: deletionSubtitle,
                      onTap: () =>
                          context.push(UserRoutes.requestAccountDeletion),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String? _formatDate(BuildContext context, String? isoDateTime) {
  if (isoDateTime == null || isoDateTime.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(isoDateTime);
  if (parsed == null) return null;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMMd(locale).format(parsed.toLocal());
}
