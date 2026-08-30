import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_ui_strings.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('HardcodedUiStringsConfig', () {
    test('provides target-and-argument-aware defaults', () {
      final config = HardcodedUiStringsConfig.fromJson(null);

      expect(config.sinkFor('Text')!.positionalArguments, contains(0));
      expect(
        config.sinkFor('Semantics')!.namedArguments,
        containsAll(['label', 'hint', 'onTapHint']),
      );
      expect(
        config.sinkFor('InputDecoration')!.namedArguments,
        containsAll(['labelText', 'hintText', 'errorText']),
      );
      expect(
        config.sinkFor('AppTextField')!.namedArguments,
        containsAll(['labelText', 'semanticLabel', 'tooltip']),
      );
      expect(
        config.sinkFor('AppSnackBar')!.namedArguments,
        containsAll(['message', 'actionLabel']),
      );
      expect(config.hasSink('UnregisteredApi'), isFalse);
    });

    test('every default sink argument reports a direct literal', () {
      final config = HardcodedUiStringsConfig.fromJson(null);

      for (final sink in defaultUiStringSinks) {
        for (final argument in sink.namedArguments) {
          final invocation = _parseInvocations(
            "void example() { ${sink.target}($argument: 'Visible'); }",
          ).single;
          final matches = config
              .findLiteralArguments(sink.target, invocation.$2)
              .toList();

          expect(
            matches.map((match) => match.argument),
            [argument],
            reason: '${sink.target}.$argument',
          );
        }

        for (final index in sink.positionalArguments) {
          final arguments = [
            for (var current = 0; current <= index; current += 1)
              current == index ? "'Visible'" : 'alreadyLocalized',
          ].join(', ');
          final invocation = _parseInvocations(
            'void example() { ${sink.target}($arguments); }',
          ).single;
          final matches = config
              .findLiteralArguments(sink.target, invocation.$2)
              .toList();

          expect(
            matches.map((match) => match.argument),
            ['positional[$index]'],
            reason: '${sink.target}.positional[$index]',
          );
        }
      }
    });

    test('adds consumer sinks without replacing defaults', () {
      final config = HardcodedUiStringsConfig.fromJson({
        'sinks': [
          {
            'target': 'MoodChartItem',
            'named_arguments': ['label'],
          },
          {
            'target': 'Text',
            'named_arguments': ['customAccessibilityLabel'],
          },
        ],
      });

      expect(config.sinkFor('MoodChartItem')!.namedArguments, {'label'});
      expect(
        config.sinkFor('Text')!.namedArguments,
        containsAll(['semanticsLabel', 'customAccessibilityLabel']),
      );
      expect(config.sinkFor('Text')!.positionalArguments, contains(0));
    });

    test('matches only direct non-empty literals at registered arguments', () {
      final config = HardcodedUiStringsConfig.fromJson(null);
      final invocations = _parseInvocations('''
void example(String localized) {
  Text('Visible', semanticsLabel: 'Accessible');
  Text('Welcome, \$localized');
  Text('\$localized');
  Text(localized);
  Text('');
  Analytics(label: 'technical_id');
}
''');

      final textMatches = [
        for (final invocation in invocations.where((item) => item.$1 == 'Text'))
          ...config.findLiteralArguments(invocation.$1, invocation.$2),
      ];
      final analyticsMatches = [
        for (final invocation in invocations.where(
          (item) => item.$1 == 'Analytics',
        ))
          ...config.findLiteralArguments(invocation.$1, invocation.$2),
      ];

      expect(textMatches.map((match) => match.argument), [
        'positional[0]',
        'semanticsLabel',
        'positional[0]',
      ]);
      expect(analyticsMatches, isEmpty);
    });

    test('supports configured positional arguments', () {
      final config = HardcodedUiStringsConfig.fromJson({
        'sinks': [
          {
            'target': 'ProductCopy',
            'positional_arguments': [1],
          },
        ],
      });
      final invocation = _parseInvocations(
        "void example() { ProductCopy('id', 'Visible'); }",
      ).single;

      final matches = config
          .findLiteralArguments(invocation.$1, invocation.$2)
          .toList();

      expect(matches, hasLength(1));
      expect(matches.single.argument, 'positional[1]');
      expect(matches.single.literal.toSource(), "'Visible'");
    });

    test('rejects malformed or weakening configuration', () {
      final invalidOptions = <Map<String, Object?>>[
        {'unknown': true},
        {'include': 'lib/**'},
        {
          'sinks': [
            {'target': 'MoodChartItem'},
          ],
        },
        {
          'sinks': [
            {
              'target': 'MoodChartItem',
              'named_arguments': ['label', 'label'],
            },
          ],
        },
        {
          'sinks': [
            {
              'target': 'MoodChartItem',
              'positional_arguments': [-1],
            },
          ],
        },
        {
          'sinks': [
            {
              'target': 'MoodChartItem',
              'named_arguments': ['label'],
            },
            {
              'target': 'MoodChartItem',
              'named_arguments': ['semanticLabel'],
            },
          ],
        },
      ];

      for (final options in invalidOptions) {
        expect(
          () => HardcodedUiStringsConfig.fromJson(options),
          throwsFormatException,
          reason: '$options',
        );
      }
    });

    test('respects configured path scope', () {
      final config = HardcodedUiStringsConfig.fromJson({
        'include': ['lib/features/**'],
        'exclude': ['lib/features/dev/**'],
      });

      expect(config.paths.isIncluded('lib/features/auth/page.dart'), isTrue);
      expect(
        config.paths.isIncluded('lib/features/dev/showcase.dart'),
        isFalse,
      );
      expect(config.paths.isIncluded('lib/domain/value.dart'), isFalse);
    });
  });

  test(
    'actual custom-lint plugin rejects literals and accepts localized values',
    () async {
      final repositoryRoot = _findRepositoryRoot();
      final fixture = await Directory.systemTemp.createTemp(
        'mobile_core_kit_l10n_lint_',
      );
      addTearDown(() => fixture.delete(recursive: true));

      await File(p.join(fixture.path, 'pubspec.yaml')).writeAsString('''
name: localization_lint_fixture
publish_to: none
environment:
  sdk: ^3.10.3
dependencies:
  custom_lint: ^0.8.1
dev_dependencies:
  mobile_core_kit_lints:
    path: ${p.join(repositoryRoot, 'packages/mobile_core_kit_lints')}
''');
      await File(p.join(fixture.path, 'analysis_options.yaml')).writeAsString(
        '''
analyzer:
  plugins:
    - custom_lint
custom_lint:
  enable_all_lint_rules: false
  rules:
    - hardcoded_ui_strings:
      include:
        - lib/features/**
      sinks:
        - target: MoodChartItem
          named_arguments: [label]
''',
      );
      final source = File(p.join(fixture.path, 'lib/features/example.dart'));
      await source.parent.create(recursive: true);
      await File(p.join(fixture.path, 'lib/widgets.dart')).writeAsString('''
class Text {
  const Text(String value);
}
''');
      await source.writeAsString('''
import '../widgets.dart' as ui;

class MoodChartItem {
  const MoodChartItem({required String label});
}

class AppSnackBar {
  static void show({required String message}) {}
}

Object buildText(String localized) => const ui.Text('Visible');
Object buildChartItem() => const MoodChartItem(label: 'Happy');
void showMessage() => AppSnackBar.show(message: 'Saved');
''');

      final pubGet = await Process.run(Platform.resolvedExecutable, [
        'pub',
        'get',
        '--offline',
      ], workingDirectory: fixture.path);
      expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');

      final violating = await _runCustomLint(fixture.path);
      final violatingOutput = '${violating.stdout}\n${violating.stderr}';
      expect(violating.exitCode, isNot(0), reason: violatingOutput);
      expect(violatingOutput, contains('hardcoded_ui_strings'));
      expect(violatingOutput, contains('Text.positional[0]'));
      expect(violatingOutput, contains('MoodChartItem.label'));
      expect(violatingOutput, contains('AppSnackBar.message'));

      await source.writeAsString('''
import '../widgets.dart' as ui;

class MoodChartItem {
  const MoodChartItem({required String label});
}

class AppSnackBar {
  static void show({required String message}) {}
}

Object buildText(String localized) => ui.Text(localized);
Object buildChartItem(String localized) => MoodChartItem(label: localized);
void showMessage(String localized) => AppSnackBar.show(message: localized);
''');

      final compliant = await _runCustomLint(fixture.path);
      expect(
        compliant.exitCode,
        0,
        reason: '${compliant.stdout}\n${compliant.stderr}',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

List<(String, ArgumentList)> _parseInvocations(String source) {
  final visitor = _InvocationVisitor();
  parseString(content: source).unit.accept(visitor);
  return visitor.invocations;
}

class _InvocationVisitor extends RecursiveAstVisitor<void> {
  final invocations = <(String, ArgumentList)>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    invocations.add((node.constructorName.type.toSource(), node.argumentList));
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    invocations.add((
      target?.toSource() ?? node.methodName.name,
      node.argumentList,
    ));
    super.visitMethodInvocation(node);
  }
}

String _findRepositoryRoot() {
  var current = Directory.current.absolute;
  while (true) {
    final lintPackage = Directory(
      p.join(current.path, 'packages/mobile_core_kit_lints'),
    );
    if (lintPackage.existsSync()) return current.path;
    if (current.parent.path == current.path) {
      throw StateError('Could not find the mobile-core-kit repository root.');
    }
    current = current.parent;
  }
}

Future<ProcessResult> _runCustomLint(String workingDirectory) => Process.run(
  Platform.resolvedExecutable,
  ['run', 'custom_lint'],
  workingDirectory: workingDirectory,
);
