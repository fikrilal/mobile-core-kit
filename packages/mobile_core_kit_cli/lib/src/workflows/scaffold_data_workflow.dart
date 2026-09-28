import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/contracts/openapi_schema_resolver.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class ScaffoldDataWorkflow {
  const ScaffoldDataWorkflow(this.context);

  final WorkflowContext context;

  static const String defaultOpenApiPath =
      'docs/contracts/openapi/backend.openapi.yaml';

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Print outputs; does not write files.',
      )
      ..addFlag(
        'force',
        negatable: false,
        help: 'Overwrite existing model files.',
      )
      ..addFlag(
        'no-codegen',
        negatable: false,
        help: 'Skip running targeted build_runner codegen.',
      )
      ..addFlag(
        'list',
        negatable: false,
        help: 'List all operations in the OpenAPI contract.',
      )
      ..addOption('filter', help: 'Filter string when listing operations.')
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Target feature name (snake_case), e.g. "merchant_onboarding".',
      )
      ..addOption(
        'operation',
        abbr: 'o',
        help:
            'OpenAPI operationId or "METHOD /path", e.g. "merchantOnboarding.applications.submit".',
      )
      ..addOption(
        'openapi-spec',
        defaultsTo: defaultOpenApiPath,
        help: 'Repository-relative path to OpenAPI specification.',
      );

    final args = parser.parse(argv);
    if (args.flag('help')) {
      _printUsage(parser);
      return 0;
    }

    final specRelativePath = args.option('openapi-spec') ?? defaultOpenApiPath;
    final specFile = context.file(specRelativePath);
    if (!specFile.existsSync()) {
      context.errorOutput.writeln(
        "ERROR: OpenAPI specification not found at '$specRelativePath'.",
      );
      return 1;
    }

    final resolver = OpenApiSchemaResolver.fromYaml(
      specFile.readAsStringSync(),
    );

    if (args.flag('list')) {
      _listOperations(resolver, args.option('filter'));
      return 0;
    }

    final feature = (args.option('feature') ?? '').trim();
    final operationQuery = (args.option('operation') ?? '').trim();

    if (feature.isEmpty) {
      context.errorOutput.writeln(
        'ERROR: Missing required option: --feature (-f)',
      );
      context.errorOutput.writeln(
        'Example: mobilekit scaffold data --feature merchant_onboarding --operation merchantOnboarding.applications.submit',
      );
      return 2;
    }

    if (operationQuery.isEmpty) {
      context.errorOutput.writeln(
        'ERROR: Missing required option: --operation (-o)',
      );
      context.errorOutput.writeln(
        'Tip: Use `mobilekit scaffold data --list` to browse available operations.',
      );
      return 2;
    }

    final operation = resolver.findOperation(operationQuery);
    if (operation == null) {
      context.errorOutput.writeln(
        "ERROR: Operation '$operationQuery' not found in OpenAPI specification.",
      );
      context.errorOutput.writeln(
        'Tip: Run `mobilekit scaffold data --list` to view available operations.',
      );
      return 1;
    }

    final dryRun = args.flag('dry-run');
    final force = args.flag('force');
    final noCodegen = args.flag('no-codegen');

    return _generate(
      feature: feature,
      operation: operation,
      resolver: resolver,
      dryRun: dryRun,
      force: force,
      noCodegen: noCodegen,
    );
  }

  void _printUsage(ArgParser parser) {
    context.output.writeln(
      [
        'mobilekit scaffold data',
        '',
        'Scaffolds verified Freezed DTO models, core endpoint constants, and remote',
        'datasource methods directly from the repository pinned OpenAPI contract.',
        '',
        'Usage:',
        '  mobilekit scaffold data --feature <name> --operation <id> [options]',
        '  mobilekit scaffold data --list [--filter <keyword>]',
        '',
        'Options:',
        parser.usage,
      ].join('\n'),
    );
  }

  void _listOperations(OpenApiSchemaResolver resolver, String? filter) {
    final operations = resolver.allOperations();
    final term = (filter ?? '').trim().toLowerCase();

    final filtered = term.isEmpty
        ? operations
        : operations.where((op) {
            return op.operationId.toLowerCase().contains(term) ||
                op.path.toLowerCase().contains(term) ||
                op.tags.any((t) => t.toLowerCase().contains(term));
          }).toList();

    context.output.writeln(
      'Found ${filtered.length} operation(s) in OpenAPI contract:',
    );
    context.output.writeln();
    for (final op in filtered) {
      final authTag = op.requiresAuth ? '[Auth]' : '[Public]';
      context.output.writeln(
        '  ${op.httpMethod.toUpperCase().padRight(7)} ${op.path.padRight(40)} ${op.operationId.padRight(45)} $authTag',
      );
    }
  }

  Future<int> _generate({
    required String feature,
    required OpenApiOperation operation,
    required OpenApiSchemaResolver resolver,
    required bool dryRun,
    required bool force,
    required bool noCodegen,
  }) async {
    final featurePascal = _toPascalCase(feature);
    final opSnake = _deriveOperationSnake(operation.operationId, feature);
    final opPascal = _toPascalCase(opSnake);

    final reqModelName = '${opPascal}RequestModel';
    final resModelName = '${opPascal}ResponseModel';

    final reqSchema =
        resolver.resolveRequestBodyForOperation(
          operation,
          preferredName: reqModelName,
        ) ??
        operation.requestSchema;
    final resSchema =
        resolver.resolveResponseForOperation(
          operation,
          preferredName: resModelName,
        ) ??
        operation.responseSchema;

    final plannedWrites = <String, String>{};

    // 1. Request DTO
    String? reqFileName;
    if (reqSchema != null) {
      reqFileName = '${opSnake}_request_model';
      final relativePath =
          'lib/features/$feature/data/model/remote/$reqFileName.dart';
      final file = context.file(relativePath);
      if (file.existsSync() && !force && !dryRun) {
        context.errorOutput.writeln(
          "ERROR: Target file '$relativePath' already exists. Use --force to overwrite.",
        );
        return 1;
      }
      final content = _generateModelFile(
        schema: reqSchema,
        modelName: reqModelName,
        fileName: reqFileName,
      );
      plannedWrites[relativePath] = content;
    }

    // 2. Response DTO
    String? resFileName;
    if (resSchema != null) {
      resFileName = '${opSnake}_response_model';
      final relativePath =
          'lib/features/$feature/data/model/remote/$resFileName.dart';
      final file = context.file(relativePath);
      if (file.existsSync() && !force && !dryRun) {
        context.errorOutput.writeln(
          "ERROR: Target file '$relativePath' already exists. Use --force to overwrite.",
        );
        return 1;
      }
      final content = _generateModelFile(
        schema: resSchema,
        modelName: resModelName,
        fileName: resFileName,
      );
      plannedWrites[relativePath] = content;
    }

    // 3. Core Endpoint Constant
    final strippedPath = _stripVersionPrefix(operation.path);
    final endpointRelativePath =
        'lib/core/infra/network/endpoints/${feature}_endpoint.dart';
    final endpointFile = context.file(endpointRelativePath);
    final endpointClassName = '${featurePascal}Endpoint';
    final endpointConstantName = _deriveEndpointConstantName(
      strippedPath,
      opSnake,
    );
    final pathParams = _extractPathParameters(strippedPath);

    String resolvedEndpointConstant = endpointConstantName;
    if (endpointFile.existsSync()) {
      final existingContent = endpointFile.readAsStringSync();
      final existingConst = _findExistingEndpointConstant(
        existingContent,
        strippedPath,
      );
      if (existingConst != null) {
        resolvedEndpointConstant = existingConst;
      } else {
        final existingPattern = RegExp(
          r'static\s+(?:const\s+String|String)\s+' +
              RegExp.escape(endpointConstantName) +
              r'[\s=(]',
        );
        if (existingPattern.hasMatch(existingContent)) {
          resolvedEndpointConstant = _toCamelCase(
            '${opSnake}_$endpointConstantName',
          );
        }
        plannedWrites[endpointRelativePath] = _appendEndpointConstant(
          existingContent,
          constantName: endpointConstantName,
          path: strippedPath,
          opSnake: opSnake,
        );
      }
    } else {
      plannedWrites[endpointRelativePath] = _createEndpointFile(
        feature: feature,
        className: endpointClassName,
        constantName: endpointConstantName,
        path: strippedPath,
      );
    }

    // 4. Remote DataSource Method
    final datasourceRelativePath =
        'lib/features/$feature/data/datasource/remote/${feature}_remote_datasource.dart';
    final datasourceFile = context.file(datasourceRelativePath);
    final datasourceClassName = '${featurePascal}RemoteDataSource';
    final methodName = _toCamelCase(opSnake);
    final effectiveResModelName = resSchema != null
        ? resModelName
        : 'ApiNoData';

    final methodCode = _generateDataSourceMethod(
      httpMethod: operation.httpMethod,
      methodName: methodName,
      endpointClass: endpointClassName,
      endpointConstant: resolvedEndpointConstant,
      pathParams: pathParams,
      reqModelName: reqSchema != null ? reqModelName : null,
      resModelName: effectiveResModelName,
      requiresAuth: operation.requiresAuth,
    );

    if (datasourceFile.existsSync()) {
      final existingDs = datasourceFile.readAsStringSync();
      if (!existingDs.contains('$methodName(')) {
        plannedWrites[datasourceRelativePath] = _appendDataSourceMethod(
          existingDs,
          feature: feature,
          methodCode: methodCode,
          reqFileName: reqFileName,
          resFileName: resFileName,
          resModelName: effectiveResModelName,
        );
      }
    } else {
      plannedWrites[datasourceRelativePath] = _createDataSourceFile(
        feature: feature,
        className: datasourceClassName,
        methodCode: methodCode,
        reqFileName: reqFileName,
        resFileName: resFileName,
        resModelName: effectiveResModelName,
      );
    }

    // Report / Write
    context.output.writeln(
      '${dryRun ? "[DRY-RUN] " : ""}Scaffolding data layer for operation: ${operation.operationId}',
    );

    for (final entry in plannedWrites.entries) {
      final path = entry.key;
      final content = entry.value;
      context.output.writeln('  -> $path');

      if (!dryRun) {
        final targetFile = context.file(path);
        targetFile.parent.createSync(recursive: true);
        targetFile.writeAsStringSync(content);
      }
    }

    if (dryRun) {
      context.output.writeln('\nDry run completed. No files were written.');
      return 0;
    }

    // 5. Targeted Codegen Execution
    if (!noCodegen && (reqSchema != null || resSchema != null)) {
      final filter = 'lib/features/$feature/data/model/remote/**';
      context.output.writeln('\nRunning targeted build_runner codegen:');
      final codegenResult = await context.step('Dart build_runner (targeted)', [
        'dart',
        'run',
        'build_runner',
        'build',
        '--build-filter=$filter',
      ]);
      if (codegenResult != 0) {
        context.errorOutput.writeln(
          'WARNING: Targeted build_runner exited with code $codegenResult.',
        );
        context.errorOutput.writeln(
          'You may need to run `dart run build_runner build` manually.',
        );
      }
    } else if (noCodegen) {
      context.output.writeln('\nCodegen skipped (--no-codegen).');
      context.output.writeln(
        'Remember to run: dart run build_runner build --build-filter="lib/features/$feature/data/model/remote/**"',
      );
    }

    context.output.writeln(
      '\nSuccess! Scaffolding completed for ${operation.operationId}.',
    );
    return 0;
  }

  static String _deriveOperationSnake(String operationId, String feature) {
    var raw = operationId;
    final dotParts = raw.split('.');
    if (dotParts.length > 1) {
      final featureClean = feature.replaceAll('_', '').toLowerCase();
      final firstClean = dotParts.first.toLowerCase();
      if (firstClean == featureClean || featureClean.contains(firstClean)) {
        raw = dotParts.skip(1).join('_');
      } else {
        raw = dotParts.join('_');
      }
    }
    return _toSnakeCase(raw);
  }

  static String _deriveEndpointConstantName(
    String strippedPath,
    String opSnake,
  ) {
    final cleanSegments = strippedPath
        .split('/')
        .where((s) => s.isNotEmpty)
        .map((s) => s.replaceAll(RegExp(r'[{}]'), ''))
        .toList();
    if (cleanSegments.isNotEmpty) {
      final last = cleanSegments.last;
      return _toCamelCase(last.replaceAll('-', '_'));
    }
    return _toCamelCase(opSnake);
  }

  static String _stripVersionPrefix(String path) {
    if (path.startsWith('/v1/')) return path.substring(3);
    if (path == '/v1') return '/';
    if (path.startsWith('/v2/')) return path.substring(3);
    return path;
  }

  static List<String> _extractPathParameters(String path) {
    return RegExp(
      r'\{([a-zA-Z0-9_]+)\}',
    ).allMatches(path).map((m) => m.group(1)!).toList();
  }

  static String _createEndpointEntry(String name, String path) {
    final pathParams = _extractPathParameters(path);
    if (pathParams.isEmpty) {
      return "  static const String $name = '$path';\n";
    }
    var interpolated = path;
    for (final param in pathParams) {
      interpolated = interpolated.replaceAll(
        '{$param}',
        '\${Uri.encodeComponent($param)}',
      );
    }
    final paramsDecl = pathParams.map((p) => 'String $p').join(', ');
    return "  static String $name($paramsDecl) => '$interpolated';\n";
  }

  static String? _findExistingEndpointConstant(
    String fileContent,
    String path,
  ) {
    final pathParams = _extractPathParameters(path);
    if (pathParams.isEmpty) {
      final regex = RegExp(
        r'static\s+const\s+String\s+([a-zA-Z0-9_]+)\s*=\s*[\x27\x22]' +
            RegExp.escape(path) +
            r'[\x27\x22]',
      );
      final match = regex.firstMatch(fileContent);
      return match?.group(1);
    } else {
      final basePrefix = path.split('{').first;
      final regex = RegExp(r'static\s+String\s+([a-zA-Z0-9_]+)\s*\([^)]*\)');
      for (final match in regex.allMatches(fileContent)) {
        final name = match.group(1)!;
        if (fileContent.contains('static String $name') &&
            fileContent.contains(basePrefix)) {
          return name;
        }
      }
      return null;
    }
  }

  static String _createEndpointFile({
    required String feature,
    required String className,
    required String constantName,
    required String path,
  }) {
    final entry = _createEndpointEntry(constantName, path);
    return '''/// Endpoint constants for the $feature feature (core API host).
///
/// Paths exclude the `/v1` prefix because the core host base URL already
/// carries it (see `BuildConfigValues._devHosts` / `_stagingHosts`).
class $className {
  $className._();

$entry}
''';
  }

  static String _appendEndpointConstant(
    String fileContent, {
    required String constantName,
    required String path,
    required String opSnake,
  }) {
    final lastBrace = fileContent.lastIndexOf('}');
    if (lastBrace == -1) return fileContent;

    var targetName = constantName;
    final existingPattern = RegExp(
      r'static\s+(?:const\s+String|String)\s+' +
          RegExp.escape(targetName) +
          r'[\s=(]',
    );
    if (existingPattern.hasMatch(fileContent)) {
      targetName = _toCamelCase('${opSnake}_$targetName');
    }

    final entryLine = _createEndpointEntry(targetName, path);
    return fileContent.substring(0, lastBrace) +
        entryLine +
        fileContent.substring(lastBrace);
  }

  static String _generateModelFile({
    required ResolvedSchema schema,
    required String modelName,
    required String fileName,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    );
    buffer.writeln();
    buffer.writeln("part '$fileName.freezed.dart';");
    buffer.writeln("part '$fileName.g.dart';");
    buffer.writeln();
    buffer.writeln('// ignore_for_file: invalid_annotation_target');
    buffer.writeln();

    // Collect all transitive sub-schemas and enums
    final allSubSchemas = <String, ResolvedSchema>{};
    final allEnums = <String, ResolvedEnum>{};

    void collect(ResolvedSchema s) {
      for (final enumDef in s.enums) {
        allEnums[enumDef.name] = enumDef;
      }
      for (final sub in s.subSchemas) {
        if (!allSubSchemas.containsKey(sub.name)) {
          allSubSchemas[sub.name] = sub;
          collect(sub);
        }
      }
    }

    collect(schema);

    // Enums
    for (final enumDef in allEnums.values) {
      buffer.writeln('enum ${enumDef.name} {');
      for (final val in enumDef.values) {
        final id = _toCamelCase(val.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'));
        buffer.writeln("  @JsonValue('$val')");
        buffer.writeln('  $id,');
      }
      buffer.writeln('}');
      buffer.writeln();
    }

    // Sub-schemas
    for (final sub in allSubSchemas.values) {
      if (sub.name == modelName) continue;
      _writeFreezedClass(buffer, sub.name, sub.properties);
      buffer.writeln();
    }

    // Main schema
    _writeFreezedClass(buffer, modelName, schema.properties);

    return buffer.toString();
  }

  static void _writeFreezedClass(
    StringBuffer buffer,
    String name,
    List<ResolvedProperty> properties,
  ) {
    buffer.writeln('@freezed');
    buffer.writeln('abstract class $name with _\$$name {');
    buffer.writeln('  @JsonSerializable(includeIfNull: false)');
    buffer.writeln('  const factory $name({');
    for (final prop in properties) {
      final prefix = prop.isRequired ? 'required ' : '';
      buffer.writeln('    $prefix${prop.dartType} ${prop.name},');
    }
    buffer.writeln('  }) = _$name;');
    buffer.writeln();
    buffer.writeln('  const $name._();');
    buffer.writeln();
    buffer.writeln('  factory $name.fromJson(Map<String, dynamic> json) =>');
    buffer.writeln('      _\$${name}FromJson(json);');
    buffer.writeln('}');
  }

  static String _generateDataSourceMethod({
    required String httpMethod,
    required String methodName,
    required String endpointClass,
    required String endpointConstant,
    required List<String> pathParams,
    required String? reqModelName,
    required String resModelName,
    required bool requiresAuth,
  }) {
    final methodLower = httpMethod.toLowerCase();
    final helperMethod = methodLower == 'get' ? 'getOne' : methodLower;
    final hasBody = reqModelName != null;
    final hasPathParams = pathParams.isNotEmpty;

    String paramSignature = '';
    if (hasPathParams && hasBody) {
      final pList = pathParams.map((p) => 'required String $p').join(', ');
      paramSignature = '{$pList, required $reqModelName requestModel}';
    } else if (hasPathParams) {
      if (pathParams.length == 1) {
        paramSignature = 'String ${pathParams.first}';
      } else {
        final pList = pathParams.map((p) => 'required String $p').join(', ');
        paramSignature = '{$pList}';
      }
    } else if (hasBody) {
      paramSignature = '$reqModelName requestModel';
    }

    final endpointCall = hasPathParams
        ? '$endpointClass.$endpointConstant(${pathParams.join(', ')})'
        : '$endpointClass.$endpointConstant';

    final dataArg = hasBody ? '      data: requestModel.toJson(),\n' : '';
    final parserArg = (resModelName != 'dynamic' && resModelName != 'ApiNoData')
        ? '      parser: $resModelName.fromJson,\n'
        : '';

    return '''  Future<ApiResponse<$resModelName>> $methodName($paramSignature) async {
    Log.info('Executing $methodName', name: _tag);

    final response = await _apiHelper.$helperMethod<$resModelName>(
      $endpointCall,
$dataArg      host: ApiHost.core,
      requiresAuth: $requiresAuth,
      throwOnError: false,
$parserArg    );
    return response;
  }''';
  }

  static String _createDataSourceFile({
    required String feature,
    required String className,
    required String methodCode,
    required String? reqFileName,
    required String? resFileName,
    required String resModelName,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      "import 'package:mobile_core_kit/core/foundation/config/api_host.dart';",
    );
    buffer.writeln(
      "import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';",
    );
    buffer.writeln(
      "import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';",
    );
    buffer.writeln(
      "import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';",
    );
    if (resModelName == 'ApiNoData') {
      buffer.writeln(
        "import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';",
      );
    }
    buffer.writeln(
      "import 'package:mobile_core_kit/core/infra/network/endpoints/${feature}_endpoint.dart';",
    );
    if (reqFileName != null) {
      buffer.writeln(
        "import 'package:mobile_core_kit/features/$feature/data/model/remote/$reqFileName.dart';",
      );
    }
    if (resFileName != null && resFileName != reqFileName) {
      buffer.writeln(
        "import 'package:mobile_core_kit/features/$feature/data/model/remote/$resFileName.dart';",
      );
    }
    buffer.writeln();
    buffer.writeln('class $className {');
    buffer.writeln('  $className(this._apiHelper);');
    buffer.writeln("  final String _tag = '$className';");
    buffer.writeln();
    buffer.writeln('  final ApiHelper _apiHelper;');
    buffer.writeln();
    buffer.writeln(methodCode);
    buffer.writeln('}');
    buffer.writeln();
    return buffer.toString();
  }

  static String _appendDataSourceMethod(
    String existingContent, {
    required String feature,
    required String methodCode,
    required String? reqFileName,
    required String? resFileName,
    required String resModelName,
  }) {
    var content = existingContent;

    // Collect all existing imports and required imports
    final importRegex = RegExp(r"import\s+['\x22][^'\x22]+['\x22];\s*");
    final allImports = importRegex
        .allMatches(content)
        .map((m) => m.group(0)!.trim())
        .toSet();

    allImports.add(
      "import 'package:mobile_core_kit/core/foundation/config/api_host.dart';",
    );
    allImports.add(
      "import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';",
    );
    allImports.add(
      "import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';",
    );
    allImports.add(
      "import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';",
    );
    allImports.add(
      "import 'package:mobile_core_kit/core/infra/network/endpoints/${feature}_endpoint.dart';",
    );

    if (resModelName == 'ApiNoData') {
      allImports.add(
        "import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';",
      );
    }

    if (reqFileName != null) {
      allImports.add(
        "import 'package:mobile_core_kit/features/$feature/data/model/remote/$reqFileName.dart';",
      );
    }
    if (resFileName != null) {
      allImports.add(
        "import 'package:mobile_core_kit/features/$feature/data/model/remote/$resFileName.dart';",
      );
    }

    // Strip imports from content body
    content = content.replaceAll(importRegex, '').trimLeft();

    // Prepend alphabetically sorted imports
    final sortedImports = allImports.toList()..sort();
    content = '${sortedImports.join('\n')}\n\n$content';

    // Ensure _tag definition exists in class
    if (!content.contains(RegExp(r'final\s+String\s+_tag\s*='))) {
      final classRegex = RegExp(r'class\s+([a-zA-Z0-9_]+)\s*\{');
      final classMatch = classRegex.firstMatch(content);
      if (classMatch != null) {
        final className = classMatch.group(1)!;
        final ctorRegex = RegExp(
          r'(\s+' + RegExp.escape(className) + r'\s*\([^)]*\)\s*;)',
        );
        final ctorMatch = ctorRegex.firstMatch(content);
        if (ctorMatch != null) {
          final pos = ctorMatch.end;
          content =
              '${content.substring(0, pos)}\n  final String _tag = \'$className\';${content.substring(pos)}';
        } else {
          final classOpen = classMatch.end;
          content =
              '${content.substring(0, classOpen)}\n  final String _tag = \'$className\';\n${content.substring(classOpen)}';
        }
      }
    }

    final lastBrace = content.lastIndexOf('}');
    if (lastBrace == -1) return content;

    return '${content.substring(0, lastBrace)}\n$methodCode\n${content.substring(lastBrace)}';
  }

  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  static String _toPascalCase(String input) {
    final parts = input.split(RegExp(r'[._\-\s]+'));
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part.isEmpty) continue;
      buffer.write(part[0].toUpperCase());
      if (part.length > 1) {
        final isAllCaps = part == part.toUpperCase();
        final rest = isAllCaps
            ? part.substring(1).toLowerCase()
            : part.substring(1);
        buffer.write(rest);
      }
    }
    return buffer.toString();
  }

  static String _toSnakeCase(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '.' || char == '-' || char == ' ') {
        buffer.write('_');
      } else if (char.toUpperCase() == char &&
          char.toLowerCase() != char &&
          i > 0 &&
          input[i - 1] != '_' &&
          input[i - 1] != '.') {
        buffer.write('_${char.toLowerCase()}');
      } else {
        buffer.write(char.toLowerCase());
      }
    }
    return buffer.toString().replaceAll(RegExp(r'_+'), '_');
  }
}
