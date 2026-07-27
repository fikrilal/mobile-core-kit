import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/doctor/doctor.dart';
import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';

typedef CommandExecutor = Future<int> Function(List<String> command);

class MobilekitCli {
  MobilekitCli({
    Directory? currentDirectory,
    RepositoryRootLocator? rootLocator,
    ExecutableFinder? executableFinder,
    CommandPlatform? platform,
    CommandExecutor? commandExecutor,
    StringSink? output,
    StringSink? errorOutput,
  }) : _currentDirectory = currentDirectory ?? Directory.current,
       _rootLocator = rootLocator ?? const RepositoryRootLocator(),
       _executableFinder = executableFinder,
       _platform = platform,
       _commandExecutor = commandExecutor,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory _currentDirectory;
  final RepositoryRootLocator _rootLocator;
  final ExecutableFinder? _executableFinder;
  final CommandPlatform? _platform;
  final CommandExecutor? _commandExecutor;
  final StringSink _output;
  final StringSink _errorOutput;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      _writeUsage(_output);
      return 0;
    }

    return switch (arguments.first) {
      'doctor' => _runDoctor(arguments.skip(1).toList()),
      'verify' => _runTool(
        command: 'verify',
        script: 'tool/verify.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit verify [options]',
      ),
      'fix' => _runTool(
        command: 'fix',
        script: 'tool/fix.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit fix [--dry-run|--apply]',
      ),
      'config' => _runGroupedTool(
        group: 'config',
        subcommand: 'generate',
        script: 'tool/gen_config.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit config generate [--env <env>]',
      ),
      'env' => _runGroupedTool(
        group: 'env',
        subcommand: 'verify',
        script: 'tool/verify_env_schema.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit env verify [options]',
      ),
      'codegen' => _runGroupedTool(
        group: 'codegen',
        subcommand: 'verify',
        script: 'tool/verify_codegen.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit codegen verify',
      ),
      'l10n' => _runGroupedTool(
        group: 'l10n',
        subcommand: 'verify',
        script: 'tool/verify_untranslated_messages.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit l10n verify [path]',
      ),
      'project-map' => _runGroupedTool(
        group: 'project-map',
        subcommand: 'verify',
        script: 'tool/verify_project_map_drift.dart',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit project-map verify',
      ),
      _ => _unknownCommand(arguments.first),
    };
  }

  Future<int> _runTool({
    required String command,
    required String script,
    required List<String> arguments,
    required String usage,
  }) async {
    if (_containsHelp(arguments)) {
      _writeCommandUsage(_output, usage);
      return 0;
    }

    final root = _rootLocator.find(startDirectory: _currentDirectory);
    if (root == null) {
      _errorOutput.writeln(
        'ERROR: Repository root not found. '
        'Run this command from inside the repository.',
      );
      return 1;
    }

    final execute =
        _commandExecutor ??
        CommandRunner(rootDirectory: root, platform: _platform).run;
    try {
      return await execute(['dart', 'run', script, ...arguments]);
    } on ProcessException catch (error) {
      _errorOutput.writeln('ERROR: Failed to run mobilekit $command.');
      _errorOutput.writeln(error.message);
      return 1;
    }
  }

  Future<int> _runGroupedTool({
    required String group,
    required String subcommand,
    required String script,
    required List<String> arguments,
    required String usage,
  }) async {
    if (arguments.isEmpty) {
      _writeCommandUsage(_errorOutput, usage);
      return 2;
    }
    if (_isHelp(arguments.first)) {
      _writeCommandUsage(_output, usage);
      return 0;
    }
    if (arguments.first != subcommand) {
      _errorOutput.writeln(
        "ERROR: Unknown $group command '${arguments.first}'.",
      );
      _writeCommandUsage(_errorOutput, usage);
      return 2;
    }

    return _runTool(
      command: '$group $subcommand',
      script: script,
      arguments: arguments.skip(1).toList(),
      usage: usage,
    );
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
    output.writeln(
      '  verify    Run the canonical repository verification gate.',
    );
    output.writeln('  fix       Apply or preview safe Dart fixes.');
    output.writeln('  config    Generate environment build configuration.');
    output.writeln('  env       Validate environment schema files.');
    output.writeln('  codegen   Verify generated-code freshness.');
    output.writeln('  l10n      Verify untranslated localization messages.');
    output.writeln('  project-map  Verify AGENTS project-map drift.');
    output.writeln();
    output.writeln('Run `mobilekit <command> --help` for command usage.');
  }

  void _writeCommandUsage(StringSink output, String usage) {
    output.writeln(usage);
    output.writeln();
    output.writeln('Existing tool options are passed through unchanged.');
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

  bool _containsHelp(List<String> arguments) => arguments.any(_isHelp);
}
