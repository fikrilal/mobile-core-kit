import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final root = Directory.current;
  final required = File(
    p.join(root.path, '.github', 'workflows', 'required.yml'),
  ).readAsStringSync();
  final bootstrap = File(
    p.join(root.path, '.github', 'actions', 'flutter-bootstrap', 'action.yml'),
  ).readAsStringSync();
  final firebaseFixture = File(
    p.join(root.path, 'harness', 'fixtures', 'google-services.ci.json'),
  ).readAsStringSync();

  test('required workflow exposes one stable aggregate over five lanes', () {
    for (final name in [
      'CI Risk',
      'CI Full',
      'CI Coverage',
      'CI Runtime',
      'CI Governance',
      'CI Required',
    ]) {
      expect(
        RegExp(
          '^    name: ${RegExp.escape(name)}\$',
          multiLine: true,
        ).allMatches(required),
        hasLength(1),
        reason: name,
      );
    }
    expect(required, contains('needs.risk.outputs.runtime_required'));
    expect(required, contains('RUNTIME_RESULT" != "skipped"'));
    expect(required, contains('mobilekit verify --profile ci --env dev'));
    expect(required, contains('mobilekit ci classify'));
  });

  test(
    'aggregate executes fail-closed coverage and selected runtime policy',
    () async {
      final workflow = loadYaml(required) as YamlMap;
      final jobs = workflow['jobs'] as YamlMap;
      final aggregate = jobs['required'] as YamlMap;
      expect(aggregate['needs'], contains('coverage'));
      final script =
          ((aggregate['steps'] as YamlList).single as YamlMap)['run'] as String;
      for (final scenario in [
        ('success', 'success', 'true', 0),
        ('failure', 'success', 'true', 1),
        ('cancelled', 'success', 'true', 1),
        ('skipped', 'success', 'true', 1),
        ('success', 'skipped', 'true', 1),
        ('success', 'failure', 'true', 1),
        ('success', 'skipped', 'false', 0),
      ]) {
        final result = await Process.run(
          'bash',
          ['-c', script],
          environment: {
            'RISK_RESULT': 'success',
            'FULL_RESULT': 'success',
            'GOVERNANCE_RESULT': 'success',
            'COVERAGE_RESULT': scenario.$1,
            'RUNTIME_RESULT': scenario.$2,
            'RUNTIME_REQUIRED': scenario.$3,
          },
        );
        expect(result.exitCode, scenario.$4, reason: '$scenario');
      }
      final runtime = jobs['runtime'] as YamlMap;
      final emulator = (runtime['steps'] as YamlList)
          .cast<YamlMap>()
          .singleWhere(
            (step) => '${step['uses']}'.startsWith(
              'reactivecircus/android-emulator-runner@',
            ),
          );
      final scriptText = (emulator['with'] as YamlMap)['script'] as String;
      expect(
        scriptText,
        contains('mobilekit oracle paths --kind integration-test'),
      );
      expect(scriptText, contains('flutter test "\$target"'));
      final golden = (runtime['steps'] as YamlList).cast<YamlMap>().singleWhere(
        (step) => '${step['name']}' == 'Run portable golden evidence',
      );
      expect(
        '${golden['run']}',
        contains('mobilekit oracle paths --kind golden-test'),
      );
      expect(emulator['continue-on-error'], isNull);
      final coverage = jobs['coverage'] as YamlMap;
      expect(
        (coverage['steps'] as YamlList).any(
          (step) => '${step['run']}'.contains('Coverage gate failed'),
        ),
        isTrue,
      );
    },
  );

  test('CI Full prepares every environment validated by the CI profile', () {
    final fullLane = RegExp(
      r'^  full:$([\s\S]*?)^  runtime:$',
      multiLine: true,
    ).firstMatch(required)!.group(1)!;

    for (final environment in ['dev', 'staging', 'prod']) {
      expect(
        fullLane,
        contains('cp .env/$environment.example.yaml .env/$environment.yaml'),
        reason: environment,
      );
    }
  });

  test('CI Runtime installs a synthetic package-matched Firebase fixture', () {
    final runtimeLane = RegExp(
      r'^  runtime:$([\s\S]*?)^  governance:$',
      multiLine: true,
    ).firstMatch(required)!.group(1)!;
    expect(
      runtimeLane,
      contains(
        'cp harness/fixtures/google-services.ci.json '
        'android/app/google-services.json',
      ),
    );

    final fixture = jsonDecode(firebaseFixture) as Map<String, dynamic>;
    final project = fixture['project_info'] as Map<String, dynamic>;
    final clients = fixture['client'] as List<dynamic>;
    final client = clients.single as Map<String, dynamic>;
    final clientInfo = client['client_info'] as Map<String, dynamic>;
    final android = clientInfo['android_client_info'] as Map<String, dynamic>;
    final apiKeys = client['api_key'] as List<dynamic>;
    final apiKey = apiKeys.single as Map<String, dynamic>;
    expect(project['project_id'], 'mobile-core-kit-ci-only');
    expect(android['package_name'], 'dev.fikril.mobile.corekit.dev');
    expect(apiKey['current_key'], 'ci-build-only-not-a-credential');
    expect(firebaseFixture, isNot(contains('AIza')));
  });

  test('required workflow and composite pin every external action', () {
    final sources = [
      required,
      bootstrap,
      ...Directory(p.join(root.path, '.github', 'workflows'))
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.yml'))
          .map((file) => file.readAsStringSync()),
    ];
    for (final source in sources) {
      for (final match in RegExp(
        r'^\s*uses:\s*(\S+)',
        multiLine: true,
      ).allMatches(source)) {
        final reference = match.group(1)!;
        if (reference.startsWith('./')) continue;
        expect(
          reference,
          matches(RegExp(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@[0-9a-f]{40}$')),
          reason: reference,
        );
      }
    }
    final checkoutCount = RegExp(r'uses: actions/checkout@')
        .allMatches(required)
        .length;
    expect(checkoutCount, greaterThan(0));
    expect(
      RegExp(r'persist-credentials: false').allMatches(required).length,
      checkoutCount,
    );
  });

  test('required workflow is bounded and has no publication capability', () {
    expect(required, contains('permissions:\n  contents: read'));
    expect(required, contains('cancel-in-progress: true'));
    expect(RegExp(r'timeout-minutes:').allMatches(required).length, 6);
    for (final unavailable in [
      'git push',
      'gh pr create',
      '--force',
      'deploy',
      'signingConfig',
      'publishProd',
    ]) {
      expect(required, isNot(contains(unavailable)), reason: unavailable);
    }
  });
}
