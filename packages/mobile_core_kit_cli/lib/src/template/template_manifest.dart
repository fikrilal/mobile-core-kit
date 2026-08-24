import 'dart:io';

import 'package:yaml/yaml.dart';

const templateMarkerRelativePath = '.mobilekit/template.yaml';
const projectManifestRelativePath = '.mobilekit/project.yaml';
const supportedTemplateId = 'mobile_core_kit';
const currentTemplateSchema = 1;
const currentTemplateVersion = '2026-08-16';

const defaultManagedSurfaces = <String>[
  'application_package',
  'product_branding',
  'android_identity',
  'ios_identity',
  'deep_links',
  'environment_examples',
  'firebase',
];

enum DeepLinkMode {
  enabled,
  disabled;

  String get wireValue => name;

  static DeepLinkMode parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'enabled' => DeepLinkMode.enabled,
      'disabled' => DeepLinkMode.disabled,
      _ => throw FormatException(
        'deep_links.mode must be enabled or disabled.',
      ),
    };
  }
}

enum FirebaseMode {
  configure,
  keepDemo,
  disabled;

  String get wireValue => switch (this) {
    FirebaseMode.configure => 'configure',
    FirebaseMode.keepDemo => 'keep-demo',
    FirebaseMode.disabled => 'disabled',
  };

  static FirebaseMode parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'configure' => FirebaseMode.configure,
      'keep-demo' => FirebaseMode.keepDemo,
      'disabled' => FirebaseMode.disabled,
      _ => throw FormatException(
        'firebase.mode must be configure, keep-demo, or disabled.',
      ),
    };
  }
}

class TemplateMarker {
  const TemplateMarker({
    required this.schema,
    required this.template,
    required this.version,
  });

  final int schema;
  final String template;
  final String version;

  factory TemplateMarker.fromFile(File file) {
    if (!file.existsSync()) {
      throw FormatException('Missing template marker: ' + file.path);
    }

    final map = _loadMap(file.readAsStringSync(), 'template marker');
    _rejectSecretKeys(map, 'template marker');
    _assertAllowedKeys(map, const {
      'schema',
      'template',
      'version',
    }, 'template marker');
    final schema = _optionalInt(map['schema']) ?? currentTemplateSchema;
    if (schema != currentTemplateSchema) {
      throw FormatException(
        'Unsupported template marker schema ' +
            schema.toString() +
            '. Expected ' +
            currentTemplateSchema.toString() +
            '.',
      );
    }

    final template = _requiredString(map['template'], 'template');
    if (template != supportedTemplateId) {
      throw FormatException(
        'Unsupported template "' +
            template +
            '". Expected ' +
            supportedTemplateId +
            '.',
      );
    }

    return TemplateMarker(
      schema: schema,
      template: template,
      version: _requiredString(map['version'], 'version'),
    );
  }
}

class TemplateCustomization {
  const TemplateCustomization._({
    required this.repositorySlug,
    required this.repositoryDescription,
    required this.displayName,
    required this.dartPackage,
    required this.androidNamespace,
    required this.androidApplicationId,
    required this.androidDevSuffix,
    required this.androidStagingSuffix,
    required this.iosBundleId,
    required this.iosTestBundleId,
    required this.deepLinkMode,
    required this.deepLinkHost,
    required this.firebaseMode,
    required this.environmentExamplesUpdated,
  });

  static const defaultAndroidNamespace = 'com.example.mobile_core_kit';
  static const defaultAndroidApplicationId = 'dev.fikril.mobile.corekit';
  static const defaultIosBundleId = 'dev.fikril.mobile.corekit';
  static const defaultDeepLinkHost = 'links.fikril.dev';

  final String repositorySlug;
  final String repositoryDescription;
  final String displayName;
  final String dartPackage;
  final String androidNamespace;
  final String androidApplicationId;
  final String androidDevSuffix;
  final String androidStagingSuffix;
  final String iosBundleId;
  final String iosTestBundleId;
  final DeepLinkMode deepLinkMode;
  final String? deepLinkHost;
  final FirebaseMode firebaseMode;
  final bool environmentExamplesUpdated;

