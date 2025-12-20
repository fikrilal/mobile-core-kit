import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/theme/responsive/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space24),
            child: AppText.titleLarge('Mobile Core Kit'),
          ),
        ),
      ),
    );
  }
}
