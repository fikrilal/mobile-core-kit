import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/contracts/openapi_contract_workflow.dart';
import 'package:mobile_core_kit_cli/src/doctor/doctor.dart';
import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/duplication/duplication_runner.dart';
import 'package:mobile_core_kit_cli/src/events/event_workflow.dart';
import 'package:mobile_core_kit_cli/src/maintenance/maintenance_workflow.dart';
import 'package:mobile_core_kit_cli/src/oracle/oracle_workflow.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_workflow.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_log_session.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_log_workflow.dart';
import 'package:mobile_core_kit_cli/src/task/task_workflow.dart';
import 'package:mobile_core_kit_cli/src/template/template_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/codegen_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/environment_schema_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/fix_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/knowledge_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/l10n_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/lint_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/project_map_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/scaffold_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/verify_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

typedef CommandExecutor = Future<int> Function(List<String> command);

class MobilekitCli {
  MobilekitCli({
    Directory? currentDirectory,
    RepositoryRootLocator? rootLocator,
    ExecutableFinder? executableFinder,
    CommandPlatform? platform,
    CommandExecutor? commandExecutor,
    TemplateInputReader? inputReader,
    StringSink? output,
    StringSink? errorOutput,
  }) : _currentDirectory = currentDirectory ?? Directory.current,
       _rootLocator = rootLocator ?? const RepositoryRootLocator(),
       _executableFinder = executableFinder,
       _platform = platform,
       _commandExecutor = commandExecutor,
       _inputReader = inputReader,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory _currentDirectory;
  final RepositoryRootLocator _rootLocator;
  final ExecutableFinder? _executableFinder;
  final CommandPlatform? _platform;
  final CommandExecutor? _commandExecutor;
  final TemplateInputReader? _inputReader;
  final StringSink _output;
  final StringSink _errorOutput;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      _writeUsage(_output);
      return 0;
    }

    return switch (arguments.first) {
      'init' => _runTemplateLifecycle(
        command: TemplateLifecycleCommand.init,
        arguments: arguments.skip(1).toList(),
      ),
      'customize' => _runTemplateLifecycle(
        command: TemplateLifecycleCommand.customize,
        arguments: arguments.skip(1).toList(),
      ),
      'doctor' => _runDoctor(arguments.skip(1).toList()),
      'verify' => _runWorkflow(
        command: 'verify',
        arguments: arguments.skip(1).toList(),
        usage:
            'Usage: mobilekit verify '
            '[--profile <fast|full|runtime|ci>] [options]',
        workflow: (context) => VerifyWorkflow(
          context,
          runtimeVerification: (runtimeArguments) => RuntimeEvidenceWorkflow(
            rootDirectory: context.rootDirectory,
            platform: _platform,
            output: _output,
            errorOutput: _errorOutput,
          ).run(runtimeArguments),
        ).run(arguments.skip(1).toList()),
      ),
      'lint' => _runWorkflow(
        command: 'lint',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit lint',
        workflow: (context) =>
            LintWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'fix' => _runWorkflow(
        command: 'fix',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit fix [--dry-run|--apply]',
        workflow: (context) =>
            FixWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'config' => _runGroupedWorkflow(
        group: 'config',
        subcommand: 'generate',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit config generate [--env <env>]',
        workflow: (context, workflowArguments) =>
            BuildConfigWorkflow(context).run(workflowArguments),
      ),
      'env' => _runGroupedWorkflow(
        group: 'env',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit env verify [options]',
        workflow: (context, workflowArguments) =>
            EnvironmentSchemaWorkflow(context).run(workflowArguments),
      ),
      'codegen' => _runGroupedWorkflow(
        group: 'codegen',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit codegen verify',
        workflow: (context, workflowArguments) =>
            CodegenWorkflow(context).run(workflowArguments),
      ),
      'l10n' => _runGroupedWorkflow(
        group: 'l10n',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit l10n verify [path]',
        workflow: (context, workflowArguments) =>
            L10nWorkflow(context).run(workflowArguments),
      ),
      'project-map' => _runGroupedWorkflow(
        group: 'project-map',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit project-map verify',
        workflow: (context, workflowArguments) =>
            ProjectMapWorkflow(context).run(workflowArguments),
      ),
      'knowledge' => _runGroupedWorkflow(
        group: 'knowledge',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit knowledge verify',
        workflow: (context, workflowArguments) =>
            KnowledgeWorkflow(context).run(workflowArguments),
      ),
      'oracle' => _runGroupedWorkflow(
        group: 'oracle',
        subcommand: 'verify',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit oracle verify',
        workflow: (context, workflowArguments) =>
            OracleWorkflow(context).run(workflowArguments),
      ),
      'contract' => _runContract(arguments.skip(1).toList()),
      'task' => _runWorkflow(
        command: 'task',
        arguments: arguments.skip(1).toList(),
        usage:
            'Usage: mobilekit task begin --plan <path> | '
            'task preflight --task <id> [--action <action>] | '
            'task verify --task <id> [--env <env>] | '
            'task repair --task <id> | '
            'task workspace <prepare|status|cancel|cleanup> --task <id> | '
            'task status --task <id>',
        workflow: (context) =>
            TaskWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'event' => _runWorkflow(
        command: 'event',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit event intake --once',
        workflow: (context) =>
            EventWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'maintenance' => _runWorkflow(
        command: 'maintenance',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit maintenance run --once',
        workflow: (context) =>
            MaintenanceWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'risk' => _runWorkflow(
        command: 'risk',
        arguments: arguments.skip(1).toList(),
        usage: 'Usage: mobilekit risk classify [--plan <path>]',
        workflow: (context) =>
            RiskWorkflow(context).run(arguments.skip(1).toList()),
      ),
      'scaffold' => _runScaffold(arguments.skip(1).toList()),
      'duplication' => _runDuplication(arguments.skip(1).toList()),
      'runtime' => _runRuntime(arguments.skip(1).toList()),
      _ => _unknownCommand(arguments.first),
    };
  }

  Future<int> _runRuntime(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      _writeRuntimeUsage(_output);
      return arguments.isEmpty ? 2 : 0;
    }
    return switch (arguments.first) {
      'logs' => _runRuntimeLogs(arguments.skip(1).toList()),
      'evidence' => _runRuntimeEvidence(arguments.skip(1).toList()),
      _ => _unknownRuntimeCommand(arguments.first),
    };
  }

  Future<int> _runContract(List<String> arguments) async {
    const usage =
        'Usage: mobilekit contract openapi verify | '
        'contract openapi sync --source <path> '
        '--source-revision <revision> --accept';
    if (arguments.isEmpty) {
      _writeCommandUsage(_errorOutput, usage);
      return 2;
    }
    if (_isHelp(arguments.first)) {
      _writeCommandUsage(_output, usage);
      return 0;
    }
    if (arguments.first != 'openapi') {
      _errorOutput.writeln(
        "ERROR: Unknown contract command '${arguments.first}'.",
      );
      _writeCommandUsage(_errorOutput, usage);
      return 2;
    }
    return _runWorkflow(
      command: 'contract openapi',
      arguments: arguments.skip(1).toList(),
      usage: usage,
      workflow: (context) =>
          OpenApiContractWorkflow(context).run(arguments.skip(1).toList()),
    );
  }

  Future<int> _runTemplateLifecycle({
    required TemplateLifecycleCommand command,
    required List<String> arguments,
  }) async {
    if (_containsHelp(arguments)) {
      TemplateLifecycleWorkflow.writeUsage(_output, command);
      return 0;
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    return _runRepositoryWorkflow(
      command: command.label,
      root: root,
      usage: 'Usage: mobilekit ${command.label} [options]',
      workflow: (context) => TemplateLifecycleWorkflow(
        context,
        inputReader: _inputReader,
      ).run(command, arguments),
    );
  }

  Future<int> _runRuntimeLogs(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      RuntimeLogWorkflow.writeUsage(_output);
      return arguments.isEmpty ? 2 : 0;
    }

    if (_containsCommandHelp(arguments)) {
      RuntimeLogWorkflow.writeUsage(_output);
      return 0;
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    final sessionManager = RuntimeLogSessionManager(
      rootDirectory: root,
      platform: _platform,
      output: _output,
      errorOutput: _errorOutput,
    );
    return RuntimeLogWorkflow(
      sessionManager: sessionManager,
      output: _output,
      errorOutput: _errorOutput,
    ).run(arguments);
  }

  Future<int> _runRuntimeEvidence(List<String> arguments) async {
    if (arguments.isEmpty || arguments.any(_isHelp)) {
      RuntimeEvidenceWorkflow.writeUsage(_output);
      return arguments.isEmpty ? 2 : 0;
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    return RuntimeEvidenceWorkflow(
      rootDirectory: root,
      platform: _platform,
      output: _output,
      errorOutput: _errorOutput,
    ).run(arguments);
  }

  int _unknownRuntimeCommand(String command) {
    _errorOutput.writeln("ERROR: Unknown runtime command '$command'.");
    _writeRuntimeUsage(_errorOutput);
    return 2;
  }

  void _writeRuntimeUsage(StringSink output) {
    output.writeln('Usage: mobilekit runtime <command> [options]');
    output.writeln();
    output.writeln('Commands:');
    output.writeln('  logs      Manage live Flutter log sessions.');
    output.writeln(
      '  evidence  Run device integration tests and collect evidence.',
    );
    output.writeln();
    output.writeln('Run `mobilekit runtime <command> --help` for usage.');
  }

  Future<int> _runWorkflow({
    required String command,
    required List<String> arguments,
    required String usage,
    required Future<int> Function(WorkflowContext context) workflow,
  }) async {
    if (_containsHelp(arguments)) {
      _writeCommandUsage(_output, usage);
      return 0;
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    return _runRepositoryWorkflow(
      command: command,
      root: root,
      usage: usage,
      workflow: workflow,
    );
  }

  Future<int> _runScaffold(List<String> arguments) async {
    if (arguments.isEmpty || _isHelp(arguments.first)) {
      _writeScaffoldUsage(_output);
      return arguments.isEmpty ? 2 : 0;
    }
    if (arguments.first != 'feature') {
      _errorOutput.writeln(
        "ERROR: Unknown scaffold command '${arguments.first}'.",
      );
      _writeScaffoldUsage(_errorOutput);
      return 2;
    }

    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addFlag('dry-run', negatable: false)
      ..addOption('slice', abbr: 's');

    ArgResults parsed;
    try {
      parsed = parser.parse(arguments.skip(1).toList());
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      _writeScaffoldUsage(_errorOutput);
      return 2;
    }

    if (parsed.flag('help')) {
      _writeScaffoldUsage(_output);
      return 0;
    }
    if (parsed.rest.length != 1) {
      _errorOutput.writeln(
        'ERROR: Expected exactly one feature name in snake_case.',
      );
      _writeScaffoldUsage(_errorOutput);
      return 2;
    }

    final workflowArguments = <String>['--feature', parsed.rest.single];
    final slice = parsed.option('slice');
    if (slice != null) {
      workflowArguments.addAll(['--slice', slice]);
    }
    if (parsed.flag('dry-run')) {
      workflowArguments.add('--dry-run');
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    return _runRepositoryWorkflow(
      command: 'scaffold feature',
      root: root,
      usage: 'Usage: mobilekit scaffold feature <name> [options]',
      workflow: (context) => ScaffoldWorkflow(context).run(workflowArguments),
    );
  }

  Future<int> _runDuplication(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'profile',
        allowed: DuplicationProfile.values.map((profile) => profile.label),
      );

    ArgResults parsed;
    try {
      parsed = parser.parse(arguments);
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      _writeDuplicationUsage(_errorOutput);
      return 2;
    }

    if (parsed.flag('help')) {
      _writeDuplicationUsage(_output);
      return 0;
    }
    if (parsed.rest.length != 1 || parsed.rest.single != 'check') {
      _errorOutput.writeln('ERROR: Expected `mobilekit duplication check`.');
      _writeDuplicationUsage(_errorOutput);
      return 2;
    }

    final root = _findRepositoryRoot();
    if (root == null) return 1;

    final execute =
        _commandExecutor ??
        CommandRunner(
          rootDirectory: root,
          platform: _platform,
          output: _output,
        ).run;
    final runner = DuplicationRunner(
      rootDirectory: root,
      execute: execute,
      output: _output,
      errorOutput: _errorOutput,
    );

    try {
      final profile = parsed.option('profile');
      if (profile == null) return runner.runDefault();
      return runner.run(
        DuplicationProfile.values.firstWhere(
          (candidate) => candidate.label == profile,
        ),
      );
    } on ProcessException catch (error) {
      _errorOutput.writeln('ERROR: Failed to run mobilekit duplication check.');
      _errorOutput.writeln(error.message);
      return 1;
    }
  }

  Future<int> _runRepositoryWorkflow({
    required String command,
    required Directory root,
    required String usage,
    required Future<int> Function(WorkflowContext context) workflow,
  }) async {
    final execute =
        _commandExecutor ??
        CommandRunner(
          rootDirectory: root,
          platform: _platform,
          output: _output,
        ).run;
    final context = WorkflowContext(
      rootDirectory: root,
      execute: execute,
      output: _output,
      errorOutput: _errorOutput,
    );
    try {
      return await workflow(context);
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      _writeCommandUsage(_errorOutput, usage);
      return 2;
    } on ProcessException catch (error) {
      _errorOutput.writeln('ERROR: Failed to run mobilekit $command.');
      _errorOutput.writeln(error.message);
      return 1;
    }
  }

  Directory? _findRepositoryRoot() {
    final root = _rootLocator.find(startDirectory: _currentDirectory);
    if (root != null) return root;

    _errorOutput.writeln(
      'ERROR: Repository root not found. '
      'Run this command from inside the repository.',
    );
    return null;
  }

  Future<int> _runGroupedWorkflow({
    required String group,
    required String subcommand,
    required List<String> arguments,
    required String usage,
    required Future<int> Function(
      WorkflowContext context,
      List<String> arguments,
    )
    workflow,
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

    return _runWorkflow(
      command: '$group $subcommand',
      arguments: arguments.skip(1).toList(),
      usage: usage,
      workflow: (context) => workflow(context, arguments.skip(1).toList()),
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
    output.writeln('  init      Initialize and customize a template copy.');
    output.writeln('  customize Re-run template customization.');
    output.writeln('  doctor    Diagnose local repository tooling.');
    output.writeln('  lint      Run Dart and Flutter lint checks.');
    output.writeln(
      '  verify    Run the canonical repository verification gate.',
    );
    output.writeln('  fix       Apply or preview safe Dart fixes.');
    output.writeln('  config    Generate environment build configuration.');
    output.writeln('  env       Validate environment schema files.');
    output.writeln('  codegen   Verify generated-code freshness.');
    output.writeln('  l10n      Verify untranslated localization messages.');
    output.writeln('  project-map  Verify AGENTS project-map drift.');
    output.writeln(
      '  knowledge Verify project-map, links, and plan lifecycle.',
    );
    output.writeln('  oracle    Verify registered behavioral oracles.');
    output.writeln('  contract  Verify or explicitly sync pinned contracts.');
    output.writeln(
      '  task      Manage current-agent task authority and state.',
    );
    output.writeln('  event     Activate one authorized queued V2 plan.');
    output.writeln(
      '  maintenance  Run fixed read-only repository observations.',
    );
    output.writeln('  risk      Classify current repository change risk.');
    output.writeln('  scaffold  Generate feature scaffolding.');
    output.writeln('  duplication  Run duplication profiles.');
    output.writeln('  runtime   Manage runtime evidence and log sessions.');
    output.writeln();
    output.writeln('Run `mobilekit <command> --help` for command usage.');
  }

  void _writeCommandUsage(StringSink output, String usage) {
    output.writeln(usage);
    output.writeln();
    output.writeln('Existing tool options are passed through unchanged.');
  }

  void _writeScaffoldUsage(StringSink output) {
    output.writeln('Usage: mobilekit scaffold feature <name> [options]');
    output.writeln();
    output.writeln('Options:');
    output.writeln('  --slice, -s <name>  Optional slice name.');
    output.writeln(
      '  --dry-run           Print outputs without writing files.',
    );
  }

  void _writeDuplicationUsage(StringSink output) {
    output.writeln('Usage: mobilekit duplication check [--profile <profile>]');
    output.writeln();
    output.writeln('Profiles:');
    output.writeln('  core          Main maintainability duplication profile.');
    output.writeln('  small-helpers Small helper duplication profile.');
    output.writeln('  presentation  Flutter presentation duplication profile.');
    output.writeln();
    output.writeln(
      'Without --profile, core and small-helpers run sequentially.',
    );
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

  bool _containsCommandHelp(List<String> arguments) {
    final separatorIndex = arguments.indexOf('--');
    final commandArguments = separatorIndex == -1
        ? arguments
        : arguments.take(separatorIndex);
    return commandArguments.any(_isHelp);
  }
}
