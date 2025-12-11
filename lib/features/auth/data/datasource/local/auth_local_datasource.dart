import '../../../../../core/database/app_database.dart';
import '../../model/local/user_local_model.dart';
import 'dao/user_dao.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  Future get _db async => AppDatabase().database;

  Future cacheUser(UserLocalModel user) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dao = UserDao(txn);
      await dao.deleteAll();
      await dao.insert(user);
    });
  }

  Future<UserLocalModel?> getCachedUser() async {
    final db = await _db;
    final dao = UserDao(db);
    return dao.getFirst();
  }

  Future updateCachedUser(UserLocalModel user) async {
    final db = await _db;
    final dao = UserDao(db);
    final existing = await dao.getFirst();
    if (existing != null) {
      await dao.update(UserLocalModel(
        id: existing.id,
        email: user.email,
        displayName: user.displayName,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
        avatarUrl: user.avatarUrl,
      ));
    }
  }

  Future clearAll() async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.deleteAll();
  }
}
