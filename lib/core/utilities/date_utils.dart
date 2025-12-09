import 'package:intl/intl.dart';

/// Date formatting helpers for the app.
///
/// These helpers are intentionally small and semantic so that
/// feature-specific formats can live closer to their domains.
class AppDateUtils {
  AppDateUtils._();

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
      final m = (date.month >= 1 && date.month <= 12) ? months[date.month - 1] : '';
      return '$m ${date.year}';
    }
  }

  /// Formats a date in a short, locale-aware form like "Jan 5, 2025".
  static String formatShortDate(DateTime date) {
    try {
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      // Fallback: "YYYY-MM-DD"
      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      return '${date.year}-$mm-$dd';
    }
  }

  /// Formats a date in a long, locale-aware form like "January 5, 2025".
  static String formatLongDate(DateTime date) {
    try {
      return DateFormat.yMMMMd().format(date);
    } catch (_) {
      return formatShortDate(date);
    }
  }

  /// Formats a time in a short, locale-aware form like "14:30" or "2:30 PM".
  static String formatTime(DateTime date) {
    try {
      return DateFormat.jm().format(date);
    } catch (_) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
  }

  /// Generic formatter using a custom pattern.
  /// Prefer the semantic helpers above where possible.
  static String formatWithPattern(DateTime date, String pattern) {
    try {
      return DateFormat(pattern).format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }
}
