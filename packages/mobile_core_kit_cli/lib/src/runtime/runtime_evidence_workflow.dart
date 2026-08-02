import 'dart:io';

import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_process.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

class RuntimeEvidenceOptions {
  const RuntimeEvidenceOptions({
    required this.device,
    required this.flavor,
    required this.targets,
    required this.artifactsDirectory,
    required this.allowExampleEnvFallback,
    required this.googleServicesJson,
  });

  final String device;
  final String flavor;
  final List<String> targets;
  final String? artifactsDirectory;
  final bool allowExampleEnvFallback;
  final String? googleServicesJson;
}

class RuntimeEvidenceWorkflow {
  RuntimeEvidenceWorkflow({
    required Directory rootDirectory,
    RuntimeEvidenceProcessRunner? processRunner,
    CommandPlatform? platform,
    StringSink? output,
    StringSink? errorOutput,
  }) : rootDirectory = rootDirectory,
       _processRunner =
           processRunner ??
           DartRuntimeEvidenceProcessRunner(
             rootDirectory: rootDirectory,
             platform: platform,
           ),
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory rootDirectory;
  final RuntimeEvidenceProcessRunner _processRunner;
  final StringSink _output;
  final StringSink _errorOutput;

  static void writeUsage(StringSink output) {
    output.writeln('Usage: mobilekit runtime evidence [options]');
    output.writeln();
    output.writeln('Options:');
    output.writeln(
      '  --device <id>            Required device or emulator id.',
    );
    output.writeln(
      '  --flavor <name>          dev, staging, or prod (default: dev).',
    );
    output.writeln(
      '  --target <path>          Repeatable integration test target.',
    );
    output.writeln(
      '  --artifacts-dir <path>   Artifact directory '
      '(default: _artifacts/mobile/<timestamp>).',
    );
    output.writeln(
      '  --no-example-env-fallback  Disable dev/staging env example fallback.',
    );
    output.writeln(
      '  --google-services-json <path>  Copy explicit Firebase config before run.',
    );
    output.writeln();
    output.writeln('Examples:');
    output.writeln('  mobilekit runtime evidence --device emulator-5554');
    output.writeln(
      '  mobilekit runtime evidence --device emulator-5554 '
      '--target integration_test/auth_happy_path_test.dart',
    );
    output.writeln(
      '  mobilekit runtime evidence --device emulator-5554 '
      '--flavor dev --google-services-json /secure/google-services.json',
    );
  }

