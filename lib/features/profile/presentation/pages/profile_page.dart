import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/widgets/avatar/app_avatar.dart';
import 'package:mobile_core_kit/core/widgets/avatar/avatar_size.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/tappable/app_tappable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/adaptive/adaptive_context.dart';
import '../../../../core/adaptive/tokens/surface_tokens.dart';
import '../../../../core/adaptive/widgets/app_page_container.dart';
import '../../../../core/theme/typography/components/text.dart';
import '../../../../core/widgets/button/app_button.dart';
import '../../../../core/widgets/button/button_variants.dart';
import '../../../../core/widgets/dialog/app_confirmation_dialog.dart';
import '../../../../core/widgets/loading/loading.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../auth/presentation/cubit/logout/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout/logout_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = context.select(
      (LogoutCubit c) => c.state.isSubmitting,
    );
    return BlocListener<LogoutCubit, LogoutState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        AppSnackBar.showError(context, message: state.errorMessage!);
      },
      child: AppLoadingOverlay(
        isLoading: isLoggingOut,
        message: 'Logging out...',
        child: _ProfileContent(isLoggingOut: isLoggingOut),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.isLoggingOut});

  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    final sectionSpacing = layout.gutter * 3;

    return AppPageContainer(
      surface: SurfaceKind.settings,
      safeArea: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppText.titleLarge('Profile'),
            SizedBox(height: sectionSpacing),
            AppAvatar(size: AppAvatarSize.xl, onChangePhoto: () {}),
            SizedBox(height: sectionSpacing),
            AppTappable(
              onTap: () {},
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Row(
                children: [
                  Row(
                    children: [
                      const AppIconBadge(
                        icon: Icon(Icons.settings),
                        showDot: true,
                      ),
                      const SizedBox(width: AppSpacing.space20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyLarge(
                            'Settings',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          AppText.bodyMedium(
                            'Manage your account settings',
                            color: context.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  PhosphorIcon(PhosphorIconsRegular.caretRight, size: 24),
                ],
              ),
            ),
            SizedBox(height: sectionSpacing),
            AppButton(
              text: 'Log out',
              variant: ButtonVariant.danger,
              isLoading: isLoggingOut,
              isDisabled: isLoggingOut,
              onPressed: isLoggingOut
                  ? null
                  : () async {
                      final confirmed = await showAppConfirmationDialog(
                        context: context,
                        title: 'Log out?',
                        message:
                            'You will need to sign in again to continue. This will also revoke your sessions on other devices.',
                        confirmLabel: 'Log out',
                        cancelLabel: 'Cancel',
                        variant: AppConfirmationDialogVariant.standard,
                      );

                      if (confirmed != true) return;
                      if (!context.mounted) return;
                      await context.read<LogoutCubit>().logout();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
