import 'dart:convert';
import 'dart:io';

/// Result of pruning an ARB localization file.
class ArbPruneResult {
  const ArbPruneResult({
    required this.filePath,
    required this.prunedKeysCount,
    required this.prunedKeys,
  });

  final String filePath;
  final int prunedKeysCount;
  final List<String> prunedKeys;
}

/// Prunes ARB keys starting with a given prefix (usually the feature camelCase name)
/// and their corresponding `@key` metadata objects.
class ArbKeyPruner {
  const ArbKeyPruner();

  /// Scans and prunes matching keys from all ARB files in [arbDirectory].
  ///
  /// If [dryRun] is true, files are read but not modified on disk.
  List<ArbPruneResult> pruneDirectory(
    Directory arbDirectory, {
    required String prefix,
    bool dryRun = false,
  }) {
    if (!arbDirectory.existsSync()) return const [];

    final results = <ArbPruneResult>[];
    final arbFiles =
        arbDirectory
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in arbFiles) {
      final result = pruneFile(file, prefix: prefix, dryRun: dryRun);
      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// Prunes matching keys from a single ARB [file].
  ArbPruneResult? pruneFile(
    File file, {
    required String prefix,
    bool dryRun = false,
  }) {
    if (!file.existsSync()) return null;

    final content = file.readAsStringSync();
    if (content.trim().isEmpty) return null;

    final Object? decoded;
    try {
      decoded = json.decode(content);
    } catch (_) {
      return null;
    }

    if (decoded is! Map<String, dynamic>) return null;

    final prunedKeys = <String>[];
    final keysToRemove = <String>{};

    for (final key in decoded.keys) {
      if (key.startsWith(prefix)) {
        keysToRemove.add(key);
        // If it's a regular key, record it (avoid duplicate counting with @key)
        if (!key.startsWith('@')) {
          prunedKeys.add(key);
        }
      } else if (key.startsWith('@') && key.substring(1).startsWith(prefix)) {
        keysToRemove.add(key);
      }
    }

    if (keysToRemove.isEmpty) {
      return ArbPruneResult(
        filePath: file.path,
        prunedKeysCount: 0,
        prunedKeys: const [],
      );
    }

    if (!dryRun) {
      final updatedMap = <String, dynamic>{};
      for (final entry in decoded.entries) {
        if (!keysToRemove.contains(entry.key)) {
          updatedMap[entry.key] = entry.value;
        }
      }

      final encoder = const JsonEncoder.withIndent('  ');
      final newContent = '${encoder.convert(updatedMap)}\n';
      file.writeAsStringSync(newContent);
    }

    return ArbPruneResult(
      filePath: file.path,
      prunedKeysCount: prunedKeys.length,
      prunedKeys: prunedKeys..sort(),
    );
  }
}
