import 'package:flutter/foundation.dart';

import '../adaptive_spec.dart';

sealed class PlatformPolicy {
  const PlatformPolicy();

  const factory PlatformPolicy.standard() = _StandardPlatformPolicy;

  PlatformSpec derive({required TargetPlatform platform});
}

class _StandardPlatformPolicy extends PlatformPolicy {
  const _StandardPlatformPolicy();

  @override
  PlatformSpec derive({required TargetPlatform platform}) {
    return PlatformSpec(platform: platform);
  }
}

