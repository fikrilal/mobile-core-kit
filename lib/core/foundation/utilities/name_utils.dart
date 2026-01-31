class NameUtils {
  /// Returns 1–2 uppercase initials from a display name or email.
  /// - "Jane Doe" -> "JD"
  /// - "single" -> "S"
  /// - "user@example.com" -> "UE"
  static String? initialsFrom(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    final s = source.trim();
    final parts = s.split(RegExp('\\s+'));
    if (parts.length >= 2) {
      final a = parts[0].isNotEmpty ? parts[0][0] : '';
      final b = parts[1].isNotEmpty ? parts[1][0] : '';
      final ini = (a.toString() + b.toString()).toUpperCase();
      return ini.isEmpty ? null : ini;
    }
    if (s.contains('@')) {
      final p = s.split('@');
      final a = p[0].isNotEmpty ? p[0][0] : '';
      final b = p.length > 1 && p[1].isNotEmpty ? p[1][0] : '';
      final ini = (a.toString() + b.toString()).toUpperCase();
      return ini.isEmpty ? null : ini;
    }
    return s[0].toUpperCase();
  }
}