  String get androidDevApplicationId => androidApplicationId + androidDevSuffix;

  String get androidStagingApplicationId =>
      androidApplicationId + androidStagingSuffix;

  String get androidProductionApplicationId => androidApplicationId;

  TemplateCustomization withEnvironmentExamplesUpdated(bool updated) {
    return TemplateCustomization._(
      repositorySlug: repositorySlug,
      repositoryDescription: repositoryDescription,
      displayName: displayName,
      dartPackage: dartPackage,
      androidNamespace: androidNamespace,
      androidApplicationId: androidApplicationId,
      androidDevSuffix: androidDevSuffix,
      androidStagingSuffix: androidStagingSuffix,
      iosBundleId: iosBundleId,
      iosTestBundleId: iosTestBundleId,
      deepLinkMode: deepLinkMode,
      deepLinkHost: deepLinkHost,
      firebaseMode: firebaseMode,
      environmentExamplesUpdated: updated,
    );
  }

  factory TemplateCustomization.fromValues({
    required String repositorySlug,
    String? repositoryDescription,
    required String displayName,
    String? dartPackage,
    required String androidNamespace,
    required String androidApplicationId,
    String androidDevSuffix = '.dev',
    String androidStagingSuffix = '.staging',
    required String iosBundleId,
    String? iosTestBundleId,
    DeepLinkMode deepLinkMode = DeepLinkMode.disabled,
    String? deepLinkHost,
    FirebaseMode firebaseMode = FirebaseMode.configure,
    bool environmentExamplesUpdated = false,
  }) {
    final normalizedSlug = normalizeRepositorySlug(repositorySlug);
    final normalizedDisplayName = displayName.trim();
    final normalizedIosBundleId = iosBundleId.trim().toLowerCase();
    final normalizedDeepLinkHost = deepLinkMode == DeepLinkMode.enabled
        ? deepLinkHost?.trim().toLowerCase()
        : null;

    final value = TemplateCustomization._(
      repositorySlug: normalizedSlug,
      repositoryDescription: repositoryDescription?.trim().isNotEmpty == true
          ? repositoryDescription!.trim()
          : normalizedDisplayName,
      displayName: normalizedDisplayName,
      dartPackage: (dartPackage ?? dartPackageForSlug(normalizedSlug))
          .trim()
          .toLowerCase(),
      androidNamespace: androidNamespace.trim().toLowerCase(),
      androidApplicationId: androidApplicationId.trim().toLowerCase(),
      androidDevSuffix: androidDevSuffix.trim().toLowerCase(),
      androidStagingSuffix: androidStagingSuffix.trim().toLowerCase(),
      iosBundleId: normalizedIosBundleId,
      iosTestBundleId:
          iosTestBundleId?.trim().toLowerCase() ??
          normalizedIosBundleId + '.runnertests',
      deepLinkMode: deepLinkMode,
      deepLinkHost: normalizedDeepLinkHost,
      firebaseMode: firebaseMode,
      environmentExamplesUpdated: environmentExamplesUpdated,
    );
    value.validate();
    return value;
  }

  factory TemplateCustomization.fromYaml(String contents) {
    return TemplateCustomization.fromMap(
      _loadMap(contents, 'customization input'),
    );
  }

