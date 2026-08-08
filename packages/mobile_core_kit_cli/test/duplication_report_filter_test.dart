import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/duplication/duplication_report_filter.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('lists actionable groups but returns 0 by default (review signal)', () {
    final repository = Directory.systemTemp.createTempSync(
      'mobile_core_kit_cli_duplication_filter_test_',
    );
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeReport(repository);

    final output = StringBuffer();
    final errors = StringBuffer();
    final result =
        DuplicationReportFilter(
          rootDirectory: repository,
          output: output,
          errorOutput: errors,
        ).run(
          reportPath: '.tmp/report.json',
          allowlistPath: 'duplication/duplication_allowlist.json',
        );

    expect(result, 0);
    expect(errors.toString(), isEmpty);
    expect(
      output.toString(),
      contains(
        'lib/core/infra/error/error_mapper.dart <> '
        'lib/core/infra/error/session_error_mapper.dart',
      ),
    );
    expect(output.toString(), contains('Actionable duplicate groups: 1'));
  });

  test('returns 1 when fatalFound and actionable groups exist', () {
    final repository = Directory.systemTemp.createTempSync(
      'mobile_core_kit_cli_duplication_fatal_test_',
    );
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeReport(repository);

    final output = StringBuffer();
    final errors = StringBuffer();
    final result =
        DuplicationReportFilter(
          rootDirectory: repository,
          output: output,
          errorOutput: errors,
        ).run(
          reportPath: '.tmp/report.json',
          allowlistPath: 'duplication/duplication_allowlist.json',
          fatalFound: true,
        );

    expect(result, 1);
    expect(errors.toString(), isEmpty);
    expect(output.toString(), contains('Actionable duplicate groups: 1'));
  });

  test('allowlisted pairs are reported as reviewed and not actionable', () {
    final repository = Directory.systemTemp.createTempSync(
      'mobile_core_kit_cli_duplication_allowlist_test_',
    );
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeReport(repository);
    final allowlist = File(
      p.join(repository.path, 'duplication', 'duplication_allowlist.json'),
    )..createSync(recursive: true);
    allowlist.writeAsStringSync(
      jsonEncode({
        'reviewedAcceptable': [
          {
            'firstPath': 'lib/core/infra/error/error_mapper.dart',
            'secondPath': 'lib/core/infra/error/session_error_mapper.dart',
            'reason': 'Intentional compatibility bridge.',
            'reviewedOn': '2026-08-01',
            'status': 'reviewed_acceptable',
          },
        ],
      }),
    );

    final output = StringBuffer();
    final errors = StringBuffer();
    final result =
        DuplicationReportFilter(
          rootDirectory: repository,
          output: output,
          errorOutput: errors,
        ).run(
          reportPath: '.tmp/report.json',
          allowlistPath: 'duplication/duplication_allowlist.json',
        );

    expect(result, 0);
    expect(errors.toString(), isEmpty);
    expect(output.toString(), contains('Reviewed acceptable groups: 1'));
    expect(output.toString(), contains('Actionable duplicate groups: 0'));
    expect(
      output.toString(),
      contains(
        'lib/core/infra/error/error_mapper.dart <> '
        'lib/core/infra/error/session_error_mapper.dart',
      ),
    );
  });

  test('returns 0 when no duplicates exist', () {
    final repository = Directory.systemTemp.createTempSync(
      'mobile_core_kit_cli_duplication_empty_test_',
    );
    addTearDown(() => repository.deleteSync(recursive: true));
    final report = File(p.join(repository.path, '.tmp', 'report.json'))
      ..createSync(recursive: true);
    report.writeAsStringSync(jsonEncode({'duplicates': []}));

    final output = StringBuffer();
    final errors = StringBuffer();
    final result =
        DuplicationReportFilter(
          rootDirectory: repository,
          output: output,
          errorOutput: errors,
        ).run(
          reportPath: '.tmp/report.json',
          allowlistPath: 'duplication/duplication_allowlist.json',
        );

    expect(result, 0);
    expect(output.toString(), contains('Actionable duplicate groups: 0'));
  });
}

void _writeReport(Directory repository) {
  final report = File(p.join(repository.path, '.tmp', 'report.json'))
    ..createSync(recursive: true);
  report.writeAsStringSync(
    jsonEncode({
      'duplicates': [
        {
          'fragment': 'ApiErrorCode mapFailure() => null;',
          'firstFile': {'name': 'lib/core/infra/error/error_mapper.dart'},
          'secondFile': {
            'name': 'lib/core/infra/error/session_error_mapper.dart',
          },
          'lines': 12,
          'tokens': 40,
        },
      ],
    }),
  );
}
