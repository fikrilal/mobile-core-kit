import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const openApiSnapshotPath = 'docs/contracts/openapi/backend.openapi.yaml';
const openApiLockPath = 'docs/contracts/openapi/backend.openapi.lock.json';

class OpenApiContractWorkflow {
  const OpenApiContractWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      throw const FormatException('Expected `contract openapi verify|sync`.');
    }
    return switch (arguments.first) {
      'verify' => _verify(arguments.skip(1).toList()),
      'sync' => _sync(arguments.skip(1).toList()),
      _ => throw FormatException(
        "Unknown contract openapi command '${arguments.first}'.",
      ),
    };
  }

  int _verify(List<String> arguments) {
    if (arguments.isNotEmpty) {
      throw FormatException("Unexpected argument '${arguments.first}'.");
    }
    try {
      final snapshot = _snapshotFile;
      final lock = _readLock();
      final bytes = snapshot.readAsBytesSync();
      _validateOpenApi(bytes);
      final actual = sha256.convert(bytes).toString();
      if (actual != lock.sha256) {
        throw const _ContractError(
          'contract.openapi-drift',
          'OpenAPI snapshot digest does not match its lock.',
        );
      }
      context.output.writeln(
        'OpenAPI snapshot is valid: $actual '
        '(source ${lock.sourceRevision.substring(0, 12)}).',
      );
      return 0;
    } on _ContractError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on FileSystemException catch (error) {
      context.errorOutput.writeln(
        'FAIL [contract.openapi-io] ${error.message}',
      );
      return 1;
    }
  }

  int _sync(List<String> arguments) {
    final parser = ArgParser()
      ..addOption('source')
      ..addOption('source-revision')
      ..addFlag('accept', negatable: false);
    final parsed = parser.parse(arguments);
    if (parsed.rest.isNotEmpty) {
      throw FormatException("Unexpected argument '${parsed.rest.first}'.");
    }
    final sourcePath = parsed.option('source');
    final sourceRevision = parsed.option('source-revision');
    if (sourcePath == null || sourcePath.isEmpty) {
      throw const FormatException('--source is required.');
    }
    if (sourceRevision == null || !_gitRevision.hasMatch(sourceRevision)) {
      throw const FormatException(
        '--source-revision must be a full 40-character Git revision.',
      );
    }
    if (!parsed.flag('accept')) {
      throw const FormatException(
        'Contract sync requires explicit --accept after backend review.',
      );
    }

    try {
      final source = File(
        p.isAbsolute(sourcePath)
            ? sourcePath
            : p.join(context.rootDirectory.path, sourcePath),
      );
      if (!source.existsSync() || source.lengthSync() == 0) {
        throw const _ContractError(
          'contract.openapi-source-invalid',
          'Accepted OpenAPI source is missing or empty.',
        );
      }
      final bytes = source.readAsBytesSync();
      _validateOpenApi(bytes);
      final digest = sha256.convert(bytes).toString();
      final current = _tryReadLock();
      if (_snapshotFile.existsSync() &&
          current?.sha256 == digest &&
          current?.sourceRevision == sourceRevision) {
        context.output.writeln('OpenAPI snapshot is already current: $digest.');
        return 0;
      }

      _atomicWrite(_snapshotFile, bytes);
      final lockBytes = utf8.encode(
        '${const JsonEncoder.withIndent('  ').convert({'schemaVersion': 1, 'artifact': openApiSnapshotPath, 'sha256': digest, 'sourceRevision': sourceRevision})}\n',
      );
      _atomicWrite(_lockFile, lockBytes);
      context.output.writeln(
        'Accepted OpenAPI snapshot $digest from source '
        '${sourceRevision.substring(0, 12)}.',
      );
      return 0;
    } on _ContractError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on FileSystemException catch (error) {
      context.errorOutput.writeln(
        'FAIL [contract.openapi-io] ${error.message}',
      );
      return 1;
    }
  }

  _OpenApiLock _readLock() {
    final lock = _tryReadLock();
    if (lock == null) {
      throw const _ContractError(
        'contract.openapi-lock-invalid',
        'OpenAPI lock is missing or malformed.',
      );
    }
    return lock;
  }

  _OpenApiLock? _tryReadLock() {
    if (!_lockFile.existsSync()) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(_lockFile.readAsStringSync());
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic> ||
        decoded.length != 4 ||
        decoded['schemaVersion'] != 1 ||
        decoded['artifact'] != openApiSnapshotPath ||
        decoded['sha256'] is! String ||
        !_sha256.hasMatch(decoded['sha256'] as String) ||
        decoded['sourceRevision'] is! String ||
        !_gitRevision.hasMatch(decoded['sourceRevision'] as String)) {
      return null;
    }
    return _OpenApiLock(
      sha256: decoded['sha256'] as String,
      sourceRevision: decoded['sourceRevision'] as String,
    );
  }

  void _validateOpenApi(List<int> bytes) {
    Object? decoded;
    try {
      decoded = loadYaml(utf8.decode(bytes));
    } on Object {
      throw const _ContractError(
        'contract.openapi-source-invalid',
        'OpenAPI source is not valid UTF-8 YAML.',
      );
    }
    if (decoded is! YamlMap ||
        decoded['openapi'] is! String ||
        !(decoded['openapi'] as String).startsWith('3.') ||
        decoded['info'] is! YamlMap ||
        decoded['paths'] is! YamlMap) {
      throw const _ContractError(
        'contract.openapi-source-invalid',
        'OpenAPI source must contain version 3, info, and paths.',
      );
    }
  }

  void _atomicWrite(File destination, List<int> bytes) {
    destination.parent.createSync(recursive: true);
    final temporary = File('${destination.path}.tmp');
    try {
      temporary.writeAsBytesSync(bytes, flush: true);
      temporary.renameSync(destination.path);
    } finally {
      if (temporary.existsSync()) temporary.deleteSync();
    }
  }

  File get _snapshotFile =>
      File(p.join(context.rootDirectory.path, openApiSnapshotPath));
  File get _lockFile =>
      File(p.join(context.rootDirectory.path, openApiLockPath));
}

class _OpenApiLock {
  const _OpenApiLock({required this.sha256, required this.sourceRevision});

  final String sha256;
  final String sourceRevision;
}

class _ContractError implements Exception {
  const _ContractError(this.code, this.message);

  final String code;
  final String message;
}

final _sha256 = RegExp(r'^[a-f0-9]{64}$');
final _gitRevision = RegExp(r'^[a-f0-9]{40}$');