  factory TemplateCustomization.fromMap(Map<String, dynamic> root) {
    _rejectSecretKeys(root, 'root');
    _assertAllowedKeys(root, const {
      'schema',
      'template',
      'template_version',
      'repository',
      'app',
      'platforms',
      'deep_links',
      'firebase',
      'environment',
      'managed_surfaces',
      'managed_files',
    }, 'root');

    final schema = _optionalInt(root['schema']);
    if (schema != null && schema != currentTemplateSchema) {
      throw FormatException(
        'Unsupported customization schema ' +
            schema.toString() +
            '. Expected ' +
            currentTemplateSchema.toString() +
            '.',
      );
    }

    final template = _optionalString(root['template']);
    if (template != null && template != supportedTemplateId) {
      throw FormatException(
        'Unsupported template "' +
            template +
            '". Expected ' +
            supportedTemplateId +
            '.',
      );
    }

    final repository = _mapValue(root['repository'], 'repository');
    _assertAllowedKeys(repository, const {'slug', 'description'}, 'repository');
    final repositorySlug = _requiredString(
      repository['slug'],
      'repository.slug',
    );

    final app = _mapValue(root['app'], 'app');
    _assertAllowedKeys(app, const {'display_name', 'dart_package'}, 'app');
    final displayName = _requiredString(
      app['display_name'],
      'app.display_name',
    );

    final platforms = _mapValue(root['platforms'], 'platforms');
    _assertAllowedKeys(platforms, const {'android', 'ios'}, 'platforms');

    final android = _mapValue(platforms['android'], 'platforms.android');
    _assertAllowedKeys(android, const {
      'namespace',
      'application_id',
      'flavor_suffixes',
    }, 'platforms.android');
    final flavorSuffixes = android['flavor_suffixes'] == null
        ? const <String, dynamic>{}
        : _mapValue(
            android['flavor_suffixes'],
            'platforms.android.flavor_suffixes',
          );
    _assertAllowedKeys(flavorSuffixes, const {
      'dev',
      'staging',
    }, 'platforms.android.flavor_suffixes');

    final ios = _mapValue(platforms['ios'], 'platforms.ios');
    _assertAllowedKeys(ios, const {
      'bundle_id',
      'test_bundle_id',
    }, 'platforms.ios');

    final deepLinks = root['deep_links'] == null
        ? const <String, dynamic>{}
        : _mapValue(root['deep_links'], 'deep_links');
    _assertAllowedKeys(deepLinks, const {'mode', 'host'}, 'deep_links');

    final firebase = root['firebase'] == null
        ? const <String, dynamic>{}
        : _mapValue(root['firebase'], 'firebase');
    _assertAllowedKeys(firebase, const {'mode'}, 'firebase');

    final environment = root['environment'] == null
        ? const <String, dynamic>{}
        : _mapValue(root['environment'], 'environment');
    _assertAllowedKeys(environment, const {'examples_updated'}, 'environment');

    return TemplateCustomization.fromValues(
      repositorySlug: repositorySlug,
      repositoryDescription: _optionalString(repository['description']),
      displayName: displayName,
      dartPackage: _optionalString(app['dart_package']),
      androidNamespace: _requiredString(
        android['namespace'],
        'platforms.android.namespace',
      ),
      androidApplicationId: _requiredString(
        android['application_id'],
        'platforms.android.application_id',
      ),
      androidDevSuffix: _optionalString(flavorSuffixes['dev']) ?? '.dev',
      androidStagingSuffix:
          _optionalString(flavorSuffixes['staging']) ?? '.staging',
      iosBundleId: _requiredString(ios['bundle_id'], 'platforms.ios.bundle_id'),
      iosTestBundleId: _optionalString(ios['test_bundle_id']),
      deepLinkMode: DeepLinkMode.parse(
        _optionalString(deepLinks['mode']) ?? 'disabled',
      ),
      deepLinkHost: _optionalString(deepLinks['host']),
      firebaseMode: FirebaseMode.parse(
        _optionalString(firebase['mode']) ?? 'configure',
      ),
      environmentExamplesUpdated:
          _optionalBool(environment['examples_updated']) ?? false,
    );
  }

  static String dartPackageForSlug(String slug) {
    final normalized = slug
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'mobile_app' : normalized;
  }

