import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/doctor/doctor.dart';
import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';

class MobilekitCli {
  MobilekitCli({
    Directory? currentDirectory,
    RepositoryRootLocator? rootLocator,
    ExecutableFinder? executableFinder,
    CommandPlatform? platform,
    StringSink? output,
    StringSink? errorOutput,
  }) : _currentDirectory = currentDirectory ?? Directory.current,
       _rootLocator = rootLocator ?? const RepositoryRootLocator(),
       _executableFinder = executableFinder,
       _platform = platform,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory _currentDirectory;
  final RepositoryRootLocator _rootLocator;
  final ExecutableFinder? _executableFinder;
  final CommandPlatform? _platform;
  final StringSink _output;
  final StringSink _errorOutput;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      _writeUsage(_output);
      return 0;
    }

    return switch (arguments.first) {
      'doctor' => _runDoctor(arguments.skip(1).toList()),
      _ => _unknownCommand(arguments.first),
    };
  }

  Future<int> _runDoctor(List<String> arguments) async {
    final parser = ArgParser()..addFlag('help', abbr: 'h', negatable: false);

    ArgResults parsed;
    try {
      parsed = parser.parse(arguments);
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      _errorOutput.writeln('Use `mobilekit doctor --help` for usage.');
      return 2;
    }

    if (parsed.flag('help')) {
      _writeDoctorUsage(_output);
      return 0;
    }
    if (parsed.rest.isNotEmpty) {
      _errorOutput.writeln(
        "ERROR: Unexpected argument '${parsed.rest.first}'.",
      );
      _errorOutput.writeln('Use `mobilekit doctor --help` for usage.');
      return 2;
    }

    final report = Doctor(
      rootLocator: _rootLocator,
      executableFinder: _executableFinder,
      platform: _platform,
    ).inspect(startDirectory: _currentDirectory);
    report.writeTo(_output);
    return report.hasErrors ? 1 : 0;
  }

  int _unknownCommand(String command) {
    _errorOutput.writeln("ERROR: Unknown command '$command'.");
    _writeUsage(_errorOutput);
    return 2;
  }

  void _writeUsage(StringSink output) {
    output.writeln('mobilekit - mobile-core-kit repository tooling');
    output.writeln();
    output.writeln('Usage:');
    output.writeln('  mobilekit <command> [options]');
    output.writeln();
    output.writeln('Commands:');
    output.writeln('  doctor    Diagnose local repository tooling.');
    output.writeln();
    output.writeln('Run `mobilekit <command> --help` for command usage.');
  }

  void _writeDoctorUsage(StringSink output) {
    output.writeln('Usage: mobilekit doctor');
    output.writeln();
    output.writeln(
      'Reports repository discovery, SDK pinning, and required tool status.',
    );
    output.writeln('This command is read-only.');
  }

  bool _isHelp(String argument) => argument == '-h' || argument == '--help';
}
