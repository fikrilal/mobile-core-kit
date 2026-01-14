import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';

void main() {
  group('AdaptiveModel', () {
    testWidgets('notifies only dependents for changed aspects', (tester) async {
      _LayoutBuildCounter.reset();
      _InsetsBuildCounter.reset();
      _AnyBuildCounter.reset();

      final initialSpec = _spec(
        layout: _layout(
          size: const Size(400, 800),
          widthClass: WindowWidthClass.compact,
          heightClass: WindowHeightClass.medium,
        ),
        insets: const InsetsSpec(
          safePadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: _AdaptiveHost(
            initialSpec: initialSpec,
            child: const Column(
              children: [
                _LayoutBuildCounter(),
                _InsetsBuildCounter(),
                _AnyBuildCounter(),
              ],
            ),
          ),
        ),
      );

      expect(_LayoutBuildCounter.builds, 1);
      expect(_InsetsBuildCounter.builds, 1);
      expect(_AnyBuildCounter.builds, 1);

      final state = tester.state<_AdaptiveHostState>(
        find.byType(_AdaptiveHost),
      );

      var current = initialSpec;
      final updatedInsets = const InsetsSpec(
        safePadding: EdgeInsets.only(top: 10),
        viewInsets: EdgeInsets.zero,
      );

      state.updateSpec(current = current.copyWith(insets: updatedInsets));
      await tester.pump();

      expect(_LayoutBuildCounter.builds, 1, reason: 'layout did not change');
      expect(_InsetsBuildCounter.builds, 2, reason: 'insets changed');
      expect(_AnyBuildCounter.builds, 2, reason: 'spec changed');

      final updatedLayout = _layout(
        size: const Size(700, 800),
        widthClass: WindowWidthClass.medium,
        heightClass: WindowHeightClass.medium,
      );

      state.updateSpec(current = current.copyWith(layout: updatedLayout));
      await tester.pump();

      expect(_LayoutBuildCounter.builds, 2, reason: 'layout changed');
      expect(_InsetsBuildCounter.builds, 2, reason: 'insets did not change');
      expect(_AnyBuildCounter.builds, 3, reason: 'spec changed');
    });
  });
}

AdaptiveSpec _spec({required LayoutSpec layout, required InsetsSpec insets}) {
  return AdaptiveSpec(
    layout: layout,
    insets: insets,
    text: TextSpec(textScaler: TextScaler.linear(1.0), boldText: false),
    motion: const MotionSpec(reduceMotion: false),
    input: const InputSpec(mode: InputMode.touch, pointerHoverEnabled: false),
    platform: const PlatformSpec(platform: TargetPlatform.android),
    foldable: FoldableSpec.none,
  );
}

LayoutSpec _layout({
  required Size size,
  required WindowWidthClass widthClass,
  required WindowHeightClass heightClass,
}) {
  return LayoutSpec(
    size: size,
    widthClass: widthClass,
    heightClass: heightClass,
    orientation: size.width >= size.height
        ? Orientation.landscape
        : Orientation.portrait,
    density: LayoutDensity.comfortable,
    pagePadding: EdgeInsets.zero,
    gutter: 0,
    minTapTarget: 48,
    surfaceTokens: const <SurfaceKind, SurfaceTokens>{},
    grid: const GridSpec(columns: 2, minTileWidth: 160, maxColumns: 4),
    navigation: const NavigationSpec(kind: NavigationKind.none),
  );
}

class _AdaptiveHost extends StatefulWidget {
  const _AdaptiveHost({required this.initialSpec, required this.child});

  final AdaptiveSpec initialSpec;
  final Widget child;

  @override
  State<_AdaptiveHost> createState() => _AdaptiveHostState();
}

class _AdaptiveHostState extends State<_AdaptiveHost> {
  late AdaptiveSpec _spec;

  @override
  void initState() {
    super.initState();
    _spec = widget.initialSpec;
  }

  void updateSpec(AdaptiveSpec spec) {
    setState(() {
      _spec = spec;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveModel(spec: _spec, child: widget.child);
  }
}

class _LayoutBuildCounter extends StatelessWidget {
  const _LayoutBuildCounter();

  static int builds = 0;

  static void reset() => builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return Text(context.adaptiveLayout.widthClass.name);
  }
}

class _InsetsBuildCounter extends StatelessWidget {
  const _InsetsBuildCounter();

  static int builds = 0;

  static void reset() => builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return Text('${context.adaptiveInsets.safePadding.top}');
  }
}

class _AnyBuildCounter extends StatelessWidget {
  const _AnyBuildCounter();

  static int builds = 0;

  static void reset() => builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return Text(context.adaptive.layout.widthClass.name);
  }
}
