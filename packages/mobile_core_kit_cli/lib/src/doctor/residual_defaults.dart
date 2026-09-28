import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:path/path.dart' as p;

enum ResidualDefaultSeverity {
  blocking,
  reviewRequired,
  historical;

  String get label => switch (this) {
    ResidualDefaultSeverity.blocking => 'blocking',
    ResidualDefaultSeverity.reviewRequired => 'review-required',
    ResidualDefaultSeverity.historical => 'historical',
  };
}

class ResidualDefaultFinding {
  const ResidualDefaultFinding({
    required this.marker,
    required this.severity,
    required this.detail,
    required this.paths,
  });

  final String marker;
  final ResidualDefaultSeverity severity;
  final String detail;
  final List<String> paths;
}

/// Finds known template values after a project has been customized.
///
/// The scanner is intentionally narrow. It is a diagnostic safety net for
/// values the customization registry already knows about, not a replacement
/// for the registry and not a repository-wide search-and-replace mechanism.
class ResidualDefaultScanner {
  List<ResidualDefaultFinding> scan(
    Directory rootDirectory,
    TemplateCustomization customization,
  ) {
    final matches = <String, _ResidualMatch>{};
    for (final file in _textFiles(rootDirectory)) {
      final relativePath = _relativePath(rootDirectory, file);
      final contents = _readText(file);
      if (contents == null) continue;

      for (final marker in _markers) {
        if (!marker.pattern.hasMatch(contents)) continue;
        final severity = marker.severity(relativePath, customization);
        final key = marker.id + ':' + severity.label;
        final match = matches.putIfAbsent(
          key,
          () => _ResidualMatch(marker: marker, severity: severity),
        );
        match.paths.add(relativePath);
      }
    }

    final findings = matches.values
        .map(
          (match) => ResidualDefaultFinding(
            marker: match.marker.id,
            severity: match.severity,
            detail: match.marker.detail(customization),
            paths: List<String>.unmodifiable(match.paths.toList()..sort()),
          ),
        )
        .toList();
    findings.sort((left, right) {
      final severity = left.severity.index.compareTo(right.severity.index);
      if (severity != 0) return severity;
      return left.marker.compareTo(right.marker);
    });
    return findings;
  }
}

class _ResidualMatch {
  _ResidualMatch({required this.marker, required this.severity});

  final _ResidualMarker marker;
  final ResidualDefaultSeverity severity;
  final paths = <String>{};
}

class _ResidualMarker {
  const _ResidualMarker({
    required this.id,
    required this.pattern,
    required this.detail,
    required this.severity,
  });

  final String id;
  final RegExp pattern;
  final String Function(TemplateCustomization customization) detail;
  final ResidualDefaultSeverity Function(
    String relativePath,
    TemplateCustomization customization,
  )
  severity;
}

final _markers = <_ResidualMarker>[
  _ResidualMarker(
    id: 'template Dart package',
    pattern: RegExp(
      r'(?:name:\s*mobile_core_kit\s*$|package:mobile_core_kit/)',
    ),
    detail: (_) =>
        'The application still contains the template Dart package identity.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'template display name',
    pattern: RegExp(r'\bMobile Core Kit\b'),
    detail: (_) => 'The application still contains the template display name.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'template description',
    pattern: RegExp(r'A new Flutter project\.'),
    detail: (_) =>
        'The root project still contains the Flutter template description.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'Android namespace',
    pattern: RegExp(r'com\.example\.mobile_core_kit'),
    detail: (_) =>
        'The Android namespace or Kotlin package still uses the template default.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'platform bundle identity',
    pattern: RegExp(r'dev\.fikril\.mobile\.corekit(?:\.runnertests)?'),
    detail: (_) =>
        'Android or iOS bundle identity still uses the template default.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'deep-link host',
    pattern: RegExp(r'\blinks\.fikril\.dev\b'),
    detail: (customization) =>
        customization.deepLinkMode == DeepLinkMode.disabled
        ? 'The disabled deep-link policy still contains the template host.'
        : 'The enabled deep-link policy still contains the template host.',
    severity: _applicationSeverity,
  ),
  _ResidualMarker(
    id: 'demo Firebase project',
    pattern: RegExp(r'\bmobile-kit-5f1d6\b'),
    detail: (customization) =>
        customization.firebaseMode == FirebaseMode.disabled
        ? 'Demo Firebase identity is intentionally preserved because Firebase is disabled.'
        : 'Firebase still points at the template demo project; run flutterfire configure.',
    severity: (path, customization) {
      if (customization.firebaseMode == FirebaseMode.disabled) {
        return ResidualDefaultSeverity.historical;
      }
      return ResidualDefaultSeverity.blocking;
    },
  ),
  _ResidualMarker(
    id: 'placeholder environment value',
    pattern: RegExp(
      r'<your-[^>]+>|https?://[a-z0-9-]+-(?:core|auth|profile)\.example\.com',
      caseSensitive: false,
    ),
    detail: (_) =>
        'Environment examples still contain placeholder endpoints or client IDs; configure real user-owned values before release.',
    severity: (path, _) => path == '.env/prod.yaml'
        ? ResidualDefaultSeverity.blocking
        : ResidualDefaultSeverity.reviewRequired,
  ),
];

ResidualDefaultSeverity _applicationSeverity(
  String relativePath,
  TemplateCustomization _,
) {
  if (_isHistoricalPath(relativePath)) {
    return ResidualDefaultSeverity.historical;
  }
  return ResidualDefaultSeverity.blocking;
}

bool _isHistoricalPath(String relativePath) {
  final path = relativePath.replaceAll('\\', '/');
  const prefixes = [
    '_WIP/',
    'docs/engineering/',
    'docs/exec-plans/',
    'packages/mobile_core_kit_cli/',
    'packages/mobile_core_kit_lints/',
  ];
  return prefixes.any(path.startsWith) || path == '.mobilekit/template.yaml';
}

List<File> _textFiles(Directory rootDirectory) {
  final files = <File>[];
  _collectTextFiles(rootDirectory, rootDirectory, files);
  return files;
}

void _collectTextFiles(
  Directory rootDirectory,
  Directory directory,
  List<File> output,
) {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is Directory) {
      final relativePath = _relativePath(rootDirectory, entity);
      if (_isExcludedDirectory(relativePath)) continue;
      _collectTextFiles(rootDirectory, entity, output);
    } else if (entity is File && _isTextFile(entity.path)) {
      output.add(entity);
    }
  }
}

String? _readText(File file) {
  try {
    return file.readAsStringSync();
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}

bool _isExcludedDirectory(String relativePath) {
  final path = relativePath.replaceAll('\\', '/');
  const prefixes = [
    '.git',
    '.dart_tool',
    '.fvm',
    '.tmp',
    'build',
    'android/.gradle',
    'ios/Pods',
  ];
  return prefixes.any(
    (prefix) => path == prefix || path.startsWith('$prefix/'),
  );
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
    '.swift',
    '.txt',
    '.xml',
    '.yaml',
    '.yml',
  };
  return extensions.any(path.endsWith);
}

String _relativePath(Directory rootDirectory, FileSystemEntity entity) {
  return p
      .relative(entity.path, from: rootDirectory.path)
      .replaceAll('\\', '/');
}
