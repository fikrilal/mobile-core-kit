import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_plan.dart';
import 'package:path/path.dart' as p;

abstract interface class TemplateTransformation {
  String get id;

  TemplateTransformationResult plan(TemplateTransformationContext context);
}

class TemplateTransformationResult {
  TemplateTransformationResult({
    Iterable<TemplateFileChange> changes = const [],
    Iterable<TemplatePlanItem> items = const [],
  }) : changes = List<TemplateFileChange>.unmodifiable(changes),
       items = List<TemplatePlanItem>.unmodifiable(items);

  final List<TemplateFileChange> changes;
  final List<TemplatePlanItem> items;
}

class TemplateTransformationContext {
  TemplateTransformationContext({
    required this.rootDirectory,
    required this.previous,
    required this.next,
  });

  final Directory rootDirectory;
  final TemplateCustomization previous;
  final TemplateCustomization next;
  final _plannedBytes = <String, List<int>?>{};

  File file(String relativePath) =>
      File(p.join(rootDirectory.path, relativePath));

  TemplateFileChange change(String relativePath, String contents) {
    final target = file(relativePath);
    final before = target.existsSync() ? target.readAsBytesSync() : null;
    final after = utf8.encode(contents);
    _plannedBytes[relativePath] = after;
    return TemplateFileChange(
      relativePath: relativePath,
      beforeBytes: before,
      afterBytes: after,
    );
  }

  TemplateFileChange delete(String relativePath) {
    final target = file(relativePath);
    final before = target.existsSync() ? target.readAsBytesSync() : null;
    _plannedBytes[relativePath] = null;
    return TemplateFileChange(
      relativePath: relativePath,
      beforeBytes: before,
      afterBytes: null,
    );
  }

  String? readText(String relativePath) {
    if (_plannedBytes.containsKey(relativePath)) {
      final bytes = _plannedBytes[relativePath];
      return bytes == null ? null : utf8.decode(bytes);
    }
    final target = file(relativePath);
    if (!target.existsSync()) return null;
    if (target.statSync().type != FileSystemEntityType.file) return null;
    return target.readAsStringSync();
  }

  List<File> dartFiles() {
    final files = <File>[];
    for (final root in const ['lib', 'test', 'integration_test']) {
      _collectFiles(
        Directory(p.join(rootDirectory.path, root)),
        files,
        extension: '.dart',
      );
    }
    files.sort((left, right) => left.path.compareTo(right.path));
    return files;
  }

  List<File> arbFiles() {
    final files = <File>[];
    _collectFiles(
      Directory(p.join(rootDirectory.path, 'lib', 'l10n')),
      files,
      extension: '.arb',
    );
    files.sort((left, right) => left.path.compareTo(right.path));
    return files;
  }

  String relativePath(File file) => _relativePath(rootDirectory, file);
}

class TemplateCustomizationPlan {
  TemplateCustomizationPlan({
    required this.summary,
    required Iterable<TemplateFileChange> changes,
    required this.manifest,
  }) : changes = List<TemplateFileChange>.unmodifiable(changes);

  final TemplatePlan summary;
  final List<TemplateFileChange> changes;
  final TemplateManifest manifest;

  bool get hasChanges => summary.hasChanges;

  bool get hasConflicts => summary.hasConflicts;
}

class TemplateCustomizationResult {
  const TemplateCustomizationResult({required this.outcome, this.message});

  final TemplateLifecycleOutcome outcome;
  final String? message;

  bool get succeeded =>
      outcome == TemplateLifecycleOutcome.applied ||
      outcome == TemplateLifecycleOutcome.skipped;

  int get exitCode => outcome == TemplateLifecycleOutcome.failed ? 1 : 0;
}

class TemplateCustomizationEngine {
  TemplateCustomizationEngine({
    required this.rootDirectory,
    required this.nextManifest,
    this.existingManifest,
  });

  static const _reservedPackageNames = {
    'mobile_core_kit_cli',
    'mobile_core_kit_lints',
  };

  final Directory rootDirectory;
  final TemplateManifest nextManifest;
  final TemplateManifest? existingManifest;

  TemplateCustomizationPlan buildPlan() {
    _validateInputs();

    final previous =
        existingManifest != null &&
            existingManifest!.managedFileFingerprints.isNotEmpty
        ? existingManifest!.customization
        : _inferCurrentValues();
    final nextCustomization = _effectiveNextCustomization();
    final context = TemplateTransformationContext(
      rootDirectory: rootDirectory,
      previous: previous,
      next: nextCustomization,
    );
    final items = <TemplatePlanItem>[];
    final changes = <TemplateFileChange>[];

    items.addAll(_checkManagedFileFingerprints(context));

    final transformations = <TemplateTransformation>[
      _PubspecTransformation(),
      _DartPackageImportTransformation(),
      _LocalizationTransformation(),
      _ReadmeTransformation(),
      _AndroidTransformation(),
      _IosTransformation(),
      _DeepLinkTransformation(),
      _FirebaseTransformation(),
    ];
    for (final transformation in transformations) {
      final result = transformation.plan(context);
      for (final change in result.changes) {
        final index = changes.indexWhere(
          (existing) => existing.relativePath == change.relativePath,
        );
        if (index < 0) {
          changes.add(change);
          continue;
        }
        final existing = changes[index];
        changes[index] = TemplateFileChange(
          relativePath: change.relativePath,
          beforeBytes: existing.beforeBytes,
          afterBytes: change.afterBytes,
        );
      }
      items.addAll(result.items);
      for (final change in result.changes) {
        items.add(_filePlanItem(change, transformation.id));
      }
    }

    final managedFiles = <String, String>{
      ...?existingManifest?.managedFileFingerprints,
    };
    for (final change in changes) {
      if (change.relativePath == projectManifestRelativePath) continue;
      if (change.afterFingerprint == null) {
        managedFiles.remove(change.relativePath);
      } else {
        managedFiles[change.relativePath] = change.afterFingerprint!;
      }
    }

    final manifest = nextManifest
        .withCustomization(nextCustomization)
        .withManagedFileFingerprints(managedFiles);
    final manifestChange = _manifestChange(context, manifest);
    changes.add(manifestChange);
    items.add(_filePlanItem(manifestChange, 'manifest'));

    final residualItem = _residualItem(context, changes);
    if (residualItem != null) items.add(residualItem);
    items.add(
      const TemplatePlanItem(
        status: TemplatePlanStatus.external,
        target: 'environment and external services',
        description:
            'API endpoints, OIDC client IDs, credentials, and external setup remain user-owned',
      ),
    );

    return TemplateCustomizationPlan(
      summary: TemplatePlan(items: items, fileChanges: changes),
      changes: changes,
      manifest: manifest,
    );
  }

  TemplateCustomization _effectiveNextCustomization() {
    if (nextManifest.customization.environmentExamplesUpdated) {
      return nextManifest.customization;
    }
    const paths = [
      '.env/dev.example.yaml',
      '.env/staging.example.yaml',
      '.env/prod.example.yaml',
    ];
    final examplesExist = paths.any(
      (path) => File(p.join(rootDirectory.path, path)).existsSync(),
    );
    return examplesExist
        ? nextManifest.customization.withEnvironmentExamplesUpdated(true)
        : nextManifest.customization;
  }

  TemplateCustomizationResult apply(
    TemplateCustomizationPlan plan, {
    void Function(String relativePath)? beforeWrite,
  }) {
    if (plan.hasConflicts) {
      return const TemplateCustomizationResult(
        outcome: TemplateLifecycleOutcome.failed,
        message: 'The customization plan contains conflicts.',
      );
    }

    final changes = plan.changes.where((change) => change.hasChanges).toList();
    if (changes.isEmpty) {
      return const TemplateCustomizationResult(
        outcome: TemplateLifecycleOutcome.skipped,
      );
    }

    try {
      _TemplateFileTransaction(
        rootDirectory,
      ).apply(changes, beforeWrite: beforeWrite);
      return const TemplateCustomizationResult(
        outcome: TemplateLifecycleOutcome.applied,
      );
    } on _TemplateConflictException catch (error) {
      return TemplateCustomizationResult(
        outcome: TemplateLifecycleOutcome.failed,
        message: error.message,
      );
    } catch (error) {
      return TemplateCustomizationResult(
        outcome: TemplateLifecycleOutcome.failed,
        message: 'Customization was rolled back: ' + error.toString(),
      );
    }
  }

