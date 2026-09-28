// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class ModalEntrypointsLint extends DartLintRule {
  const ModalEntrypointsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'modal_entrypoints',
    problemMessage:
        'Direct modal entrypoint "{0}" is not allowed here. Use `showAdaptiveModal` / `showAdaptiveSideSheet`.',
    correctionMessage:
        'Feature/app code should call adaptive modal entrypoints (from `lib/core/adaptive/widgets/`).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const Set<String> _bannedCalls = {
    'showDialog',
    'showGeneralDialog',
    'showModalBottomSheet',
    'showCupertinoModalPopup',
    'showCupertinoDialog',
  };

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
    if (isGeneratedDart(sourceRelativePath)) return;

    final config = _ModalEntrypointsConfig.fromOptions(_options);
    if (!config.isIncluded(sourceRelativePath)) return;
    if (config.isAllowed(sourceRelativePath)) return;

    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      if (!_bannedCalls.contains(name)) return;

      reporter.atNode(node.methodName, _code, arguments: [name]);
    });
  }
}

class _ModalEntrypointsConfig {
  _ModalEntrypointsConfig({
    required this.include,
    required this.exclude,
    required this.allowPrefixes,
  });

  final List<Glob> include;
  final List<Glob> exclude;
  final List<String> allowPrefixes;

  static _ModalEntrypointsConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const ['lib/**'],
    );
    final exclude = _readGlobList(options?.json['exclude'], fallback: const []);
    final allowPrefixes = _readStringList(
      options?.json['allow_prefixes'],
      fallback: const ['lib/core/adaptive/widgets/'],
    );

    return _ModalEntrypointsConfig(
      include: include,
      exclude: exclude,
      allowPrefixes: allowPrefixes,
    );
  }

  bool isIncluded(String path) {
    if (exclude.any((g) => g.matches(path))) return false;
    return include.any((g) => g.matches(path));
  }

  bool isAllowed(String path) {
    for (final prefix in allowPrefixes) {
      if (path.startsWith(prefix)) return true;
    }
    return false;
  }
}

List<Glob> _readGlobList(Object? raw, {required List<String> fallback}) =>
    readGlobList(raw, fallback: fallback);

List<String> _readStringList(Object? raw, {required List<String> fallback}) {
  if (raw is List) {
    return [
      for (final v in raw)
        if (v is String && v.trim().isNotEmpty) v.trim(),
    ];
  }
  return [...fallback];
}
