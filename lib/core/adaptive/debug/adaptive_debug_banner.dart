import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../adaptive_context.dart';

class AdaptiveDebugBanner extends StatelessWidget {
  const AdaptiveDebugBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final spec = context.adaptive;
    final layout = spec.layout;

    final scaleAt16 = spec.text.textScaler.scale(16) / 16;
    final safe = spec.insets.safePadding;
    final insets = spec.insets.viewInsets;

    final lines = <String>[
      'size ${layout.size.width.toStringAsFixed(0)}×${layout.size.height.toStringAsFixed(0)} '
          '${layout.widthClass.name}/${layout.heightClass.name} '
          '${layout.orientation.name}',
      'nav ${layout.navigation.kind.name}  density ${layout.density.name}',
      'input ${spec.input.mode.name}  motion ${spec.motion.reduceMotion ? "reduced" : "standard"}',
      'text ~${scaleAt16.toStringAsFixed(2)}x@16  bold ${spec.text.boldText}',
      'safe (${safe.left.toStringAsFixed(0)},${safe.top.toStringAsFixed(0)},'
          '${safe.right.toStringAsFixed(0)},${safe.bottom.toStringAsFixed(0)})',
      'insets (${insets.left.toStringAsFixed(0)},${insets.top.toStringAsFixed(0)},'
          '${insets.right.toStringAsFixed(0)},${insets.bottom.toStringAsFixed(0)})',
      'fold ${spec.foldable.posture.name}  spanned ${spec.foldable.isSpanned}',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 11,
            height: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [for (final line in lines) Text(line)],
          ),
        ),
      ),
    );
  }
}