  Future<int> run(List<String> arguments) async {
    final parser = _createParser();
    ArgResults parsed;
    try {
      parsed = parser.parse(arguments);
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
      final options = _optionsFrom(parsed);
      return await _runEvidence(options);
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
      ..addOption('device')
      ..addOption(
        'flavor',
        allowed: const ['dev', 'staging', 'prod'],
        defaultsTo: 'dev',
      )
      ..addMultiOption('target')
      ..addOption('artifacts-dir')
      ..addFlag('no-example-env-fallback', negatable: false)
      ..addOption('google-services-json');
  }

  RuntimeEvidenceOptions _optionsFrom(ArgResults parsed) {
    final device = parsed.option('device');
    if (device == null || device.isEmpty) {
      throw const FormatException('--device is required.');
    }

    if (parsed.rest.isNotEmpty) {
      throw FormatException("Unknown argument '${parsed.rest.first}'.");
    }

    return RuntimeEvidenceOptions(
      device: device,
      flavor: parsed.option('flavor')!,
      targets: List.unmodifiable(parsed.multiOption('target')),
      artifactsDirectory: parsed.option('artifacts-dir'),
      allowExampleEnvFallback: !parsed.flag('no-example-env-fallback'),
      googleServicesJson: parsed.option('google-services-json'),
    );
  }

  Future<int> _runEvidence(RuntimeEvidenceOptions options) async {
    final targets = options.targets.isEmpty
        ? _discoverTargets()
        : options.targets;
    if (targets.isEmpty) {
      _errorOutput.writeln('ERROR: No integration_test targets found.');
      return 1;
    }

    final artifacts = _RuntimeEvidenceArtifacts(
      rootDirectory: rootDirectory,
      requestedDirectory: options.artifactsDirectory,
    );
    artifacts.directory.createSync(recursive: true);
    artifacts.logsDirectory.createSync(recursive: true);

    final envSource = _prepareEnvironment(options);
    if (envSource == null) return 1;
    final googleServicesSource = _prepareGoogleServices(options);
    if (googleServicesSource == null) return 1;

    _writeMetadata(
      artifacts,
      device: options.device,
      flavor: options.flavor,
      targets: targets,
      envSource: envSource,
      googleServicesSource: googleServicesSource,
    );
    _writeSummaryHeader(
      artifacts,
      device: options.device,
      flavor: options.flavor,
      envSource: envSource,
      googleServicesSource: googleServicesSource,
    );

    final preflightLog = artifacts.logFile('preflight');
    _writeOutputAndLog(
      '==> Generating build config for env=${options.flavor}',
      preflightLog,
    );
    final preflightErrors = StringBuffer();
    final preflightContext = WorkflowContext(
      rootDirectory: rootDirectory,
      output: _output,
      errorOutput: _TeeStringSink([_errorOutput, preflightErrors]),
      execute: (command) => _processRunner.run(
        command: command,
        workingDirectory: rootDirectory,
        logFile: preflightLog,
        output: _output,
        errorOutput: _errorOutput,
      ),
    );
    final preflightExit = await BuildConfigWorkflow(
      preflightContext,
    ).run(['--env', options.flavor]);
    if (preflightErrors.isNotEmpty) {
      preflightLog.writeAsStringSync(
        preflightErrors.toString(),
        mode: FileMode.append,
      );
    }

    if (preflightExit != 0) {
      _appendSummary(
        artifacts,
        '- ❌ build config generation failed (exit=$preflightExit)',
      );
      _output.writeln(
        'Mobile evidence preflight failed. See: ${artifacts.summaryFile.path}',
      );
      return 1;
    }
    _appendSummary(
      artifacts,
      '- ✅ build config generated (`mobilekit config generate --env ${options.flavor}`)',
    );

    final googleServicesFile = _findGoogleServicesFile(options.flavor);
    if (googleServicesFile == null) {
      _appendSummary(
        artifacts,
        '- ❌ google-services missing for flavor `${options.flavor}`',
      );
      _appendSummary(artifacts, '');
      _appendSummary(artifacts, 'Expected one of:');
      for (final candidate in _googleServicesCandidates(options.flavor)) {
        _appendSummary(artifacts, '- `${candidate}`');
      }
      _errorOutput.writeln(
        "ERROR: google-services.json not found for flavor '${options.flavor}'.",
      );
      _errorOutput.writeln(
        'See setup guide: docs/engineering/firebase_setup.md',
      );
      _output.writeln(
        'Mobile evidence preflight failed. See: ${artifacts.summaryFile.path}',
      );
      return 1;
    }
    artifacts.metadataFile.writeAsStringSync(
      'google_services_file=$googleServicesFile\n',
      mode: FileMode.append,
    );
    _appendSummary(
      artifacts,
      '- ✅ google-services present (`$googleServicesFile`)',
    );

    _appendSummary(artifacts, '');
    _appendSummary(artifacts, '## Results');

    var failCount = 0;
    for (final target in targets) {
      final targetFile = _resolveFile(target);
      if (!targetFile.existsSync()) {
        _errorOutput.writeln('ERROR: Target not found: $target');
        return 1;
      }

      final logFile = artifacts.logFile(target.replaceAll('/', '_'));
      _output.writeln(
        '==> Running $target on ${options.device} (flavor=${options.flavor})',
      );
      final testExit = await _processRunner.run(
        command: [
          'flutter',
          'test',
          '-d',
          options.device,
          '--flavor',
          options.flavor,
          target,
        ],
        workingDirectory: rootDirectory,
        logFile: logFile,
        output: _output,
        errorOutput: _errorOutput,
      );

      if (testExit == 0) {
        _appendSummary(artifacts, '- ✅ `$target`');
      } else {
        _appendSummary(artifacts, '- ❌ `$target` (exit=$testExit)');
        failCount++;
      }
    }

    _appendSignalExtracts(artifacts);
    if (failCount != 0) {
      _output.writeln(
        'Mobile evidence run completed with failures. '
        'See: ${artifacts.summaryFile.path}',
      );
      return 1;
    }

    _output.writeln(
      'Mobile evidence run completed successfully. '
      'See: ${artifacts.summaryFile.path}',
    );
    return 0;
  }

  List<String> _discoverTargets() {
    final integrationDirectory = Directory(
      p.join(rootDirectory.path, 'integration_test'),
    );
    if (!integrationDirectory.existsSync()) return const [];

    final targets =
        integrationDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .map((file) => p.relative(file.path, from: rootDirectory.path))
            .where((path) => path.endsWith('_test.dart'))
            .toList()
          ..sort();
    return targets;
  }

  String? _prepareEnvironment(RuntimeEvidenceOptions options) {
    final envFile = _resolveFile('.env/${options.flavor}.yaml');
    if (envFile.existsSync() && envFile.lengthSync() > 0) return 'existing';

    final exampleFile = _resolveFile('.env/${options.flavor}.example.yaml');
    if (options.allowExampleEnvFallback &&
        options.flavor != 'prod' &&
        exampleFile.existsSync() &&
        exampleFile.lengthSync() > 0) {
      exampleFile.copySync(envFile.path);
      return 'copied-from-example';
    }

    _errorOutput.writeln(
      'ERROR: Missing or empty env file: .env/${options.flavor}.yaml',
    );
    if (exampleFile.existsSync()) {
      _errorOutput.writeln(
        'Hint: copy .env/${options.flavor}.example.yaml -> '
        '.env/${options.flavor}.yaml or re-run with fallback enabled.',
      );
    }
    return null;
  }

  String? _prepareGoogleServices(RuntimeEvidenceOptions options) {
    final input = options.googleServicesJson;
    if (input == null || input.isEmpty) return 'existing';

    final inputFile = _resolveFile(input);
    if (!inputFile.existsSync() || inputFile.lengthSync() == 0) {
      _errorOutput.writeln(
        'ERROR: --google-services-json path is missing or empty: $input',
      );
      return null;
    }

    final destination = _resolveFile('android/app/google-services.json');
    if (p.normalize(inputFile.path) != p.normalize(destination.path)) {
      inputFile.copySync(destination.path);
    }
    return 'copied-from-flag';
  }

  String? _findGoogleServicesFile(String flavor) {
    for (final candidate in _googleServicesCandidates(flavor)) {
      final file = _resolveFile(candidate);
      if (file.existsSync() && file.lengthSync() > 0) return candidate;
    }
    return null;
  }

  List<String> _googleServicesCandidates(String flavor) {
    return [
      'android/app/src/$flavor/debug/google-services.json',
      'android/app/src/debug/$flavor/google-services.json',
      'android/app/src/$flavor/google-services.json',
      'android/app/src/debug/google-services.json',
      'android/app/src/${flavor}Debug/google-services.json',
      'android/app/google-services.json',
    ];
  }

  File _resolveFile(String path) {
    return File(p.isAbsolute(path) ? path : p.join(rootDirectory.path, path));
  }

  void _writeMetadata(
    _RuntimeEvidenceArtifacts artifacts, {
    required String device,
    required String flavor,
    required List<String> targets,
    required String envSource,
    required String googleServicesSource,
  }) {
    artifacts.metadataFile.writeAsStringSync(
      [
            'timestamp=${DateTime.now().toIso8601String()}',
            'device=$device',
            'flavor=$flavor',
            'env_file=.env/$flavor.yaml',
            'env_source=$envSource',
            'google_services_source=$googleServicesSource',
            'repo=${rootDirectory.path}',
            'targets=${targets.join(' ')}',
          ].join('\n') +
          '\n',
    );
  }

  void _writeSummaryHeader(
    _RuntimeEvidenceArtifacts artifacts, {
    required String device,
    required String flavor,
    required String envSource,
    required String googleServicesSource,
  }) {
    artifacts.summaryFile.writeAsStringSync(
      [
            '# Mobile Runtime Evidence Summary',
            '',
            '- Device: `$device`',
            '- Flavor: `$flavor`',
            '- Env file: `.env/$flavor.yaml` (`$envSource`)',
            '- Google services source: `$googleServicesSource`',
            '- Timestamp: `${DateTime.now().toIso8601String()}`',
            '- Artifacts dir: `${artifacts.displayDirectory}`',
            '',
            '## Preflight',
          ].join('\n') +
          '\n',
    );
  }

  void _appendSummary(_RuntimeEvidenceArtifacts artifacts, String line) {
    artifacts.summaryFile.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  void _writeOutputAndLog(String line, File logFile) {
    _output.writeln(line);
    logFile.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  void _appendSignalExtracts(_RuntimeEvidenceArtifacts artifacts) {
    final logFiles =
        artifacts.logsDirectory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.log'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    _appendSummary(artifacts, '');
    _appendSummary(artifacts, '## Signal Extracts');
    _appendSummary(artifacts, '');
    _appendSummary(artifacts, '### Startup Metrics');
    _appendMatchingLines(
      artifacts,
      logFiles,
      pattern: 'Startup metrics',
      noMatchMessage: '_No startup metric lines found._',
    );
    _appendSummary(artifacts, '');
    _appendSummary(artifacts, '### Trace IDs');
    _appendMatchingLines(
      artifacts,
      logFiles,
      pattern: 'traceId',
      noMatchMessage: '_No traceId lines found._',
    );
  }

  void _appendMatchingLines(
    _RuntimeEvidenceArtifacts artifacts,
    List<File> logFiles, {
    required String pattern,
    required String noMatchMessage,
  }) {
    var found = false;
    for (final file in logFiles) {
      for (final line in file.readAsLinesSync()) {
        if (line.contains(pattern)) {
          _appendSummary(artifacts, line);
          found = true;
        }
      }
    }
    if (!found) _appendSummary(artifacts, noMatchMessage);
  }
}

class _RuntimeEvidenceArtifacts {
  _RuntimeEvidenceArtifacts({
    required Directory rootDirectory,
    required String? requestedDirectory,
  }) {
    final displayDirectory =
        requestedDirectory ?? p.join('_artifacts', 'mobile', _timestamp());
    final absoluteDirectory = p.isAbsolute(displayDirectory)
        ? displayDirectory
        : p.join(rootDirectory.path, displayDirectory);
    this.displayDirectory = displayDirectory;
    directory = Directory(absoluteDirectory);
    logsDirectory = Directory(p.join(absoluteDirectory, 'logs'));
  }

  late final String displayDirectory;
  late final Directory directory;
  late final Directory logsDirectory;

  File get metadataFile => File(p.join(directory.path, 'metadata.txt'));

  File get summaryFile => File(p.join(directory.path, 'summary.md'));

  File logFile(String name) => File(p.join(logsDirectory.path, '$name.log'));

  String _timestamp() {
    final now = DateTime.now();
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${pad(now.month)}${pad(now.day)}_'
        '${pad(now.hour)}${pad(now.minute)}${pad(now.second)}';
  }
}

class _TeeStringSink implements StringSink {
  _TeeStringSink(this.sinks);

  final List<StringSink> sinks;

  @override
  void write(Object? object) {
    for (final sink in sinks) {
      sink.write(object);
    }
  }

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    for (final sink in sinks) {
      sink.writeAll(objects, separator);
    }
  }

  @override
  void writeCharCode(int charCode) {
    for (final sink in sinks) {
      sink.writeCharCode(charCode);
    }
  }

  @override
  void writeln([Object? object = '']) {
    for (final sink in sinks) {
      sink.writeln(object);
    }
  }
}
