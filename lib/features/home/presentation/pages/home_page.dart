import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';

import '../../../../core/adaptive/tokens/surface_tokens.dart';
import '../../../../core/adaptive/widgets/app_page_container.dart';
import '../../../../core/theme/typography/components/text.dart';

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
