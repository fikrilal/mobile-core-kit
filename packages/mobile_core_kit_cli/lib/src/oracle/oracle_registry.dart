import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const oracleRegistryPath = 'harness/oracles.yaml';

class OracleRegistryError implements Exception {
  const OracleRegistryError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class OracleDefinition {
  const OracleDefinition({
    required this.id,
    required this.kind,
    required this.target,
    required this.covers,
  });

  final String id;
  final String kind;
  final String target;
  final Set<String> covers;
}

class OracleRegistry {
  const OracleRegistry._(this.root, this.definitions);

  final Directory root;
  final Map<String, OracleDefinition> definitions;

  factory OracleRegistry.load(Directory root) {
    final file = File(p.join(root.path, oracleRegistryPath));
    if (!file.existsSync()) {
      throw const OracleRegistryError(
        'oracle.registry-missing',
        'Checked-in oracle registry is missing.',
      );
    }

    Object? decoded;
    try {
      decoded = loadYaml(file.readAsStringSync());
    } on YamlException catch (error) {
      throw OracleRegistryError('oracle.registry-invalid', error.message);
    }
    if (decoded is! YamlMap || decoded['schemaVersion'] != 1) {
      throw const OracleRegistryError(
        'oracle.registry-invalid',
        'Oracle registry schemaVersion must be 1.',
      );
    }
    final rawOracles = decoded['oracles'];
    if (rawOracles is! YamlMap || rawOracles.isEmpty) {
      throw const OracleRegistryError(
        'oracle.registry-invalid',
        'Oracle registry must contain at least one oracle.',
      );
    }

    final definitions = <String, OracleDefinition>{};
    for (final entry in rawOracles.entries) {
      final id = entry.key;
      final value = entry.value;
      if (id is! String || !_oracleId.hasMatch(id) || value is! YamlMap) {
        throw const OracleRegistryError(
          'oracle.registry-invalid',
          'Oracle IDs and definitions must use the supported schema.',
        );
      }
      final kind = value['kind'];
      final target = value['target'];
      final rawCovers = value['covers'];
      if (kind is! String ||
          !_oracleKinds.contains(kind) ||
          target is! String ||
          target.trim().isEmpty ||
          rawCovers is! YamlList ||
          rawCovers.isEmpty ||
          rawCovers.any(
            (impact) => impact is! String || !_impactNames.contains(impact),
          )) {
        throw OracleRegistryError(
          'oracle.registry-invalid',
          "Oracle '$id' has an invalid kind, target, or coverage.",
        );
      }
      final covers = rawCovers.cast<String>().toSet();
      if (covers.length != rawCovers.length) {
        throw OracleRegistryError(
          'oracle.registry-invalid',
          "Oracle '$id' repeats an impact area.",
        );
      }
      _validateTarget(root, id: id, kind: kind, target: target);
      definitions[id] = OracleDefinition(
        id: id,
        kind: kind,
        target: target,
        covers: Set.unmodifiable(covers),
      );
    }
    return OracleRegistry._(root, Map.unmodifiable(definitions));
  }

  void validatePlan(TaskPlan plan) {
    if (plan.risk == TaskRisk.low && plan.oracleIds.isEmpty) return;
    if (plan.oracleIds.isEmpty) {
      throw const OracleRegistryError(
        'oracle.plan-empty',
        'Medium/high-risk plans must declare at least one Oracle ID.',
      );
    }

    final selected = <OracleDefinition>[];
    for (final id in plan.oracleIds) {
      final definition = definitions[id];
      if (definition == null) {
        throw OracleRegistryError(
          'oracle.plan-unknown',
          "Plan references unregistered oracle '$id'.",
        );
      }
      selected.add(definition);
    }
    final covered = selected.expand((oracle) => oracle.covers).toSet();
    final missing = _requiredImpacts(plan.impacts).difference(covered).toList()
      ..sort();
    if (missing.isNotEmpty) {
      throw OracleRegistryError(
        'oracle.plan-coverage-missing',
        'Selected oracles do not cover declared impacts: ${missing.join(', ')}.',
      );
    }
  }

  static void _validateTarget(
    Directory root, {
    required String id,
    required String kind,
    required String target,
  }) {
    if (kind == 'verification-profile') {
      if (!const {'fast', 'full', 'runtime', 'ci'}.contains(target)) {
        throw OracleRegistryError(
          'oracle.registry-invalid',
          "Oracle '$id' references an unknown verification profile.",
        );
      }
      return;
    }
    String normalized;
    try {
      normalized = normalizeRepositoryPath(target);
    } on TaskPlanError catch (error) {
      throw OracleRegistryError('oracle.registry-invalid', error.message);
    }
    if (!File(p.join(root.path, normalized)).existsSync()) {
      throw OracleRegistryError(
        'oracle.target-missing',
        "Oracle '$id' target does not exist: '$normalized'.",
      );
    }
  }
}

Set<String> _requiredImpacts(TaskImpactAreas impacts) => {
  if (impacts.auth) 'auth',
  if (impacts.navigation) 'navigation',
  if (impacts.api) 'api',
  if (impacts.database) 'database',
  if (impacts.platform) 'platform',
  if (impacts.ui) 'ui',
  if (impacts.harness) 'harness',
  if (impacts.externalSystems) 'external-systems',
};

final _oracleId = RegExp(r'^[a-z0-9][a-z0-9.-]{2,79}$');
const _oracleKinds = {
  'verification-profile',
  'contract',
  'integration-test',
  'golden-test',
  'metric-assertion',
  'regression-test',
  'procedure',
  'manual-review',
};
const _impactNames = {
  'auth',
  'navigation',
  'api',
  'database',
  'platform',
  'ui',
  'harness',
  'external-systems',
};
