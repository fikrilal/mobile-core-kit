import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      surface: SurfaceKind.dashboard,
      alignment: Alignment.center,
      child: AppText.titleLarge(
        context.l10n.commonHome,
        textAlign: TextAlign.center,
      ),
    );
  }
}
