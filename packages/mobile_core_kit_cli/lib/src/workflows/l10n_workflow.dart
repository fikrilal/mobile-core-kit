import 'dart:convert';

import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

const String _defaultPath = 'tool/untranslated_messages.json';

class L10nWorkflow {
  const L10nWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> args) async {
    final path = args.isNotEmpty ? args.first : _defaultPath;
    final file = context.file(path);

    if (!file.existsSync()) {
      context.errorOutput.writeln(
        'Missing untranslated messages file at "$path".',
      );
      context.errorOutput.writeln('Run: flutter gen-l10n');
      return 2;
    }

    dynamic decoded;
    try {
      final raw = await file.readAsString();
      decoded = jsonDecode(raw);
    } catch (e) {
      context.errorOutput.writeln('Failed to read/parse "$path": $e');
      return 2;
    }

    if (_isEmpty(decoded)) {
      context.output.writeln('OK: no untranslated messages found.');
      return 0;
    }

    final keys = <String>{};
    _collectKeys(decoded, keys);

    context.errorOutput.writeln(
      'Found untranslated localization messages in "$path".',
    );
    if (keys.isNotEmpty) {
      final sorted = keys.toList()..sort();
      final top = sorted.take(30).toList();
      context.errorOutput.writeln('Missing keys (top ${top.length}):');
      for (final k in top) {
        context.errorOutput.writeln('  - $k');
      }
    } else {
      context.errorOutput.writeln('Open "$path" to see the missing entries.');
    }

    context.errorOutput.writeln(
      'Fix missing translations in your .arb files, then rerun:',
    );
    context.errorOutput.writeln('  flutter gen-l10n');
    return 1;
  }
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
