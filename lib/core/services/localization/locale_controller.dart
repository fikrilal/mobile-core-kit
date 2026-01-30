import 'package:flutter/widgets.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/services/localization/locale_store.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// In-memory locale override with SharedPreferences persistence.
///
/// Default is always `null` (system). When the user selects a specific locale,
/// that override is persisted and applied at the app shell via `MaterialApp.locale`.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController({required LocaleStore store, BuildEnv? env})
    : _store = store,
      _env = env ?? BuildConfig.env,
      super(null);

  final LocaleStore _store;
  final BuildEnv _env;
  Future<void>? _loadFuture;

  Locale? get localeOverride => value;

  List<Locale> get supportedLocales => supportedLocalesForEnv(
    env: _env,
    allSupportedLocales: AppLocalizations.supportedLocales,
  );

  /// Loads the persisted locale override (idempotent).
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
      final normalized = normalizeLocaleOverride(loaded, env: _env);
      if (normalized == null && loaded != null) {
        // Stored locale is no longer allowed (e.g., pseudo-locale in prod).
        await _store.write(null);
      }
      if (normalized == value) return;
      value = normalized;
    } catch (e, st) {
      _loadFuture = null;
      Log.warning('Failed to load locale preference', name: 'Locale');
      Log.error('Locale load error', e, st, false, 'Locale');
      // Fail safe: keep `null` (system default).
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final normalized = normalizeLocaleOverride(locale, env: _env);
    if (normalized == value) return;
    value = normalized;
    try {
      await _store.write(normalized);
    } catch (e, st) {
      Log.warning('Failed to persist locale preference', name: 'Locale');
      Log.error('Locale persist error', e, st, false, 'Locale');
    }
  }
}

/// Returns `true` if the locale is one of the Android pseudo-locales.
///
/// We support these only in dev builds and only when explicitly selected.
bool isPseudoLocale(Locale locale) {
  final country = locale.countryCode?.toUpperCase();
  return (locale.languageCode == 'en' && country == 'XA') ||
      (locale.languageCode == 'ar' && country == 'XB');
}

/// Normalizes a user locale override to a safe value.
///
/// Behavior:
/// - `null` remains `null` (system default).
/// - Pseudo-locales are allowed only for [BuildEnv.dev].
/// - Any locale with language `ar` is rejected unless it is exactly `ar-XB`
///   (prevents accidentally matching real Arabic locales to the RTL pseudo-locale).
@visibleForTesting
Locale? normalizeLocaleOverride(Locale? locale, {required BuildEnv env}) {
  if (locale == null) return null;

  final normalized = Locale(
    locale.languageCode.toLowerCase(),
    locale.countryCode?.toUpperCase(),
  );

  // Pseudo locales are available only for dev builds.
  if (isPseudoLocale(normalized) && env != BuildEnv.dev) return null;

  final allowedLocales = supportedLocalesForEnv(
    env: env,
    allSupportedLocales: AppLocalizations.supportedLocales,
  );

  // Prefer exact match.
  for (final supported in allowedLocales) {
    if (_isSameLocale(supported, normalized)) return supported;
  }

  // Fall back to the language-only locale if available (e.g., `en-US` -> `en`).
  for (final supported in allowedLocales) {
    if (supported.languageCode != normalized.languageCode) continue;
    final supportedCountry = supported.countryCode;
    if (supportedCountry == null || supportedCountry.isEmpty) return supported;
  }

  return null;
}

@visibleForTesting
List<Locale> supportedLocalesForEnv({
  required BuildEnv env,
  required List<Locale> allSupportedLocales,
}) {
  final hasRtlPseudo = allSupportedLocales.any(
    (l) => l.languageCode == 'ar' && l.countryCode?.toUpperCase() == 'XB',
  );

  bool isInternalArFallback(Locale l) =>
      hasRtlPseudo &&
      l.languageCode == 'ar' &&
      (l.countryCode == null || l.countryCode!.isEmpty);

  if (env == BuildEnv.dev) {
    return List<Locale>.unmodifiable(
      allSupportedLocales.where((l) => !isInternalArFallback(l)),
    );
  }
  return List<Locale>.unmodifiable(
    allSupportedLocales.where(
      (l) => !isPseudoLocale(l) && !isInternalArFallback(l),
    ),
  );
}

bool _isSameLocale(Locale a, Locale b) =>
    a.languageCode == b.languageCode &&
    (a.countryCode ?? '') == (b.countryCode ?? '');
