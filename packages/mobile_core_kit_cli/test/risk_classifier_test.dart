import 'package:mobile_core_kit_cli/src/policy/risk_classifier.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:test/test.dart';

void main() {
  test('raises sensitive mobile and harness paths to high', () {
    for (final path in [
      '.github/workflows/android.yml',
      'packages/mobile_core_kit_cli/lib/tool.dart',
      'lib/features/auth/domain/session.dart',
      'lib/navigation/app_router.dart',
      'android/app/build.gradle.kts',
      'lib/core/infra/network/client.dart',
    ]) {
      expect(classifyPath(path).risk, TaskRisk.high, reason: path);
    }
  });

  test('keeps narrow docs low and unknown paths medium', () {
    expect(classifyPath('docs/explainers/example.md').risk, TaskRisk.low);
    expect(classifyPath('tooling/new_script.sh').risk, TaskRisk.medium);
  });

  test('declared risk and impacts can raise but never lower risk', () {
    final lowPath = classifyRisk([
      'docs/explainers/example.md',
    ], declaredRisk: TaskRisk.medium);
    expect(lowPath.effectiveRisk, TaskRisk.medium);

    final highImpact = classifyRisk(
      ['docs/explainers/example.md'],
      declaredRisk: TaskRisk.low,
      impacts: _impacts(auth: true),
    );
    expect(highImpact.effectiveRisk, TaskRisk.high);
    expect(highImpact.reasons.single.ruleId, 'risk.high.impact.auth');
  });
}

TaskImpactAreas _impacts({bool auth = false}) => TaskImpactAreas(
  auth: auth,
  navigation: false,
  api: false,
  database: false,
  platform: false,
  ui: false,
  harness: false,
  externalSystems: false,
);
