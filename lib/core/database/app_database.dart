import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef DbTask = Future<void> Function(Database db);
typedef DbBasePathProvider = Future<String> Function();

class DatabaseMigration {
  const DatabaseMigration({
    required this.fromVersion,
    required this.toVersion,
    required this.migrate,
  }) : assert(
         toVersion > fromVersion,
         'Migration toVersion must be greater than fromVersion',
       );

  final int fromVersion;
  final int toVersion;
  final DbTask migrate;
}

class AppDatabase {
  static const _dbName = 'mobile_core_kit.db';
  static const _dbVersion = 2;

  /// Override used by tests to avoid platform-channel directory lookups.
  static DbBasePathProvider? basePathOverride;

  AppDatabase._internal();
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  Database? _db;

  static final List<DbTask> _onCreateTasks = <DbTask>[];
  static final List<DatabaseMigration> _migrations = <DatabaseMigration>[];

  static void registerOnCreate(DbTask task) => _onCreateTasks.add(task);

  static void registerMigration(DatabaseMigration migration) =>
      _migrations.add(migration);

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final String basePath;
    final override = basePathOverride;
    if (override != null) {
      basePath = await override();
    } else {
      final Directory dir = await getApplicationDocumentsDirectory();
      basePath = dir.path;
    }

    final String path = join(basePath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final task in _onCreateTasks) {
      await task(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion >= newVersion) return;
    if (_migrations.isEmpty) {
      throw StateError(
        'Database upgraded from $oldVersion to $newVersion but no migrations are registered.',
      );
    }
    final sortedMigrations = List<DatabaseMigration>.from(_migrations)
      ..sort((a, b) => a.fromVersion.compareTo(b.fromVersion));
    var versionCursor = oldVersion;
    while (versionCursor < newVersion) {
      final migration = sortedMigrations.firstWhere(
        (m) => m.fromVersion == versionCursor,
        orElse: () => throw StateError(
          'Missing migration for database upgrade path '
          '$versionCursor -> $newVersion.',
        ),
      );
      await migration.migrate(db);
      versionCursor = migration.toVersion;
    }
  }

  Future<void> deleteDb() async {
    final String basePath;
    final override = basePathOverride;
    if (override != null) {
      basePath = await override();
    } else {
      final Directory dir = await getApplicationDocumentsDirectory();
      basePath = dir.path;
    }

    final String path = join(basePath, _dbName);
    final existing = _db;
    _db = null;
    if (existing != null) {
      await existing.close();
    }
    await deleteDatabase(path);
  }
}
