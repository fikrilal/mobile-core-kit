import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/services/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/services/media/image_picker_service.dart';
import 'package:mobile_core_kit/core/services/media/media_pick_exception.dart';
import 'package:mobile_core_kit/core/services/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/services/user_context/user_context_service.dart';
import 'package:mobile_core_kit/core/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/avatar/avatar.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_state.dart';
import 'package:mobile_core_kit/features/user/presentation/widgets/locale_setting_tile.dart';
import 'package:mobile_core_kit/features/user/presentation/widgets/theme_mode_setting_tile.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';
import 'package:mobile_core_kit/navigation/user/user_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.userContext,
    required this.themeModeController,
    required this.localeController,
    required this.imagePicker,
    required this.isLoggingOut,
    required this.onLogout,
  });

  final UserContextService userContext;
  final ThemeModeController themeModeController;
  final LocaleController localeController;
  final ImagePickerService imagePicker;
  final bool isLoggingOut;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final isProfileImageBusy = context.select(
      (ProfileImageCubit c) => c.state.isUploading || c.state.isClearing,
    );
    final profileImageAction = context.select(
      (ProfileImageCubit c) => c.state.action,
    );

    final isOverlayLoading = isLoggingOut || isProfileImageBusy;
    final overlayMessage = isLoggingOut
        ? context.l10n.profileLoggingOut
        : isProfileImageBusy
        ? switch (profileImageAction) {
            ProfileImageAction.clear => context.l10n.profilePhotoRemoving,
            _ => context.l10n.profilePhotoUploading,
          }
        : context.l10n.commonLoading;

    return BlocListener<ProfileImageCubit, ProfileImageState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.action != curr.action ||
          prev.failure != curr.failure,
      listener: (context, state) async {
        if (state.status == ProfileImageStatus.failure &&
            state.action != ProfileImageAction.loadAvatar &&
            state.failure != null) {
          AppSnackBar.showError(
            context,
            message: messageForAuthFailure(state.failure!, context.l10n),
          );
          context.read<ProfileImageCubit>().resetStatus();
          return;
        }

        if (state.status != ProfileImageStatus.success) return;

        switch (state.action) {
          case ProfileImageAction.upload:
            AppSnackBar.showSuccess(
              context,
              message: context.l10n.profilePhotoUpdated,
            );
            break;
          case ProfileImageAction.clear:
            AppSnackBar.showSuccess(
              context,
              message: context.l10n.profilePhotoRemoved,
            );
            break;
          case ProfileImageAction.loadAvatar:
          case ProfileImageAction.none:
            return;
        }

        final cubit = context.read<ProfileImageCubit>();
        await cubit.loadAvatar();
        cubit.resetStatus();
      },
      child: AppLoadingOverlay(
        isLoading: isOverlayLoading,
        message: overlayMessage,
        child: _ProfileContent(
          isLoggingOut: isLoggingOut,
          isProfileImageBusy: isProfileImageBusy,
          userContext: userContext,
          themeModeController: themeModeController,
          localeController: localeController,
          imagePicker: imagePicker,
          onLogout: onLogout,
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.isLoggingOut,
    required this.isProfileImageBusy,
    required this.userContext,
    required this.themeModeController,
    required this.localeController,
    required this.imagePicker,
    required this.onLogout,
  });

  final bool isLoggingOut;
  final bool isProfileImageBusy;
  final UserContextService userContext;
  final ThemeModeController themeModeController;
  final LocaleController localeController;
  final ImagePickerService imagePicker;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    final sectionSpacing = layout.gutter * 3;
    final showDevTools = BuildConfig.env == BuildEnv.dev;
    final cachedFilePath = context.select(
      (ProfileImageCubit c) => c.state.cachedFilePath,
    );
    final profileImageFileId = userContext.user?.profile.profileImageFileId;
    final canRemoveProfilePhoto =
        profileImageFileId != null && profileImageFileId.trim().isNotEmpty;
    final avatarProvider =
        cachedFilePath == null || cachedFilePath.trim().isEmpty
        ? null
        : FileImage(File(cachedFilePath));

    Future<void> handleProfilePhotoAction(_ProfilePhotoAction action) async {
      final cubit = context.read<ProfileImageCubit>();
      if (cubit.state.isUploading || cubit.state.isClearing) return;

      switch (action) {
        case _ProfilePhotoAction.gallery:
          try {
            final picked = await imagePicker.pickFromGallery();
            if (picked == null) return;
            await cubit.upload(
              bytes: picked.bytes,
              contentType: picked.contentType,
              idempotencyKey: IdempotencyKeyUtils.generate(),
            );
          } on MediaPickException catch (e) {
            if (!context.mounted) return;
            AppSnackBar.showError(
              context,
              message: _messageForMediaPickException(e, context.l10n),
            );
          }
        case _ProfilePhotoAction.camera:
          try {
            final picked = await imagePicker.pickFromCamera();
            if (picked == null) return;
            await cubit.upload(
              bytes: picked.bytes,
              contentType: picked.contentType,
              idempotencyKey: IdempotencyKeyUtils.generate(),
            );
          } on MediaPickException catch (e) {
            if (!context.mounted) return;
            AppSnackBar.showError(
              context,
              message: _messageForMediaPickException(e, context.l10n),
            );
          }
        case _ProfilePhotoAction.remove:
          await cubit.clear(idempotencyKey: IdempotencyKeyUtils.generate());
      }
    }

    Future<void> showProfilePhotoPicker() async {
      if (isProfileImageBusy) return;

      final selected = await showAdaptiveModal<_ProfilePhotoAction>(
        context: context,
        builder: (_) =>
            _ProfilePhotoActionPicker(canRemove: canRemoveProfilePhoto),
      );
      if (selected == null) return;
      await handleProfilePhotoAction(selected);
    }

    return AppPageContainer(
      surface: SurfaceKind.settings,
      safeArea: true,
      child: Padding(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ValueListenableBuilder<CurrentUserState>(
                  valueListenable: userContext.stateListenable,
                  builder: (context, state, _) {
                    final displayName = userContext.displayName;
                    final email = userContext.email;
                    final hasDisplayName =
                        displayName != null && displayName.trim().isNotEmpty;
                    final showEmail =
                        hasDisplayName &&
                        email != null &&
                        email.trim().isNotEmpty &&
                        email.trim() != displayName.trim();

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
                              onChangePhoto: showProfilePhotoPicker,
                              size: AppAvatarSize.xl,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        if (hasDisplayName) AppText.headlineMedium(displayName),
                        if (showEmail) ...[
                          const SizedBox(height: AppSpacing.space4),
                          AppText.bodyMedium(email),
                        ] else if (displayName == null &&
                            email != null &&
                            email.trim().isNotEmpty)
                          AppText.headlineMedium(email),
                        if (state.isAuthPending) ...[
                          const SizedBox(height: AppSpacing.space4),
                          AppText.bodySmall(context.l10n.commonLoading),
                        ],
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: sectionSpacing),
              AppText.titleLarge(context.l10n.profileYourAccountHeading),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.bell,
                    size: AppSizing.iconSizeMedium,
                  ),
                  showDot: true,
                ),
                title: context.l10n.profileInbox,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.question,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.profileHelp,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.fileText,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.profileStatementsAndReports,
                onTap: () {},
              ),
              SizedBox(height: sectionSpacing),

              // Settings Section
              AppText.titleLarge(context.l10n.commonSettings),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.shieldCheck,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.profileSecurityAndPrivacy,
                subtitle: context.l10n.profileSecurityAndPrivacySubtitle,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.userCircle,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.commonChangeProfilePhoto,
                onTap: showProfilePhotoPicker,
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.key,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.authChangePasswordTitle,
                onTap: () => context.push(UserRoutes.changePassword),
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.bellRinging,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.profileNotifications,
                subtitle: context.l10n.profileNotificationsSubtitle,
                onTap: () {},
              ),
              ThemeModeSettingTile(controller: themeModeController),
              LocaleSettingTile(
                includePseudoLocales: showDevTools,
                controller: localeController,
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.bank,
                    size: AppSizing.iconSizeMedium,
                  ),
                ),
                title: context.l10n.profilePaymentMethods,
                subtitle: context.l10n.profilePaymentMethodsSubtitle,
                onTap: () {},
              ),
              if (showDevTools) ...[
                SizedBox(height: sectionSpacing),
                AppText.titleLarge(context.l10n.commonDeveloper),
                const SizedBox(height: AppSpacing.space8),
                AppListTile(
                  leading: AppIconBadge(
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.palette,
                      size: AppSizing.iconSizeMedium,
                    ),
                  ),
                  title: context.l10n.profileThemeRoles,
                  subtitle: context.l10n.profileThemeRolesSubtitle,
                  onTap: () => context.push(DevToolsRoutes.themeRoles),
                ),
                AppListTile(
                  leading: AppIconBadge(
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.cube,
                      size: AppSizing.iconSizeMedium,
                    ),
                  ),
                  title: context.l10n.profileWidgetShowcases,
                  subtitle: context.l10n.profileWidgetShowcasesSubtitle,
                  onTap: () => context.push(DevToolsRoutes.widgetShowcases),
                ),
              ],
              SizedBox(height: sectionSpacing),

              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.signOut,
                    size: AppSizing.iconSizeMedium,
                  ),
                  iconColor: Theme.of(context).colorScheme.error,
                ),
                title: context.l10n.commonLogout,
                showChevron: false,
                enabled: !isLoggingOut,
                onTap: () async {
                  final confirmed = await showAppConfirmationDialog(
                    context: context,
                    title: context.l10n.profileLogoutDialogTitle,
                    message: context.l10n.profileLogoutDialogMessage,
                    confirmLabel: context.l10n.commonLogout,
                    cancelLabel: context.l10n.commonCancel,
                    variant: AppConfirmationDialogVariant.standard,
                  );

                  if (confirmed != true) return;
                  if (!context.mounted) return;
                  await onLogout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProfilePhotoAction { gallery, camera, remove }

class _ProfilePhotoActionPicker extends StatelessWidget {
  const _ProfilePhotoActionPicker({required this.canRemove});

  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    void select(_ProfilePhotoAction action) =>
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
            onTap: () => select(_ProfilePhotoAction.gallery),
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
            onTap: () => select(_ProfilePhotoAction.camera),
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
              onTap: () => select(_ProfilePhotoAction.remove),
            ),
        ],
      ),
    );
  }
}

String _messageForMediaPickException(
  MediaPickException error,
  AppLocalizations l10n,
) {
  return switch (error.code) {
    MediaPickErrorCode.cameraPermissionDenied =>
      l10n.mediaErrorsCameraPermissionDenied,
    MediaPickErrorCode.photoPermissionDenied =>
      l10n.mediaErrorsPhotoPermissionDenied,
    MediaPickErrorCode.unsupportedFormat ||
    MediaPickErrorCode.invalidImage => l10n.mediaErrorsUnsupportedImageFormat,
    MediaPickErrorCode.tooLargeAfterProcessing => l10n.mediaErrorsImageTooLarge,
    _ => l10n.errorsUnexpected,
  };
}
