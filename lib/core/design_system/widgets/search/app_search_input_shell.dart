import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_keys.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_style.dart';

class AppSearchInputShell extends StatelessWidget {
  const AppSearchInputShell({
    super.key,
    required this.textFieldKey,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.palette,
    required this.placeholder,
    required this.enabled,
    required this.autofocus,
    required this.showLoading,
    required this.showClearButton,
    required this.onSubmitted,
    required this.onClearPressed,
  });

  final Key textFieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppSearchStyle style;
  final AppSearchPalette palette;
  final String placeholder;
  final bool enabled;
  final bool autofocus;
  final bool showLoading;
  final bool showClearButton;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final hasFocus = focusNode.hasFocus;
    final borderWidth = hasFocus && enabled
        ? style.focusedBorderWidth
        : style.borderWidth;

    return AnimatedContainer(
      duration: MotionDurations.short,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: style.searchHorizontalPadding,
        vertical: style.searchVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? palette.shellBackground
            : palette.shellDisabledBackground,
        borderRadius: BorderRadius.circular(style.searchRadius),
        border: Border.all(color: palette.shellBorder, width: borderWidth),
      ),
      child: Row(
        children: [
          _SearchGlyph(palette: palette, enabled: enabled),
          SizedBox(width: style.inputHorizontalInset),
          Expanded(
            child: TextField(
              key: textFieldKey,
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: palette.shellText),
              cursorColor: palette.shellCursor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isCollapsed: true,
                hintText: placeholder,
                hintStyle: TextStyle(color: palette.shellHint),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          AnimatedSwitcher(
            duration: MotionDurations.short,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: showLoading
                ? const SizedBox(
                    key: ValueKey<String>('loading'),
                    width: AppSpacing.space20,
                    height: AppSpacing.space20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : showClearButton
                ? _ClearButton(
                    key: appSearchExperienceClearButtonKey,
                    onPressed: enabled ? onClearPressed : null,
                  )
                : const SizedBox(
                    key: ValueKey<String>('idle'),
                    width: AppSpacing.space20,
                    height: AppSpacing.space20,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph({required this.palette, required this.enabled});

  final AppSearchPalette palette;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.search_rounded,
      size: AppSpacing.space20,
      color: enabled ? palette.shellIconForeground : palette.shellDisabledText,
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkResponse(
        onTap: onPressed,
        radius: AppSpacing.space16,
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.space2),
          child: Icon(Icons.close_rounded, size: AppSpacing.space20),
        ),
      ),
    );
  }
}
