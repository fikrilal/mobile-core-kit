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

  File file(String relativePath) =>
      File(p.join(rootDirectory.path, relativePath));

  TemplateFileChange change(String relativePath, String contents) {
    final target = file(relativePath);
    final before = target.existsSync() ? target.readAsBytesSync() : null;
    return TemplateFileChange(
      relativePath: relativePath,
      beforeBytes: before,
      afterBytes: utf8.encode(contents),
    );
  }

  String? readText(String relativePath) {
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
    final context = TemplateTransformationContext(
      rootDirectory: rootDirectory,
      previous: previous,
      next: nextManifest.customization,
    );
    final items = <TemplatePlanItem>[];
    final changes = <TemplateFileChange>[];

    items.addAll(_checkManagedFileFingerprints(context));

    final transformations = <TemplateTransformation>[
      _PubspecTransformation(),
      _DartPackageImportTransformation(),
      _LocalizationTransformation(),
      _ReadmeTransformation(),
    ];
    for (final transformation in transformations) {
      final result = transformation.plan(context);
      changes.addAll(result.changes);
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
      managedFiles[change.relativePath] = change.afterFingerprint;
    }

    final manifest = nextManifest.withManagedFileFingerprints(managedFiles);
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
    return TemplateCustomization.fromValues(
      repositorySlug: repositorySlug,
      repositoryDescription: displayName,
      displayName: displayName,
      dartPackage: packageName,
      androidNamespace: TemplateCustomization.defaultAndroidNamespace,
      androidApplicationId: TemplateCustomization.defaultAndroidApplicationId,
      iosBundleId: TemplateCustomization.defaultIosBundleId,
    );
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
        target.parent.createSync(recursive: true);
        temporary.writeAsBytesSync(change.afterBytes, flush: true);
        if (target.existsSync()) {
          target.renameSync(backup.path);
          entry.backupCreated = true;
        }
        temporary.renameSync(target.path);
        entry.targetInstalled = true;
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
