import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/state_message/app_state_message_panel.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together.',
       );

  final String? title;
  final String? description;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final defaultIcon = Icon(
      Icons.inbox_outlined,
      size: AppSizing.iconSizeLarge,
      color: Theme.of(context).colorScheme.outline,
    );

    return AppStateMessagePanel(
      title: title?.trim().isNotEmpty == true
          ? title!.trim()
          : context.l10n.commonItemsCount(count: 0),
      description: description,
      leading: icon ?? defaultIcon,
      actions: onAction == null || actionLabel == null
          ? const <Widget>[]
          : <Widget>[
              AppButton.primary(
                text: actionLabel!,
                semanticLabel: actionLabel!,
                isExpanded: true,
                onPressed: onAction,
              ),
            ],
    );
  }
}
