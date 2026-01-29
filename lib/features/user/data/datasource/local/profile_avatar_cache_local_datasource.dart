import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Disk-backed cache for the current user's profile avatar.
///
/// This cache stores:
/// - the image bytes as a file under app-internal storage, and
/// - metadata (cached timestamp + profileImageFileId) in SharedPreferences.
///
/// Contract:
/// - Cache is scoped per user (`<userId>` directory + per-user preference keys).
/// - Cache is invalidated when the current `profileImageFileId` differs from the
///   stored one (prevents stale images after account/profile updates).
/// - Cache is considered expired when `now - cachedAt >= ttl`.
/// - If `profileImageFileId` is null/empty, cache is cleared (no avatar set).
/// - Fail-safe: corrupted metadata or missing files are cleared.
class ProfileAvatarCacheLocalDataSource {
  ProfileAvatarCacheLocalDataSource({
    Future<SharedPreferences>? prefs,
    Duration ttl = const Duration(days: 7),
    DateTime Function()? now,
    Future<Directory> Function()? supportDir,
  }) : _prefsFuture = prefs ?? SharedPreferences.getInstance(),
       _ttl = ttl,
       _now = now ?? DateTime.now,
       _supportDir = supportDir ?? getApplicationSupportDirectory;

  static const String _kCachedAtPrefix = 'user_profile_avatar_cached_at:';
  static const String _kFileIdPrefix = 'user_profile_avatar_file_id:';
  static const String _kRootDir = 'user/profile_avatar';
  static const String _kFileName = 'avatar.bin';

  final Future<SharedPreferences> _prefsFuture;
  final Duration _ttl;
  final DateTime Function() _now;
  final Future<Directory> Function() _supportDir;

  /// Returns cached entry when:
  /// - cache exists on disk, and
  /// - metadata is valid, and
  /// - stored fileId matches current [profileImageFileId].
  ///
  /// Returns `null` (and clears any stale cache) when:
  /// - [profileImageFileId] is null/empty (no avatar set), or
  /// - cache is missing/corrupt/mismatched.
  Future<ProfileAvatarCacheEntryLocal?> get({
    required String userId,
    required String? profileImageFileId,
  }) async {
    final normalizedUserId = _normalizeId(userId);
    if (normalizedUserId == null) return null;

    final currentFileId = _normalizeId(profileImageFileId);
    if (currentFileId == null) {
      await clear(userId: normalizedUserId);
      return null;
    }

    final prefs = await _prefsFuture;

    final storedFileId = _normalizeId(
      prefs.getString(_fileIdKeyFor(normalizedUserId)),
    );
    final cachedAtMs = prefs.getInt(_cachedAtKeyFor(normalizedUserId));

    // If metadata is missing/corrupt, clear cache (fail-safe).
    if (storedFileId == null || cachedAtMs == null) {
      await clear(userId: normalizedUserId);
      return null;
    }

    // If the backend's fileId changed, invalidate local cache.
    if (storedFileId != currentFileId) {
      await clear(userId: normalizedUserId);
      return null;
    }

    final file = File(await _filePathFor(normalizedUserId));
    final exists = await file.exists();
    if (!exists) {
      await _clearPrefsForUser(prefs, normalizedUserId);
      return null;
    }

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
    final age = _now().difference(cachedAt);
    final isExpired = age >= _ttl;

    return ProfileAvatarCacheEntryLocal(
      filePath: file.path,
      cachedAt: cachedAt,
      isExpired: isExpired,
    );
  }

  /// Saves bytes to disk and updates metadata (cachedAt + profileImageFileId).
  ///
  /// Returns `null` if input IDs are invalid.
  Future<ProfileAvatarCacheEntryLocal?> save({
    required String userId,
    required String profileImageFileId,
    required Uint8List bytes,
  }) async {
    final normalizedUserId = _normalizeId(userId);
    final normalizedFileId = _normalizeId(profileImageFileId);
    if (normalizedUserId == null || normalizedFileId == null) return null;

    final path = await _filePathFor(normalizedUserId);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    final now = _now();
    final prefs = await _prefsFuture;
    await prefs.setInt(
      _cachedAtKeyFor(normalizedUserId),
      now.millisecondsSinceEpoch,
    );
    await prefs.setString(_fileIdKeyFor(normalizedUserId), normalizedFileId);

    return ProfileAvatarCacheEntryLocal(
      filePath: file.path,
      cachedAt: now,
      isExpired: false,
    );
  }

  Future<void> clear({required String userId}) async {
    final normalizedUserId = _normalizeId(userId);
    if (normalizedUserId == null) return;

    final prefs = await _prefsFuture;
    await _deleteFileForUser(normalizedUserId);
    await _clearPrefsForUser(prefs, normalizedUserId);
  }

  /// Clears avatar cache for all users.
  ///
  /// Used for safety on logout/session cleared without requiring a user ID.
  Future<void> clearAll() async {
    final prefs = await _prefsFuture;
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_kCachedAtPrefix) || key.startsWith(_kFileIdPrefix)) {
        await prefs.remove(key);
      }
    }

    final rootDir = Directory(await _rootDirPath());
    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
  }

  String _cachedAtKeyFor(String userId) => '$_kCachedAtPrefix$userId';

  String _fileIdKeyFor(String userId) => '$_kFileIdPrefix$userId';

  Future<String> _filePathFor(String userId) async {
    final root = await _rootDirPath();
    return p.join(root, userId, _kFileName);
  }

  Future<String> _rootDirPath() async {
    final dir = await _supportDir();
    return p.join(dir.path, _kRootDir);
  }

  Future<void> _deleteFileForUser(String userId) async {
    final file = File(await _filePathFor(userId));
    if (await file.exists()) {
      await file.delete();
    }

    final userDir = file.parent;
    if (await userDir.exists()) {
      // If the directory is empty after deleting, remove it to avoid clutter.
      final entries = await userDir.list(followLinks: false).isEmpty;
      if (entries) {
        await userDir.delete();
      }
    }
  }

  Future<void> _clearPrefsForUser(
    SharedPreferences prefs,
    String userId,
  ) async {
    await prefs.remove(_cachedAtKeyFor(userId));
    await prefs.remove(_fileIdKeyFor(userId));
  }

  String? _normalizeId(String? raw) {
    final normalized = raw?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    // Fail-safe: prevent path traversal / invalid directory names.
    if (normalized.contains('/') || normalized.contains('\\')) return null;
    if (normalized.contains('..')) return null;

    return normalized;
  }
}

class ProfileAvatarCacheEntryLocal {
  const ProfileAvatarCacheEntryLocal({
    required this.filePath,
    required this.cachedAt,
    required this.isExpired,
  });

  final String filePath;
  final DateTime cachedAt;
  final bool isExpired;
}
