import 'package:mobile_core_kit/features/account/data/model/local/cached_user_local_model.dart';
import 'package:sqflite/sqflite.dart';

class CachedUserDao {
  final DatabaseExecutor _db;
  CachedUserDao(this._db);

  Future<void> createTable() async {
    await _db.execute(UserLocalModel.createTableQuery);
  }

  Future<int> insert(UserLocalModel user) async {
    return _db.insert(
      UserLocalModel.tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserLocalModel?> getFirst() async {
    final rows = await _db.query(UserLocalModel.tableName, limit: 1);
    if (rows.isEmpty) return null;
    return UserLocalModel.fromMap(rows.first);
  }

  Future<int> update(UserLocalModel user) async {
    return _db.update(
      UserLocalModel.tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteAll() async {
    return _db.delete(UserLocalModel.tableName);
  }
}
