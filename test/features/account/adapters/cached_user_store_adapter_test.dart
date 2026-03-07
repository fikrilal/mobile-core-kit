import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/adapters/cached_user_store_adapter.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/account_cached_user_local_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountCachedUserLocalDataSource extends Mock
    implements AccountCachedUserLocalDataSource {}

void main() {
  group('AccountCachedUserStoreAdapter', () {
    test('delegates reads to the local datasource', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      final datasource = _MockAccountCachedUserLocalDataSource();
      final adapter = AccountCachedUserStoreAdapter(datasource);

      when(() => datasource.read()).thenAnswer((_) async => user);

      expect(await adapter.read(), user);
    });

    test('delegates writes and clears to the local datasource', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      final datasource = _MockAccountCachedUserLocalDataSource();
      final adapter = AccountCachedUserStoreAdapter(datasource);

      when(() => datasource.write(user)).thenAnswer((_) async {});
      when(() => datasource.clear()).thenAnswer((_) async {});

      await adapter.write(user);
      await adapter.clear();

      verify(() => datasource.write(user)).called(1);
      verify(() => datasource.clear()).called(1);
    });
  });
}
