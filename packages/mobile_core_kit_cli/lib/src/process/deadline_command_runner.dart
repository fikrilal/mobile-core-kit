import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';

class DeadlineCommandResult {
  const DeadlineCommandResult({
    required this.exitCode,
    required this.timedOut,
    required this.diagnostic,
  });

  final int exitCode;
  final bool timedOut;
  final String diagnostic;
}

class DeadlineCommandRunner {
  DeadlineCommandRunner({
    required this.rootDirectory,
    required this.deadline,
    required this.output,
    required this.errorOutput,
    CommandPlatform? platform,
  }) : platform = platform ?? CommandPlatform.host(),
       _resolver = CommandRunner(
         rootDirectory: rootDirectory,
         platform: platform,
         output: output,
       );

  final Directory rootDirectory;
  final DateTime deadline;
  final StringSink output;
  final StringSink errorOutput;
  final CommandPlatform platform;
  final CommandRunner _resolver;

  DeadlineCommandResult? lastResult;

  Future<int> run(List<String> command) async {
    if (command.isEmpty) return 0;
    final remaining = deadline.difference(DateTime.now().toUtc());
    if (remaining <= Duration.zero) {
      lastResult = const DeadlineCommandResult(
        exitCode: 124,
        timedOut: true,
        diagnostic: 'Task deadline expired before command start.',
      );
      return 124;
    }

    final resolved = _resolver.resolve(command.first);
    if (command.first == 'dart' || command.first == 'flutter') {
      output.writeln(_resolver.toolchainDiagnostic(command.first, resolved));
    }
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
    );
    final captured = StringBuffer();
    final stdoutDone = _pipe(process.stdout, output, captured);
    final stderrDone = _pipe(process.stderr, errorOutput, captured);
    var timedOut = false;
    final exitCode = await process.exitCode.timeout(
      remaining,
      onTimeout: () {
        timedOut = true;
        process.kill();
        return 124;
      },
    );
    if (timedOut) {
      try {
        await process.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
      }
    }
    await Future.wait([stdoutDone, stderrDone]);
    lastResult = DeadlineCommandResult(
      exitCode: exitCode,
      timedOut: timedOut,
      diagnostic: captured.toString(),
    );
    return exitCode;
  }

  Future<void> _pipe(
    Stream<List<int>> stream,
    StringSink destination,
    StringBuffer captured,
  ) async {
    await for (final chunk in stream.transform(utf8.decoder)) {
      destination.write(chunk);
      final remaining = 8192 - captured.length;
      if (remaining > 0) {
        captured.write(
          chunk.length <= remaining ? chunk : chunk.substring(0, remaining),
        );
      }
    }
  }
}