  void _validateInputs() {
    final packageName = nextManifest.customization.dartPackage;
    if (_reservedPackageNames.contains(packageName)) {
      throw FormatException(
        'app.dart_package cannot use a reserved harness package name: ' +
            packageName,
      );
    }

    final pubspec = File(p.join(rootDirectory.path, 'pubspec.yaml'));
    if (!pubspec.existsSync() ||
        pubspec.statSync().type != FileSystemEntityType.file) {
      throw const FormatException('Root pubspec.yaml is required.');
    }
    for (final relativePath in const ['pubspec.yaml', 'README.md']) {
      final target = File(p.join(rootDirectory.path, relativePath));
      if (Directory(target.path).existsSync()) {
        throw FormatException(
          'Managed target is a directory, not a file: ' + relativePath,
        );
      }
    }
  }

  TemplateCustomization _inferCurrentValues() {
    final pubspec = File(p.join(rootDirectory.path, 'pubspec.yaml'));
    final contents = pubspec.existsSync() ? pubspec.readAsStringSync() : '';
    final packageMatch = RegExp(
      r'^ *name: *([a-z][a-z0-9_]*) *$',
      multiLine: true,
    ).firstMatch(contents);
    final packageName = packageMatch?.group(1) ?? supportedTemplateId;
    final displayName = _inferDisplayName();
    final repositorySlug = _inferRepositorySlug();
    final deepLinkHost = _inferDeepLinkHost();
    return TemplateCustomization.fromValues(
      repositorySlug: repositorySlug,
      repositoryDescription: displayName,
      displayName: displayName,
      dartPackage: packageName,
      androidNamespace: TemplateCustomization.defaultAndroidNamespace,
      androidApplicationId: TemplateCustomization.defaultAndroidApplicationId,
      iosBundleId: TemplateCustomization.defaultIosBundleId,
      deepLinkMode: deepLinkHost == null
          ? DeepLinkMode.disabled
          : DeepLinkMode.enabled,
      deepLinkHost: deepLinkHost,
    );
  }

  String? _inferDeepLinkHost() {
    const paths = [
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Runner.entitlements',
      '.env/dev.example.yaml',
    ];
    for (final path in paths) {
      final contents = File(p.join(rootDirectory.path, path));
      if (!contents.existsSync()) continue;
      if (contents.readAsStringSync().contains(
        TemplateCustomization.defaultDeepLinkHost,
      )) {
        return TemplateCustomization.defaultDeepLinkHost;
      }
    }
    return null;
  }

  String _inferDisplayName() {
    final file = File(p.join(rootDirectory.path, 'lib', 'l10n', 'app_en.arb'));
    if (file.existsSync()) {
      final match = _appTitlePattern.firstMatch(file.readAsStringSync());
      if (match != null) {
        final value = _decodeJsonString(match.group(2)!);
        if (value != null && !value.startsWith('⟪')) return value;
      }
    }
    return 'Mobile Core Kit';
  }

  String _inferRepositorySlug() {
    final file = File(p.join(rootDirectory.path, 'README.md'));
    if (file.existsSync()) {
      final match = _readmeHeadingPattern.firstMatch(file.readAsStringSync());
      if (match != null) {
        final normalized = TemplateCustomization.normalizeRepositorySlug(
          match.group(2)!,
        );
        if (normalized.isNotEmpty) return normalized;
      }
    }
    return TemplateCustomization.normalizeRepositorySlug(
      p.basename(rootDirectory.path),
    );
  }

  List<TemplatePlanItem> _checkManagedFileFingerprints(
    TemplateTransformationContext context,
  ) {
    final items = <TemplatePlanItem>[];
    for (final entry
        in existingManifest?.managedFileFingerprints.entries ??
            const <MapEntry<String, String>>[]) {
      final target = context.file(entry.key);
      final current =
          target.existsSync() &&
              target.statSync().type == FileSystemEntityType.file
          ? target.readAsBytesSync()
          : null;
      final fingerprint = current == null
          ? null
          : templateContentFingerprint(current);
      if (fingerprint != entry.value) {
        items.add(
          TemplatePlanItem(
            status: TemplatePlanStatus.conflicted,
            target: entry.key,
            description:
                'managed file changed since the previous customization; expected ' +
                entry.value +
                ', found ' +
                (fingerprint ?? 'missing'),
          ),
        );
      }
    }
    return items;
  }

  TemplateFileChange _manifestChange(
    TemplateTransformationContext context,
    TemplateManifest manifest,
  ) {
    return context.change(projectManifestRelativePath, manifest.toYaml());
  }

  TemplatePlanItem _filePlanItem(
    TemplateFileChange change,
    String transformationId,
  ) {
    return TemplatePlanItem(
      status: change.hasChanges
          ? TemplatePlanStatus.changed
          : TemplatePlanStatus.skipped,
      target: change.relativePath,
      description: change.hasChanges
          ? 'apply ' + transformationId
          : transformationId + ' is already up to date',
    );
  }

  TemplatePlanItem? _residualItem(
    TemplateTransformationContext context,
    Iterable<TemplateFileChange> changes,
  ) {
    final managedPaths = changes.map((change) => change.relativePath).toSet();
    final patterns = <String, String>{};
    final previousPackage = context.previous.dartPackage;
    final nextPackage = context.next.dartPackage;
    if (previousPackage != nextPackage) {
      patterns['package:' + previousPackage + '/'] = 'old Dart package URI';
    }
    final previousDisplay = context.previous.displayName;
    if (previousDisplay != context.next.displayName) {
      patterns[previousDisplay] = 'old display name';
    }
    final previousSlug = context.previous.repositorySlug;
    if (previousSlug != context.next.repositorySlug) {
      patterns[previousSlug] = 'old repository slug';
    }
    if (patterns.isEmpty) return null;

    final matches = <String>{};
    for (final file in _textFiles(rootDirectory)) {
      final relativePath = _relativePath(rootDirectory, file);
      if (managedPaths.contains(relativePath) ||
          _isExcludedFromResidualScan(relativePath)) {
        continue;
      }
      final contents = file.readAsStringSync();
      if (patterns.keys.any(contents.contains)) matches.add(relativePath);
    }
    if (matches.isEmpty) return null;
    final listed = matches.toList()..sort();
    final preview = listed.take(5).join(', ');
    return TemplatePlanItem(
      status: TemplatePlanStatus.external,
      target: 'residual-defaults',
      description:
          '${matches.length} file(s) still contain old identity references; review manually: ' +
          preview,
    );
  }
}

class _PubspecTransformation implements TemplateTransformation {
  @override
  String get id => 'application package and root metadata';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    final relativePath = 'pubspec.yaml';
    final contents = context.readText(relativePath);
    if (contents == null) {
      return _conflict(relativePath, 'root pubspec.yaml is missing');
    }

    final nameMatch = _pubspecNamePattern.firstMatch(contents);
    if (nameMatch == null) {
      return _conflict(relativePath, 'root package name is missing');
    }
    final currentName = nameMatch.group(2)!;
    if (currentName != context.previous.dartPackage &&
        currentName != context.next.dartPackage) {
      return _conflict(
        relativePath,
        'root package name is ' +
            currentName +
            ', expected ' +
            context.previous.dartPackage,
      );
    }

    final descriptionMatch = _pubspecDescriptionPattern.firstMatch(contents);
    if (descriptionMatch == null) {
      return _conflict(relativePath, 'root project description is missing');
    }

    var updated = contents;
    if (currentName != context.next.dartPackage) {
      updated = updated.replaceRange(
        nameMatch.start,
        nameMatch.end,
        nameMatch.group(1)! + context.next.dartPackage + nameMatch.group(3)!,
      );
    }
    final updatedDescriptionMatch = _pubspecDescriptionPattern.firstMatch(
      updated,
    );
    updated = updated.replaceRange(
      updatedDescriptionMatch!.start,
      updatedDescriptionMatch.end,
      updatedDescriptionMatch.group(1)! +
          _yamlQuote(context.next.repositoryDescription),
    );
    return TemplateTransformationResult(
      changes: [context.change(relativePath, updated)],
    );
  }
}

class _DartPackageImportTransformation implements TemplateTransformation {
  @override
  String get id => 'application Dart package imports';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    if (context.previous.dartPackage == context.next.dartPackage) {
      return TemplateTransformationResult();
    }
    final oldPackage = RegExp.escape(context.previous.dartPackage);
    final directive = RegExp(
      r'''^( *(?:import|export|part) +['"])package:''' + oldPackage + r'''/''',
      multiLine: true,
    );
    final changes = <TemplateFileChange>[];
    for (final file in context.dartFiles()) {
      final contents = file.readAsStringSync();
      if (!directive.hasMatch(contents)) continue;
      final updated = contents.replaceAllMapped(
        directive,
        (match) =>
            match.group(1)! + 'package:' + context.next.dartPackage + '/',
      );
      changes.add(context.change(context.relativePath(file), updated));
    }
    return TemplateTransformationResult(changes: changes);
  }
}

