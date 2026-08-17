import 'package:mobile_core_kit_cli/src/task/task_failure.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';
import 'package:test/test.dart';

void main() {
  test('maps every canonical verification step to a stable failure', () {
    expect(
      verificationFailureTaxonomy.keys.toSet(),
      VerificationStep.values.toSet(),
    );
    expect(
      verificationFailureTaxonomy[VerificationStep.format]!.boundary,
      'format.dart',
    );
    expect(
      verificationFailureTaxonomy[VerificationStep.cliTests]!.category,
      TaskFailureCategory.test,
    );
  });

  test('redacts credentials and PII and bounds diagnostics', () {
    final source = [
      'Authorization: Bearer abc.def.secret',
      'password=hunter2 token:top-secret api_key=12345',
      'contact person@example.com',
      List.filled(5000, 'x').join(),
    ].join('\n');

    final result = sanitizeTaskDiagnostic(source, maximumLength: 200);

    expect(result, isNot(contains('abc.def.secret')));
    expect(result, isNot(contains('hunter2')));
    expect(result, isNot(contains('top-secret')));
    expect(result, isNot(contains('person@example.com')));
    expect(result.length, lessThanOrEqualTo(201));
    expect(result, contains('[REDACTED]'));
    expect(result, contains('[REDACTED_EMAIL]'));
  });
}
