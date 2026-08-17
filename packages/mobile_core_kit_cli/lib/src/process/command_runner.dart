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
  CommandRunner({
    required this.rootDirectory,
    CommandPlatform? platform,
    StringSink? output,
  }) : platform = platform ?? CommandPlatform.host(),
       _output = output ?? stdout;

  final Directory rootDirectory;
  final CommandPlatform platform;
  final StringSink _output;
  final Set<String> _reportedToolchains = {};

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
    _reportToolchain(command.first, resolved);
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

  void _reportToolchain(String requested, ResolvedCommand resolved) {
    if (requested != 'dart' && requested != 'flutter') return;
    if (!_reportedToolchains.add(requested)) return;
    _output.writeln(toolchainDiagnostic(requested, resolved));
  }

  String toolchainDiagnostic(String requested, ResolvedCommand resolved) {
    if (resolved.isPinned) {
      return 'Toolchain [$requested]: pinned checkout SDK '
          '(${p.relative(resolved.executable, from: rootDirectory.path)}).';
    }
    return 'WARN [toolchain.path-fallback] `$requested` resolved from PATH '
        'because `.fvm/flutter_sdk/bin/$requested` is unavailable.';
  }

  String _pinnedExecutable(String executable) {
    final fileName = platform == CommandPlatform.windows
        ? '$executable.bat'
        : executable;
    return p.join(rootDirectory.path, '.fvm', 'flutter_sdk', 'bin', fileName);
  }
}
