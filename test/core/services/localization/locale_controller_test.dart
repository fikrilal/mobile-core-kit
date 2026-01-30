import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/services/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/services/localization/locale_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController + LocaleStore', () {
    test('defaults to system when no override is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final store = LocaleStore(prefs: SharedPreferences.getInstance());
      final controller = LocaleController(store: store, env: BuildEnv.dev);

      expect(controller.localeOverride, isNull);
      await controller.load();
      expect(controller.localeOverride, isNull);
    });

    test('persists and restores locale overrides', () async {
      SharedPreferences.setMockInitialValues({});

      final store = LocaleStore(prefs: SharedPreferences.getInstance());
      final controller = LocaleController(store: store, env: BuildEnv.dev);
      await controller.load();

      await controller.setLocale(const Locale('id'));
      expect(controller.localeOverride, const Locale('id'));

      final controller2 = LocaleController(
        store: LocaleStore(prefs: SharedPreferences.getInstance()),
        env: BuildEnv.dev,
      );
      await controller2.load();
      expect(controller2.localeOverride, const Locale('id'));
    });

    test('clearing override (system) removes persisted value', () async {
      SharedPreferences.setMockInitialValues({});

      final store = LocaleStore(prefs: SharedPreferences.getInstance());
      final controller = LocaleController(store: store, env: BuildEnv.dev);
      await controller.load();

      await controller.setLocale(const Locale('en'));
      expect(controller.localeOverride, const Locale('en'));

      await controller.setLocale(null);
      expect(controller.localeOverride, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), isNull);
    });

    test('pseudo-locales are allowed only in dev', () async {
      SharedPreferences.setMockInitialValues({});

      final devController = LocaleController(
        store: LocaleStore(prefs: SharedPreferences.getInstance()),
        env: BuildEnv.dev,
      );
      await devController.load();
      await devController.setLocale(const Locale('en', 'XA'));
      expect(devController.localeOverride, const Locale('en', 'XA'));

      final stageController = LocaleController(
        store: LocaleStore(prefs: SharedPreferences.getInstance()),
        env: BuildEnv.stage,
      );
      await stageController.load();
      await stageController.setLocale(const Locale('en', 'XA'));
      expect(stageController.localeOverride, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), isNull);
    });

    test('unsupported stored values fail safe to system', () async {
      SharedPreferences.setMockInitialValues({'locale': 'weird'});

      final prefs = SharedPreferences.getInstance();
      final store = LocaleStore(prefs: prefs);
      expect(await store.read(), isNull);
    });
  });
}
