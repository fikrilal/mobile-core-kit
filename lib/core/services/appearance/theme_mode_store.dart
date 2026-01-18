import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for theme mode user preference.
///
/// Contract:
/// - Missing key => system default (no override).
/// - Stored values are forward-compatible; unknown values fail safe to system.
class ThemeModeStore {
  ThemeModeStore({Future<SharedPreferences>? prefs})
    : _prefsFuture = prefs ?? SharedPreferences.getInstance();

  static const String _kThemeModeKey = 'theme_mode';

  final Future<SharedPreferences> _prefsFuture;

  Future<ThemeMode> read() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_kThemeModeKey);
    return _parse(raw);
  }

  Future<void> write(ThemeMode mode) async {
    final prefs = await _prefsFuture;
    if (mode == ThemeMode.system) {
      await prefs.remove(_kThemeModeKey);
      return;
    }
    await prefs.setString(_kThemeModeKey, _serialize(mode));
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      case null:
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}

