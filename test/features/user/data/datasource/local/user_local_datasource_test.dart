import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/database/app_database.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/di/user_module.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('UserLocalDataSource', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mck_user_db_');
      AppDatabase.basePathOverride = () async => tempDir.path;
      await AppDatabase().deleteDb();
    });

    tearDown(() async {
      await AppDatabase().deleteDb();
      AppDatabase.basePathOverride = null;
      await tempDir.delete(recursive: true);
    });

    test('cacheMe then getCachedMe returns entity', () async {
      const user = UserEntity(
        id: 'u1',
        email: 'user@example.com',
        emailVerified: true,
        roles: ['USER'],
        authMethods: ['PASSWORD', 'GOOGLE'],
        profile: UserProfileEntity(
          profileImageFileId: 'file-1',
          displayName: 'Dante',
          givenName: 'First',
          familyName: 'Last',
        ),
        accountDeletion: AccountDeletionEntity(
          requestedAt: '2026-01-20T00:00:00.000Z',
          scheduledFor: '2026-02-01T00:00:00.000Z',
        ),
      );

      const datasource = UserLocalDataSource();

      await datasource.cacheMe(user);
      final cached = await datasource.getCachedMe();

      expect(cached, isNotNull);
      expect(cached?.id, user.id);
      expect(cached?.email, user.email);
      expect(cached?.emailVerified, user.emailVerified);
      expect(cached?.roles, user.roles);
      expect(cached?.authMethods, user.authMethods);
      expect(cached?.profile.givenName, user.profile.givenName);
      expect(cached?.profile.familyName, user.profile.familyName);
      expect(
        cached?.profile.profileImageFileId,
        user.profile.profileImageFileId,
      );
      expect(cached?.profile.displayName, user.profile.displayName);
      expect(cached?.accountDeletion, user.accountDeletion);
    });

    test('clearMe removes entity', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      const datasource = UserLocalDataSource();

      await datasource.cacheMe(user);
      expect(await datasource.getCachedMe(), isNotNull);

      await datasource.clearMe();
      expect(await datasource.getCachedMe(), isNull);
    });
  });

  group('User database schema', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mck_user_db_schema_');
      AppDatabase.basePathOverride = () async => tempDir.path;
      await AppDatabase().deleteDb();
    });

    tearDown(() async {
      await AppDatabase().deleteDb();
      AppDatabase.basePathOverride = null;
      await tempDir.delete(recursive: true);
    });

    test(
      'UserModule registers users table via AppDatabase onCreate tasks',
      () async {
        final getIt = GetIt.asNewInstance();
        getIt.registerLazySingleton<ApiHelper>(() => _MockApiHelper());

        UserModule.register(getIt);

        final db = await AppDatabase().database;
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
        );

        expect(tables, isNotEmpty);

        await getIt.reset();
      },
    );
  });

  group('User database migrations', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mck_user_db_migration_');
      AppDatabase.basePathOverride = () async => tempDir.path;
      await AppDatabase().deleteDb();
    });

    tearDown(() async {
      await AppDatabase().deleteDb();
      AppDatabase.basePathOverride = null;
      await tempDir.delete(recursive: true);
    });

    test(
      'migrates users cache from v1 to v2 by recreating the table',
      () async {
        final path = p.join(tempDir.path, 'mobile_core_kit.db');

        final dbV1 = await openDatabase(
          path,
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS users ('
              'id TEXT PRIMARY KEY,'
              'email TEXT,'
              'firstName TEXT,'
              'lastName TEXT,'
              'emailVerified INTEGER,'
              'createdAt TEXT'
              ');',
            );
            await db.insert('users', {
              'id': 'old',
              'email': 'old@example.com',
              'firstName': 'Old',
              'lastName': 'User',
              'emailVerified': 1,
              'createdAt': '2026-01-01',
            });
          },
        );
        await dbV1.close();

        final getIt = GetIt.asNewInstance();
        getIt.registerLazySingleton<ApiHelper>(() => _MockApiHelper());
        UserModule.register(getIt);

        final db = await AppDatabase().database;

        final columns = await db.rawQuery("PRAGMA table_info('users')");
        final columnNames = columns
            .map((r) => r['name'])
            .whereType<String>()
            .toSet();

        expect(columnNames.contains('rolesJson'), isTrue);
        expect(columnNames.contains('authMethodsJson'), isTrue);
        expect(columnNames.contains('givenName'), isTrue);
        expect(columnNames.contains('familyName'), isTrue);
        expect(columnNames.contains('firstName'), isFalse);
        expect(columnNames.contains('lastName'), isFalse);
        expect(columnNames.contains('createdAt'), isFalse);

        final rows = await db.query('users');
        expect(rows, isEmpty);

        await getIt.reset();
      },
    );
  });
}
