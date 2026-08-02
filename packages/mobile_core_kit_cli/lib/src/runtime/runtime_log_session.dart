import 'dart:async';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:path/path.dart' as p;

enum RuntimeLogMode { logs, run }

class RuntimeLogOptions {
  const RuntimeLogOptions({
    required this.session,
    required this.artifactsDirectory,
    required this.mode,
    required this.device,
    required this.flavor,
    required this.target,
    required this.lines,
    required this.extraArguments,
  });

  final String session;
  final String artifactsDirectory;
  final RuntimeLogMode mode;
  final String? device;
  final String flavor;
  final String target;
  final int lines;
  final List<String> extraArguments;
}

abstract interface class RuntimeLogProcessController {
  Future<int> start({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
  });

  Future<bool> isRunning(int pid);

  Future<void> stop(int pid);
}

class DartRuntimeLogProcessController implements RuntimeLogProcessController {
  DartRuntimeLogProcessController({required this.platform});

  final CommandPlatform platform;

  @override
  Future<int> start({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
  }) async {
    if (command.isEmpty) {
      throw ArgumentError.value(command, 'command');
    }

    final process = await Process.start(
      command.first,
      command.skip(1).toList(),
      workingDirectory: workingDirectory.path,
      mode: ProcessStartMode.detachedWithStdio,
    );
    await process.stdin.close();

    final logSink = logFile.openWrite(mode: FileMode.append);
    unawaited(_captureOutput(process, logSink));
    return process.pid;
  }

  @override
  Future<bool> isRunning(int pid) async {
    if (pid <= 0) return false;

    try {
      if (platform == CommandPlatform.windows) {
        final result = await Process.run('tasklist', [
          '/FI',
          'PID eq $pid',
          '/NH',
        ]);
        if (result.exitCode != 0) return false;
        return RegExp(
          r'\b' + pid.toString() + r'\b',
        ).hasMatch(result.stdout.toString());
      }

      final result = await Process.run('kill', ['-0', '$pid']);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  @override
  Future<void> stop(int pid) async {
    if (!await isRunning(pid)) return;

    Process.killPid(pid, ProcessSignal.sigterm);
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!await isRunning(pid)) return;
    }

    Process.killPid(pid, ProcessSignal.sigkill);
  }

  Future<void> _captureOutput(Process process, IOSink sink) async {
    try {
      await Future.wait([
        _copyStream(process.stdout, sink),
        _copyStream(process.stderr, sink),
      ]);
    } finally {
      await sink.close();
    }
  }

  Future<void> _copyStream(Stream<List<int>> stream, IOSink sink) async {
    try {
      await for (final chunk in stream) {
        sink.add(chunk);
      }
    } catch (_) {
      // The session is detached; an output-channel failure must not surface
      // as an unhandled future after the CLI process has exited.
    }
  }
}

class RuntimeLogSessionManager {
  RuntimeLogSessionManager({
    required Directory rootDirectory,
    CommandPlatform? platform,
    RuntimeLogProcessController? processController,
    Duration startupDelay = const Duration(seconds: 1),
    StringSink? output,
    StringSink? errorOutput,
  }) : rootDirectory = rootDirectory,
       _processController =
           processController ??
           DartRuntimeLogProcessController(
             platform: platform ?? CommandPlatform.host(),
           ),
       _startupDelay = startupDelay,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr,
       _commandRunner = CommandRunner(
         rootDirectory: rootDirectory,
         platform: platform ?? CommandPlatform.host(),
       );

  final Directory rootDirectory;
  final RuntimeLogProcessController _processController;
  final Duration _startupDelay;
  final StringSink _output;
  final StringSink _errorOutput;
  final CommandRunner _commandRunner;

  Future<int> start(RuntimeLogOptions options) async {
    _validateSessionName(options.session);
    final paths = _pathsFor(options);
    paths.directory.createSync(recursive: true);

    final existingPid = _readPid(paths.pidFile);
    if (existingPid != null &&
        await _processController.isRunning(existingPid)) {
      _errorOutput.writeln(
        "ERROR: Session '${options.session}' is already running "
        '(pid=$existingPid).',
      );
      _errorOutput.writeln(
        'Use: mobilekit runtime logs stop --session ${options.session}',
      );
      return 1;
    }
    if (paths.pidFile.existsSync()) {
      paths.pidFile.deleteSync();
    }

    final command = _resolveCommand(_buildCommand(options));
    _appendLog(
      paths.logFile,
      '[${DateTime.now().toIso8601String()}] '
      'START session=${options.session} mode=${options.mode.name}',
    );

    final pid = await _processController.start(
      command: command,
      workingDirectory: rootDirectory,
      logFile: paths.logFile,
    );
    paths.pidFile.writeAsStringSync('$pid\n');
    paths.metadataFile.writeAsStringSync(
      [
            'session=${options.session}',
            'mode=${options.mode.name}',
            'device=${options.device ?? ''}',
            'flavor=${options.flavor}',
            'target=${options.target}',
            'pid=$pid',
            'started_at=${DateTime.now().toIso8601String()}',
            'repo_root=${rootDirectory.path}',
            'log_file=${paths.displayLogFile}',
          ].join('\n') +
          '\n',
    );
    paths.commandFile.writeAsStringSync(
      '${command.map(_shellQuote).join(' ')}\n',
    );

    if (_startupDelay > Duration.zero) {
      await Future<void>.delayed(_startupDelay);
    }
    if (!await _processController.isRunning(pid)) {
      _errorOutput.writeln(
        'ERROR: Stream process exited immediately. '
        'Check log: ${paths.displayLogFile}',
      );
      _writeRecentLogLines(paths.logFile, 40);
      if (paths.pidFile.existsSync()) {
        paths.pidFile.deleteSync();
      }
      return 1;
    }

    _output.writeln("Started session '${options.session}' (pid=$pid).");
    _output.writeln('Log file: ${paths.displayLogFile}');
    return 0;
  }

