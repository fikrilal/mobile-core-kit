import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';

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
    final logSink = logFile.openWrite(mode: FileMode.append);

    try {
      await Future.wait([
        _forward(process.stdout, logSink, output),
        _forward(process.stderr, logSink, errorOutput),
      ]);
      return await process.exitCode;
    } finally {
      await logSink.close();
    }
  }

  Future<void> _forward(
    Stream<List<int>> stream,
    IOSink logSink,
    StringSink output,
  ) async {
    await for (final chunk in stream.transform(utf8.decoder)) {
      logSink.write(chunk);
      output.write(chunk);
    }
  }
}
