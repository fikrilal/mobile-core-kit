import 'package:flutter/material.dart';

import '../../../../core/theme/typography/components/text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppText.titleLarge(
        'Home',
        textAlign: TextAlign.center,
      ),
    );
  }
}
