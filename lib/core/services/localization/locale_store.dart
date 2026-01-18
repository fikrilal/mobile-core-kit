import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for the user locale override.
///
/// Contract:
/// - Missing key => system default (no override).
/// - Values are stored as BCP-47-ish tags: `en`, `id`, `en-XA`, `ar-XB`.
/// - Unknown/invalid values fail safe to `null`.
class LocaleStore {
  LocaleStore({Future<SharedPreferences>? prefs})
    : _prefsFuture = prefs ?? SharedPreferences.getInstance();

  static const String _kLocaleKey = 'locale';

  final Future<SharedPreferences> _prefsFuture;

  Future<Locale?> read() async {
    final prefs = await _prefsFuture;
    final raw = prefs.getString(_kLocaleKey);
    return _parse(raw);
  }

  Future<void> write(Locale? locale) async {
    final prefs = await _prefsFuture;
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
      return;
    }
    await prefs.setString(_kLocaleKey, _serialize(locale));
  }

  static Locale? _parse(String? raw) {
    final normalized = raw?.trim();
    if (normalized == null || normalized.isEmpty || normalized == 'system') {
      return null;
    }

    final parts = normalized.split(RegExp(r'[-_]'));
    if (parts.isEmpty) return null;

    final language = parts.first.trim().toLowerCase();
    if (!RegExp(r'^[a-z]{2,3}$').hasMatch(language)) return null;

    String? countryCode;
    if (parts.length >= 2) {
      final country = parts[1].trim().toUpperCase();
      if (country.isNotEmpty) {
        if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) return null;
        countryCode = country;
      }
    }

    return Locale(language, countryCode);
  }

  static String _serialize(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.trim().toUpperCase();
    if (country == null || country.isEmpty) return language;
    return '$language-$country';
  }
}

