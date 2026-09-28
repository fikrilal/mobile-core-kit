// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class HardcodedUiStringsLint extends DartLintRule {
  HardcodedUiStringsLint(LintOptions? options)
    : _config = HardcodedUiStringsConfig.fromOptions(options),
      super(code: _code);

  final HardcodedUiStringsConfig _config;

  static const _code = LintCode(
    name: 'hardcoded_ui_strings',
    problemMessage: 'Hardcoded UI string at {0}.{1}: {2}',
    correctionMessage:
        'Use `context.l10n.*` or pass already-localized copy into the component. Suppress with `// ignore: hardcoded_ui_strings` only for a reviewed exception.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final projectRoot = ProjectRootFinder.findForFile(resolver.path);
    if (projectRoot == null) return;

    final sourceRelativePath = normalizePath(
      p.relative(resolver.path, from: projectRoot),
    );
    if (isGeneratedDart(sourceRelativePath) ||
        !_config.paths.isIncluded(sourceRelativePath)) {
      return;
    }

    void inspect(String target, ArgumentList arguments) {
      for (final match in _config.findLiteralArguments(target, arguments)) {
        reporter.atNode(
          match.literal,
          _code,
          arguments: [
            target,
            match.argument,
            shorten(match.literal.toSource()),
          ],
        );
      }
    }

    context.registry.addInstanceCreationExpression((node) {
      inspect(
        _simpleTargetName(node.constructorName.type.toSource()),
        node.argumentList,
      );
    });

    context.registry.addMethodInvocation((node) {
      final target = node.target;
      if (target == null) return;
      inspect(_simpleTargetName(target.toSource()), node.argumentList);
    });
  }
}

class HardcodedUiStringsConfig {
  HardcodedUiStringsConfig({
    required this.paths,
    required Map<String, UiStringSink> sinks,
  }) : _sinks = Map.unmodifiable(sinks);

  factory HardcodedUiStringsConfig.fromOptions(LintOptions? options) =>
      HardcodedUiStringsConfig.fromJson(options?.json);

  factory HardcodedUiStringsConfig.fromJson(Map<String, Object?>? json) {
    final values = json ?? const <String, Object?>{};
    const allowedKeys = {'include', 'exclude', 'sinks'};
    final unknownKeys = values.keys.where((key) => !allowedKeys.contains(key));
    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'hardcoded_ui_strings has unknown option(s): ${unknownKeys.join(', ')}',
      );
    }

    final include = _readStringList(
      values['include'],
      field: 'include',
      fallback: _fallbackInclude,
    );
    final exclude = _readStringList(
      values['exclude'],
      field: 'exclude',
      fallback: _fallbackExclude,
    );
    final sinks = <String, UiStringSink>{
      for (final sink in defaultUiStringSinks) sink.target: sink,
    };

    final configuredTargets = <String>{};
    final rawSinks = values['sinks'];
    if (rawSinks != null) {
      if (rawSinks is! List) {
        throw const FormatException(
          'hardcoded_ui_strings.sinks must be a list.',
        );
      }
      for (final rawSink in rawSinks) {
        final configured = UiStringSink.fromJson(rawSink);
        if (!configuredTargets.add(configured.target)) {
          throw FormatException(
            'hardcoded_ui_strings.sinks contains duplicate target '
            '`${configured.target}`.',
          );
        }
        sinks.update(
          configured.target,
          (existing) => existing.merge(configured),
          ifAbsent: () => configured,
        );
      }
    }

    return HardcodedUiStringsConfig(
      paths: PathConfig(
        include: [for (final value in include) Glob(value)],
        exclude: [for (final value in exclude) Glob(value)],
      ),
      sinks: sinks,
    );
  }

  final PathConfig paths;
  final Map<String, UiStringSink> _sinks;

  Iterable<UiStringLiteralMatch> findLiteralArguments(
    String target,
    ArgumentList arguments,
  ) sync* {
    final sink = _sinks[target];
    if (sink == null) return;

    var positionalIndex = 0;
    for (final argument in arguments.arguments) {
      if (argument case NamedExpression(:final name, :final expression)) {
        final argumentName = name.label.name;
        if (sink.namedArguments.contains(argumentName) &&
            _isNonEmptyStringLiteral(expression)) {
          yield UiStringLiteralMatch(
            literal: expression as StringLiteral,
            argument: argumentName,
          );
        }
        continue;
      }

      if (sink.positionalArguments.contains(positionalIndex) &&
          _isNonEmptyStringLiteral(argument)) {
        yield UiStringLiteralMatch(
          literal: argument as StringLiteral,
          argument: 'positional[$positionalIndex]',
        );
      }
      positionalIndex += 1;
    }
  }

  bool hasSink(String target) => _sinks.containsKey(target);

  UiStringSink? sinkFor(String target) => _sinks[target];
}

