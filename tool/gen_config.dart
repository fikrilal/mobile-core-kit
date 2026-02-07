import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

void main(List<String> argv) {
  final parser = ArgParser()..addOption('env', abbr: 'e');
  final requestedEnv = parser.parse(argv)['env'] as String? ?? 'dev';

  const environments = <String>['dev', 'staging', 'prod'];
  if (!environments.contains(requestedEnv)) {
    stderr.writeln(
      "Unknown environment '$requestedEnv'. "
      'Expected one of: ${environments.join(', ')}',
    );
    exitCode = 1;
    return;
  }

  Map<String, dynamic> readYaml(String env) {
    final file = File('.env/$env.yaml');
    if (!file.existsSync()) {
      return <String, dynamic>{};
    }
    final contents = file.readAsStringSync();
    final parsed = loadYaml(contents);
    if (parsed is YamlMap) {
      return Map<String, dynamic>.from(parsed);
    }
    return <String, dynamic>{};
  }

  String escapeSingleQuotes(String value) => value.replaceAll("'", r"\'");

  String mapLiteral(String name, Map<String, dynamic> map) {
    // Only map known API hosts.
    const allowed = {'core', 'auth', 'profile'};
    final entries = map.entries
        .where((entry) => allowed.contains(entry.key))
        .map(
          (entry) =>
              "  ApiHost.${entry.key}: '${escapeSingleQuotes('${entry.value ?? ''}')}',",
        )
        .join('\n');
    return 'const Map<ApiHost, String> _$name = {\n$entries\n};';
  }

  String boolLiteralForKey(
    Map<String, dynamic> map,
    String key, {
    bool defaultValue = false,
  }) {
    final value = map[key];
    if (value is bool) return value.toString();
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return 'true';
      if (lower == 'false') return 'false';
    }
    return defaultValue.toString();
  }

  String stringLiteral(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return "''";
    return "'${escapeSingleQuotes('$value')}'";
  }

  String stringListLiteral(String name, Map<String, dynamic> map, String key) {
    final value = map[key];
    final items = <String>[];

    if (value is YamlList) {
      for (final item in value) {
        final normalized = '$item'.trim();
        if (normalized.isNotEmpty) {
          items.add(normalized);
        }
      }
    } else if (value is List) {
      for (final item in value) {
        final normalized = '$item'.trim();
        if (normalized.isNotEmpty) {
          items.add(normalized);
        }
      }
    } else if (value is String) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        items.add(normalized);
      }
    }

    if (items.isEmpty) {
      return 'const List<String> _$name = [];';
    }

    final entries = items
        .map((item) => "  '${escapeSingleQuotes(item)}',")
        .join('\n');
    return 'const List<String> _$name = [\n$entries\n];';
  }

  int intLiteral(Map<String, dynamic> map, String key, int defaultValue) {
    final value = map[key];
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED; do not edit.\n')
    ..writeln("part of 'build_config.dart';\n");

  final envConfigs = <String, Map<String, dynamic>>{
    for (final env in environments) env: readYaml(env),
  };

  final missingRequested = envConfigs[requestedEnv]?.isEmpty ?? true;
  if (missingRequested) {
    stderr.writeln(
      'Configuration file .env/$requestedEnv.yaml is missing or empty. '
      'Prod builds require the corresponding YAML before running.',
    );
    exitCode = 1;
    return;
  }

  for (final env in environments) {
    final map = envConfigs[env] ?? <String, dynamic>{};
    buffer
      ..writeln(mapLiteral('${env}Hosts', map))
      ..writeln(
        'const bool _${env}EnableLogging = ${boolLiteralForKey(map, 'enableLogging')};',
      )
      ..writeln(
        'const bool _${env}ReminderExperiment = ${boolLiteralForKey(map, 'reminderExperiment')};',
      )
      ..writeln(
        'const bool _${env}AnalyticsEnabledDefault = ${boolLiteralForKey(map, 'analyticsEnabledDefault')};',
      )
      ..writeln(
        'const bool _${env}AnalyticsDebugLoggingEnabled = ${boolLiteralForKey(map, 'analyticsDebugLoggingEnabled', defaultValue: false)};',
      )
      // Google OIDC (Sign-In) config
      ..writeln(
        'const String _${env}GoogleOidcServerClientId = ${stringLiteral(map, 'googleOidcServerClientId')};',
      )
      ..writeln(
        stringListLiteral(
          '${env}DeepLinkAllowedHosts',
          map,
          'deepLinkAllowedHosts',
        ),
      )
      // Network logging config
      ..writeln(
        "const String _${env}NetLogMode = ${stringLiteral(map, 'netLogMode')};",
      )
      ..writeln(
        'const int _${env}NetLogBodyLimitBytes = ${intLiteral(map, 'netLogBodyLimitBytes', 8192)};',
      )
      ..writeln(
        'const int _${env}NetLogLargeThresholdBytes = ${intLiteral(map, 'netLogLargeThresholdBytes', 65536)};',
      )
      ..writeln(
        'const int _${env}NetLogSlowMs = ${intLiteral(map, 'netLogSlowMs', 800)};',
      )
      ..writeln(
        'const bool _${env}NetLogRedact = ${boolLiteralForKey(map, 'netLogRedact', defaultValue: true)};',
      );
  }

  const outputPath = 'lib/core/foundation/config/build_config_values.dart';
  File(outputPath).writeAsStringSync(buffer.toString());

  final formatResult = Process.runSync(Platform.resolvedExecutable, [
    'format',
    outputPath,
  ]);
  if (formatResult.exitCode != 0) {
    stderr.writeln('Failed to format $outputPath');
    if (formatResult.stdout is String &&
        (formatResult.stdout as String).isNotEmpty) {
      stdout.write(formatResult.stdout);
    }
    if (formatResult.stderr is String &&
        (formatResult.stderr as String).isNotEmpty) {
      stderr.write(formatResult.stderr);
    }
    exitCode = 1;
  }
}
