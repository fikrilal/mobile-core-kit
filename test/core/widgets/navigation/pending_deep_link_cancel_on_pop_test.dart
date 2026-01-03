import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/widgets/navigation/pending_deep_link_cancel_on_pop.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PendingDeepLinkCancelOnPop', () {
    testWidgets('clears pending deep link before popping', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final deepLinks = PendingDeepLinkController(
        store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
        parser: DeepLinkParser(),
        now: () => DateTime(2026, 1, 1),
      );

      await deepLinks.setPendingLocation('/profile', source: 'test');
      expect(deepLinks.hasPending, isTrue);

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('home')),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => PendingDeepLinkCancelOnPop(
            deepLinks: deepLinks,
            child: const Scaffold(body: Text('auth')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(deepLinks.hasPending, isFalse);
    });

    testWidgets(
      'does not clear when canPop and clearWhenCanPop is false',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        final deepLinks = PendingDeepLinkController(
          store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
          parser: DeepLinkParser(),
          now: () => DateTime(2026, 1, 1),
        );

        await deepLinks.setPendingLocation('/profile', source: 'test');
        expect(deepLinks.hasPending, isTrue);

        final navigatorKey = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('home')),
          ),
        );

        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => PendingDeepLinkCancelOnPop(
              deepLinks: deepLinks,
              clearWhenCanPop: false,
              child: const Scaffold(body: Text('auth')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(deepLinks.hasPending, isTrue);
      },
    );

    testWidgets(
      'clears when cannot pop and clearWhenCanPop is false',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        var didRequestExit = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'SystemNavigator.pop') {
                didRequestExit = true;
              }
              return null;
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        final deepLinks = PendingDeepLinkController(
          store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
          parser: DeepLinkParser(),
          now: () => DateTime(2026, 1, 1),
        );

        await deepLinks.setPendingLocation('/profile', source: 'test');
        expect(deepLinks.hasPending, isTrue);

        final navigatorKey = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: PendingDeepLinkCancelOnPop(
              deepLinks: deepLinks,
              clearWhenCanPop: false,
              child: const Scaffold(body: Text('auth')),
            ),
          ),
        );

        await navigatorKey.currentState!.maybePop();
        await tester.pumpAndSettle();

        expect(deepLinks.hasPending, isFalse);
        expect(didRequestExit, isTrue);
      },
    );
  });
}
