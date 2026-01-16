import 'dart:io';

import 'package:args/args.dart';

Future<int> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('env', abbr: 'e', defaultsTo: 'dev')
    ..addFlag('skip-format', defaultsTo: false)
    ..addFlag('skip-tests', defaultsTo: false);

  final args = parser.parse(argv);
  final env = args.option('env')!;
  final skipFormat = args.flag('skip-format');
  final skipTests = args.flag('skip-tests');

  final envs = {'dev', 'staging', 'prod'};
  if (!envs.contains(env)) {
    stderr.writeln("Unknown --env '$env'. Expected one of: ${envs.join(', ')}");
    return 2;
  }

  final runner = _CommandRunner.detect(Directory.current);

  Future<int> step(String title, List<String> command) async {
    stdout.writeln('\n==> $title');
    return runner.run(command);
  }

  var exitCode = 0;

  exitCode = await step('Flutter pub get', ['flutter', 'pub', 'get']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Generate build config (.env/$env.yaml)', [
    'dart',
    'run',
    'tool/gen_config.dart',
    '--env',
    env,
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Flutter analyze', ['flutter', 'analyze']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Custom lint', ['dart', 'run', 'custom_lint']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify modal entrypoints', [
    'dart',
    'run',
    'tool/verify_modal_entrypoints.dart',
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify hardcoded UI colors', [
    'dart',
    'run',
    'tool/verify_hardcoded_ui_colors.dart',
  ]);
  if (exitCode != 0) return exitCode;

  if (!skipTests) {
    exitCode = await step('Flutter test', ['flutter', 'test']);
    if (exitCode != 0) return exitCode;
  }

  if (!skipFormat) {
    exitCode = await step('Dart format (check)', [
      'dart',
      'format',
      '--output',
      'none',
      '--set-exit-if-changed',
      '.',
    ]);
    if (exitCode != 0) return exitCode;
  }

  stdout.writeln('\nOK');
  return 0;
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
