import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_binding.dart';
import 'package:mobile_core_kit_cli/src/runtime/runtime_evidence_process.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/workflows/build_config_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

const runtimeEvidenceSchemaVersion = 1;

class RuntimeEvidenceOptions {
  const RuntimeEvidenceOptions({
    required this.taskId,
    required this.device,
    required this.flavor,
    required this.targets,
    required this.artifactsDirectory,
    required this.allowExampleEnvFallback,
    required this.googleServicesJson,
  });

  final String taskId;
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
    RuntimeEvidenceBindingResolver? bindingResolver,
    CommandPlatform? platform,
    DateTime Function()? now,
    StringSink? output,
    StringSink? errorOutput,
  }) : rootDirectory = rootDirectory,
       _processRunner =
           processRunner ??
           DartRuntimeEvidenceProcessRunner(
             rootDirectory: rootDirectory,
             platform: platform,
           ),
       _bindingResolver =
           bindingResolver ?? TaskRuntimeEvidenceBindingResolver(rootDirectory),
       _now = now ?? DateTime.now,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory rootDirectory;
  final RuntimeEvidenceProcessRunner _processRunner;
  final RuntimeEvidenceBindingResolver _bindingResolver;
  final DateTime Function() _now;
  final StringSink _output;
  final StringSink _errorOutput;

  static void writeUsage(StringSink output) {
    output.writeln('Usage: mobilekit runtime evidence [options]');
    output.writeln();
    output.writeln('Options:');
    output.writeln('  --task <id>              Required verified task ID.');
    output.writeln(
      '  --device <id>            Required device or emulator id.',
    );
    output.writeln(
      '  --flavor <name>          dev, staging, or prod (default: dev).',
    );
    output.writeln(
      '  --target <path>          Repeatable selected registered target.',
    );
    output.writeln(
      '  --artifacts-dir <path>   Repository-local artifact directory '
      '(default: _artifacts/mobile/<timestamp>).',
    );
    output.writeln(
      '  --no-example-env-fallback  Disable dev/staging env example fallback.',
    );
    output.writeln(
      '  --google-services-json <path>  Use explicit Firebase config transactionally.',
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
      return await _runEvidence(_optionsFrom(parsed));
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      return 2;
    } on TaskControlError catch (error) {
      _errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on FileSystemException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      return 1;
    } on ProcessException catch (error) {
      _errorOutput.writeln('ERROR: ${error.message}');
      return 1;
    }
  }

  ArgParser _createParser() => ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('task')
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

  RuntimeEvidenceOptions _optionsFrom(ArgResults parsed) {
    final taskId = parsed.option('task');
    if (taskId == null || taskId.isEmpty) {
      throw const FormatException('--task is required.');
    }
    final device = parsed.option('device');
    if (device == null || device.isEmpty) {
      throw const FormatException('--device is required.');
    }
    if (parsed.rest.isNotEmpty) {
      throw FormatException("Unknown argument '${parsed.rest.first}'.");
    }
    return RuntimeEvidenceOptions(
      taskId: taskId,
      device: device,
      flavor: parsed.option('flavor')!,
      targets: List.unmodifiable(parsed.multiOption('target')),
      artifactsDirectory: parsed.option('artifacts-dir'),
      allowExampleEnvFallback: !parsed.flag('no-example-env-fallback'),
      googleServicesJson: parsed.option('google-services-json'),
    );
  }

  Future<int> _runEvidence(RuntimeEvidenceOptions options) async {
    final binding = await _bindingResolver.resolve(options.taskId);
    final selectedTargets = _selectTargets(binding, options.targets);
    final artifacts = _RuntimeEvidenceArtifacts(
      rootDirectory: rootDirectory,
      requestedDirectory: options.artifactsDirectory,
      now: _now,
    );
    artifacts.create();

    final started = _now().toUtc();
    final results = <_RuntimeTargetResult>[];
    final mutations = <_RestorableFile>[];
    var outcome = 'failed';
    var boundary = 'runtime.preflight';
    var exitCode = 1;
    String envSource = 'unavailable';
    String googleServicesSource = 'unavailable';
    try {
      final environment = _prepareEnvironment(options);
      if (environment == null) return 1;
      envSource = environment.source;
      if (environment.mutation != null) mutations.add(environment.mutation!);

      final googleServices = _prepareGoogleServices(options);
      if (googleServices == null) return 1;
      googleServicesSource = googleServices.source;
      if (googleServices.mutation != null) {
        mutations.add(googleServices.mutation!);
      }

      mutations.add(
        _RestorableFile.capture(
          _resolveFile('lib/core/foundation/config/build_config_values.dart'),
        ),
      );
      final preflightExit = await _runBuildConfig(
        flavor: options.flavor,
        logFile: artifacts.logFile('preflight'),
      );
      if (preflightExit != 0) return 1;

      final googleServicesFile = _findGoogleServicesFile(options.flavor);
      if (googleServicesFile == null) {
        _errorOutput.writeln(
          "ERROR: google-services.json not found for flavor '${options.flavor}'.",
        );
        return 1;
      }

      boundary = 'runtime.integration';
      var failures = 0;
      for (final entry in selectedTargets.entries) {
        final target = entry.value;
        final targetFile = _resolveFile(target);
        if (!targetFile.existsSync()) {
          _errorOutput.writeln('ERROR: Target not found: $target');
          results.add(
            _RuntimeTargetResult(
              oracleId: entry.key,
              target: target,
              exitCode: 1,
            ),
          );
          failures++;
          continue;
        }
        final logFile = artifacts.logFile(target.replaceAll('/', '_'));
        _output.writeln(
          '==> Running $target (oracle=${entry.key}, flavor=${options.flavor})',
        );
        final targetExit = await _processRunner.run(
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
        _boundLog(logFile);
        results.add(
          _RuntimeTargetResult(
            oracleId: entry.key,
            target: target,
            exitCode: targetExit,
          ),
        );
        if (targetExit != 0) failures++;
      }
      exitCode = failures == 0 ? 0 : 1;
      outcome = failures == 0 ? 'passed' : 'failed';
      return exitCode;
    } finally {
      for (final mutation in mutations.reversed) {
        mutation.restore();
      }
      for (final file in artifacts.logFiles) {
        _boundLog(file);
      }
      _writeSummary(
        artifacts,
        binding: binding,
        flavor: options.flavor,
        deviceHash: _hashIdentifier(options.device),
        outcome: outcome,
        results: results,
      );
      _writeManifest(
        artifacts,
        binding: binding,
        started: started,
        finished: _now().toUtc(),
        flavor: options.flavor,
        deviceHash: _hashIdentifier(options.device),
        envSource: envSource,
        googleServicesSource: googleServicesSource,
        outcome: outcome,
        boundary: boundary,
        exitCode: exitCode,
        results: results,
      );
      _output.writeln(
        'Mobile evidence $outcome. See: ${artifacts.displayDirectory}/evidence.json',
      );
    }
  }

  Map<String, String> _selectTargets(
    RuntimeEvidenceBinding binding,
    List<String> requested,
  ) {
    if (requested.isEmpty) return binding.runtimeTargets;
    final selected = <String, String>{};
    for (final target in requested) {
      final matches = binding.runtimeTargets.entries
          .where((entry) => entry.value == target)
          .toList();
      if (matches.length != 1) {
        throw FormatException(
          "Target '$target' is not selected by exactly one registered task oracle.",
        );
      }
      selected[matches.single.key] = matches.single.value;
    }
    return Map.unmodifiable(selected);
  }

  Future<int> _runBuildConfig({
    required String flavor,
    required File logFile,
  }) async {
    _output.writeln('==> Generating build config for env=$flavor');
    logFile.parent.createSync(recursive: true);
    logFile.writeAsStringSync(
      'Generating build config for env=$flavor\n',
      mode: FileMode.append,
    );
    final errors = StringBuffer();
    final context = WorkflowContext(
      rootDirectory: rootDirectory,
      output: _output,
      errorOutput: _TeeStringSink([_errorOutput, errors]),
      execute: (command) => _processRunner.run(
        command: command,
        workingDirectory: rootDirectory,
        logFile: logFile,
        output: _output,
        errorOutput: _errorOutput,
      ),
    );
    final result = await BuildConfigWorkflow(context).run(['--env', flavor]);
    if (errors.isNotEmpty) {
      logFile.writeAsStringSync(errors.toString(), mode: FileMode.append);
    }
    _boundLog(logFile);
    return result;
  }

  _PreparedFile? _prepareEnvironment(RuntimeEvidenceOptions options) {
    final envFile = _resolveFile('.env/${options.flavor}.yaml');
    if (envFile.existsSync() && envFile.lengthSync() > 0) {
      return const _PreparedFile('existing');
    }
    final exampleFile = _resolveFile('.env/${options.flavor}.example.yaml');
    if (options.allowExampleEnvFallback &&
        options.flavor != 'prod' &&
        exampleFile.existsSync() &&
        exampleFile.lengthSync() > 0) {
      final mutation = _RestorableFile.capture(envFile);
      envFile.parent.createSync(recursive: true);
      exampleFile.copySync(envFile.path);
      return _PreparedFile('temporary-example', mutation);
    }
    _errorOutput.writeln(
      'ERROR: Missing or empty env file: .env/${options.flavor}.yaml',
    );
    return null;
  }

  _PreparedFile? _prepareGoogleServices(RuntimeEvidenceOptions options) {
    final input = options.googleServicesJson;
    if (input == null || input.isEmpty) {
      return const _PreparedFile('existing');
    }
    final inputFile = _resolveFile(input);
    if (!inputFile.existsSync() || inputFile.lengthSync() == 0) {
      _errorOutput.writeln(
        'ERROR: --google-services-json path is missing or empty.',
      );
      return null;
    }
    final destination = _resolveFile('android/app/google-services.json');
    final mutation = _RestorableFile.capture(destination);
    destination.parent.createSync(recursive: true);
    if (p.normalize(inputFile.path) != p.normalize(destination.path)) {
      inputFile.copySync(destination.path);
    }
    return _PreparedFile('temporary-explicit', mutation);
  }

  String? _findGoogleServicesFile(String flavor) {
    for (final candidate in _googleServicesCandidates(flavor)) {
      final file = _resolveFile(candidate);
      if (file.existsSync() && file.lengthSync() > 0) return candidate;
    }
    return null;
  }

  List<String> _googleServicesCandidates(String flavor) => [
    'android/app/src/$flavor/debug/google-services.json',
    'android/app/src/debug/$flavor/google-services.json',
    'android/app/src/$flavor/google-services.json',
    'android/app/src/debug/google-services.json',
    'android/app/src/${flavor}Debug/google-services.json',
    'android/app/google-services.json',
  ];

  File _resolveFile(String path) =>
      File(p.isAbsolute(path) ? path : p.join(rootDirectory.path, path));

  void _writeSummary(
    _RuntimeEvidenceArtifacts artifacts, {
    required RuntimeEvidenceBinding binding,
    required String flavor,
    required String deviceHash,
    required String outcome,
    required List<_RuntimeTargetResult> results,
  }) {
    final lines = <String>[
      '# Mobile Runtime Evidence Summary',
      '',
      '- Task: `${binding.taskId}`',
      '- Fingerprint: `${binding.taskFingerprint}`',
      '- Device hash: `$deviceHash`',
      '- Flavor: `$flavor`',
      '- Outcome: `$outcome`',
      '',
      '## Registered Results',
      '',
      for (final result in results)
        '- ${result.exitCode == 0 ? 'PASS' : 'FAIL'} `${result.oracleId}` -> `${result.target}`',
    ];
    artifacts.summaryFile.writeAsStringSync('${lines.join('\n')}\n');
  }

  void _writeManifest(
    _RuntimeEvidenceArtifacts artifacts, {
    required RuntimeEvidenceBinding binding,
    required DateTime started,
    required DateTime finished,
    required String flavor,
    required String deviceHash,
    required String envSource,
    required String googleServicesSource,
    required String outcome,
    required String boundary,
    required int exitCode,
    required List<_RuntimeTargetResult> results,
  }) {
    final artifactEntries = <Map<String, Object?>>[];
    for (final file in [artifacts.summaryFile, ...artifacts.logFiles]) {
      if (!file.existsSync()) continue;
      artifactEntries.add({
        'path': artifacts.relativePath(file),
        'sha256': sha256.convert(file.readAsBytesSync()).toString(),
        'sizeBytes': file.lengthSync(),
        'durability': file == artifacts.summaryFile
            ? 'durable-summary'
            : 'transient-local-log',
      });
    }
    final manifest = <String, Object?>{
      'schemaVersion': runtimeEvidenceSchemaVersion,
      'task': {
        'id': binding.taskId,
        'planPath': binding.planPath,
        'planSourceHash': binding.planSourceHash,
        'authorityHash': binding.authorityHash,
        'baseRevision': binding.baseRevision,
        'candidateRevision': binding.candidateRevision,
        'fingerprint': binding.taskFingerprint,
        'oracleIds': binding.oracleIds,
      },
      'run': {
        'startedAt': started.toIso8601String(),
        'finishedAt': finished.toIso8601String(),
        'durationMs': finished.difference(started).inMilliseconds,
        'outcome': outcome,
        'exitCode': exitCode,
        'boundary': boundary,
        'flavor': flavor,
        'deviceIdentifierHash': deviceHash,
        'environmentPreparation': envSource,
        'firebasePreparation': googleServicesSource,
        'artifactRoot': artifacts.displayDirectory,
        'logPolicy': {
          'durability': 'transient-local-ignored',
          'maximumBytesPerLog': runtimeEvidenceLogLimitBytes,
        },
      },
      'results': results.map((result) => result.toJson()).toList(),
      'artifacts': artifactEntries,
    };
    artifacts.manifestFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
      flush: true,
    );
  }

  void _boundLog(File file) {
    if (!file.existsSync()) return;
    if (file.lengthSync() <= runtimeEvidenceLogLimitBytes) {
      _restrict(file.path, '600');
      return;
    }
    final handle = file.openSync(mode: FileMode.read);
    try {
      handle.setPositionSync(file.lengthSync() - runtimeEvidenceLogLimitBytes);
      final tail = handle.readSync(runtimeEvidenceLogLimitBytes);
      file.writeAsBytesSync(tail, flush: true);
    } finally {
      handle.closeSync();
    }
    _restrict(file.path, '600');
  }

  void _restrict(String path, String mode) {
    if (Platform.isWindows) return;
    final result = Process.runSync('chmod', [mode, path]);
    if (result.exitCode != 0) {
      throw FileSystemException(
        'Unable to restrict runtime evidence permissions.',
        path,
      );
    }
  }
}

