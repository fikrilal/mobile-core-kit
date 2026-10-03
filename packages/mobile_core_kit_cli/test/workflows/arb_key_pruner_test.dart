import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/arb_key_pruner.dart';
import 'package:test/test.dart';

void main() {
  group('ArbKeyPruner', () {
    late Directory tempDir;
    const pruner = ArbKeyPruner();

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('arb_pruner_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('prunes matching keys and metadata in single file', () {
      final arbFile = File('${tempDir.path}/app_en.arb');
      arbFile.writeAsStringSync('''
{
  "@@locale": "en",
  "appTitle": "Mobile Core Kit",
  "reviewTitle": "Review Title",
  "@reviewTitle": {
    "description": "Title for review feature"
  },
  "reviewBody": "Review Body",
  "@reviewBody": {
    "description": "Body for review feature"
  },
  "otherTitle": "Keep Me"
}
''');

      final result = pruner.pruneFile(arbFile, prefix: 'review');

      expect(result, isNotNull);
      expect(result!.prunedKeysCount, 2);
      expect(result.prunedKeys, ['reviewBody', 'reviewTitle']);

      final updatedContent = arbFile.readAsStringSync();
      expect(updatedContent, contains('appTitle'));
      expect(updatedContent, contains('otherTitle'));
      expect(updatedContent, isNot(contains('reviewTitle')));
      expect(updatedContent, isNot(contains('@reviewTitle')));
      expect(updatedContent, isNot(contains('reviewBody')));
      expect(updatedContent, isNot(contains('@reviewBody')));
    });

    test('dryRun does not modify the file on disk', () {
      final arbFile = File('${tempDir.path}/app_en.arb');
      const original = '''
{
  "reviewTitle": "Review Title",
  "@reviewTitle": {
    "description": "Title"
  }
}
''';
      arbFile.writeAsStringSync(original);

      final result = pruner.pruneFile(arbFile, prefix: 'review', dryRun: true);

      expect(result, isNotNull);
      expect(result!.prunedKeysCount, 1);
      expect(arbFile.readAsStringSync(), original);
    });

    test('returns empty results when no keys match prefix', () {
      final arbFile = File('${tempDir.path}/app_en.arb');
      arbFile.writeAsStringSync('{"appTitle": "Test"}');

      final result = pruner.pruneFile(arbFile, prefix: 'nonexistent');

      expect(result, isNotNull);
      expect(result!.prunedKeysCount, 0);
      expect(result.prunedKeys, isEmpty);
    });

    test('prunes across multiple ARB files in directory', () {
      final fileEn = File('${tempDir.path}/app_en.arb');
      fileEn.writeAsStringSync('{"fooBar": "1", "@fooBar": {}, "baz": "2"}');

      final fileId = File('${tempDir.path}/app_id.arb');
      fileId.writeAsStringSync(
        '{"fooBar": "1_id", "@fooBar": {}, "baz": "2_id"}',
      );

      final results = pruner.pruneDirectory(tempDir, prefix: 'fooBar');

      expect(results.length, 2);
      expect(results[0].prunedKeysCount, 1);
      expect(results[1].prunedKeysCount, 1);

      expect(fileEn.readAsStringSync(), isNot(contains('fooBar')));
      expect(fileId.readAsStringSync(), isNot(contains('fooBar')));
      expect(fileEn.readAsStringSync(), contains('baz'));
      expect(fileId.readAsStringSync(), contains('baz'));
    });
  });
}
