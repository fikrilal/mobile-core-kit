import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_draft_local_datasource.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const key = 'user_profile_draft:u1';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saveDraft then getDraft returns entity', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime(2026, 1, 1, 0, 0, 0);
    final datasource = ProfileDraftLocalDataSource(
      prefs: Future.value(prefs),
      now: () => now,
    );

    await datasource.saveDraft(
      userId: 'u1',
      draft: ProfileDraftEntity(
        givenName: 'John',
        familyName: 'Doe',
        displayName: null,
        updatedAt: now,
      ),
    );

    final result = await datasource.getDraft(userId: 'u1');

    expect(result, isNotNull);
    expect(result!.givenName, 'John');
    expect(result.familyName, 'Doe');
    expect(result.displayName, isNull);
    expect(result.updatedAt, now);
  });

  test('clearDraft removes entity', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime(2026, 1, 1, 0, 0, 0);
    final datasource = ProfileDraftLocalDataSource(
      prefs: Future.value(prefs),
      now: () => now,
    );

    await datasource.saveDraft(
      userId: 'u1',
      draft: ProfileDraftEntity(
        givenName: 'John',
        familyName: 'Doe',
        displayName: null,
        updatedAt: now,
      ),
    );

    await datasource.clearDraft(userId: 'u1');

    final result = await datasource.getDraft(userId: 'u1');
    expect(result, isNull);
  });

  test('expired draft returns null and clears persisted value', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime(2026, 1, 8, 0, 0, 0);
    final datasource = ProfileDraftLocalDataSource(
      prefs: Future.value(prefs),
      ttl: const Duration(days: 7),
      now: () => now,
    );

    await datasource.saveDraft(
      userId: 'u1',
      draft: ProfileDraftEntity(
        givenName: 'John',
        familyName: 'Doe',
        displayName: null,
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
    );

    final result = await datasource.getDraft(userId: 'u1');
    expect(result, isNull);
    expect(prefs.getString(key), isNull);
  });

  test(
    'invalid draft payload returns null and clears persisted value',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{key: 'not json'});

      final prefs = await SharedPreferences.getInstance();
      final datasource = ProfileDraftLocalDataSource(
        prefs: Future.value(prefs),
      );

      final result = await datasource.getDraft(userId: 'u1');
      expect(result, isNull);
      expect(prefs.getString(key), isNull);
    },
  );
}
