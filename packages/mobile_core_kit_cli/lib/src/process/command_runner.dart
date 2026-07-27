import 'dart:io';

import 'package:path/path.dart' as p;

enum CommandPlatform {
  posix,
  windows;

  static CommandPlatform host() =>
      Platform.isWindows ? CommandPlatform.windows : CommandPlatform.posix;
}

class ResolvedCommand {
  const ResolvedCommand({required this.executable, required this.isPinned});

  final String executable;
  final bool isPinned;
}

class CommandRunner {
  CommandRunner({required this.rootDirectory, CommandPlatform? platform})
    : platform = platform ?? CommandPlatform.host();

  final Directory rootDirectory;
  final CommandPlatform platform;

  ResolvedCommand resolve(String executable) {
    if (executable == 'dart' || executable == 'flutter') {
      final pinnedExecutable = _pinnedExecutable(executable);
      if (File(pinnedExecutable).existsSync()) {
        return ResolvedCommand(executable: pinnedExecutable, isPinned: true);
      }
    }

    return ResolvedCommand(executable: executable, isPinned: false);
  }

  Future<int> run(List<String> command) async {
    if (command.isEmpty) return 0;

    final resolved = resolve(command.first);
    final executable =
        platform == CommandPlatform.windows && command.first == 'npx'
        ? 'cmd.exe'
        : resolved.executable;
    final arguments =
        platform == CommandPlatform.windows && command.first == 'npx'
        ? ['/d', '/c', 'npx', ...command.sublist(1)]
        : command.sublist(1);
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: rootDirectory.path,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  String _pinnedExecutable(String executable) {
    final fileName = platform == CommandPlatform.windows
        ? '$executable.bat'
        : executable;
    return p.join(rootDirectory.path, '.fvm', 'flutter_sdk', 'bin', fileName);
  }
}
