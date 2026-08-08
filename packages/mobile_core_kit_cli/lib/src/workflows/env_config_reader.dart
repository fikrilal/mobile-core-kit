import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Supported app environments. Single source of truth for the env list.
const supportedEnvs = <String>['dev', 'staging', 'prod'];

/// Reads `.env/<env>.yaml` files with typed scalar accessors.
///
/// Shared by the build-config generator and the env schema validator so the
/// YAML-reading and value-coercion logic lives in one place.
class EnvConfigReader {
  const EnvConfigReader(this.rootDirectory);

  final Directory rootDirectory;

  bool isSupported(String env) => supportedEnvs.contains(env);

  /// Reads and parses `.env/<env>.yaml`. Returns an empty map when missing or
  /// not a YAML map.
  Map<String, dynamic> read(String env) {
    final file = File(p.join(rootDirectory.path, '.env', '$env.yaml'));
    if (!file.existsSync()) return <String, dynamic>{};

    final parsed = loadYaml(file.readAsStringSync());
    if (parsed is YamlMap) return Map<String, dynamic>.from(parsed);
    return <String, dynamic>{};
  }

  String? stringValue(dynamic value) => EnvConfigReader.stringValueOf(value);

  bool? boolValue(dynamic value) => EnvConfigReader.boolValueOf(value);

  int? intValue(dynamic value) => EnvConfigReader.intValueOf(value);

  List<String> stringListValue(dynamic value) =>
      EnvConfigReader.stringListValueOf(value);

  /// Normalizes a scalar into a trimmed string, or null when empty.
  static String? stringValueOf(dynamic value) {
    if (value == null) return null;
    final normalized = '$value'.trim();
    if (normalized.isEmpty) return null;
    return normalized;
  }

  /// Parses a boolean scalar, accepting `true`/`false` strings.
  static bool? boolValueOf(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }

  /// Parses an integer scalar, accepting numeric strings.
  static int? intValueOf(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Normalizes a scalar or list value into a trimmed string list.
  static List<String> stringListValueOf(dynamic value) {
    if (value is YamlList || value is List) {
      final result = <String>[];
      for (final item in (value as Iterable<dynamic>)) {
        final normalized = stringValueOf(item);
        if (normalized != null) result.add(normalized);
      }
      return result;
    }
    final single = stringValueOf(value);
    if (single == null) return const <String>[];
    return <String>[single];
  }
}
