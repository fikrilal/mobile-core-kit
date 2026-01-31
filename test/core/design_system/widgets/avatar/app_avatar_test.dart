import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/widgets/avatar/avatar.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

Uint8List _oneByOnePngBytes() {
  const base64Png =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+4tJkAAAAASUVORK5CYII=';
  return base64Decode(base64Png);
}

void main() {
  group('AppAvatar', () {
    testWidgets('shows initials from displayName when no image', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(displayName: 'Ahmad Fikril')),
      );

      expect(find.text('AF'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.user()), findsNothing);
      expect(find.byIcon(PhosphorIcons.camera()), findsNothing);
    });

    testWidgets('computes initials for single-word displayName', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppAvatar(displayName: 'Dante')));

      expect(find.text('DA'), findsOneWidget);
    });

    testWidgets('shows generic icon when no name/initials and no image', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppAvatar()));

      expect(find.byIcon(PhosphorIcons.user()), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.camera()), findsNothing);
    });

    testWidgets('shows camera badge and triggers callback when editable', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            displayName: 'Ahmad Fikril',
            onChangePhoto: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(PhosphorIcons.camera()), findsOneWidget);

      await tester.tap(find.byIcon(PhosphorIcons.camera()));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('tapping avatar surface triggers onChangePhoto by default', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            displayName: 'Ahmad Fikril',
            onChangePhoto: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('AF'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'prefers onTap for avatar surface when both callbacks are set',
      (tester) async {
        var surfaceTapped = false;
        var badgeTapped = false;

        await tester.pumpWidget(
          _wrap(
            AppAvatar(
              displayName: 'Ahmad Fikril',
              onTap: () => surfaceTapped = true,
              onChangePhoto: () => badgeTapped = true,
            ),
          ),
        );

        await tester.tap(find.text('AF'));
        await tester.pump();

        expect(surfaceTapped, isTrue);
        expect(badgeTapped, isFalse);

        await tester.tap(find.byIcon(PhosphorIcons.camera()));
        await tester.pump();

        expect(badgeTapped, isTrue);
      },
    );

    testWidgets('prefers imageProvider over initials', (tester) async {
      final bytes = _oneByOnePngBytes();

      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            imageProvider: MemoryImage(bytes),
            displayName: 'Ahmad Fikril',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('AF'), findsNothing);
      expect(find.byIcon(PhosphorIcons.user()), findsNothing);
    });

    testWidgets('badge stays anchored when parent expands width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: Row(
              children: [Expanded(child: AppAvatar(onChangePhoto: () {}))],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final avatarRect = tester.getRect(find.byIcon(PhosphorIcons.user()));
      final badgeRect = tester.getRect(find.byIcon(PhosphorIcons.camera()));

      final dx = (badgeRect.center.dx - avatarRect.center.dx).abs();
      // If anchored correctly, the badge should be near the avatar, not at the
      // far edge of the expanded parent.
      expect(dx, lessThan(120));
    });
  });
}
