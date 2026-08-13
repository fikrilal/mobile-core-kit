import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';

const runtimeEvidenceLogLimitBytes = 1024 * 1024;

abstract interface class RuntimeEvidenceProcessRunner {
  Future<int> run({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
    required StringSink output,
    required StringSink errorOutput,
  });
}

class DartRuntimeEvidenceProcessRunner implements RuntimeEvidenceProcessRunner {
  DartRuntimeEvidenceProcessRunner({
    required Directory rootDirectory,
    CommandPlatform? platform,
  }) : _commandRunner = CommandRunner(
         rootDirectory: rootDirectory,
         platform: platform ?? CommandPlatform.host(),
       );

  final CommandRunner _commandRunner;

  @override
  Future<int> run({
    required List<String> command,
    required Directory workingDirectory,
    required File logFile,
    required StringSink output,
    required StringSink errorOutput,
  }) async {
    if (command.isEmpty) {
      throw ArgumentError.value(command, 'command');
    }

    final resolved = _commandRunner.resolve(command.first);
    final process = await Process.start(
      resolved.executable,
      command.skip(1).toList(),
      workingDirectory: workingDirectory.path,
    );
    final existingBytes = logFile.existsSync() ? logFile.lengthSync() : 0;
    final logSink = logFile.openWrite(mode: FileMode.append);
    final log = _BoundedLogWriter(
      logSink,
      remainingBytes: runtimeEvidenceLogLimitBytes - existingBytes,
    );

    try {
      await Future.wait([
        _forward(process.stdout, log, output),
        _forward(process.stderr, log, errorOutput),
      ]);
      return await process.exitCode;
    } finally {
      await logSink.close();
    }
  }

  Future<void> _forward(
    Stream<List<int>> stream,
    _BoundedLogWriter log,
    StringSink output,
  ) async {
    await for (final chunk in stream) {
      log.add(chunk);
      output.write(utf8.decode(chunk, allowMalformed: true));
    }
  }
}

class _BoundedLogWriter {
  _BoundedLogWriter(this.sink, {required int remainingBytes})
    : _remainingBytes = remainingBytes < 0 ? 0 : remainingBytes;

  final IOSink sink;
  int _remainingBytes;

  void add(List<int> bytes) {
    if (_remainingBytes == 0) return;
    if (bytes.length <= _remainingBytes) {
      sink.add(bytes);
      _remainingBytes -= bytes.length;
      return;
    }
    sink.add(bytes.sublist(0, _remainingBytes));
    _remainingBytes = 0;
  }
}
