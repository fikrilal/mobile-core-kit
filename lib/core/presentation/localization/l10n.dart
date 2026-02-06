import 'package:flutter/widgets.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// Ergonomic access to app localizations.
///
/// Usage:
/// - `context.l10n.commonOk`
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
