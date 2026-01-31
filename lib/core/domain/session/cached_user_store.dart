import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';

/// Core abstraction for caching the current signed-in user ("me") locally.
///
/// This exists so runtime session orchestration can persist user data without depending on a
/// feature-local database implementation.
abstract class CachedUserStore {
  Future<UserEntity?> read();
  Future<void> write(UserEntity user);
  Future<void> clear();
}
