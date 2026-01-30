import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/appearance/theme_mode_store.dart';

/// In-memory theme mode preference with SharedPreferences persistence.
///
/// Default is always [ThemeMode.system]. When the user selects Light/Dark, that
/// override is persisted and applied at the app shell via `MaterialApp.themeMode`.
class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController({required ThemeModeStore store})
    : _store = store,
      super(ThemeMode.system);

  final ThemeModeStore _store;
  Future<void>? _loadFuture;

  ThemeMode get themeMode => value;

  /// Loads the persisted theme mode override (idempotent).
  Future<void> load() {
    final existing = _loadFuture;
    if (existing != null) return existing;

    final future = _loadInternal();
    _loadFuture = future;
    return future;
  }

  Future<void> _loadInternal() async {
    try {
      final loaded = await _store.read();
      if (loaded == value) return;
      value = loaded;
    } catch (e, st) {
      _loadFuture = null;
      Log.warning('Failed to load theme mode preference', name: 'ThemeMode');
      Log.error('Theme mode load error', e, st, false, 'ThemeMode');
      // Fail safe: keep `ThemeMode.system`.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == value) return;
    value = mode;
    try {
      await _store.write(mode);
    } catch (e, st) {
      Log.warning('Failed to persist theme mode preference', name: 'ThemeMode');
      Log.error('Theme mode persist error', e, st, false, 'ThemeMode');
    }
  }
}
