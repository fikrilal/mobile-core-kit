import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Adaptive golden matrix (settings surface)', () {
    Future<void> pumpCase(
      WidgetTester tester, {
      required Size size,
      required double textScale,
    }) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 16, color: Color(0xFF111111)),
              child: AdaptiveScope(
                navigationPolicy: NavigationPolicy.none(),
                child: _GoldenSettingsSurface(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('compact 1.0x', (tester) async {
      await pumpCase(tester, size: const Size(500, 800), textScale: 1.0);
      await expectLater(
        find.byKey(_GoldenSettingsSurface.boundaryKey),
        matchesGoldenFile('settings_compact_1.0.png'),
      );
    });

    testWidgets('compact 2.0x', (tester) async {
      await pumpCase(tester, size: const Size(500, 800), textScale: 2.0);
      await expectLater(
        find.byKey(_GoldenSettingsSurface.boundaryKey),
        matchesGoldenFile('settings_compact_2.0.png'),
      );
    });

    testWidgets('expanded 1.0x', (tester) async {
      await pumpCase(tester, size: const Size(900, 800), textScale: 1.0);
      await expectLater(
        find.byKey(_GoldenSettingsSurface.boundaryKey),
        matchesGoldenFile('settings_expanded_1.0.png'),
      );
    });

    testWidgets('expanded 2.0x', (tester) async {
      await pumpCase(tester, size: const Size(900, 800), textScale: 2.0);
      await expectLater(
        find.byKey(_GoldenSettingsSurface.boundaryKey),
        matchesGoldenFile('settings_expanded_2.0.png'),
      );
    });
  });
}

class _GoldenSettingsSurface extends StatelessWidget {
  const _GoldenSettingsSurface();

  static const boundaryKey = Key('adaptive_golden_surface');

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;

    return RepaintBoundary(
      key: boundaryKey,
      child: ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: AppPageContainer(
          surface: SurfaceKind.settings,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              border: Border.all(color: const Color(0xFF1976D2), width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Settings (golden)',
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: layout.gutter),
                  const _FakeField(label: 'Email'),
                  SizedBox(height: layout.gutter),
                  const _FakeField(label: 'Password'),
                  SizedBox(height: layout.gutter),
                  const _FakeField(label: 'Confirm'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(
                        width: 140,
                        height: 44,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeField extends StatelessWidget {
  const _FakeField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFF90CAF9)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
