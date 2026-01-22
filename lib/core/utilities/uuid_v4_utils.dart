import 'dart:math';

/// UUID v4 generator (RFC 4122).
///
/// This is used for:
/// - Request correlation IDs (`X-Request-Id`)
/// - Stable device identifiers (`deviceId`) sent to the backend as metadata
abstract final class UuidV4Utils {
  static String generate({Random? random}) {
    final rng = random ?? _secureOrFallbackRandom();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));

    // RFC 4122 section 4.4:
    // - Set the four most significant bits of the 7th byte to 0100'B (version 4).
    // - Set the two most significant bits of the 9th byte to 10'B (variant 1).
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return _format(bytes);
  }

  static Random _secureOrFallbackRandom() {
    try {
      return Random.secure();
    } catch (_) {
      // Web does not support Random.secure().
      return Random();
    }
  }

  static String _format(List<int> bytes) {
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
