import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/platform/media/image_picker_service.dart';
import 'package:mobile_core_kit/core/platform/media/media_pick_exception.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/runtime/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/account_developer_section.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/account_header_section.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/account_main_section.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/account_settings_section.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_state.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/widgets/profile_photo_action_sheet.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mobile_core_kit/navigation/account/account_routes.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
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
        child: _AccountContent(
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

class _AccountContent extends StatelessWidget {
  const _AccountContent({
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

    Future<void> handleProfilePhotoAction(
      ProfilePhotoActionSheetOption action,
    ) async {
      final cubit = context.read<ProfileImageCubit>();
      if (cubit.state.isUploading || cubit.state.isClearing) return;

      switch (action) {
        case ProfilePhotoActionSheetOption.gallery:
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
        case ProfilePhotoActionSheetOption.camera:
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
        case ProfilePhotoActionSheetOption.remove:
          await cubit.clear(idempotencyKey: IdempotencyKeyUtils.generate());
      }
    }

    Future<void> showProfilePhotoPicker() async {
      if (isProfileImageBusy) return;

      final selected = await showAdaptiveModal<ProfilePhotoActionSheetOption>(
        context: context,
        builder: (_) =>
            ProfilePhotoActionSheet(canRemove: canRemoveProfilePhoto),
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
                    return AccountHeaderSection(
                      displayName: userContext.displayName,
                      email: userContext.email,
                      isAuthPending: state.isAuthPending,
                      avatarProvider: avatarProvider,
                      onChangePhoto: showProfilePhotoPicker,
                    );
                  },
                ),
              ),
              AccountMainSection(
                sectionSpacing: sectionSpacing,
                onInboxTap: () {},
                onHelpTap: () {},
                onStatementsTap: () {},
              ),
              SizedBox(height: sectionSpacing),
              AccountSettingsSection(
                showDevTools: showDevTools,
                themeModeController: themeModeController,
                localeController: localeController,
                onSecurityPrivacyTap: () =>
                    context.push(AccountRoutes.securityPrivacy),
                onNotificationsTap: () {},
                onChangeProfilePhotoTap: showProfilePhotoPicker,
                onPaymentMethodsTap: () {},
              ),
              if (showDevTools) ...[
                AccountDeveloperSection(
                  sectionSpacing: sectionSpacing,
                  onThemeRolesTap: () =>
                      context.push(DevToolsRoutes.themeRoles),
                  onWidgetShowcasesTap: () =>
                      context.push(DevToolsRoutes.widgetShowcases),
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
