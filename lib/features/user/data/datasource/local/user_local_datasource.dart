import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/user/data/model/local/user_local_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalDataSource {
  const UserLocalDataSource({Future<Database> Function()? database})
    : _database = database;

  final Future<Database> Function()? _database;

  Future<Database> get _db => (_database ?? () => AppDatabase().database)();

  Future<UserEntity?> getCachedMe() async => read();

  Future<void> cacheMe(UserEntity user) async => write(user);

  Future<void> clearMe() async => clear();

  Future<UserEntity?> read() async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.createTable();
    final model = await dao.getFirst();
    return model?.toEntity();
  }

  Future<void> write(UserEntity user) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dao = UserDao(txn);
      await dao.createTable();
      await dao.deleteAll();
      await dao.insert(user.toLocalModel());
    });
  }

  Future<void> clear() async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.createTable();
    await dao.deleteAll();
  }
}
