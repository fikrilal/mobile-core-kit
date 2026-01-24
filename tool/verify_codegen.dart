import 'dart:convert';
import 'dart:io';

/// Codegen freshness gate.
///
/// This script ensures `build_runner` outputs are checked in and up-to-date.
///
/// In CI, this prevents PRs from forgetting to run codegen after changing:
/// - Freezed models (`*.freezed.dart`)
/// - JsonSerializable models (`*.g.dart`)
///
/// Local usage:
/// - Run this after `flutter pub get`.
/// - If it fails, run the suggested `build_runner` command and commit the
///   generated outputs.
Future<int> main(List<String> _) async {
  final runner = _CommandRunner.detect(Directory.current);

  Future<int> step(String title, List<String> command) async {
    stdout.writeln('\n==> $title');
    return runner.run(command);
  }

  var exitCode = 0;

  exitCode = await step('Build runner', [
    'dart',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  if (exitCode != 0) return exitCode;

  final diffExitCode = await _verifyGeneratedFilesClean();
  if (diffExitCode != 0) return diffExitCode;

  stdout.writeln('\nOK');
  return 0;
}

Future<int> _verifyGeneratedFilesClean() async {
  final changedFiles = await _gitDiffNameOnly();
  if (changedFiles == null) {
    stderr.writeln('Unable to run `git diff`. Is git installed and on PATH?');
    return 2;
  }

  final generatedChanges =
      changedFiles
          .where(
            (path) =>
                path.endsWith('.g.dart') ||
                path.endsWith('.freezed.dart') ||
                path.endsWith('.gr.dart'),
          )
          .toList()
        ..sort();

  if (generatedChanges.isEmpty) return 0;

  stderr.writeln(
    'Codegen outputs are out-of-date (build_runner produced changes).',
  );
  stderr.writeln('');
  stderr.writeln('Changed generated files:');
  for (final path in generatedChanges) {
    stderr.writeln('- $path');
  }
  stderr.writeln('');
  stderr.writeln('Fix:');
  stderr.writeln('  dart run build_runner build --delete-conflicting-outputs');
  return 1;
}

Future<List<String>?> _gitDiffNameOnly() async {
  try {
    final result = await Process.run(
      'git',
      const ['diff', '--name-only'],
      workingDirectory: Directory.current.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      return null;
    }
    final out = (result.stdout as String).trim();
    if (out.isEmpty) return const [];
    return out
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } on ProcessException {
    return null;
  }
}

class _CommandRunner {
  _CommandRunner(this._rootDir, this._mode);

  final Directory _rootDir;
  final _RunnerMode _mode;

  static _CommandRunner detect(Directory rootDir) {
    if (_isWsl()) return _CommandRunner(rootDir, _RunnerMode.wslWindows);
    if (Platform.isWindows) return _CommandRunner(rootDir, _RunnerMode.windows);
    return _CommandRunner(rootDir, _RunnerMode.posix);
  }

  static bool _isWsl() {
    final env = Platform.environment;
    if (env.containsKey('WSL_DISTRO_NAME') || env.containsKey('WSL_INTEROP')) {
      return true;
    }
    try {
      final version = File('/proc/version').readAsStringSync();
      return version.toLowerCase().contains('microsoft');
    } catch (_) {
      return false;
    }
  }

  Future<int> run(List<String> command) async {
    if (command.isEmpty) return 0;

    final executable = command.first;
    final args = command.sublist(1);

    return switch (_mode) {
      _RunnerMode.wslWindows => _runViaWindowsToolchain(executable, args),
      _RunnerMode.windows => _runNativeWindows(executable, args),
      _RunnerMode.posix => _runPosix(executable, args),
    };
  }

  Future<int> _runPosix(String executable, List<String> args) async {
    final resolved = _resolvePosixExecutable(executable);
    final process = await Process.start(
      resolved.executable,
      args,
      workingDirectory: _rootDir.path,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  _ResolvedCommand _resolvePosixExecutable(String executable) {
    final flutterPath = File('.fvm/flutter_sdk/bin/flutter');
    final dartPath = File('.fvm/flutter_sdk/bin/dart');
    if (executable == 'flutter' && flutterPath.existsSync()) {
      return _ResolvedCommand(flutterPath.path);
    }
    if (executable == 'dart' && dartPath.existsSync()) {
      return _ResolvedCommand(dartPath.path);
    }
    return _ResolvedCommand(executable);
  }

  Future<int> _runNativeWindows(String executable, List<String> args) async {
    final resolved = _resolveWindowsExecutable(executable);
    final process = await Process.start(
      resolved.executable,
      args,
      workingDirectory: _rootDir.path,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  _ResolvedCommand _resolveWindowsExecutable(String executable) {
    final flutterBat = File('.fvm\\flutter_sdk\\bin\\flutter.bat');
    final dartBat = File('.fvm\\flutter_sdk\\bin\\dart.bat');
    if (executable == 'flutter' && flutterBat.existsSync()) {
      return _ResolvedCommand(flutterBat.path);
    }
    if (executable == 'dart' && dartBat.existsSync()) {
      return _ResolvedCommand(dartBat.path);
    }
    return _ResolvedCommand(executable);
  }

  Future<int> _runViaWindowsToolchain(
    String executable,
    List<String> args,
  ) async {
    final windowsRoot = _toWindowsPath(_rootDir.path);
    final resolved = _resolveWindowsExecutable(executable);

    final joinedArgs = args.map(_escapeWindowsArg).join(' ');
    final cmd =
        'cd /d $windowsRoot && ${resolved.executable} '
        '$joinedArgs';

    final process = await Process.start(
      'cmd.exe',
      ['/C', cmd],
      workingDirectory: _rootDir.path,
      mode: ProcessStartMode.normal,
    );

    // Non-interactive safe: prevent Windows console handshake hangs in PTY runners
    // by closing stdin (equivalent to `< /dev/null` in bash).
    await process.stdin.close();

    final stdoutFuture = stdout.addStream(process.stdout);
    final stderrFuture = stderr.addStream(process.stderr);
    final exitCode = await process.exitCode;
    await Future.wait([stdoutFuture, stderrFuture]);
    return exitCode;
  }

  static String _toWindowsPath(String wslPath) {
    final normalized = wslPath.replaceAll('\\', '/');
    final match = RegExp(r'^/mnt/([a-zA-Z])/(.*)$').firstMatch(normalized);
    if (match == null) return wslPath;
    final drive = match.group(1)!.toUpperCase();
    final rest = match.group(2)!.replaceAll('/', '\\');
    return '$drive:\\$rest';
  }

  static String _escapeWindowsArg(String value) {
    if (value.isEmpty) return '""';
    final needsQuotes =
        value.contains(' ') || value.contains('"') || value.contains('&');
    if (!needsQuotes) return value;
    return '"${value.replaceAll('"', r'\"')}"';
  }
}

class _ResolvedCommand {
  _ResolvedCommand(this.executable);

  final String executable;
}

enum _RunnerMode { wslWindows, windows, posix }
