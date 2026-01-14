import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'adaptive_debug_banner.dart';

class AdaptiveDebugOverlay extends StatelessWidget {
  const AdaptiveDebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topLeft,
            child: const AdaptiveDebugBanner(),
          ),
        ),
      ),
    );
  }
}
