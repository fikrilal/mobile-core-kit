import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:path/path.dart' as p;

class RepositoryMutationLock {
  const RepositoryMutationLock(this.controlRoot);

  final Directory controlRoot;

  Future<T> protect<T>(Future<T> Function() action) async {
    final file = File(
      p.join(
        controlRoot.path,
        '.tmp',
        'mobilekit',
        'locks',
        'repository-mutation.lock',
      ),
    );
    file.parent.createSync(recursive: true);
    try {
      file.createSync(exclusive: true);
    } on FileSystemException {
      throw const TaskControlError(
        'workspace.locked',
        'Another repository mutation holds the mobilekit lock.',
      );
    }
    late final RandomAccessFile handle;
    try {
      handle = file.openSync(mode: FileMode.writeOnly);
      handle.writeFromSync(utf8.encode('pid=$pid\n'));
      handle.flushSync();
    } on FileSystemException {
      if (file.existsSync()) file.deleteSync();
      throw const TaskControlError(
        'workspace.lock-unavailable',
        'The repository mutation lock could not be initialized.',
      );
    }
    try {
      return await action();
    } finally {
      handle.closeSync();
      if (file.existsSync()) file.deleteSync();
    }
  }
}
