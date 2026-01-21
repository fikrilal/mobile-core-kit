import 'dart:convert';

/// Minimal JWT helpers for client-side token introspection.
///
/// Important:
/// - This does **not** verify signatures.
/// - This is intended only for convenience (e.g. expiry derivation) and must
///   never be used for authorization decisions.
class JwtUtils {
  JwtUtils._();

  /// Attempts to decode the JWT payload (the middle `.<payload>.` segment).
  ///
  /// Returns `null` if the token is not a JWT or cannot be decoded.
  static Map<String, dynamic>? tryDecodePayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;

    final payloadPart = parts[1];
    try {
      final normalized = base64Url.normalize(payloadPart);
      final payloadBytes = base64Url.decode(normalized);
      final jsonStr = utf8.decode(payloadBytes);
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Attempts to read the JWT `exp` claim and convert it into a [DateTime].
  ///
  /// The `exp` claim is expected to be seconds since epoch (UTC), per RFC7519.
  static DateTime? tryGetExpiresAt(String jwt) {
    final payload = tryDecodePayload(jwt);
    if (payload == null) return null;

    final seconds = _tryParseEpochSeconds(payload['exp']);
    if (seconds == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Computes a stable expiry tuple derived from the JWT `exp` claim.
  ///
  /// Returns `null` if `exp` is missing or the token cannot be decoded.
  ///
  /// - `expiresAt`: the absolute token expiry time (UTC).
  /// - `expiresIn`: seconds remaining, clamped to `>= 0`.
  static ({DateTime expiresAt, int expiresIn})? tryComputeExpiry(
    String jwt, {
    DateTime? now,
  }) {
    final expiresAt = tryGetExpiresAt(jwt);
    if (expiresAt == null) return null;

    final reference = now ?? DateTime.now();
    final remaining = expiresAt.difference(reference).inSeconds;

    return (
      expiresAt: expiresAt,
      expiresIn: remaining < 0 ? 0 : remaining,
    );
  }

  static int? _tryParseEpochSeconds(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