class _LocalizationTransformation implements TemplateTransformation {
  @override
  String get id => 'localized app branding';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    final changes = <TemplateFileChange>[];
    final items = <TemplatePlanItem>[];
    for (final file in context.arbFiles()) {
      final relativePath = context.relativePath(file);
      final contents = file.readAsStringSync();
      final match = _appTitlePattern.firstMatch(contents);
      if (match == null) {
        items.add(
          TemplatePlanItem(
            status: TemplatePlanStatus.conflicted,
            target: relativePath,
            description: 'appTitle resource is missing',
          ),
        );
        continue;
      }
      final current = _decodeJsonString(match.group(2)!);
      if (current == null) {
        items.add(
          TemplatePlanItem(
            status: TemplatePlanStatus.conflicted,
            target: relativePath,
            description: 'appTitle is not a valid JSON string',
          ),
        );
        continue;
      }
      final target = _localizedTitle(
        current,
        context.previous.displayName,
        context.next.displayName,
      );
      if (target == null) {
        items.add(
          TemplatePlanItem(
            status: TemplatePlanStatus.conflicted,
            target: relativePath,
            description:
                'appTitle does not match the managed plain, RTL, or pseudo-locale shape',
          ),
        );
        continue;
      }
      final updated = contents.replaceRange(
        match.start,
        match.end,
        match.group(1)! + jsonEncode(target),
      );
      changes.add(context.change(relativePath, updated));
    }
    return TemplateTransformationResult(changes: changes, items: items);
  }
}

class _ReadmeTransformation implements TemplateTransformation {
  @override
  String get id => 'current README identity';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    const relativePath = 'README.md';
    final contents = context.readText(relativePath);
    if (contents == null) return TemplateTransformationResult();
    final match = _readmeHeadingPattern.firstMatch(contents);
    if (match == null) {
      return _conflict(relativePath, 'README heading is missing');
    }
    final current = match.group(2)!.trim();
    if (current != context.previous.repositorySlug &&
        current != context.next.repositorySlug) {
      return _conflict(
        relativePath,
        'README heading is ' +
            current +
            ', expected ' +
            context.previous.repositorySlug,
      );
    }
    final updated = contents.replaceRange(
      match.start,
      match.end,
      match.group(1)! + context.next.repositorySlug,
    );
    return TemplateTransformationResult(
      changes: [context.change(relativePath, updated)],
    );
  }
}

class _AndroidTransformation implements TemplateTransformation {
  static const _gradlePath = 'android/app/build.gradle.kts';
  static const _manifestPath = 'android/app/src/main/AndroidManifest.xml';
  static const _sourceRoots = [
    'android/app/src/main/kotlin',
    'android/app/src/main/java',
    'android/app/src/debug/kotlin',
    'android/app/src/debug/java',
    'android/app/src/profile/kotlin',
    'android/app/src/profile/java',
  ];

  @override
  String get id => 'Android identity and packaging';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    if (!Directory(
      p.join(context.rootDirectory.path, 'android'),
    ).existsSync()) {
      return TemplateTransformationResult();
    }

    final items = <TemplatePlanItem>[];
    final changes = <TemplateFileChange>[];
    final gradle = context.readText(_gradlePath);
    final manifest = context.readText(_manifestPath);

    if (gradle == null) {
      items.add(
        _androidConflict(
          _gradlePath,
          'Android Gradle configuration is missing',
        ),
      );
    } else {
      final result = _planGradle(context, gradle);
      items.addAll(result.items);
      changes.addAll(result.changes);
    }

    if (manifest == null) {
      items.add(
        _androidConflict(_manifestPath, 'Android main manifest is missing'),
      );
    } else {
      final result = _planManifest(context, manifest);
      items.addAll(result.items);
      changes.addAll(result.changes);
    }

    final sourceResult = _planSourcePackages(context);
    items.addAll(sourceResult.items);
    changes.addAll(sourceResult.changes);

    return TemplateTransformationResult(changes: changes, items: items);
  }

  TemplateTransformationResult _planGradle(
    TemplateTransformationContext context,
    String contents,
  ) {
    var updated = contents;
    final errors = <String>[];
    final replacements = [
      _AndroidReplacement(
        field: 'namespace',
        pattern: RegExp(
          r'^([ \t]*namespace[ \t]*=[ \t]*")([^"]+)("[ \t]*)$',
          multiLine: true,
        ),
        expected: context.previous.androidNamespace,
        replacement: context.next.androidNamespace,
      ),
      _AndroidReplacement(
        field: 'defaultConfig.applicationId',
        pattern: RegExp(
          r'^([ \t]*applicationId[ \t]*=[ \t]*")([^"]+)("[ \t]*)$',
          multiLine: true,
        ),
        expected: context.previous.androidApplicationId,
        replacement: context.next.androidApplicationId,
      ),
      _AndroidReplacement(
        field: 'dev.applicationIdSuffix',
        pattern: _flavorSuffixPattern('dev'),
        expected: context.previous.androidDevSuffix,
        replacement: context.next.androidDevSuffix,
      ),
      _AndroidReplacement(
        field: 'staging.applicationIdSuffix',
        pattern: _flavorSuffixPattern('staging'),
        expected: context.previous.androidStagingSuffix,
        replacement: context.next.androidStagingSuffix,
      ),
    ];

    for (final replacement in replacements) {
      final result = _replaceAndroidText(
        updated,
        replacement.pattern,
        expected: replacement.expected,
        replacement: replacement.replacement,
      );
      if (result.error != null) {
        errors.add(replacement.field + ': ' + result.error!);
      } else {
        updated = result.contents;
      }
    }

    if (errors.isNotEmpty) {
      return TemplateTransformationResult(
        items: [_androidConflict(_gradlePath, errors.join('; '))],
      );
    }
    if (updated == contents) return TemplateTransformationResult();
    return TemplateTransformationResult(
      changes: [context.change(_gradlePath, updated)],
    );
  }

  TemplateTransformationResult _planManifest(
    TemplateTransformationContext context,
    String contents,
  ) {
    final doubleQuote = RegExp(
      r'^([ \t]*android:label[ \t]*=[ \t]*")([^"]*)("[ \t]*)$',
      multiLine: true,
    );
    final singleQuote = RegExp(
      r"^([ \t]*android:label[ \t]*=[ \t]*')([^']*)('[ \t]*)$",
      multiLine: true,
    );
    final matches = [
      ...doubleQuote.allMatches(contents),
      ...singleQuote.allMatches(contents),
    ];
    if (matches.length != 1) {
      return TemplateTransformationResult(
        items: [
          _androidConflict(
            _manifestPath,
            matches.isEmpty
                ? 'application label is missing'
                : 'application label is defined more than once',
          ),
        ],
      );
    }

    final match = matches.single;
    final current = _xmlUnescape(match.group(2)!);
    if (current != context.previous.displayName &&
        current != context.next.displayName) {
      return TemplateTransformationResult(
        items: [
          _androidConflict(
            _manifestPath,
            'application label is ' +
                current +
                ', expected ' +
                context.previous.displayName,
          ),
        ],
      );
    }
    if (current == context.next.displayName) {
      return TemplateTransformationResult();
    }

    final updated = contents.replaceRange(
      match.start,
      match.end,
      match.group(1)! + _xmlEscape(context.next.displayName) + match.group(3)!,
    );
    return TemplateTransformationResult(
      changes: [context.change(_manifestPath, updated)],
    );
  }

  TemplateTransformationResult _planSourcePackages(
    TemplateTransformationContext context,
  ) {
    if (context.previous.androidNamespace == context.next.androidNamespace) {
      return TemplateTransformationResult();
    }
    if (_namespacePathOverlaps(
      context.previous.androidNamespace,
      context.next.androidNamespace,
    )) {
      return TemplateTransformationResult(
        items: [
          _androidConflict(
            'android/app/src',
            'old and new Android namespaces overlap; choose unrelated package paths',
          ),
        ],
      );
    }

    final oldPath = _packagePath(context.previous.androidNamespace);
    final newPath = _packagePath(context.next.androidNamespace);
    final sourceFiles = <File>[];
    for (final sourceRoot in _sourceRoots) {
      final directory = Directory(
        p.join(context.rootDirectory.path, sourceRoot, oldPath),
      );
      _collectAndroidSourceFiles(directory, sourceFiles);
    }
    sourceFiles.sort((left, right) => left.path.compareTo(right.path));
    if (sourceFiles.isEmpty) {
      return TemplateTransformationResult(
        items: [
          _androidConflict(
            'android/app/src',
            'Android source package directory is missing: ' + oldPath,
          ),
        ],
      );
    }

    final sourcePaths = sourceFiles
        .map((file) => _relativePath(context.rootDirectory, file))
        .toSet();
    final changes = <TemplateFileChange>[];
    final errors = <String>[];
    for (final source in sourceFiles) {
      final sourceRelativePath = _relativePath(context.rootDirectory, source);
      final sourceRoot = _sourceRoots.firstWhere(
        (root) => sourceRelativePath.startsWith(root + '/'),
      );
      final sourcePackageDirectory = Directory(
        p.join(context.rootDirectory.path, sourceRoot, oldPath),
      );
      final relativeDirectory = p
          .relative(p.dirname(source.path), from: sourcePackageDirectory.path)
          .replaceAll('\\', '/');
      final suffix = relativeDirectory == '.'
          ? ''
          : '.' + relativeDirectory.replaceAll('/', '.');
      final expectedOldPackage = context.previous.androidNamespace + suffix;
      final expectedNewPackage = context.next.androidNamespace + suffix;
      final contents = source.readAsStringSync();
      final packagePattern = RegExp(
        r'^([ \t]*package[ \t]+)([A-Za-z_][A-Za-z0-9_.]*)([ \t]*)$',
        multiLine: true,
      );
      final packageMatches = packagePattern.allMatches(contents).toList();
      if (packageMatches.length != 1) {
        errors.add(
          sourceRelativePath + ': package declaration is missing or ambiguous',
        );
        continue;
      }
      final packageMatch = packageMatches.single;
      final currentPackage = packageMatch.group(2)!;
      if (currentPackage != expectedOldPackage &&
          currentPackage != expectedNewPackage) {
        errors.add(
          sourceRelativePath +
              ': package is ' +
              currentPackage +
              ', expected ' +
              expectedOldPackage,
        );
        continue;
      }

      final updated = currentPackage == expectedNewPackage
          ? contents
          : contents.replaceRange(
              packageMatch.start,
              packageMatch.end,
              packageMatch.group(1)! +
                  expectedNewPackage +
                  packageMatch.group(3)!,
            );
      final relativeFile = p.relative(
        source.path,
        from: sourcePackageDirectory.path,
      );
      final target = p.join(
        context.rootDirectory.path,
        sourceRoot,
        newPath,
        relativeFile,
      );
      final targetRelativePath = _relativePath(
        context.rootDirectory,
        File(target),
      );
      if (Directory(target).existsSync() ||
          (File(target).existsSync() &&
              !sourcePaths.contains(targetRelativePath))) {
        errors.add(
          targetRelativePath + ': destination already exists and is user-owned',
        );
        continue;
      }
      changes.add(context.change(targetRelativePath, updated));
      changes.add(context.delete(sourceRelativePath));
    }

    if (errors.isNotEmpty) {
      return TemplateTransformationResult(
        items: [_androidConflict('android/app/src', errors.join('; '))],
      );
    }
    return TemplateTransformationResult(changes: changes);
  }
}

