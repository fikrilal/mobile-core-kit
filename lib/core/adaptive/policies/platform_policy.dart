import 'package:flutter/foundation.dart';

import '../adaptive_spec.dart';

/// Policy for deriving [PlatformSpec].
///
/// This is a thin wrapper to keep platform handling explicit and testable.
sealed class PlatformPolicy {
  const PlatformPolicy();

  /// Standard policy: reflects the given [TargetPlatform].
  const factory PlatformPolicy.standard() = _StandardPlatformPolicy;

  /// Derives [PlatformSpec] from the current platform signal.
  PlatformSpec derive({required TargetPlatform platform});
}

class _StandardPlatformPolicy extends PlatformPolicy {
  const _StandardPlatformPolicy();

  @override
  PlatformSpec derive({required TargetPlatform platform}) {
    return PlatformSpec(platform: platform);
  }
}
