import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';

class AccountCachedUserStoreAdapter implements CachedUserStore {
  AccountCachedUserStoreAdapter(this._datasource);

  final UserLocalDataSource _datasource;

  @override
  Future<UserEntity?> read() => _datasource.getCachedMe();

  @override
  Future<void> write(UserEntity user) => _datasource.cacheMe(user);

  @override
  Future<void> clear() => _datasource.clearMe();
}