class _IosTransformation implements TemplateTransformation {
  static const _projectPath = 'ios/Runner.xcodeproj/project.pbxproj';
  static const _infoPlistPath = 'ios/Runner/Info.plist';

  @override
  String get id => 'iOS identity and packaging';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    if (!Directory(p.join(context.rootDirectory.path, 'ios')).existsSync()) {
      return TemplateTransformationResult();
    }

    final items = <TemplatePlanItem>[];
    final changes = <TemplateFileChange>[];
    final project = context.readText(_projectPath);
    final infoPlist = context.readText(_infoPlistPath);

    if (project == null) {
      items.add(
        _iosConflict(
          _projectPath,
          'iOS Xcode project configuration is missing',
        ),
      );
    } else {
      final result = _planProject(context, project);
      items.addAll(result.items);
      changes.addAll(result.changes);
    }

    if (infoPlist == null) {
      items.add(_iosConflict(_infoPlistPath, 'Runner Info.plist is missing'));
    } else {
      final result = _planInfoPlist(context, infoPlist);
      items.addAll(result.items);
      changes.addAll(result.changes);
    }

    return TemplateTransformationResult(changes: changes, items: items);
  }

  TemplateTransformationResult _planProject(
    TemplateTransformationContext context,
    String contents,
  ) {
    final objects = _parsePbxObjects(contents);
    final objectById = <String, _PbxObject>{
      for (final object in objects) object.id: object,
    };
    final edits = <_IosTextEdit>[];
    final errors = <String>[];
    final editedObjects = <String>{};

    for (final target in const [
      _IosTargetSpec(
        name: 'Runner',
        expectedPrevious: _IosBundleValue.application,
        targetNext: _IosBundleValue.application,
      ),
      _IosTargetSpec(
        name: 'RunnerTests',
        expectedPrevious: _IosBundleValue.test,
        targetNext: _IosBundleValue.test,
      ),
    ]) {
      final targetObjects = objects.where(
        (object) =>
            object.isa == 'PBXNativeTarget' && object.name == target.name,
      );
      if (targetObjects.length != 1) {
        errors.add(
          target.name +
              ': expected one PBXNativeTarget, found ' +
              targetObjects.length.toString(),
        );
        continue;
      }
      final targetObject = targetObjects.single;
      final configurationListId = targetObject.buildConfigurationListId;
      if (configurationListId == null) {
        errors.add(target.name + ': build configuration list is missing');
        continue;
      }
      final configurationList = objectById[configurationListId];
      if (configurationList == null ||
          configurationList.isa != 'XCConfigurationList') {
        errors.add(target.name + ': build configuration list is invalid');
        continue;
      }
      final configurationIds = configurationList.buildConfigurationIds;
      if (configurationIds.isEmpty) {
        errors.add(target.name + ': build configurations are missing');
        continue;
      }

      final expectedPrevious =
          target.expectedPrevious == _IosBundleValue.application
          ? <String>{context.previous.iosBundleId, context.next.iosBundleId}
          : <String>{
              context.previous.iosTestBundleId,
              context.previous.iosBundleId,
              context.next.iosTestBundleId,
            };
      final targetNext = target.targetNext == _IosBundleValue.application
          ? context.next.iosBundleId
          : context.next.iosTestBundleId;

      for (final configurationId in configurationIds) {
        final configuration = objectById[configurationId];
        if (configuration == null ||
            configuration.isa != 'XCBuildConfiguration') {
          errors.add(
            target.name +
                ': build configuration ' +
                configurationId +
                ' is invalid',
          );
          continue;
        }
        if (!editedObjects.add(configuration.id)) {
          errors.add(
            target.name +
                ': a build configuration is shared with another target',
          );
          continue;
        }
        final matches = _productBundleIdentifierPattern
            .allMatches(configuration.text)
            .toList();
        if (matches.length != 1) {
          errors.add(
            target.name +
                ' ' +
                (configuration.name ?? configuration.id) +
                ': expected one PRODUCT_BUNDLE_IDENTIFIER setting',
          );
          continue;
        }
        final match = matches.single;
        final current = match.group(2)!.trim();
        if (!expectedPrevious.contains(current) && current != targetNext) {
          errors.add(
            target.name +
                ' ' +
                (configuration.name ?? configuration.id) +
                ': found ' +
                current +
                ', expected one of ' +
                expectedPrevious.join(', '),
          );
          continue;
        }
        if (current == targetNext) continue;
        edits.add(
          _IosTextEdit(
            start: configuration.start + match.start,
            end: configuration.start + match.end,
            replacement: match.group(1)! + targetNext + match.group(3)!,
          ),
        );
      }
    }

    if (errors.isNotEmpty) {
      return TemplateTransformationResult(
        items: [_iosConflict(_projectPath, errors.join('; '))],
      );
    }
    if (edits.isEmpty) return TemplateTransformationResult();
    return TemplateTransformationResult(
      changes: [context.change(_projectPath, _applyIosEdits(contents, edits))],
    );
  }

  TemplateTransformationResult _planInfoPlist(
    TemplateTransformationContext context,
    String contents,
  ) {
    var updated = contents;
    final errors = <String>[];
    for (final key in const ['CFBundleDisplayName', 'CFBundleName']) {
      final pattern = RegExp(
        r'(<key>' + key + r'</key>[ \t\r\n]*<string>)([^<]*)(</string>)',
      );
      final matches = pattern.allMatches(updated).toList();
      if (matches.length != 1) {
        errors.add(
          key +
              ': expected one string value, found ' +
              matches.length.toString(),
        );
        continue;
      }
      final match = matches.single;
      final current = _xmlUnescape(match.group(2)!);
      if (current != context.previous.displayName &&
          current != context.next.displayName) {
        errors.add(
          key +
              ': found ' +
              current +
              ', expected ' +
              context.previous.displayName,
        );
        continue;
      }
      if (current == context.next.displayName) continue;
      updated = updated.replaceRange(
        match.start,
        match.end,
        match.group(1)! +
            _xmlEscape(context.next.displayName) +
            match.group(3)!,
      );
    }

    if (errors.isNotEmpty) {
      return TemplateTransformationResult(
        items: [_iosConflict(_infoPlistPath, errors.join('; '))],
      );
    }
    if (updated == contents) return TemplateTransformationResult();
    return TemplateTransformationResult(
      changes: [context.change(_infoPlistPath, updated)],
    );
  }
}

