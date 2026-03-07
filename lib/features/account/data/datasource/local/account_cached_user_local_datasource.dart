import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/dao/cached_user_dao.dart';
import 'package:mobile_core_kit/features/account/data/model/local/cached_user_local_model.dart';
import 'package:sqflite/sqflite.dart';

class AccountCachedUserLocalDataSource {
  const AccountCachedUserLocalDataSource({
    Future<Database> Function()? database,
  }) : _database = database;

  final Future<Database> Function()? _database;

  Future<Database> get _db => (_database ?? () => AppDatabase().database)();

  Future<UserEntity?> read() async {
    final db = await _db;
    final dao = CachedUserDao(db);
    await dao.createTable();
    final model = await dao.getFirst();
    return model?.toEntity();
  }

  Future<void> write(UserEntity user) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dao = CachedUserDao(txn);
      await dao.createTable();
      await dao.deleteAll();
      await dao.insert(user.toLocalModel());
    });
  }

  Future<void> clear() async {
    final db = await _db;
    final dao = CachedUserDao(db);
    await dao.createTable();
    await dao.deleteAll();
  }
}
