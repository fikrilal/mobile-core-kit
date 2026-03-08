import 'package:intl/intl.dart';

/// Date formatting helpers for the app.
///
/// These helpers are intentionally small and semantic so that
/// feature-specific formats can live closer to their domains.
class AppDateUtils {
  AppDateUtils._();

  /// Parses a nullable ISO date/time string and formats it as a long date.
  ///
  /// Returns `null` when the input is null, blank, or cannot be parsed.
  static String? tryFormatLongDateFromIso(
    String? isoDateTime, {
    String? locale,
  }) {
    if (isoDateTime == null || isoDateTime.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(isoDateTime);
    if (parsed == null) return null;
    return formatLongDate(parsed.toLocal(), locale: locale);
  }

  /// Formats a date like "May 2020" using Intl when available.
  static String formatMonthYear(DateTime date) {
    try {
      return DateFormat('MMM yyyy').format(date);
    } catch (_) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final m = (date.month >= 1 && date.month <= 12)
          ? months[date.month - 1]
          : '';
      return '$m ${date.year}';
    }
  }

  /// Formats a date in a short, locale-aware form like "Jan 5, 2025".
  static String formatShortDate(DateTime date, {String? locale}) {
    try {
      return DateFormat.yMMMd(locale).format(date);
    } catch (_) {
      // Fallback: "YYYY-MM-DD"
      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      return '${date.year}-$mm-$dd';
    }
  }

  /// Formats a date in a long, locale-aware form like "January 5, 2025".
  static String formatLongDate(DateTime date, {String? locale}) {
    try {
      return DateFormat.yMMMMd(locale).format(date);
    } catch (_) {
      return formatShortDate(date, locale: locale);
    }
  }

  /// Formats a time in a short, locale-aware form like "14:30" or "2:30 PM".
  static String formatTime(DateTime date, {String? locale}) {
    try {
      return DateFormat.jm(locale).format(date);
    } catch (_) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
  }

  /// Formats a date and time in a short, locale-aware form like
  /// "Jan 5, 2025 2:30 PM".
  static String formatShortDateTime(DateTime date, {String? locale}) {
    try {
      return DateFormat.yMMMd(locale).add_jm().format(date);
    } catch (_) {
      return '${formatShortDate(date, locale: locale)} ${formatTime(date, locale: locale)}';
    }
  }

  /// Generic formatter using a custom pattern.
  /// Prefer the semantic helpers above where possible.
  static String formatWithPattern(
    DateTime date,
    String pattern, {
    String? locale,
  }) {
    try {
      return DateFormat(pattern, locale).format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }
}