enum _IosBundleValue { application, test }

class _IosTargetSpec {
  const _IosTargetSpec({
    required this.name,
    required this.expectedPrevious,
    required this.targetNext,
  });

  final String name;
  final _IosBundleValue expectedPrevious;
  final _IosBundleValue targetNext;
}

class _IosTextEdit {
  const _IosTextEdit({
    required this.start,
    required this.end,
    required this.replacement,
  });

  final int start;
  final int end;
  final String replacement;
}

class _PbxObject {
  const _PbxObject({
    required this.id,
    required this.comment,
    required this.start,
    required this.end,
    required this.text,
  });

  final String id;
  final String comment;
  final int start;
  final int end;
  final String text;

  String? get isa {
    final match = RegExp(
      r'^\s*isa = ([^;]+);$',
      multiLine: true,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? get name {
    final match = RegExp(
      r'^\s*name = ([^;]+);$',
      multiLine: true,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? get buildConfigurationListId {
    final match = RegExp(
      r'^\s*buildConfigurationList = ([A-Fa-f0-9]+) /\*[^*]+\*/;$',
      multiLine: true,
    ).firstMatch(text);
    return match?.group(1);
  }

  List<String> get buildConfigurationIds {
    final section = RegExp(
      r'buildConfigurations\s*=\s*\(([\s\S]*?)\);',
    ).firstMatch(text)?.group(1);
    if (section == null) return const [];
    return RegExp(
      r'([A-Fa-f0-9]+) /\*[^*]+\*/',
    ).allMatches(section).map((match) => match.group(1)!).toList();
  }
}

List<_PbxObject> _parsePbxObjects(String contents) {
  final header = RegExp(
    r'^\t\t([A-Fa-f0-9]+)(?: /\* ([^*]+) \*/)? = \{$',
    multiLine: true,
  );
  final objects = <_PbxObject>[];
  for (final match in header.allMatches(contents)) {
    final opening = match.end - 1;
    final closing = _findPbxClosingBrace(contents, opening);
    if (closing == null) continue;
    objects.add(
      _PbxObject(
        id: match.group(1)!,
        comment: match.group(2) ?? '',
        start: match.start,
        end: closing + 1,
        text: contents.substring(match.start, closing + 1),
      ),
    );
  }
  return objects;
}

int? _findPbxClosingBrace(String contents, int opening) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var index = opening; index < contents.length; index++) {
    final character = contents[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (character == '\\') {
        escaped = true;
      } else if (character == '"') {
        inString = false;
      }
      continue;
    }
    if (character == '"') {
      inString = true;
    } else if (character == '{') {
      depth++;
    } else if (character == '}') {
      depth--;
      if (depth == 0) return index;
    }
  }
  return null;
}

String _applyIosEdits(String contents, List<_IosTextEdit> edits) {
  final sorted = edits.toList()
    ..sort((left, right) => right.start.compareTo(left.start));
  var updated = contents;
  for (final edit in sorted) {
    updated = updated.replaceRange(edit.start, edit.end, edit.replacement);
  }
  return updated;
}

TemplatePlanItem _iosConflict(String target, String description) {
  return TemplatePlanItem(
    status: TemplatePlanStatus.conflicted,
    target: target,
    description: description,
  );
}

class _DeepLinkTransformation implements TemplateTransformation {
  static const _androidManifestPath =
      'android/app/src/main/AndroidManifest.xml';
  static const _entitlementsPath = 'ios/Runner/Runner.entitlements';
  static const _environmentExamplePaths = [
    '.env/dev.example.yaml',
    '.env/staging.example.yaml',
    '.env/prod.example.yaml',
  ];
  static const _fixturePaths = [
    'test/core/runtime/navigation/deep_link_parser_test.dart',
    'test/core/runtime/navigation/pending_deep_link_controller_test.dart',
    'test/navigation/app_redirect_test.dart',
    'test/navigation/widgets/pending_deep_link_cancel_on_pop_test.dart',
    'integration_test/auth_happy_path_test.dart',
    'integration_test/startup_deep_link_resume_test.dart',
  ];
  static const _documentationPaths = ['docs/template/deep_linking.md'];

  @override
  String get id => 'deep-link policy';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    final changes = <TemplateFileChange>[];
    final items = <TemplatePlanItem>[];

    for (final path in _environmentExamplePaths) {
      final contents = context.readText(path);
      if (contents == null) continue;
      final result = _replaceDeepLinkExample(context, contents);
      if (result.error != null) {
        items.add(_integrationConflict(path, result.error!));
      } else if (result.contents != contents) {
        changes.add(context.change(path, result.contents));
      }
    }

    final androidManifest = context.readText(_androidManifestPath);
    if (androidManifest != null) {
      final result = _planAndroidManifest(context, androidManifest);
      if (result.error != null) {
        items.add(_integrationConflict(_androidManifestPath, result.error!));
      } else if (result.contents != androidManifest) {
        changes.add(context.change(_androidManifestPath, result.contents));
      }
    }

    final entitlements = context.readText(_entitlementsPath);
    if (entitlements != null) {
      final result = _planEntitlements(context, entitlements);
      if (result.error != null) {
        items.add(_integrationConflict(_entitlementsPath, result.error!));
      } else if (result.contents != entitlements) {
        changes.add(context.change(_entitlementsPath, result.contents));
      }
    }

    for (final path in _fixturePaths) {
      final contents = context.readText(path);
      if (contents == null) continue;
      final result = _replaceDeepLinkReferences(context, contents);
      if (result.error != null) {
        items.add(_integrationConflict(path, result.error!));
      } else if (result.contents != contents) {
        changes.add(context.change(path, result.contents));
      }
    }

    for (final path in _documentationPaths) {
      final contents = context.readText(path);
      if (contents == null) continue;
      final result = _replaceDeepLinkDocumentation(context, contents);
      if (result.error != null) {
        items.add(_integrationConflict(path, result.error!));
      } else if (result.contents != contents) {
        changes.add(context.change(path, result.contents));
      }
    }

    items.add(
      TemplatePlanItem(
        status: TemplatePlanStatus.external,
        target: 'environment runtime inputs',
        description: context.next.deepLinkMode == DeepLinkMode.enabled
            ? 'Update ignored .env/*.yaml with the configured deep-link host, then regenerate BuildConfig.'
            : 'Clear deepLinkAllowedHosts in ignored .env/*.yaml and regenerate BuildConfig; existing files were preserved.',
      ),
    );
    items.add(
      TemplatePlanItem(
        status: TemplatePlanStatus.external,
        target: 'deep-link domains',
        description: context.next.deepLinkMode == DeepLinkMode.enabled
            ? 'Publish Android assetlinks.json and iOS AASA for ' +
                  context.next.deepLinkHost! +
                  '.'
            : 'No deep-link host verification or domain ownership is required while deep links are disabled.',
      ),
    );
    items.addAll(_protectedIntegrationFiles(context));

    return TemplateTransformationResult(changes: changes, items: items);
  }

  _DeepLinkTextResult _replaceDeepLinkExample(
    TemplateTransformationContext context,
    String contents,
  ) {
    final matches = _deepLinkAllowedHostsPattern.allMatches(contents).toList();
    if (matches.length != 1) {
      return _DeepLinkTextResult(
        contents: contents,
        error: matches.isEmpty
            ? 'deepLinkAllowedHosts is missing'
            : 'deepLinkAllowedHosts is defined more than once',
      );
    }

    final match = matches.single;
    final current = _parseDeepLinkHosts(match.group(0)!);
    if (current.error != null) {
      return _DeepLinkTextResult(contents: contents, error: current.error);
    }
    final expected = _managedDeepLinkHosts(context);
    if (current.hosts.any((host) => !expected.contains(host))) {
      return _DeepLinkTextResult(
        contents: contents,
        error:
            'deepLinkAllowedHosts contains a user-owned host; resolve it before customization',
      );
    }

    final replacement = context.next.deepLinkMode == DeepLinkMode.enabled
        ? 'deepLinkAllowedHosts:\n  - ' + context.next.deepLinkHost!
        : 'deepLinkAllowedHosts: []';
    return _DeepLinkTextResult(
      contents: contents.replaceRange(match.start, match.end, replacement),
    );
  }

  _DeepLinkTextResult _planAndroidManifest(
    TemplateTransformationContext context,
    String contents,
  ) {
    final matches = _androidDeepLinkFilterPattern.allMatches(contents).toList();
    if (context.next.deepLinkMode == DeepLinkMode.disabled) {
      if (matches.isEmpty) {
        if (_androidAutoVerifyPattern.hasMatch(contents) ||
            _androidHttpsHostPattern.hasMatch(contents)) {
          return const _DeepLinkTextResult(
            contents: '',
            error: 'an unsupported autoVerify intent filter is present',
          );
        }
        return _DeepLinkTextResult(contents: contents);
      }
      if (matches.length != 1) {
        return _DeepLinkTextResult(
          contents: contents,
          error: 'expected one managed HTTPS intent filter',
        );
      }
      final filter = matches.single.group(0)!;
      final hosts = _androidHosts(filter);
      if (hosts.isEmpty ||
          _androidHttpsHosts(contents).length != hosts.length ||
          hosts.any((host) => !_managedDeepLinkHosts(context).contains(host))) {
        return _DeepLinkTextResult(
          contents: contents,
          error: 'intent filter contains an unknown deep-link host',
        );
      }
      return _DeepLinkTextResult(
        contents: contents.replaceRange(
          matches.single.start,
          matches.single.end,
          '',
        ),
      );
    }

    if (matches.length != 1) {
      return _DeepLinkTextResult(
        contents: contents,
        error: matches.isEmpty
            ? 'managed HTTPS intent filter is missing'
            : 'expected one managed HTTPS intent filter',
      );
    }
    final match = matches.single;
    final filter = match.group(0)!;
    final hosts = _androidHosts(filter);
    if (hosts.isEmpty || _androidHttpsHosts(contents).length != hosts.length) {
      return const _DeepLinkTextResult(
        contents: '',
        error: 'managed HTTPS intent filter has no hosts',
      );
    }
    final managedHosts = _managedDeepLinkHosts(context);
    if (hosts.any((host) => !managedHosts.contains(host))) {
      return const _DeepLinkTextResult(
        contents: '',
        error: 'intent filter contains an unknown deep-link host',
      );
    }
    final nextHost = context.next.deepLinkHost!;
    var updatedFilter = filter;
    for (final host in hosts) {
      if (host != nextHost) {
        updatedFilter = updatedFilter.replaceAll(
          'android:host="' + host + '"',
          'android:host="' + nextHost + '"',
        );
      }
    }
    return _DeepLinkTextResult(
      contents: contents.replaceRange(match.start, match.end, updatedFilter),
    );
  }

  _DeepLinkTextResult _planEntitlements(
    TemplateTransformationContext context,
    String contents,
  ) {
    final matches = _associatedDomainsPattern.allMatches(contents).toList();
    if (matches.length > 1) {
      return const _DeepLinkTextResult(
        contents: '',
        error: 'associated-domains entitlement is defined more than once',
      );
    }
    if (matches.isEmpty) {
      if (context.next.deepLinkMode == DeepLinkMode.disabled) {
        return _DeepLinkTextResult(contents: contents);
      }
      return const _DeepLinkTextResult(
        contents: '',
        error: 'associated-domains entitlement is missing',
      );
    }

    final match = matches.single;
    final domains = _associatedDomains(match.group(0)!);
    final deepLinkDomains = domains
        .where((domain) => domain.startsWith('applinks:'))
        .toList();
    if (context.next.deepLinkMode == DeepLinkMode.enabled &&
        deepLinkDomains.isEmpty) {
      return const _DeepLinkTextResult(
        contents: '',
        error: 'associated-domains has no applinks entry',
      );
    }
    final managedHosts = _managedDeepLinkHosts(context);
    final unknown = domains.where((domain) {
      if (!domain.startsWith('applinks:')) return false;
      return !managedHosts.contains(domain.substring('applinks:'.length));
    });
    if (unknown.isNotEmpty) {
      return const _DeepLinkTextResult(
        contents: '',
        error: 'associated-domains contains an unknown deep-link host',
      );
    }

    if (context.next.deepLinkMode == DeepLinkMode.disabled) {
      final remaining = domains
          .where((domain) => !domain.startsWith('applinks:'))
          .toList();
      if (remaining.isEmpty) {
        return _DeepLinkTextResult(
          contents: contents.replaceRange(match.start, match.end, ''),
        );
      }
      return _DeepLinkTextResult(
        contents: contents.replaceRange(
          match.start,
          match.end,
          _associatedDomainsXml(remaining),
        ),
      );
    }

    final nextDomain = 'applinks:' + context.next.deepLinkHost!;
    var updated = match.group(0)!;
    for (final domain in domains.where(
      (value) => value.startsWith('applinks:'),
    )) {
      if (domain != nextDomain) {
        updated = updated.replaceAll(
          '<string>' + domain + '</string>',
          '<string>' + nextDomain + '</string>',
        );
      }
    }
    return _DeepLinkTextResult(
      contents: contents.replaceRange(match.start, match.end, updated),
    );
  }

  _DeepLinkTextResult _replaceDeepLinkReferences(
    TemplateTransformationContext context,
    String contents,
  ) {
    final managedHosts = _managedDeepLinkHosts(context).toList()
      ..sort((left, right) => right.length.compareTo(left.length));
    final pattern = RegExp(managedHosts.map(RegExp.escape).join('|'));
    if (!pattern.hasMatch(contents)) {
      return _DeepLinkTextResult(contents: contents);
    }
    final replacement = context.next.deepLinkMode == DeepLinkMode.enabled
        ? context.next.deepLinkHost!
        : _deepLinkFixtureHost;
    return _DeepLinkTextResult(
      contents: contents.replaceAllMapped(pattern, (_) => replacement),
    );
  }

  _DeepLinkTextResult _replaceDeepLinkDocumentation(
    TemplateTransformationContext context,
    String contents,
  ) {
    final references = _replaceDeepLinkReferences(context, contents);
    if (references.error != null) return references;

    final replacementHost = context.next.deepLinkMode == DeepLinkMode.enabled
        ? context.next.deepLinkHost!
        : _deepLinkFixtureHost;
    var updated = references.contents.replaceFirst(
      _deepLinkDefaultsPattern,
      context.next.deepLinkMode == DeepLinkMode.enabled
          ? '- External deep links support **HTTPS** for `' +
                replacementHost +
                '` only (strict allowlist).'
          : '- External deep links are disabled for this project; the runtime allowlist and native platform claims are empty.',
    );
    final policy = context.next.deepLinkMode == DeepLinkMode.enabled
        ? 'Deep links are enabled for `https://' + replacementHost + '`.'
        : 'Deep links are disabled for this project. The `example.test` host below is illustrative only.';
    const start = '<!-- mobilekit:deep-link-policy:start -->';
    const end = '<!-- mobilekit:deep-link-policy:end -->';
    final policyBlock =
        start + '\n## Project policy\n\n- ' + policy + '\n' + end;
    final startIndex = updated.indexOf(start);
    final endIndex = updated.indexOf(end);
    if (startIndex >= 0 && endIndex > startIndex) {
      updated = updated.replaceRange(
        startIndex,
        endIndex + end.length,
        policyBlock,
      );
    } else {
      final headingEnd = updated.indexOf('\n');
      if (headingEnd < 0) {
        updated = policyBlock + '\n\n' + updated;
      } else {
        updated =
            updated.substring(0, headingEnd + 1) +
            '\n' +
            policyBlock +
            '\n' +
            updated.substring(headingEnd + 1);
      }
    }
    return _DeepLinkTextResult(contents: updated);
  }

  Set<String> _managedDeepLinkHosts(TemplateTransformationContext context) {
    return {
      TemplateCustomization.defaultDeepLinkHost,
      if (context.previous.deepLinkHost != null) context.previous.deepLinkHost!,
      if (context.next.deepLinkHost != null) context.next.deepLinkHost!,
      _deepLinkFixtureHost,
    };
  }

  List<TemplatePlanItem> _protectedIntegrationFiles(
    TemplateTransformationContext context,
  ) {
    const paths = [
      '.env/dev.yaml',
      '.env/staging.yaml',
      '.env/prod.yaml',
      'android/app/google-services.json',
      'ios/Runner/GoogleService-Info.plist',
    ];
    return [
      for (final path in paths)
        if (context.file(path).existsSync())
          TemplatePlanItem(
            status: TemplatePlanStatus.external,
            target: path,
            description:
                'protected user-owned file preserved; update it only through its explicit configuration workflow',
          ),
    ];
  }
}

class _FirebaseTransformation implements TemplateTransformation {
  @override
  String get id => 'Firebase external setup';

