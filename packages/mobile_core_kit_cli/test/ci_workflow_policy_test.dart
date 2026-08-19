import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = Directory.current;
  final required = File(
    p.join(root.path, '.github', 'workflows', 'required.yml'),
  ).readAsStringSync();
  final bootstrap = File(
    p.join(root.path, '.github', 'actions', 'flutter-bootstrap', 'action.yml'),
  ).readAsStringSync();

  test('required workflow exposes one stable aggregate over four lanes', () {
    for (final name in [
      'CI Risk',
      'CI Full',
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

  test('required workflow and composite pin every external action', () {
    final sources = [required, bootstrap];
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
    final checkoutCount = RegExp(
      r'uses: actions/checkout@',
    ).allMatches(required).length;
    expect(checkoutCount, greaterThan(0));
    expect(
      RegExp(r'persist-credentials: false').allMatches(required).length,
      checkoutCount,
    );
  });

  test('required workflow is bounded and has no publication capability', () {
    expect(required, contains('permissions:\n  contents: read'));
    expect(required, contains('cancel-in-progress: true'));
    expect(RegExp(r'timeout-minutes:').allMatches(required).length, 5);
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
