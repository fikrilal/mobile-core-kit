import 'package:mobile_core_kit_cli/src/task/task_plan.dart';

class RiskReason {
  const RiskReason({
    required this.path,
    required this.risk,
    required this.ruleId,
    required this.description,
  });

  final String path;
  final TaskRisk risk;
  final String ruleId;
  final String description;
}

class RiskClassification {
  const RiskClassification({
    required this.effectiveRisk,
    required this.pathRisk,
    required this.declaredRisk,
    required this.paths,
    required this.reasons,
  });

  final TaskRisk effectiveRisk;
  final TaskRisk pathRisk;
  final TaskRisk? declaredRisk;
  final List<String> paths;
  final List<RiskReason> reasons;
}

RiskClassification classifyRisk(
  Iterable<String> changedPaths, {
  TaskRisk? declaredRisk,
  TaskImpactAreas? impacts,
}) {
  final paths = changedPaths.map(normalizeRepositoryPath).toSet().toList()
    ..sort();
  final pathReasons = paths.map(classifyPath).toList();
  final impactReasons = impacts == null
      ? <RiskReason>[]
      : _impactReasons(impacts);
  final pathRisk = pathReasons.isEmpty
      ? TaskRisk.low
      : TaskRisk.maximum(pathReasons.map((reason) => reason.risk));
  final impactRisk = impactReasons.isEmpty
      ? TaskRisk.low
      : TaskRisk.maximum(impactReasons.map((reason) => reason.risk));
  final effectiveRisk = TaskRisk.maximum([
    pathRisk,
    impactRisk,
    if (declaredRisk != null) declaredRisk,
  ]);
  final reasons = [
    ...pathReasons,
    ...impactReasons,
  ].where((reason) => reason.risk == effectiveRisk).toList();
  return RiskClassification(
    effectiveRisk: effectiveRisk,
    pathRisk: pathRisk,
    declaredRisk: declaredRisk,
    paths: List.unmodifiable(paths),
    reasons: List.unmodifiable(reasons),
  );
}

RiskReason classifyPath(String path) {
  final normalized = normalizeRepositoryPath(path);
  for (final rule in _rules) {
    if (rule.matches(normalized)) {
      return RiskReason(
        path: normalized,
        risk: rule.risk,
        ruleId: rule.id,
        description: rule.description,
      );
    }
  }
  return RiskReason(
    path: normalized,
    risk: TaskRisk.medium,
    ruleId: 'risk.medium.unknown',
    description: 'Unknown repository path',
  );
}

List<RiskReason> _impactReasons(TaskImpactAreas impacts) {
  final reasons = <RiskReason>[];
  void add(bool selected, String id, TaskRisk risk, String description) {
    if (!selected) return;
    reasons.add(
      RiskReason(
        path: '<declared-impact>',
        risk: risk,
        ruleId: id,
        description: description,
      ),
    );
  }

  add(
    impacts.auth,
    'risk.high.impact.auth',
    TaskRisk.high,
    'Auth/session impact',
  );
  add(
    impacts.navigation,
    'risk.high.impact.navigation',
    TaskRisk.high,
    'Navigation, deep-link, or startup impact',
  );
  add(
    impacts.api,
    'risk.high.impact.api',
    TaskRisk.high,
    'API contract impact',
  );
  add(
    impacts.database,
    'risk.high.impact.database',
    TaskRisk.high,
    'Database or migration impact',
  );
  add(
    impacts.platform,
    'risk.high.impact.platform',
    TaskRisk.high,
    'Platform, Firebase, or permission impact',
  );
  add(impacts.ui, 'risk.medium.impact.ui', TaskRisk.medium, 'UI/UX impact');
  add(
    impacts.harness,
    'risk.high.impact.harness',
    TaskRisk.high,
    'Harness, CI, or release impact',
  );
  add(
    impacts.externalSystems,
    'risk.high.impact.external',
    TaskRisk.high,
    'External-system impact',
  );
  return reasons;
}

class _RiskRule {
  const _RiskRule(this.id, this.risk, this.description, this.matches);

  final String id;
  final TaskRisk risk;
  final String description;
  final bool Function(String path) matches;
}

final _rules = <_RiskRule>[
  _RiskRule(
    'risk.high.ci',
    TaskRisk.high,
    'CI or repository automation',
    (path) => path.startsWith('.github/'),
  ),
  _RiskRule(
    'risk.high.harness',
    TaskRisk.high,
    'Harness implementation or policy',
    (path) =>
        path.startsWith('packages/mobile_core_kit_cli/') ||
        path.startsWith('packages/mobile_core_kit_lints/') ||
        path.startsWith('lint/') ||
        path.startsWith('duplication/') ||
        path == 'AGENTS.md',
  ),
  _RiskRule(
    'risk.high.dependencies',
    TaskRisk.high,
    'Dependency, SDK, or generated-code policy',
    (path) =>
        path == 'pubspec.yaml' ||
        path == 'pubspec.lock' ||
        path == '.fvmrc' ||
        path == 'analysis_options.yaml' ||
        path == 'build.yaml',
  ),
  _RiskRule(
    'risk.high.platform',
    TaskRisk.high,
    'Platform, Firebase, signing, or permission behavior',
    (path) =>
        path.startsWith('android/') ||
        path.startsWith('ios/') ||
        path.contains('/platform/') ||
        path.contains('/firebase') ||
        path.contains('/push/') ||
        path.contains('/device_identity/') ||
        path.contains('/secure_storage'),
  ),
  _RiskRule(
    'risk.high.auth',
    TaskRisk.high,
    'Authentication, session, or destructive account behavior',
    (path) => RegExp(
      r'(?:^|/)(?:auth|session|account_deletion)(?:/|[._-])',
    ).hasMatch(path),
  ),
  _RiskRule(
    'risk.high.navigation',
    TaskRisk.high,
    'Navigation, deep-link, redirect, or startup behavior',
    (path) =>
        path.startsWith('lib/navigation/') ||
        path.contains('deep_link') ||
        path.contains('app_startup') ||
        path.contains('redirect'),
  ),
  _RiskRule(
    'risk.high.data-contract',
    TaskRisk.high,
    'API, external adapter, database, or migration behavior',
    (path) =>
        path.startsWith('docs/contracts/') ||
        path.contains('/datasource/remote/') ||
        path.contains('/infra/network/') ||
        path.contains('/database/') ||
        path.contains('/migration'),
  ),
  _RiskRule(
    'risk.medium.application',
    TaskRisk.medium,
    'Application behavior',
    (path) => path.startsWith('lib/') || path.startsWith('test/'),
  ),
  _RiskRule(
    'risk.low.docs',
    TaskRisk.low,
    'Non-policy documentation',
    (path) =>
        path.startsWith('docs/') ||
        path.startsWith('ADR/') ||
        path == 'README.md',
  ),
  _RiskRule(
    'risk.low.metadata',
    TaskRisk.low,
    'Repository metadata',
    (path) => path == '.gitignore',
  ),
];