  @override
  TemplateTransformationResult plan(TemplateTransformationContext context) {
    final demoDetected = _demoFirebaseDetected(context.rootDirectory);
    final description = switch (context.next.firebaseMode) {
      FirebaseMode.configure =>
        demoDetected
            ? 'Run `flutterfire configure` for the new project and platforms; the tracked demo options remain until that external step completes.'
            : 'Review or run `flutterfire configure` for the selected project and platforms; credentials and generated native files remain external.',
      FirebaseMode.keepDemo =>
        demoDetected
            ? 'BLOCKING for production readiness: the tracked Firebase options still point to the template demo project.'
            : 'keep-demo was selected, but the template demo marker was not detected; verify the external Firebase state.',
      FirebaseMode.disabled =>
        'Firebase code is retained, but no Firebase project or native configuration files are changed.',
    };
    return TemplateTransformationResult(
      items: [
        TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'Firebase',
          description: description,
        ),
        const TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'API endpoints',
          description:
              'Runtime API endpoints remain in user-owned .env files and are not requested by init.',
        ),
        const TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'OIDC client IDs',
          description:
              'OIDC client IDs remain in user-owned environment configuration and are not stored in the manifest.',
        ),
        const TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'signing',
          description:
              'Android/iOS signing identities, certificates, and provisioning remain external setup.',
        ),
        const TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'CI secrets',
          description:
              'CI credentials and secret provisioning remain external setup.',
        ),
        const TemplatePlanItem(
          status: TemplatePlanStatus.external,
          target: 'store metadata',
          description:
              'App-store records, listings, screenshots, and release metadata remain external setup.',
        ),
      ],
    );
  }
}

