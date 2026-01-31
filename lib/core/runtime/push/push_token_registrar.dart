import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/platform/push/push_platform.dart';

/// Core abstraction for registering/revoking push tokens for the current session.
///
/// Backend contract (backend-core-kit):
/// - `PUT /v1/me/push-token` (idempotent)
/// - `DELETE /v1/me/push-token` (idempotent)
///
/// The user feature provides the implementation via DI (because `/me/*` belongs
/// to the user feature).
abstract class PushTokenRegistrar {
  Future<ApiResponse<ApiNoData>> upsert({
    required PushPlatform platform,
    required String token,
  });

  Future<ApiResponse<ApiNoData>> revoke();
}
