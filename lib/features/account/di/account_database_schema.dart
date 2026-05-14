import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/dao/cached_user_dao.dart';

class AccountDatabaseSchema {
  static bool _registered = false;

  static void register() {
    if (_registered) return;

    AppDatabase.registerOnCreate((db) async => CachedUserDao(db).createTable());

    _registered = true;
  }
}