  static String normalizeRepositorySlug(String slug) {
    return slug
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void validate() {
    _validateSingleLine(repositorySlug, 'repository.slug');
    _validateSingleLine(repositoryDescription, 'repository.description');
    _validateSingleLine(displayName, 'app.display_name');

    if (displayName.isEmpty) {
      throw const FormatException('app.display_name must be non-empty.');
    }

    if (!_slugPattern.hasMatch(repositorySlug)) {
      throw FormatException(
        'repository.slug must use lowercase kebab-case: ' + repositorySlug,
      );
    }
    if (!_dartPackagePattern.hasMatch(dartPackage)) {
      throw FormatException(
        'app.dart_package must use lowercase snake_case: ' + dartPackage,
      );
    }
    if (!_dottedIdentifierPattern.hasMatch(androidNamespace)) {
      throw FormatException(
        'platforms.android.namespace is not a valid lowercase namespace: ' +
            androidNamespace,
      );
    }
    if (!_dottedIdentifierPattern.hasMatch(androidApplicationId)) {
      throw FormatException(
        'platforms.android.application_id is not a valid application ID: ' +
            androidApplicationId,
      );
    }
    if (!_suffixPattern.hasMatch(androidDevSuffix) ||
        !_suffixPattern.hasMatch(androidStagingSuffix)) {
      throw FormatException(
        'Android flavor suffixes must be empty or start with a dot and use '
        'lowercase letters, digits, or hyphens.',
      );
    }
    if (!_iosBundlePattern.hasMatch(iosBundleId) ||
        !iosBundleId.contains('.')) {
      throw FormatException(
        'platforms.ios.bundle_id is not a valid reverse-DNS bundle ID: ' +
            iosBundleId,
      );
    }
    if (!_iosBundlePattern.hasMatch(iosTestBundleId) ||
        !iosTestBundleId.contains('.')) {
      throw FormatException(
        'platforms.ios.test_bundle_id is not a valid bundle ID: ' +
            iosTestBundleId,
      );
    }
    if (iosTestBundleId == iosBundleId) {
      throw const FormatException(
        'platforms.ios.test_bundle_id must differ from the application bundle ID.',
      );
    }

    if (deepLinkMode == DeepLinkMode.enabled) {
      final host = deepLinkHost;
      if (host == null || !_hostPattern.hasMatch(host) || !host.contains('.')) {
        throw FormatException(
          'deep_links.host must be a hostname when deep links are enabled.',
        );
      }
    }

    for (final value in [
      androidNamespace,
      androidApplicationId,
      iosBundleId,
      iosTestBundleId,
      androidDevSuffix,
      androidStagingSuffix,
      deepLinkHost,
    ]) {
      if (value != null) _validateSingleLine(value, 'identity value');
    }
  }

  void writeYaml(StringBuffer buffer) {
    final host = deepLinkHost == null ? 'null' : _quote(deepLinkHost!);
    buffer
      ..writeln('repository:')
      ..writeln('  slug: ' + _quote(repositorySlug))
      ..writeln('  description: ' + _quote(repositoryDescription))
      ..writeln('app:')
      ..writeln('  display_name: ' + _quote(displayName))
      ..writeln('  dart_package: ' + _quote(dartPackage))
      ..writeln('platforms:')
      ..writeln('  android:')
      ..writeln('    namespace: ' + _quote(androidNamespace))
      ..writeln('    application_id: ' + _quote(androidApplicationId))
      ..writeln('    flavor_suffixes:')
      ..writeln('      dev: ' + _quote(androidDevSuffix))
      ..writeln('      staging: ' + _quote(androidStagingSuffix))
      ..writeln('  ios:')
      ..writeln('    bundle_id: ' + _quote(iosBundleId))
      ..writeln('    test_bundle_id: ' + _quote(iosTestBundleId))
      ..writeln('deep_links:')
      ..writeln('  mode: ' + deepLinkMode.wireValue)
      ..writeln('  host: ' + host)
      ..writeln('firebase:')
      ..writeln('  mode: ' + firebaseMode.wireValue)
      ..writeln('environment:')
      ..writeln('  examples_updated: ' + environmentExamplesUpdated.toString());
  }
}

class TemplateManifest {
  const TemplateManifest({
    required this.schema,
    required this.template,
    required this.templateVersion,
    required this.customization,
    required this.managedSurfaces,
    this.managedFileFingerprints = const {},
  });