class _RuntimeEvidenceArtifacts {
  _RuntimeEvidenceArtifacts({
    required Directory rootDirectory,
    required String? requestedDirectory,
    required DateTime Function() now,
  }) : rootDirectory = rootDirectory {
    final requested =
        requestedDirectory ?? p.join('_artifacts', 'mobile', _timestamp(now()));
    final absolute = p.normalize(
      p.absolute(
        p.isAbsolute(requested)
            ? requested
            : p.join(rootDirectory.path, requested),
      ),
    );
    final rootPath = p.normalize(p.absolute(rootDirectory.path));
    if (!p.isWithin(rootPath, absolute)) {
      throw const FormatException(
        '--artifacts-dir must stay inside the repository.',
      );
    }
    displayDirectory = p.relative(absolute, from: rootPath);
    directory = Directory(absolute);
    logsDirectory = Directory(p.join(absolute, 'logs'));
  }

  final Directory rootDirectory;
  late final String displayDirectory;
  late final Directory directory;
  late final Directory logsDirectory;

  void create() {
    directory.createSync(recursive: true);
    logsDirectory.createSync(recursive: true);
    final canonicalRoot = rootDirectory.resolveSymbolicLinksSync();
    final canonicalDirectory = directory.resolveSymbolicLinksSync();
    if (!p.isWithin(canonicalRoot, canonicalDirectory)) {
      throw const FormatException(
        '--artifacts-dir must not escape through a symlink.',
      );
    }
    _restrictDirectory(directory);
    _restrictDirectory(logsDirectory);
  }

