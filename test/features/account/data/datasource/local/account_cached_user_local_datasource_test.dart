import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/di/registrars/database_schema_registrar.dart';
import 'package:mobile_core_kit/core/domain/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/account_cached_user_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AccountCachedUserLocalDataSource', () {
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

    test('write then read returns entity', () async {
      const user = UserEntity(
        id: 'u1',
        email: 'user@example.com',
        emailVerified: true,
        roles: ['USER'],
        authMethods: ['PASSWORD'],
        profile: UserProfileEntity(
          profileImageFileId: 'file_1',
          displayName: 'First Last',
          givenName: 'First',
          familyName: 'Last',
        ),
        accountDeletion: AccountDeletionEntity(
          requestedAt: '2026-01-01T00:00:00Z',
          scheduledFor: '2026-02-01T00:00:00Z',
        ),
      );

      const datasource = AccountCachedUserLocalDataSource();

      await datasource.write(user);
      final cached = await datasource.read();

      expect(cached, isNotNull);
      expect(cached, user);
    });

    test('clear removes entity', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      const datasource = AccountCachedUserLocalDataSource();

      await datasource.write(user);
      expect(await datasource.read(), isNotNull);

      await datasource.clear();
      expect(await datasource.read(), isNull);
    });
  });

  group('Cached user database schema', () {
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
      'database schema registrar registers users table via AppDatabase onCreate tasks',
      () async {
        registerDatabaseSchema(GetIt.asNewInstance());

        final db = await AppDatabase().database;
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
        );

        expect(tables, isNotEmpty);

        final columns = await db.rawQuery('PRAGMA table_info(users)');
        final columnNames = columns
            .map((c) => c['name'])
            .whereType<String>()
            .toSet();
        expect(columnNames, contains('rolesJson'));
        expect(columnNames, contains('authMethodsJson'));
        expect(columnNames, contains('displayName'));
        expect(columnNames, contains('givenName'));
        expect(columnNames, contains('familyName'));
      },
    );
  });
}
