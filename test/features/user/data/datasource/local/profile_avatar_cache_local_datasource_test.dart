import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ProfileAvatarCacheLocalDataSource', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mck_avatar_cache_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('save then get returns entry (not expired)', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime(2026, 1, 1, 0, 0, 0);
      final datasource = ProfileAvatarCacheLocalDataSource(
        prefs: Future.value(prefs),
        ttl: const Duration(days: 7),
        now: () => now,
        supportDir: () async => tempDir,
      );

      final saved = await datasource.save(
        userId: 'u1',
        profileImageFileId: 'file_1',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(saved, isNotNull);
      expect(await File(saved!.filePath).exists(), isTrue);

      final cached = await datasource.get(
        userId: 'u1',
        profileImageFileId: 'file_1',
      );

      expect(cached, isNotNull);
      expect(cached!.filePath, saved.filePath);
      expect(cached.cachedAt, now);
      expect(cached.isExpired, isFalse);
    });

    test('expired cache returns entry with isExpired=true', () async {
      final prefs = await SharedPreferences.getInstance();
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      var now = t0;
      final datasource = ProfileAvatarCacheLocalDataSource(
        prefs: Future.value(prefs),
        ttl: const Duration(days: 7),
        now: () => now,
        supportDir: () async => tempDir,
      );

      await datasource.save(
        userId: 'u1',
        profileImageFileId: 'file_1',
        bytes: Uint8List.fromList([1]),
      );

      now = t0.add(const Duration(days: 8));

      final cached = await datasource.get(
        userId: 'u1',
        profileImageFileId: 'file_1',
      );

      expect(cached, isNotNull);
      expect(cached!.isExpired, isTrue);
      expect(await File(cached.filePath).exists(), isTrue);
    });

    test('missing file clears prefs and returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      final datasource = ProfileAvatarCacheLocalDataSource(
        prefs: Future.value(prefs),
        supportDir: () async => tempDir,
      );

      final saved = await datasource.save(
        userId: 'u1',
        profileImageFileId: 'file_1',
        bytes: Uint8List.fromList([1]),
      );

      expect(saved, isNotNull);
      final file = File(saved!.filePath);
      expect(await file.exists(), isTrue);
      await file.delete();

      final cached = await datasource.get(
        userId: 'u1',
        profileImageFileId: 'file_1',
      );

      expect(cached, isNull);
      expect(prefs.getString('user_profile_avatar_file_id:u1'), isNull);
      expect(prefs.getInt('user_profile_avatar_cached_at:u1'), isNull);
    });

    test('fileId mismatch invalidates cache and returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      final datasource = ProfileAvatarCacheLocalDataSource(
        prefs: Future.value(prefs),
        supportDir: () async => tempDir,
      );

      final saved = await datasource.save(
        userId: 'u1',
        profileImageFileId: 'file_1',
        bytes: Uint8List.fromList([1]),
      );

      expect(saved, isNotNull);
      expect(await File(saved!.filePath).exists(), isTrue);

      final cached = await datasource.get(
        userId: 'u1',
        profileImageFileId: 'file_2',
      );

      expect(cached, isNull);
      expect(await File(saved.filePath).exists(), isFalse);
      expect(prefs.getString('user_profile_avatar_file_id:u1'), isNull);
      expect(prefs.getInt('user_profile_avatar_cached_at:u1'), isNull);
    });

    test('clear removes file and prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      final datasource = ProfileAvatarCacheLocalDataSource(
        prefs: Future.value(prefs),
        supportDir: () async => tempDir,
      );

      final saved = await datasource.save(
        userId: 'u1',
        profileImageFileId: 'file_1',
        bytes: Uint8List.fromList([1]),
      );

      expect(saved, isNotNull);
      expect(await File(saved!.filePath).exists(), isTrue);

      await datasource.clear(userId: 'u1');

      expect(await File(saved.filePath).exists(), isFalse);
      expect(prefs.getString('user_profile_avatar_file_id:u1'), isNull);
      expect(prefs.getInt('user_profile_avatar_cached_at:u1'), isNull);
    });
  });
}