  File get manifestFile => File(p.join(directory.path, 'evidence.json'));
  File get summaryFile => File(p.join(directory.path, 'summary.md'));
  File logFile(String name) => File(p.join(logsDirectory.path, '$name.log'));

  List<File> get logFiles {
    if (!logsDirectory.existsSync()) return const [];
    final files = logsDirectory.listSync().whereType<File>().toList()
      ..sort((left, right) => left.path.compareTo(right.path));
    return files;
  }

  String relativePath(File file) =>
      p.relative(file.path, from: rootDirectory.path);

  static String _timestamp(DateTime value) {
    String pad(int number) => number.toString().padLeft(2, '0');
    return '${value.year}${pad(value.month)}${pad(value.day)}_'
        '${pad(value.hour)}${pad(value.minute)}${pad(value.second)}';
  }

  static void _restrictDirectory(Directory value) {
    if (Platform.isWindows) return;
    final result = Process.runSync('chmod', ['700', value.path]);
    if (result.exitCode != 0) {
      throw FileSystemException(
        'Unable to restrict runtime evidence directory permissions.',
        value.path,
      );
    }
  }
}

class _PreparedFile {
  const _PreparedFile(this.source, [this.mutation]);

  final String source;
  final _RestorableFile? mutation;
}

class _RestorableFile {
  _RestorableFile._(this.file, this.existed, this.contents);

  factory _RestorableFile.capture(File file) => _RestorableFile._(
    file,
    file.existsSync(),
    file.existsSync() ? file.readAsBytesSync() : null,
  );

  final File file;
  final bool existed;
  final List<int>? contents;

  void restore() {
    if (existed) {
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(contents!, flush: true);
    } else if (file.existsSync()) {
      file.deleteSync();
    }
  }
}

class _RuntimeTargetResult {
  const _RuntimeTargetResult({
    required this.oracleId,
    required this.target,
    required this.exitCode,
  });

  final String oracleId;
  final String target;
  final int exitCode;

  Map<String, Object?> toJson() => {
    'oracleId': oracleId,
    'target': target,
    'outcome': exitCode == 0 ? 'passed' : 'failed',
    'exitCode': exitCode,
    'boundary': 'runtime.integration',
  };
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

String _hashIdentifier(String value) =>
    sha256.convert(utf8.encode('device:$value')).toString();
