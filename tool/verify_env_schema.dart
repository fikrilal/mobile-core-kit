import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

const _supportedEnvs = <String>['dev', 'staging', 'prod'];
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

void main(List<String> argv) {
  final parser = ArgParser()
    ..addMultiOption(
      'env',
      abbr: 'e',
      allowed: _supportedEnvs,
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
      ? List<String>.from(_supportedEnvs)
      : args.multiOption('env');
  final envs = selected.isEmpty
      ? List<String>.from(_supportedEnvs)
      : _supportedEnvs.where(selected.contains).toList();

  final errors = <String>[];
  for (final env in envs) {
    errors.addAll(
      _validateEnvFile(env, enforceProdInvariants: strict && env == 'prod'),
    );
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Environment schema validation failed:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  final strictSuffix = strict ? ' (strict prod checks enabled)' : '';
  stdout.writeln(
    'OK: env schema validated for ${envs.join(', ')}$strictSuffix.',
  );
}

List<String> _validateEnvFile(
  String env, {
  required bool enforceProdInvariants,
}) {
  final errors = <String>[];
  final path = '.env/$env.yaml';
  final file = File(path);

  if (!file.existsSync()) {
    return ['[$env] Missing file: $path'];
  }

  final content = file.readAsStringSync().trim();
  if (content.isEmpty) {
    return ['[$env] File is empty: $path'];
  }

  dynamic parsed;
  try {
    parsed = loadYaml(content);
  } catch (error) {
    return ['[$env] Invalid YAML in $path: $error'];
  }

  if (parsed is! YamlMap) {
    return ['[$env] Top-level YAML node must be a map: $path'];
  }

  final map = Map<String, dynamic>.from(parsed);

  for (final key in _requiredUrlKeys) {
    final value = _stringValue(map[key]);
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

  final oidcClientId = _stringValue(map['googleOidcServerClientId']);
  if (oidcClientId == null) {
    errors.add(
      '[$env] Missing or invalid string key: googleOidcServerClientId',
    );
  }

  for (final key in _requiredBoolKeys) {
    if (!_isBoolLike(map[key])) {
      errors.add('[$env] Key $key must be boolean (true/false).');
    }
  }

  for (final key in _requiredIntKeys) {
    final value = _intValue(map[key]);
    if (value == null) {
      errors.add('[$env] Key $key must be an integer.');
      continue;
    }
    if (value <= 0) {
      errors.add('[$env] Key $key must be > 0 (got $value).');
    }
  }

  final netLogMode = _stringValue(map['netLogMode']);
  if (netLogMode == null) {
    errors.add('[$env] Missing or invalid string key: netLogMode');
  } else if (!_allowedNetLogModes.contains(netLogMode)) {
    errors.add(
      '[$env] netLogMode must be one of '
      '${_allowedNetLogModes.join(', ')} (got $netLogMode).',
    );
  }

  final hosts = _stringListValue(map['deepLinkAllowedHosts']);
  if (hosts.isEmpty) {
    errors.add('[$env] deepLinkAllowedHosts must contain at least one host.');
  } else {
    for (final host in hosts) {
      if (host.contains('://') || host.contains('/') || host.contains(' ')) {
        errors.add(
          '[$env] deepLinkAllowedHosts must contain hostnames only: $host',
        );
      }
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

String? _stringValue(dynamic value) {
  if (value == null) return null;
  final normalized = '$value'.trim();
  if (normalized.isEmpty) return null;
  return normalized;
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value.trim());
  return null;
}

bool _isBoolLike(dynamic value) {
  if (value is bool) return true;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    return lower == 'true' || lower == 'false';
  }
  return false;
}

bool? _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return null;
}

List<String> _stringListValue(dynamic value) {
  if (value is YamlList || value is List) {
    final result = <String>[];
    for (final item in (value as Iterable<dynamic>)) {
      final normalized = _stringValue(item);
      if (normalized != null) {
        result.add(normalized);
      }
    }
    return result;
  }
  final single = _stringValue(value);
  if (single == null) {
    return const <String>[];
  }
  return <String>[single];
}

void _checkBoolInvariant(
  List<String> errors, {
  required String env,
  required String key,
  required bool expected,
  required dynamic value,
}) {
  final parsed = _boolValue(value);
  if (parsed == null) {
    errors.add('[$env] Key $key must be boolean in strict mode.');
    return;
  }
  if (parsed != expected) {
    errors.add('[$env] Key $key must be $expected in strict mode.');
  }
}
