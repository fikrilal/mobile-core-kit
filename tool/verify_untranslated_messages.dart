import 'dart:convert';
import 'dart:io';

const String _defaultPath = 'tool/untranslated_messages.json';

Future<void> main(List<String> args) async {
  exitCode = await _run(args);
}

Future<int> _run(List<String> args) async {
  final path = args.isNotEmpty ? args.first : _defaultPath;
  final file = File(path);

  if (!file.existsSync()) {
    stderr.writeln('Missing untranslated messages file at "$path".');
    stderr.writeln('Run: flutter gen-l10n');
    return 2;
  }

  dynamic decoded;
  try {
    final raw = await file.readAsString();
    decoded = jsonDecode(raw);
  } catch (e) {
    stderr.writeln('Failed to read/parse "$path": $e');
    return 2;
  }

  if (_isEmpty(decoded)) {
    stdout.writeln('OK: no untranslated messages found.');
    return 0;
  }

  final keys = <String>{};
  _collectKeys(decoded, keys);

  stderr.writeln('Found untranslated localization messages in "$path".');
  if (keys.isNotEmpty) {
    final sorted = keys.toList()..sort();
    final top = sorted.take(30).toList();
    stderr.writeln('Missing keys (top ${top.length}):');
    for (final k in top) {
      stderr.writeln('  - $k');
    }
  } else {
    stderr.writeln('Open "$path" to see the missing entries.');
  }

  stderr.writeln('Fix missing translations in your .arb files, then rerun:');
  stderr.writeln('  flutter gen-l10n');
  return 1;
}

bool _isEmpty(dynamic value) {
  if (value == null) return true;
  if (value is Map) return value.isEmpty;
  if (value is List) return value.isEmpty;
  return false;
}

void _collectKeys(dynamic value, Set<String> out) {
  if (value is List) {
    for (final item in value) {
      _collectKeys(item, out);
    }
    return;
  }

  if (value is Map) {
    for (final entry in value.entries) {
      final k = entry.key;
      final v = entry.value;

      // If the value is a nested structure, recurse.
      if (v is Map || v is List) {
        _collectKeys(v, out);
        continue;
      }

      // Heuristic: treat map keys with scalar values as message keys.
      if (k is String && k.trim().isNotEmpty) {
        out.add(k.trim());
      }
    }
  }
}