  final int schema;
  final String template;
  final String templateVersion;
  final TemplateCustomization customization;
  final List<String> managedSurfaces;
  final Map<String, String> managedFileFingerprints;

  factory TemplateManifest.forMarker({
    required TemplateMarker marker,
    required TemplateCustomization customization,
    Map<String, String> managedFileFingerprints = const {},
  }) {
    return TemplateManifest(
      schema: currentTemplateSchema,
      template: marker.template,
      templateVersion: marker.version,
      customization: customization,
      managedSurfaces: List<String>.unmodifiable(defaultManagedSurfaces),
      managedFileFingerprints: Map<String, String>.unmodifiable(
        managedFileFingerprints,
      ),
    );
  }

  TemplateManifest withManagedFileFingerprints(
    Map<String, String> fingerprints,
  ) {
    return TemplateManifest(
      schema: schema,
      template: template,
      templateVersion: templateVersion,
      customization: customization,
      managedSurfaces: managedSurfaces,
      managedFileFingerprints: Map<String, String>.unmodifiable(fingerprints),
    );
  }

  TemplateManifest withCustomization(TemplateCustomization customization) {
    return TemplateManifest(
      schema: schema,
      template: template,
      templateVersion: templateVersion,
      customization: customization,
      managedSurfaces: managedSurfaces,
      managedFileFingerprints: managedFileFingerprints,
    );
  }

  factory TemplateManifest.fromFile(File file) {
    if (!file.existsSync()) {
      throw FormatException('Project manifest not found: ' + file.path);
    }

    return TemplateManifest.fromYaml(file.readAsStringSync());
  }

  factory TemplateManifest.fromYaml(String contents) {
    final root = _loadMap(contents, 'project manifest');
    final schema = _optionalInt(root['schema']) ?? currentTemplateSchema;
    if (schema != currentTemplateSchema) {
      throw FormatException(
        'Unsupported project manifest schema ' +
            schema.toString() +
            '. Expected ' +
            currentTemplateSchema.toString() +
            '.',
      );
    }

    final template = _optionalString(root['template']) ?? supportedTemplateId;
    if (template != supportedTemplateId) {
      throw FormatException(
        'Unsupported template "' +
            template +
            '". Expected ' +
            supportedTemplateId +
            '.',
      );
    }

    final customization = TemplateCustomization.fromMap(root);
    final version = _requiredString(
      root['template_version'],
      'template_version',
    );
    final surfaces =
        _stringList(root['managed_surfaces']) ??
        List<String>.from(defaultManagedSurfaces);
    if (surfaces.isEmpty) {
      throw FormatException('managed_surfaces must not be empty.');
    }

    return TemplateManifest(
      schema: schema,
      template: template,
      templateVersion: version,
      customization: customization,
      managedSurfaces: List<String>.unmodifiable(surfaces),
      managedFileFingerprints: Map<String, String>.unmodifiable(
        _stringMap(root['managed_files']) ?? const {},
      ),
    );
  }

  String toYaml() {
    final buffer = StringBuffer()
      ..writeln('schema: ' + schema.toString())
      ..writeln('template: ' + _quote(template))
      ..writeln('template_version: ' + _quote(templateVersion));
    customization.writeYaml(buffer);
    buffer
      ..writeln('managed_surfaces:')
      ..writeAll(
        managedSurfaces.map((surface) => '  - ' + _quote(surface) + '\n'),
      );
    if (managedFileFingerprints.isNotEmpty) {
      buffer.writeln('managed_files:');
      final paths = managedFileFingerprints.keys.toList()..sort();
      for (final path in paths) {
        buffer.writeln(
          '  ' + _quote(path) + ': ' + _quote(managedFileFingerprints[path]!),
        );
      }
    }
    return buffer.toString();
  }

  void writeTo(File file) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(toYaml());
  }
}

