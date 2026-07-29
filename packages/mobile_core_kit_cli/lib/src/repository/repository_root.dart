import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:path/path.dart' as p;

class RepositoryRootLocator {
  const RepositoryRootLocator();

  Directory? find({Directory? startDirectory}) {
    var candidate = Directory(
      p.normalize(p.absolute((startDirectory ?? Directory.current).path)),
    );

    while (true) {
      if (_looksLikeRepositoryRoot(candidate)) return candidate;

      final parent = candidate.parent;
      if (parent.path == candidate.path) return null;
      candidate = parent;
    }
  }

  bool _looksLikeRepositoryRoot(Directory directory) {
    final hasPubspec = File(
      p.join(directory.path, 'pubspec.yaml'),
    ).existsSync();
    if (!hasPubspec) return false;

    final hasGitMetadata =
        File(p.join(directory.path, '.git')).existsSync() ||
        Directory(p.join(directory.path, '.git')).existsSync();
    final hasTemplateMarker = File(
      p.join(directory.path, templateMarkerRelativePath),
    ).existsSync();
    final hasProjectManifest = File(
      p.join(directory.path, projectManifestRelativePath),
    ).existsSync();
    return hasGitMetadata || hasTemplateMarker || hasProjectManifest;
  }
}
