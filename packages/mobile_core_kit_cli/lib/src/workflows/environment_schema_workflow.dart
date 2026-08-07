import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/workflows/env_config_reader.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

const _requiredUrlKeys = <String>['core', 'auth', 'profile'];
const _requiredBoolKeys = <String>[
  'enableLogging',
  'reminderExperiment',
  'analyticsEnabledDefault',
  'analyticsDebugLoggingEnabled',
  'netLogRedact',
];
const _requiredIntKeys = <String>[
  'netLogBodyLimitBytes',
  'netLogLargeThresholdBytes',
  'netLogSlowMs',
];
const _allowedNetLogModes = <String>{'off', 'summary', 'smallBodies', 'full'};

class EnvironmentSchemaWorkflow {
  const EnvironmentSchemaWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addMultiOption(
        'env',
        abbr: 'e',
        allowed: supportedEnvs,
        help: 'Environment(s) to validate. Defaults to all environments.',
      )
      ..addFlag(
        'all',
        defaultsTo: false,
        help: 'Validate all environments (dev, staging, prod).',
      )
      ..addFlag(
        'strict',
        defaultsTo: false,
        help: 'Enforce production invariants in addition to schema checks.',
      );

    final args = parser.parse(argv);
    final strict = args.flag('strict');
    final selected = args.flag('all')
        ? List<String>.from(supportedEnvs)
        : args.multiOption('env');
    final envs = selected.isEmpty
        ? List<String>.from(supportedEnvs)
        : supportedEnvs.where(selected.contains).toList();

    final errors = <String>[];
    final deepLinkPolicy = _readDeepLinkPolicy(context.rootDirectory, errors);
    for (final env in envs) {
      errors.addAll(
        _validateEnvFile(
          context.rootDirectory,
          env,
          enforceProdInvariants: strict && env == 'prod',
          deepLinkPolicy: deepLinkPolicy,
        ),
      );
    }

    if (errors.isNotEmpty) {
      context.errorOutput.writeln('Environment schema validation failed:');
      for (final error in errors) {
        context.errorOutput.writeln('- $error');
      }
      return 1;
    }

    final strictSuffix = strict ? ' (strict prod checks enabled)' : '';
    context.output.writeln(
      'OK: env schema validated for ${envs.join(', ')}$strictSuffix.',
    );
    return 0;
  }
}

List<String> _validateEnvFile(
  Directory rootDirectory,
  String env, {
  required bool enforceProdInvariants,
  required TemplateCustomization? deepLinkPolicy,
}) {
  final errors = <String>[];
  final path = '.env/$env.yaml';
  final file = File(p.join(rootDirectory.path, path));

  if (!file.existsSync()) {
    return ['[$env] Missing file: $path'];
  }

  final content = file.readAsStringSync().trim();
  if (content.isEmpty) {
    return ['[$env] File is empty: $path'];
  }

  final reader = EnvConfigReader(rootDirectory);
  final map = reader.read(env);
  if (map.isEmpty) {
    return ['[$env] Invalid YAML in $path: expected a map at the top level.'];
  }

  for (final key in _requiredUrlKeys) {
    final value = reader.stringValue(map[key]);
    if (value == null) {
      errors.add('[$env] Missing or invalid string key: $key');
      continue;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      errors.add('[$env] Key $key must be a valid absolute URL: $value');
      continue;
    }
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      errors.add('[$env] Key $key must use http/https: $value');
    }
  }

  final oidcClientId = reader.stringValue(map['googleOidcServerClientId']);
  if (oidcClientId == null) {
    errors.add(
      '[$env] Missing or invalid string key: googleOidcServerClientId',
    );
  }

  for (final key in _requiredBoolKeys) {
    if (reader.boolValue(map[key]) == null) {
      errors.add('[$env] Key $key must be boolean (true/false).');
    }
  }

  for (final key in _requiredIntKeys) {
    final value = reader.intValue(map[key]);
    if (value == null) {
      errors.add('[$env] Key $key must be an integer.');
      continue;
    }
    if (value <= 0) {
      errors.add('[$env] Key $key must be > 0 (got $value).');
    }
  }

  final netLogMode = reader.stringValue(map['netLogMode']);
  if (netLogMode == null) {
    errors.add('[$env] Missing or invalid string key: netLogMode');
  } else if (!_allowedNetLogModes.contains(netLogMode)) {
    errors.add(
      '[$env] netLogMode must be one of '
      '${_allowedNetLogModes.join(', ')} (got $netLogMode).',
    );
  }

  final hosts = reader.stringListValue(map['deepLinkAllowedHosts']);
  for (final host in hosts) {
    if (!_deepLinkHostPattern.hasMatch(host)) {
      errors.add(
        '[$env] deepLinkAllowedHosts must contain valid hostnames only: $host',
      );
    }
  }
  if (deepLinkPolicy != null) {
    if (deepLinkPolicy.deepLinkMode == DeepLinkMode.enabled) {
      final expectedHost = deepLinkPolicy.deepLinkHost;
      if (expectedHost == null ||
          hosts.length != 1 ||
          hosts.single != expectedHost) {
        errors.add(
          '[$env] deepLinkAllowedHosts must contain the configured host: ' +
              (expectedHost ?? '<missing>'),
        );
      }
    } else if (hosts.isNotEmpty) {
      errors.add(
        '[$env] deepLinkAllowedHosts must be empty when deep links are disabled.',
      );
    }
  }

  if (enforceProdInvariants) {
    _checkBoolInvariant(
      errors,
      env: env,
      key: 'enableLogging',
      expected: false,
      value: map['enableLogging'],
    );
    _checkBoolInvariant(
      errors,
      env: env,
      key: 'analyticsDebugLoggingEnabled',
      expected: false,
      value: map['analyticsDebugLoggingEnabled'],
    );
    _checkBoolInvariant(
      errors,
      env: env,
      key: 'netLogRedact',
      expected: true,
      value: map['netLogRedact'],
    );

    if (netLogMode != null && netLogMode != 'off') {
      errors.add(
        '[$env] netLogMode must be off in strict mode (got $netLogMode).',
      );
    }
  }

  return errors;
}

TemplateCustomization? _readDeepLinkPolicy(
  Directory rootDirectory,
  List<String> errors,
) {
  final file = File(p.join(rootDirectory.path, projectManifestRelativePath));
  if (!file.existsSync()) return null;
  try {
    return TemplateManifest.fromFile(file).customization;
  } on FormatException catch (error) {
    errors.add('[project] Invalid template manifest: ${error.message}');
    return null;
  }
}

final _deepLinkHostPattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)+$',
);

void _checkBoolInvariant(
  List<String> errors, {
  required String env,
  required String key,
  required bool expected,
  required dynamic value,
}) {
  final parsed = EnvConfigReader.boolValueOf(value);
  if (parsed == null) {
    errors.add('[$env] Key $key must be boolean in strict mode.');
    return;
  }
  if (parsed != expected) {
    errors.add('[$env] Key $key must be $expected in strict mode.');
  }
}
