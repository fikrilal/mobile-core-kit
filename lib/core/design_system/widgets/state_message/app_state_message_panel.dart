import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';

class AppStateMessagePanel extends StatelessWidget {
  const AppStateMessagePanel({
    super.key,
    required this.title,
    this.description,
    this.leading,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? description;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final descriptionText = description;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leading != null) ...[
            Center(child: leading),
            const SizedBox(height: AppSpacing.space12),
          ],
          AppText.titleMedium(title, textAlign: TextAlign.center),
          if (descriptionText case final String nonEmptyDescription
              when nonEmptyDescription.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space12),
            AppText.bodyMedium(
              nonEmptyDescription,
              textAlign: TextAlign.center,
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space24),
            ..._buildActionsWithSpacing(actions),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActionsWithSpacing(List<Widget> widgets) {
    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) {
        result.add(const SizedBox(height: AppSpacing.space12));
      }
      result.add(widgets[i]);
    }
    return result;
  }
}
