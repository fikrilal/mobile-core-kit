import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_log_session.dart';

class RuntimeLogWorkflow {
  RuntimeLogWorkflow({
    required RuntimeLogSessionManager sessionManager,
    StringSink? output,
    StringSink? errorOutput,
  }) : _sessionManager = sessionManager,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final RuntimeLogSessionManager _sessionManager;
  final StringSink _output;
  final StringSink _errorOutput;

  static void writeUsage(StringSink output) {
    output.writeln('Usage: mobilekit runtime logs <command> [options]');
    output.writeln();
    output.writeln('Commands:');
    output.writeln('  start    Start a background Flutter log session.');
    output.writeln('  status   Show session status and artifact paths.');
    output.writeln('  tail     Print the latest lines from a session log.');
    output.writeln('  stop     Stop a running session.');
    output.writeln();
    output.writeln('Options:');
    output.writeln(
      '  --session <name>         Session name (default: default).',
    );
    output.writeln(
      '  --artifacts-dir <path>   Artifact directory '
      '(default: _artifacts/runtime_logs).',
    );
    output.writeln('  --mode <logs|run>        Start mode (default: logs).');
    output.writeln('  --device <id>            Flutter device id.');
    output.writeln(
      '  --flavor <name>          Flavor for run mode (default: dev).',
    );
    output.writeln(
      '  --target <path>          Entry file for run mode '
      '(default: lib/main_dev.dart).',
    );
    output.writeln(
      '  --lines <n>              Lines to print for tail (default: 120).',
    );
    output.writeln(
      '  -- <args...>             Extra args forwarded to Flutter on start.',
    );
    output.writeln();
    output.writeln('Examples:');
    output.writeln(
      '  mobilekit runtime logs start --session emulator '
      '--mode logs --device emulator-5554',
    );
    output.writeln(
      '  mobilekit runtime logs start --session dev-run '
      '--mode run --device emulator-5554 --flavor dev '
      '--target lib/main_dev.dart',
    );
    output.writeln(
      '  mobilekit runtime logs tail --session emulator --lines 200',
    );
    output.writeln('  mobilekit runtime logs stop --session emulator');
  }

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      writeUsage(_output);
      return arguments.isEmpty ? 2 : 0;
    }

    final operation = arguments.first;
    if (!{'start', 'status', 'tail', 'stop'}.contains(operation)) {
      _errorOutput.writeln("ERROR: Unknown runtime logs command '$operation'.");
      writeUsage(_errorOutput);
      return 2;
    }

    final parser = _createParser();
    ArgResults parsed;
    try {
      parsed = parser.parse(arguments.skip(1).toList());
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      writeUsage(_errorOutput);
      return 2;
    }

    if (parsed.flag('help')) {
      writeUsage(_output);
      return 0;
    }

    try {
      final options = _optionsFrom(parsed, operation);
      return switch (operation) {
        'start' => await _sessionManager.start(options),
        'status' => await _sessionManager.status(options),
        'tail' => await _sessionManager.tail(options),
        'stop' => await _sessionManager.stop(options),
        _ => 2,
      };
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      writeUsage(_errorOutput);
      return 2;
    } on FileSystemException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      return 1;
    } on ProcessException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      return 1;
    }
  }

  ArgParser _createParser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('session', defaultsTo: 'default')
      ..addOption('artifacts-dir', defaultsTo: '_artifacts/runtime_logs')
      ..addOption(
        'mode',
        allowed: RuntimeLogMode.values.map((mode) => mode.name),
        defaultsTo: RuntimeLogMode.logs.name,
      )
      ..addOption('device')
      ..addOption('flavor', defaultsTo: 'dev')
      ..addOption('target', defaultsTo: 'lib/main_dev.dart')
      ..addOption('lines', defaultsTo: '120');
  }

  RuntimeLogOptions _optionsFrom(ArgResults parsed, String operation) {
    if (operation != 'start' && parsed.rest.isNotEmpty) {
      throw FormatException("Unexpected argument '${parsed.rest.first}'.");
    }

    final linesValue = parsed.option('lines')!;
    final lines = int.tryParse(linesValue);
    if (lines == null || lines < 0) {
      throw const FormatException('--lines must be a non-negative integer.');
    }

    final mode = RuntimeLogMode.values.firstWhere(
      (candidate) => candidate.name == parsed.option('mode'),
    );
    return RuntimeLogOptions(
      session: parsed.option('session')!,
      artifactsDirectory: parsed.option('artifacts-dir')!,
      mode: mode,
      device: parsed.option('device'),
      flavor: parsed.option('flavor')!,
      target: parsed.option('target')!,
      lines: lines,
      extraArguments: List.unmodifiable(parsed.rest),
    );
  }

  bool _isHelp(String argument) => argument == '-h' || argument == '--help';
}
