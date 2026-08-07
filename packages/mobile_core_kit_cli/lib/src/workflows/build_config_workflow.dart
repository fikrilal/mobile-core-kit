import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/workflows/env_config_reader.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class BuildConfigWorkflow {
  const BuildConfigWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()..addOption('env', abbr: 'e');
    final requestedEnv = parser.parse(argv)['env'] as String? ?? 'dev';

    final reader = EnvConfigReader(context.rootDirectory);
    if (!reader.isSupported(requestedEnv)) {
      context.errorOutput.writeln(
        "Unknown environment '$requestedEnv'. "
        'Expected one of: ${supportedEnvs.join(', ')}',
      );
      return 1;
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
      return (reader.boolValue(map[key]) ?? defaultValue).toString();
    }

    String stringLiteral(Map<String, dynamic> map, String key) {
      final value = reader.stringValue(map[key]);
      if (value == null) return "''";
      return "'${escapeSingleQuotes(value)}'";
    }

    String stringListLiteral(
      String name,
      Map<String, dynamic> map,
      String key,
    ) {
      final items = reader.stringListValue(map[key]);

      if (items.isEmpty) {
        return 'const List<String> _$name = [];';
      }

      final entries = items
          .map((item) => "  '${escapeSingleQuotes(item)}',")
          .join('\n');
      return 'const List<String> _$name = [\n$entries\n];';
    }

    int intLiteral(Map<String, dynamic> map, String key, int defaultValue) {
      return reader.intValue(map[key]) ?? defaultValue;
    }

    final buffer = StringBuffer()
      ..writeln('// GENERATED; do not edit.\n')
      ..writeln("part of 'build_config.dart';\n");

    final envConfigs = <String, Map<String, dynamic>>{
      for (final env in supportedEnvs) env: reader.read(env),
    };

    final missingRequested = envConfigs[requestedEnv]?.isEmpty ?? true;
    if (missingRequested) {
      context.errorOutput.writeln(
        'Configuration file .env/$requestedEnv.yaml is missing or empty. '
        'Prod builds require the corresponding YAML before running.',
      );
      return 1;
    }

    for (final env in supportedEnvs) {
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
    context.file(outputPath).writeAsStringSync(buffer.toString());

    final formatExitCode = await context.execute([
      'dart',
      'format',
      outputPath,
    ]);
    if (formatExitCode != 0) {
      context.errorOutput.writeln('Failed to format $outputPath');
      return 1;
    }
    return 0;
  }
}