class _DeepLinkTextResult {
  const _DeepLinkTextResult({required this.contents, this.error});

  final String contents;
  final String? error;
}

class _ParsedDeepLinkHosts {
  const _ParsedDeepLinkHosts({required this.hosts, this.error});

  final List<String> hosts;
  final String? error;
}

_ParsedDeepLinkHosts _parseDeepLinkHosts(String block) {
  final lines = block.split(RegExp(r'\r?\n'));
  final inline = lines.first.substring(lines.first.indexOf(':') + 1).trim();
  if (inline == '[]' || inline.isEmpty && lines.length == 1) {
    return const _ParsedDeepLinkHosts(hosts: []);
  }
  if (inline.isNotEmpty) {
    return const _ParsedDeepLinkHosts(
      hosts: [],
      error: 'deepLinkAllowedHosts must be a list or []',
    );
  }
  final hosts = <String>[];
  for (final line in lines.skip(1)) {
    final value = line.trim();
    if (value.isEmpty) continue;
    if (!value.startsWith('-')) {
      return const _ParsedDeepLinkHosts(
        hosts: [],
        error: 'deepLinkAllowedHosts contains an unsupported value',
      );
    }
    final host = value.substring(1).trim();
    if (host.isEmpty) {
      return const _ParsedDeepLinkHosts(
        hosts: [],
        error: 'deepLinkAllowedHosts contains an empty host',
      );
    }
    hosts.add(host.toLowerCase());
  }
  return _ParsedDeepLinkHosts(hosts: hosts);
}

List<String> _androidHosts(String filter) {
  return RegExp(
    r'android:host="([^"]+)"',
  ).allMatches(filter).map((match) => match.group(1)!.toLowerCase()).toList();
}

List<String> _androidHttpsHosts(String contents) {
  return _androidHttpsHostPattern
      .allMatches(contents)
      .map((match) => match.group(1)!.toLowerCase())
      .toList();
}

List<String> _associatedDomains(String block) {
  return RegExp(
    r'<string>([^<]+)</string>',
  ).allMatches(block).map((match) => match.group(1)!.trim()).toList();
}

String _associatedDomainsXml(List<String> domains) {
  final lines = domains.map((domain) => '\t\t<string>' + domain + '</string>');
  return '<key>com.apple.developer.associated-domains</key>\n\t<array>\n' +
      lines.join('\n') +
      '\n\t</array>';
}

TemplatePlanItem _integrationConflict(String target, String description) {
  return TemplatePlanItem(
    status: TemplatePlanStatus.conflicted,
    target: target,
    description: description,
  );
}

bool _demoFirebaseDetected(Directory rootDirectory) {
  const paths = ['firebase.json', 'lib/firebase_options.dart'];
  return paths.any((path) {
    final file = File(p.join(rootDirectory.path, path));
    return file.existsSync() &&
        file.readAsStringSync().contains('mobile-kit-5f1d6');
  });
}

final _deepLinkAllowedHostsPattern = RegExp(
  r'^deepLinkAllowedHosts[ \t]*:[^\r\n]*(?:\r?\n[ \t]+-[^\r\n]*)*',
  multiLine: true,
);
final _androidDeepLinkFilterPattern = RegExp(
  r'(?:[ \t]*<!-- HTTPS App Links.*?-->[ \t]*\r?\n)?[ \t]*<intent-filter\s+android:autoVerify="true"\s*>.*?</intent-filter>',
  multiLine: true,
  dotAll: true,
);
final _androidAutoVerifyPattern = RegExp(
  r'<intent-filter[^>]*android:autoVerify="true"',
);
final _androidHttpsHostPattern = RegExp(
  r'<data[^>]*android:scheme="https"[^>]*android:host="([^"]+)"',
);
final _associatedDomainsPattern = RegExp(
  r'<key>com\.apple\.developer\.associated-domains</key>\s*<array>.*?</array>',
  multiLine: true,
  dotAll: true,
);
final _deepLinkDefaultsPattern = RegExp(
  r'- External deep links support \*\*HTTPS\*\* for `[^`]+` only \(strict allowlist\)\.',
);
const _deepLinkFixtureHost = 'example.test';

class _AndroidReplacement {
  const _AndroidReplacement({
    required this.field,
    required this.pattern,
    required this.expected,
    required this.replacement,
  });

  final String field;
  final RegExp pattern;
  final String expected;
  final String replacement;
}

class _AndroidTextResult {
  const _AndroidTextResult({required this.contents, this.error});

  final String contents;
  final String? error;
}

_AndroidTextResult _replaceAndroidText(
  String contents,
  RegExp pattern, {
  required String expected,
  required String replacement,
}) {
  final matches = pattern.allMatches(contents).toList();
  if (matches.length != 1) {
    return _AndroidTextResult(
      contents: contents,
      error: matches.isEmpty
          ? 'managed assignment is missing'
          : 'managed assignment is defined more than once',
    );
  }
  final match = matches.single;
  final current = match.group(2)!;
  if (current != expected && current != replacement) {
    return _AndroidTextResult(
      contents: contents,
      error: 'found ' + current + ', expected ' + expected,
    );
  }
  if (current == replacement) return _AndroidTextResult(contents: contents);
  return _AndroidTextResult(
    contents: contents.replaceRange(
      match.start,
      match.end,
      match.group(1)! + replacement + match.group(3)!,
    ),
  );
}

RegExp _flavorSuffixPattern(String flavor) {
  return RegExp(
    r'''(create[ \t]*\([ \t]*["']''' +
        flavor +
        r'''["'][ \t]*\)[ \t]*\{[^{}]*?[ \t]*applicationIdSuffix[ \t]*=[ \t]*")([^"]*)("[ \t]*)''',
    multiLine: true,
  );
}

TemplatePlanItem _androidConflict(String target, String description) {
  return TemplatePlanItem(
    status: TemplatePlanStatus.conflicted,
    target: target,
    description: description,
  );
}

String _packagePath(String namespace) => namespace.split('.').join(p.separator);

bool _namespacePathOverlaps(String oldNamespace, String newNamespace) {
  return newNamespace.startsWith(oldNamespace + '.') ||
      oldNamespace.startsWith(newNamespace + '.');
}

void _collectAndroidSourceFiles(Directory directory, List<File> output) {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is Directory) {
      _collectAndroidSourceFiles(entity, output);
    } else if (entity is File &&
        (entity.path.endsWith('.kt') || entity.path.endsWith('.java'))) {
      output.add(entity);
    }
  }
}

String _xmlEscape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String _xmlUnescape(String value) {
  return value
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&gt;', '>')
      .replaceAll('&lt;', '<')
      .replaceAll('&amp;', '&');
}

TemplateTransformationResult _conflict(String path, String description) {
  return TemplateTransformationResult(
    items: [
      TemplatePlanItem(
        status: TemplatePlanStatus.conflicted,
        target: path,
        description: description,
      ),
    ],
  );
}

enum _AppTitleStyle { plain, rtl, pseudo }

