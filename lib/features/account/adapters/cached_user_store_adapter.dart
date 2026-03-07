import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/account_cached_user_local_datasource.dart';

class AccountCachedUserStoreAdapter implements CachedUserStore {
  AccountCachedUserStoreAdapter(this._datasource);

  final AccountCachedUserLocalDataSource _datasource;

  @override
  Future<UserEntity?> read() => _datasource.read();

  @override
  Future<void> write(UserEntity user) => _datasource.write(user);

  @override
  Future<void> clear() => _datasource.clear();
}
