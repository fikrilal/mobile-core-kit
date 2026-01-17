import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeController + ThemeModeStore', () {
    test('defaults to system when no override is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeModeStore(prefs: SharedPreferences.getInstance());
      final controller = ThemeModeController(store: store);

      expect(controller.themeMode, ThemeMode.system);
      await controller.load();
      expect(controller.themeMode, ThemeMode.system);
    });

    test('persists and restores light/dark overrides', () async {
      SharedPreferences.setMockInitialValues({});

      final store = ThemeModeStore(prefs: SharedPreferences.getInstance());
      final controller = ThemeModeController(store: store);

      await controller.load();

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);

      final controller2 = ThemeModeController(
        store: ThemeModeStore(prefs: SharedPreferences.getInstance()),
      );
      await controller2.load();
      expect(controller2.themeMode, ThemeMode.dark);

      await controller.setThemeMode(ThemeMode.light);
      final controller3 = ThemeModeController(
        store: ThemeModeStore(prefs: SharedPreferences.getInstance()),
      );
      await controller3.load();
      expect(controller3.themeMode, ThemeMode.light);
    });

    test('clearing override (system) removes persisted value', () async {
      SharedPreferences.setMockInitialValues({});

      final store = ThemeModeStore(prefs: SharedPreferences.getInstance());
      final controller = ThemeModeController(store: store);
      await controller.load();

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);

      await controller.setThemeMode(ThemeMode.system);
      expect(controller.themeMode, ThemeMode.system);

      final controller2 = ThemeModeController(
        store: ThemeModeStore(prefs: SharedPreferences.getInstance()),
      );
      await controller2.load();
      expect(controller2.themeMode, ThemeMode.system);
    });

    test('unknown stored values fail safe to system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'weird'});

      final store = ThemeModeStore(prefs: SharedPreferences.getInstance());
      expect(await store.read(), ThemeMode.system);
    });
  });
}