final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
final _dartPackagePattern = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');
final _dottedIdentifierPattern = RegExp(
  r'^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+$',
);
final _iosBundlePattern = RegExp(r'^[a-z0-9][a-z0-9.-]*$');
final _hostPattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)+$',
);
final _suffixPattern = RegExp(r'^(?:\.[a-z0-9][a-z0-9-]*)?$');
final _secretKeyPattern = RegExp(
  r'(secret|token|password|private.?key|credential|api.?key|access.?key)',
  caseSensitive: false,
);

Map<String, dynamic> _loadMap(String contents, String source) {
  dynamic decoded;
  try {
    decoded = loadYaml(contents);
  } catch (error) {
    throw FormatException(
      'Invalid YAML in ' + source + ': ' + error.toString(),
    );
  }
  return _mapValue(decoded, source);
}

Map<String, dynamic> _mapValue(dynamic value, String path) {
  if (value is! Map) {
    throw FormatException(path + ' must be a YAML map.');
  }

  final result = <String, dynamic>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw FormatException(path + ' contains a non-string key.');
    }
    result[entry.key as String] = entry.value;
  }
  return result;
}

void _assertAllowedKeys(
  Map<String, dynamic> map,
  Set<String> allowed,
  String path,
) {
  for (final key in map.keys) {
    if (!allowed.contains(key)) {
      throw FormatException('Unsupported field ' + path + '.' + key + '.');
    }
  }
}

void _rejectSecretKeys(dynamic value, String path) {
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      // `managed_files` values are fingerprint hashes keyed by repository
      // file paths; the path keys legitimately contain words like `token`
      // (e.g. `token_refresher.dart`). Secret rejection applies to
      // customization input field names, not managed file paths.
      if (key == 'managed_files') continue;
      if (_secretKeyPattern.hasMatch(key)) {
        throw FormatException(
          'Secret-like field ' +
              path +
              '.' +
              key +
              ' is not accepted in template input.',
        );
      }
      _rejectSecretKeys(entry.value, path + '.' + key);
    }
  } else if (value is List) {
    for (var index = 0; index < value.length; index++) {
      _rejectSecretKeys(value[index], path + '[' + index.toString() + ']');
    }
  }
}

String _requiredString(dynamic value, String path) {
  final result = _optionalString(value);
  if (result == null || result.isEmpty) {
    throw FormatException(path + ' must be a non-empty string.');
  }
  return result;
}

String? _optionalString(dynamic value) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException(
      'Expected a string but received ' + value.runtimeType.toString() + '.',
    );
  }
  final result = value.trim();
  return result.isEmpty ? null : result;
}

int? _optionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  throw FormatException(
    'Expected an integer but received ' + value.runtimeType.toString() + '.',
  );
}

bool? _optionalBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    return switch (value.trim().toLowerCase()) {
      'true' => true,
      'false' => false,
      _ => throw FormatException(
        'Expected a boolean but received "' + value + '".',
      ),
    };
  }
  throw FormatException(
    'Expected a boolean but received ' + value.runtimeType.toString() + '.',
  );
}

List<String>? _stringList(dynamic value) {
  if (value == null) return null;
  if (value is! List) {
    throw FormatException(
      'Expected a YAML list but received ' + value.runtimeType.toString() + '.',
    );
  }

  final result = <String>[];
  for (final item in value) {
    final string = _requiredString(item, 'list item');
    result.add(string);
  }
  return result;
}

Map<String, String>? _stringMap(dynamic value) {
  if (value == null) return null;
  final map = _mapValue(value, 'managed_files');
  final result = <String, String>{};
  for (final entry in map.entries) {
    result[entry.key] = _requiredString(
      entry.value,
      'managed_files.${entry.key}',
    );
  }
  return result;
}

String _quote(String value) => "'" + value.replaceAll("'", "''") + "'";

void _validateSingleLine(String value, String path) {
  if (value.contains('\n') || value.contains('\r')) {
    throw FormatException(path + ' must be a single line.');
  }
}