class UiStringSink {
  const UiStringSink({
    required this.target,
    this.namedArguments = const {},
    this.positionalArguments = const {},
  });

  factory UiStringSink.fromJson(Object? raw) {
    if (raw is! Map) {
      throw const FormatException(
        'Each hardcoded_ui_strings sink must be a map.',
      );
    }
    final json = Map<String, Object?>.from(raw);
    const allowedKeys = {'target', 'named_arguments', 'positional_arguments'};
    final unknownKeys = json.keys.where((key) => !allowedKeys.contains(key));
    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'hardcoded_ui_strings sink has unknown field(s): '
        '${unknownKeys.join(', ')}',
      );
    }

    final target = json['target'];
    if (target is! String || !_identifier.hasMatch(target)) {
      throw const FormatException(
        'hardcoded_ui_strings sink target must be a Dart identifier.',
      );
    }
    final namedArguments = _readIdentifierSet(
      json['named_arguments'],
      field: 'named_arguments',
    );
    final positionalArguments = _readIndexSet(json['positional_arguments']);
    if (namedArguments.isEmpty && positionalArguments.isEmpty) {
      throw FormatException(
        'hardcoded_ui_strings sink `$target` must declare at least one '
        'named or positional argument.',
      );
    }

    return UiStringSink(
      target: target,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
    );
  }

  final String target;
  final Set<String> namedArguments;
  final Set<int> positionalArguments;

  UiStringSink merge(UiStringSink other) {
    if (target != other.target) {
      throw ArgumentError('Cannot merge different UI string sink targets.');
    }
    return UiStringSink(
      target: target,
      namedArguments: {...namedArguments, ...other.namedArguments},
      positionalArguments: {
        ...positionalArguments,
        ...other.positionalArguments,
      },
    );
  }
}

class UiStringLiteralMatch {
  const UiStringLiteralMatch({required this.literal, required this.argument});

  final StringLiteral literal;
  final String argument;
}

const defaultUiStringSinks = <UiStringSink>[
  UiStringSink(
    target: 'Text',
    positionalArguments: {0},
    namedArguments: {'semanticsLabel'},
  ),
  UiStringSink(
    target: 'SelectableText',
    positionalArguments: {0},
    namedArguments: {'semanticsLabel'},
  ),
  UiStringSink(target: 'TextSpan', namedArguments: {'text', 'semanticsLabel'}),
  UiStringSink(
    target: 'Semantics',
    namedArguments: {
      'label',
      'value',
      'increasedValue',
      'decreasedValue',
      'hint',
      'onTapHint',
      'onLongPressHint',
    },
  ),
  UiStringSink(target: 'Tooltip', namedArguments: {'message'}),
  UiStringSink(
    target: 'InputDecoration',
    namedArguments: {
      'labelText',
      'hintText',
      'helperText',
      'errorText',
      'prefixText',
      'suffixText',
      'counterText',
      'semanticCounterText',
    },
  ),
  UiStringSink(
    target: 'NavigationDestination',
    namedArguments: {'label', 'tooltip'},
  ),
  UiStringSink(
    target: 'BottomNavigationBarItem',
    namedArguments: {'label', 'tooltip'},
  ),
  UiStringSink(
    target: 'AppText',
    positionalArguments: {0},
    namedArguments: {'semanticsLabel'},
  ),
  UiStringSink(
    target: 'AppButton',
    namedArguments: {'text', 'semanticLabel', 'loadingText'},
  ),
  UiStringSink(
    target: 'AppTextField',
    namedArguments: {
      'labelText',
      'hintText',
      'helperText',
      'errorText',
      'prefixText',
      'suffixText',
      'semanticLabel',
      'tooltip',
    },
  ),
  UiStringSink(target: 'AppSearchInputShell', namedArguments: {'placeholder'}),
  UiStringSink(target: 'AppSearchExperience', namedArguments: {'placeholder'}),
  UiStringSink(
    target: 'AppSnackBar',
    namedArguments: {'message', 'actionLabel'},
  ),
  UiStringSink(
    target: 'AppBottomNavItem',
    namedArguments: {'label', 'tooltip'},
  ),
  UiStringSink(
    target: 'AppListTile',
    namedArguments: {'title', 'subtitle', 'semanticLabel'},
  ),
  UiStringSink(target: 'AppTappable', namedArguments: {'semanticLabel'}),
  UiStringSink(
    target: 'AppStartupOverlay',
    namedArguments: {'title', 'semanticLabel'},
  ),
  UiStringSink(target: 'AppLoadingOverlay', namedArguments: {'message'}),
  UiStringSink(
    target: 'AppConfirmationDialog',
    namedArguments: {
      'title',
      'message',
      'confirmLabel',
      'cancelLabel',
      'loadingLabel',
      'errorText',
    },
  ),
  UiStringSink(
    target: 'AppCheckboxTile',
    namedArguments: {'label', 'subtitle', 'semanticLabel'},
  ),
  UiStringSink(
    target: 'AppCheckbox',
    namedArguments: {'semanticLabel', 'tooltip'},
  ),
  UiStringSink(
    target: 'AppStateMessagePanel',
    namedArguments: {'title', 'description'},
  ),
  UiStringSink(
    target: 'AppEmptyState',
    namedArguments: {'title', 'description', 'actionLabel'},
  ),
  UiStringSink(
    target: 'AppPaginatedCollectionView',
    namedArguments: {
      'errorTitle',
      'errorDescription',
      'emptyTitle',
      'emptyDescription',
      'retryLabel',
    },
  ),
  UiStringSink(
    target: 'AppDateField',
    namedArguments: {
      'labelText',
      'hintText',
      'helperText',
      'errorText',
      'semanticLabel',
      'title',
      'confirmLabel',
      'cancelLabel',
      'resetLabel',
      'constraintMessage',
    },
  ),
  UiStringSink(
    target: 'AppDatePickerSheet',
    namedArguments: {
      'title',
      'confirmLabel',
      'cancelLabel',
      'resetLabel',
      'constraintMessage',
    },
  ),
  UiStringSink(
    target: 'AppFilterChipItem',
    namedArguments: {'label', 'tooltip'},
  ),
  UiStringSink(
    target: 'AppFilterChipsBar',
    namedArguments: {'clearActionLabel'},
  ),
  UiStringSink(target: 'AppIconBadge', namedArguments: {'semanticsLabel'}),
  UiStringSink(target: 'AppAvatar', namedArguments: {'semanticsLabel'}),
];

