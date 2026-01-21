import 'dart:math';

/// Utilities for generating request-scoped idempotency keys.
///
/// Backend contract:
/// - Idempotency keys are required to safely retry write requests
///   (POST/PUT/PATCH/DELETE) after an auth refresh.
/// - Keys are treated as opaque strings (UUIDv4 is recommended server-side),
///   with a max length of 128 characters.
abstract final class IdempotencyKeyUtils {
  static final Random _random = Random.secure();

  /// Generates a random hex string suitable for `Idempotency-Key`.
  ///
  /// Default: 16 bytes (32 hex chars).
  static String generate({int bytes = 16}) {
    final buffer = StringBuffer();
    for (var i = 0; i < bytes; i++) {
      final value = _random.nextInt(256);
      buffer.write(value.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
