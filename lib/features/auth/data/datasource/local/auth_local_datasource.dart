import '../../../../../core/database/app_database.dart';
import '../../model/local/user_local_model.dart';
import '../../../../user/domain/entity/user_entity.dart';
import 'dao/user_dao.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  Future get _db async => AppDatabase().database;

  Future cacheUserEntity(UserEntity user) async => cacheUser(
        user.toLocalModel(),
      );

  Future cacheUser(UserLocalModel user) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dao = UserDao(txn);
      await dao.createTable();
      await dao.deleteAll();
      await dao.insert(user);
    });
  }

  Future<UserLocalModel?> getCachedUser() async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.createTable();
    return dao.getFirst();
  }

  Future updateCachedUser(UserLocalModel user) async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.createTable();
    final existing = await dao.getFirst();
    if (existing != null) {
      await dao.update(UserLocalModel(
        id: existing.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        emailVerified: user.emailVerified,
      ));
    }
  }

  Future clearAll() async {
    final db = await _db;
    final dao = UserDao(db);
    await dao.createTable();
    await dao.deleteAll();
  }
}