  Future<int> status(RuntimeLogOptions options) async {
    _validateSessionName(options.session);
    final paths = _pathsFor(options);
    _output.writeln('session=${options.session}');
    _output.writeln('session_dir=${paths.displayDirectory}');
    _output.writeln('log_file=${paths.displayLogFile}');

    if (!paths.pidFile.existsSync()) {
      _output.writeln('status=stopped');
      return 0;
    }

    final pidValue = paths.pidFile.readAsStringSync().trim();
    final pid = int.tryParse(pidValue);
    if (pid != null && await _processController.isRunning(pid)) {
      _output.writeln('status=running');
      _output.writeln('pid=$pid');
      if (paths.metadataFile.existsSync()) {
        _output.writeln('metadata_file=${paths.displayMetadataFile}');
      }
    } else {
      _output.writeln('status=stopped');
      _output.writeln('stale_pid=$pidValue');
    }
    return 0;
  }

  Future<int> tail(RuntimeLogOptions options) async {
    _validateSessionName(options.session);
    final paths = _pathsFor(options);
    if (!paths.logFile.existsSync()) {
      _errorOutput.writeln(
        "ERROR: Log file not found for session '${options.session}': "
        '${paths.displayLogFile}',
      );
      return 1;
    }

    final lines = paths.logFile.readAsLinesSync();
    final start = lines.length > options.lines
        ? lines.length - options.lines
        : 0;
    for (final line in lines.skip(start)) {
      _output.writeln(line);
    }
    return 0;
  }

  Future<int> stop(RuntimeLogOptions options) async {
    _validateSessionName(options.session);
    final paths = _pathsFor(options);
    if (!paths.pidFile.existsSync()) {
      _output.writeln("Session '${options.session}' is not running.");
      return 0;
    }

    final pidValue = paths.pidFile.readAsStringSync().trim();
    final pid = int.tryParse(pidValue);
    if (pid == null || !await _processController.isRunning(pid)) {
      paths.pidFile.deleteSync();
      _output.writeln(
        "Session '${options.session}' had stale pid=$pidValue. "
        'Cleaned pid file.',
      );
      return 0;
    }

    await _processController.stop(pid);
    if (paths.pidFile.existsSync()) {
      paths.pidFile.deleteSync();
    }
    _appendLog(
      paths.logFile,
      '[${DateTime.now().toIso8601String()}] '
      'STOP session=${options.session} pid=$pid',
    );
    _output.writeln("Stopped session '${options.session}' (pid=$pid).");
    return 0;
  }

  List<String> _buildCommand(RuntimeLogOptions options) {
    final command = <String>['flutter'];
    if (options.mode == RuntimeLogMode.logs) {
      command.add('logs');
      if (options.device != null && options.device!.isNotEmpty) {
        command.addAll(['-d', options.device!]);
      }
    } else {
      command.add('run');
      if (options.device != null && options.device!.isNotEmpty) {
        command.addAll(['-d', options.device!]);
      }
      command.addAll([
        '--flavor',
        options.flavor,
        '-t',
        options.target,
        '--dart-define=ENV=${options.flavor}',
      ]);
    }
    command.addAll(options.extraArguments);
    return command;
  }

  List<String> _resolveCommand(List<String> command) {
    final resolved = _commandRunner.resolve(command.first);
    return [resolved.executable, ...command.skip(1)];
  }

  _RuntimeLogSessionPaths _pathsFor(RuntimeLogOptions options) {
    final artifactsDirectory = p.isAbsolute(options.artifactsDirectory)
        ? options.artifactsDirectory
        : p.join(rootDirectory.path, options.artifactsDirectory);
    final directory = p.join(artifactsDirectory, options.session);
    final displayDirectory = p.join(
      options.artifactsDirectory,
      options.session,
    );
    return _RuntimeLogSessionPaths(
      directory: Directory(directory),
      displayDirectory: displayDirectory,
    );
  }

  int? _readPid(File pidFile) {
    if (!pidFile.existsSync()) return null;
    return int.tryParse(pidFile.readAsStringSync().trim());
  }

  void _appendLog(File logFile, String line) {
    logFile.parent.createSync(recursive: true);
    logFile.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  void _writeRecentLogLines(File logFile, int count) {
    if (!logFile.existsSync()) return;
    final lines = logFile.readAsLinesSync();
    final start = lines.length > count ? lines.length - count : 0;
    for (final line in lines.skip(start)) {
      _errorOutput.writeln(line);
    }
  }

  void _validateSessionName(String session) {
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(session)) {
      throw FormatException(
        "Invalid session name '$session'. Use [A-Za-z0-9._-].",
      );
    }
  }

  String _shellQuote(String value) {
    if (RegExp(r'^[A-Za-z0-9_./:@%+=,-]+$').hasMatch(value)) {
      return value;
    }
    return "'${value.replaceAll("'", "'\\''")}'";
  }
}

class _RuntimeLogSessionPaths {
  _RuntimeLogSessionPaths({
    required this.directory,
    required this.displayDirectory,
  });

  final Directory directory;
  final String displayDirectory;

  File get pidFile => File(p.join(directory.path, 'stream.pid'));

  File get logFile => File(p.join(directory.path, 'stream.log'));

  File get metadataFile => File(p.join(directory.path, 'metadata.env'));

  File get commandFile => File(p.join(directory.path, 'command.txt'));

  String get displayLogFile => p.join(displayDirectory, 'stream.log');

  String get displayMetadataFile => p.join(displayDirectory, 'metadata.env');
}
