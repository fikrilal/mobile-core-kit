import 'dart:io';

void ensurePrivateDirectory(Directory directory) {
  directory.createSync(recursive: true);
  _chmod(directory.path, '700');
}

void writePrivateFile(
  File destination,
  String source, {
  bool exclusive = false,
}) {
  ensurePrivateDirectory(destination.parent);
  final temporary = File(
    '${destination.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
  );
  try {
    temporary.writeAsStringSync(source, mode: FileMode.writeOnly, flush: true);
    _chmod(temporary.path, '600');
    if (exclusive && destination.existsSync()) {
      throw FileSystemException(
        'Private artifact already exists.',
        destination.path,
      );
    }
    temporary.renameSync(destination.path);
    _chmod(destination.path, '600');
  } finally {
    if (temporary.existsSync()) temporary.deleteSync();
  }
}

void _chmod(String path, String mode) {
  if (Platform.isWindows) return;
  final result = Process.runSync('chmod', [mode, path]);
  if (result.exitCode != 0) {
    throw FileSystemException('Could not apply private permissions.', path);
  }
}