const _fallbackInclude = [
  'lib/core/widgets/**',
  'lib/features/**',
  'lib/navigation/**',
  'lib/presentation/**',
];

const _fallbackExclude = ['lib/core/dev_tools/**', '**/*showcase*'];

final _identifier = RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$');

List<String> _readStringList(
  Object? raw, {
  required String field,
  required List<String> fallback,
}) {
  if (raw == null) return fallback;
  if (raw is! List || raw.any((value) => value is! String)) {
    throw FormatException('hardcoded_ui_strings.$field must be a string list.');
  }
  final values = raw.cast<String>().map((value) => value.trim()).toList();
  if (values.any((value) => value.isEmpty) ||
      values.toSet().length != values.length) {
    throw FormatException(
      'hardcoded_ui_strings.$field must contain unique non-empty strings.',
    );
  }
  return values;
}

Set<String> _readIdentifierSet(Object? raw, {required String field}) {
  if (raw == null) return const {};
  if (raw is! List || raw.any((value) => value is! String)) {
    throw FormatException(
      'hardcoded_ui_strings sink $field must be a string list.',
    );
  }
  final values = raw.cast<String>();
  if (values.any((value) => !_identifier.hasMatch(value)) ||
      values.toSet().length != values.length) {
    throw FormatException(
      'hardcoded_ui_strings sink $field must contain unique Dart identifiers.',
    );
  }
  return Set.unmodifiable(values);
}

Set<int> _readIndexSet(Object? raw) {
  if (raw == null) return const {};
  if (raw is! List || raw.any((value) => value is! int || value < 0)) {
    throw const FormatException(
      'hardcoded_ui_strings sink positional_arguments must contain '
      'non-negative integers.',
    );
  }
  final values = raw.cast<int>();
  if (values.toSet().length != values.length) {
    throw const FormatException(
      'hardcoded_ui_strings sink positional_arguments must be unique.',
    );
  }
  return Set.unmodifiable(values);
}

bool _isNonEmptyStringLiteral(Expression expression) {
  if (expression is! StringLiteral) return false;
  if (expression is SimpleStringLiteral) return expression.value.isNotEmpty;
  if (expression is AdjacentStrings) {
    return expression.strings.any(_isNonEmptyStringLiteral);
  }
  if (expression is StringInterpolation) {
    return expression.elements.whereType<InterpolationString>().any(
      (element) => element.value.isNotEmpty,
    );
  }
  return true;
}

String _simpleTargetName(String source) {
  final withoutPrefix = source.split('.').last;
  final genericStart = withoutPrefix.indexOf('<');
  return genericStart == -1
      ? withoutPrefix
      : withoutPrefix.substring(0, genericStart);
}
