import 'package:flutter/material.dart';

import '../../../../core/theme/typography/components/text.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppText.titleLarge(
        'Profile',
        textAlign: TextAlign.center,
      ),
    );
  }
}