String? _localizedTitle(String current, String previous, String next) {
  if (current == next) return current;
  final style = _appTitleStyle(current);
  final isManaged = switch (style) {
    _AppTitleStyle.plain => current == previous,
    _AppTitleStyle.rtl => current.startsWith('⟪RTL⟫'),
    _AppTitleStyle.pseudo => current.startsWith('⟪') && current.endsWith('⟫'),
  };
  if (!isManaged) return null;
  if (previous == next) return current;
  return switch (style) {
    _AppTitleStyle.plain => next,
    _AppTitleStyle.rtl => '⟪RTL⟫ ' + next,
    _AppTitleStyle.pseudo => '⟪' + _pseudoLocalize(next) + '⟫',
  };
}

_AppTitleStyle _appTitleStyle(String value) {
  if (value.startsWith('⟪RTL⟫')) return _AppTitleStyle.rtl;
  if (value.startsWith('⟪') && value.endsWith('⟫')) {
    return _AppTitleStyle.pseudo;
  }
  return _AppTitleStyle.plain;
}

String _pseudoLocalize(String value) {
  const accents = <String, String>{
    'A': 'Å',
    'B': 'Ƀ',
    'C': 'Ç',
    'D': 'Ḓ',
    'E': 'Ḗ',
    'F': 'Ƒ',
    'G': 'Ğ',
    'H': 'Ħ',
    'I': 'Ī',
    'J': 'Ĵ',
    'K': 'Ḳ',
    'L': 'Ŀ',
    'M': 'Ḿ',
    'N': 'Ń',
    'O': 'Ö',
    'P': 'Ƥ',
    'Q': 'Ɋ',
    'R': 'Ŗ',
    'S': 'Ş',
    'T': 'Ŧ',
    'U': 'Ü',
    'V': 'Ṽ',
    'W': 'Ẇ',
    'X': 'Ẋ',
    'Y': 'Ẏ',
    'Z': 'Ż',
    'a': 'å',
    'b': 'ƀ',
    'c': 'ç',
    'd': 'ḓ',
    'e': 'ḗ',
    'f': 'ƒ',
    'g': 'ğ',
    'h': 'ħ',
    'i': 'ī',
    'j': 'ĵ',
    'k': 'ķ',
    'l': 'ŀ',
    'm': 'ḿ',
    'n': 'ñ',
    'o': 'ǿ',
    'p': 'ρ',
    'q': 'ɋ',
    'r': 'ŗ',
    's': 'ş',
    't': 'ŧ',
    'u': 'ü',
    'v': 'ṽ',
    'w': 'ẇ',
    'x': 'ẋ',
    'y': 'ẏ',
    'z': 'ž',
  };
  return value
      .split('')
      .map((character) => accents[character] ?? character)
      .join();
}

String? _decodeJsonString(String encoded) {
  try {
    final decoded = jsonDecode(encoded);
    return decoded is String ? decoded : null;
  } on FormatException {
    return null;
  }
}

String _yamlQuote(String value) => "'" + value.replaceAll("'", "''") + "'";

final _pubspecNamePattern = RegExp(
  r'^( *name: *)([a-z][a-z0-9_]*)( *)$',
  multiLine: true,
);
final _pubspecDescriptionPattern = RegExp(
  r'^( *description: *).*$',
  multiLine: true,
);
final _appTitlePattern = RegExp(
  r'''^( *"appTitle" *: *)("(?:\\.|[^"\\])*")''',
  multiLine: true,
);
final _readmeHeadingPattern = RegExp(r'^(# +)([^\r\n]+)', multiLine: true);
final _productBundleIdentifierPattern = RegExp(
  r'^([ \t]*PRODUCT_BUNDLE_IDENTIFIER[ \t]*=[ \t]*)([^;]+)(;[ \t]*)$',
  multiLine: true,
);

void _collectFiles(
  Directory directory,
  List<File> output, {
  required String extension,
}) {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is Directory) {
      final name = p.basename(entity.path);
      if (name == 'gen' || name == '.dart_tool' || name == 'build') continue;
      _collectFiles(entity, output, extension: extension);
    } else if (entity is File && entity.path.endsWith(extension)) {
      if (extension == '.dart' &&
          (entity.path.endsWith('.g.dart') ||
              entity.path.endsWith('.freezed.dart'))) {
        continue;
      }
      output.add(entity);
    }
  }
}

String _relativePath(Directory root, File file) {
  return p.relative(file.path, from: root.path).replaceAll('\\', '/');
}

List<File> _textFiles(Directory root) {
  final output = <File>[];
  _collectTextFiles(root, root, output);
  return output;
}

void _collectTextFiles(Directory root, Directory directory, List<File> output) {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is Directory) {
      final relative = _relativePath(root, File(entity.path));
      if (_isExcludedFromResidualScan(relative)) continue;
      _collectTextFiles(root, entity, output);
    } else if (entity is File && _isTextFile(entity.path)) {
      output.add(entity);
    }
  }
}

bool _isTextFile(String path) {
  const extensions = {
    '.arb',
    '.dart',
    '.entitlements',
    '.gradle',
    '.java',
    '.json',
    '.kt',
    '.kts',
    '.md',
    '.plist',
    '.properties',
    '.sh',
    '.swift',
    '.txt',
    '.xml',
    '.yaml',
    '.yml',
  };
  return extensions.any(path.endsWith);
}

bool _isExcludedFromResidualScan(String relativePath) {
  final path = relativePath.replaceAll('\\', '/');
  const prefixes = [
    '.git/',
    '.dart_tool/',
    '.fvm/',
    '.tmp/',
    'build/',
    'ios/Pods/',
    'android/.gradle/',
    'lib/l10n/gen/',
    'packages/mobile_core_kit_cli/',
    'packages/mobile_core_kit_lints/',
  ];
  return prefixes.any(path.startsWith) || path == '.git';
}

class _TemplateConflictException implements Exception {
  const _TemplateConflictException(this.message);

  final String message;
}

class _TemplateFileTransaction {
  _TemplateFileTransaction(this.rootDirectory);

  final Directory rootDirectory;

  void apply(
    List<TemplateFileChange> changes, {
    void Function(String relativePath)? beforeWrite,
  }) {
    final entries = <_AtomicFileEntry>[];
    final token = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      for (var index = 0; index < changes.length; index++) {
        final change = changes[index];
        final target = File(p.join(rootDirectory.path, change.relativePath));
        final current =
            target.existsSync() &&
                target.statSync().type == FileSystemEntityType.file
            ? target.readAsBytesSync()
            : null;
        if (!_sameBytes(change.beforeBytes, current)) {
          throw _TemplateConflictException(
            'Managed file changed during customization: ' + change.relativePath,
          );
        }

        final temporary = File(
          target.path + '.mobilekit-tmp-' + token + '-' + index.toString(),
        );
        final backup = File(
          target.path + '.mobilekit-bak-' + token + '-' + index.toString(),
        );
        final entry = _AtomicFileEntry(
          target: target,
          temporary: temporary,
          backup: backup,
          hadOriginal: current != null,
        );
        entries.add(entry);
        beforeWrite?.call(change.relativePath);
        if (target.existsSync()) {
          target.renameSync(backup.path);
          entry.backupCreated = true;
        }
        if (change.afterBytes != null) {
          target.parent.createSync(recursive: true);
          temporary.writeAsBytesSync(change.afterBytes!, flush: true);
          temporary.renameSync(target.path);
          entry.targetInstalled = true;
        }
      }
      for (final entry in entries) {
        if (entry.backup.existsSync()) entry.backup.deleteSync();
        if (entry.temporary.existsSync()) entry.temporary.deleteSync();
      }
    } catch (error) {
      for (final entry in entries.reversed) {
        try {
          if (entry.targetInstalled && entry.target.existsSync()) {
            entry.target.deleteSync();
          }
          if (entry.backupCreated && entry.backup.existsSync()) {
            entry.backup.renameSync(entry.target.path);
          }
          if (!entry.hadOriginal && entry.target.existsSync()) {
            entry.target.deleteSync();
          }
          if (entry.temporary.existsSync()) entry.temporary.deleteSync();
          if (entry.backup.existsSync()) entry.backup.deleteSync();
        } catch (_) {
          // Preserve the original failure; the next verification will report
          // any filesystem state that could not be restored.
        }
      }
      rethrow;
    }
  }
}

class _AtomicFileEntry {
  _AtomicFileEntry({
    required this.target,
    required this.temporary,
    required this.backup,
    required this.hadOriginal,
  });

  final File target;
  final File temporary;
  final File backup;
  final bool hadOriginal;
  bool backupCreated = false;
  bool targetInstalled = false;
}

bool _sameBytes(List<int>? expected, List<int>? actual) {
  if (expected == null || actual == null) {
    return expected == null && actual == null;
  }
  return templateBytesEqual(expected, actual);
}
