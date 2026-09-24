import 'package:yaml/yaml.dart';

/// Represents an OpenAPI 3.0 operation parsed from the contract spec.
class OpenApiOperation {
  const OpenApiOperation({
    required this.operationId,
    required this.httpMethod,
    required this.path,
    required this.summary,
    required this.tags,
    required this.requiresAuth,
    this.requestSchema,
    this.responseSchema,
  });

  final String operationId;
  final String httpMethod;
  final String path;
  final String summary;
  final List<String> tags;
  final bool requiresAuth;
  final ResolvedSchema? requestSchema;
  final ResolvedSchema? responseSchema;
}

/// Represents an enum extracted from a schema property.
class ResolvedEnum {
  const ResolvedEnum({
    required this.name,
    required this.values,
  });

  final String name;
  final List<String> values;
}

/// Represents a property on a model.
class ResolvedProperty {
  const ResolvedProperty({
    required this.name,
    required this.jsonKey,
    required this.dartType,
    required this.isRequired,
    required this.isNullable,
    this.enumDefinition,
  });

  final String name;
  final String jsonKey;
  final String dartType;
  final bool isRequired;
  final bool isNullable;
  final ResolvedEnum? enumDefinition;
}

/// Represents a resolved object schema to be generated with Freezed.
class ResolvedSchema {
  const ResolvedSchema({
    required this.name,
    required this.properties,
    required this.subSchemas,
    required this.enums,
  });

  final String name;
  final List<ResolvedProperty> properties;
  final List<ResolvedSchema> subSchemas;
  final List<ResolvedEnum> enums;
}

/// Resolves OpenAPI 3.0 specifications into Dart/Freezed model representations.
class OpenApiSchemaResolver {
  OpenApiSchemaResolver(this.spec);

  factory OpenApiSchemaResolver.fromYaml(String yamlContent) {
    final raw = loadYaml(yamlContent);
    final spec = _deepConvert(raw) as Map<String, dynamic>;
    return OpenApiSchemaResolver(spec);
  }

  final Map<String, dynamic> spec;

  Map<String, dynamic> get _componentsSchemas {
    final components = spec['components'];
    if (components is Map<String, dynamic>) {
      final schemas = components['schemas'];
      if (schemas is Map<String, dynamic>) {
        return schemas;
      }
    }
    return const {};
  }

  /// Finds an operation by operationId (exact or normalized) or by 'METHOD /path'.
  OpenApiOperation? findOperation(String query) {
    final trimmed = query.trim();
    final lower = trimmed.toLowerCase();

    for (final op in allOperations()) {
      if (op.operationId.toLowerCase() == lower) {
        return op;
      }
      final pathMethod = '${op.httpMethod} ${op.path}'.toLowerCase();
      if (pathMethod == lower || op.path.toLowerCase() == lower) {
        return op;
      }
    }
    return null;
  }

  /// Lists all operations in the specification.
  List<OpenApiOperation> allOperations() {
    final results = <OpenApiOperation>[];
    final paths = spec['paths'];
    if (paths is! Map<String, dynamic>) return results;

    const httpMethods = ['get', 'post', 'put', 'delete', 'patch'];

    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final pathItem = pathEntry.value;
      if (pathItem is! Map<String, dynamic>) continue;

      for (final method in httpMethods) {
        final opMap = pathItem[method];
        if (opMap is! Map<String, dynamic>) continue;

        final rawOpId = opMap['operationId'] as String?;
        final operationId = rawOpId ?? '${method}_${_sanitizeName(path)}';
        final summary = (opMap['summary'] as String?) ?? '';
        final rawTags = opMap['tags'];
        final tags = rawTags is List ? rawTags.map((e) => e.toString()).toList() : <String>[];

        final security = opMap['security'];
        final requiresAuth = security is List && security.isNotEmpty;

        final requestSchema = _resolveRequestBody(opMap, operationId);
        final responseSchema = _resolveResponse(opMap, operationId);

        results.add(
          OpenApiOperation(
            operationId: operationId,
            httpMethod: method,
            path: path,
            summary: summary,
            tags: tags,
            requiresAuth: requiresAuth,
            requestSchema: requestSchema,
            responseSchema: responseSchema,
          ),
        );
      }
    }
    return results;
  }

  /// Resolves the request body schema for an operation using a preferred model name.
  ResolvedSchema? resolveRequestBodyForOperation(
    OpenApiOperation op, {
    required String preferredName,
  }) {
    final paths = spec['paths'];
    if (paths is! Map<String, dynamic>) return null;
    final pathItem = paths[op.path];
    if (pathItem is! Map<String, dynamic>) return null;
    final opMap = pathItem[op.httpMethod];
    if (opMap is! Map<String, dynamic>) return null;
    return _resolveRequestBody(opMap, preferredName);
  }

  /// Resolves the response schema for an operation using a preferred model name.
  ResolvedSchema? resolveResponseForOperation(
    OpenApiOperation op, {
    required String preferredName,
  }) {
    final paths = spec['paths'];
    if (paths is! Map<String, dynamic>) return null;
    final pathItem = paths[op.path];
    if (pathItem is! Map<String, dynamic>) return null;
    final opMap = pathItem[op.httpMethod];
    if (opMap is! Map<String, dynamic>) return null;
    return _resolveResponse(opMap, preferredName);
  }

  ResolvedSchema? _resolveRequestBody(Map<String, dynamic> opMap, String opId) {
    final reqBody = opMap['requestBody'];
    if (reqBody is! Map<String, dynamic>) return null;

    final content = reqBody['content'];
    if (content is! Map<String, dynamic>) return null;

    final jsonContent = content['application/json'];
    if (jsonContent is! Map<String, dynamic>) return null;

    final schemaRaw = jsonContent['schema'];
    if (schemaRaw is! Map<String, dynamic>) return null;

    final defaultName = opId.endsWith('RequestModel')
        ? opId
        : '${_toPascalCase(opId)}RequestModel';
    return _resolveSchema(schemaRaw, defaultName);
  }

  ResolvedSchema? _resolveResponse(Map<String, dynamic> opMap, String opId) {
    final responses = opMap['responses'];
    if (responses is! Map<String, dynamic>) return null;

    final resRaw = responses['200'] ?? responses['201'] ?? responses['default'];
    if (resRaw is! Map<String, dynamic>) return null;

    final content = resRaw['content'];
    if (content is! Map<String, dynamic>) return null;

    final jsonContent = content['application/json'];
    if (jsonContent is! Map<String, dynamic>) return null;

    final schemaRaw = jsonContent['schema'];
    if (schemaRaw is! Map<String, dynamic>) return null;

    final defaultName = opId.endsWith('ResponseModel')
        ? opId
        : '${_toPascalCase(opId)}ResponseModel';
    return _resolveSchema(schemaRaw, defaultName);
  }

  ResolvedSchema _resolveSchema(
    Map<String, dynamic> rawSchema,
    String preferredName, [
    Set<String>? visitedRefs,
  ]) {
    final visited = visitedRefs ?? <String>{};
    var schemaMap = rawSchema;
    var name = preferredName;

    if (schemaMap.containsKey('allOf')) {
      final allOf = schemaMap['allOf'];
      if (allOf is List) {
        for (final item in allOf) {
          if (item is Map<String, dynamic> && item.containsKey(r'$ref')) {
            schemaMap = Map<String, dynamic>.from(schemaMap)..addAll(item);
            break;
          }
        }
      }
    }

    if (schemaMap.containsKey(r'$ref')) {
      final ref = schemaMap[r'$ref'] as String;
      final refName = ref.split('/').last;
      name = _normalizeModelName(refName);
      if (visited.contains(ref)) {
        return ResolvedSchema(
          name: name,
          properties: const [],
          subSchemas: const [],
          enums: const [],
        );
      }
      visited.add(ref);
      schemaMap = _lookupRef(ref);
    }

    final properties = <ResolvedProperty>[];
    final subSchemas = <ResolvedSchema>[];
    final enums = <ResolvedEnum>[];

    final rawProps = schemaMap['properties'];
    final rawRequired = schemaMap['required'];
    final requiredSet = rawRequired is List
        ? rawRequired.map((e) => e.toString()).toSet()
        : <String>{};

    if (rawProps is Map<String, dynamic>) {
      for (final entry in rawProps.entries) {
        final propName = entry.key;
        final propSchema = entry.value;
        if (propSchema is! Map<String, dynamic>) continue;

        final isRequired = requiredSet.contains(propName);
        final isNullable = propSchema['nullable'] == true;

        final propResult = _resolveProperty(
          propName: propName,
          propSchema: propSchema,
          parentName: name,
          isRequired: isRequired,
          isNullable: isNullable,
          visited: visited,
        );

        properties.add(propResult.property);
        if (propResult.subSchema != null) {
          subSchemas.add(propResult.subSchema!);
        }
        if (propResult.enumDef != null) {
          enums.add(propResult.enumDef!);
        }
      }
    }

    return ResolvedSchema(
      name: name,
      properties: properties,
      subSchemas: subSchemas,
      enums: enums,
    );
  }

  _PropertyResolveResult _resolveProperty({
    required String propName,
    required Map<String, dynamic> propSchema,
    required String parentName,
    required bool isRequired,
    required bool isNullable,
    required Set<String> visited,
  }) {
    var schema = propSchema;
    final camelName = _toCamelCase(propName);

    if (schema.containsKey('allOf')) {
      final allOf = schema['allOf'];
      if (allOf is List) {
        for (final item in allOf) {
          if (item is Map<String, dynamic> && item.containsKey(r'$ref')) {
            schema = Map<String, dynamic>.from(schema)..addAll(item);
            break;
          }
        }
      }
    }

    if (schema.containsKey(r'$ref')) {
      final ref = schema[r'$ref'] as String;
      final refName = ref.split('/').last;
      final subModelName = _normalizeModelName(refName);
      final resolvedSub = _resolveSchema(schema, subModelName, visited);
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: '$subModelName$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
        subSchema: resolvedSub,
      );
    }

    final type = schema['type'] as String? ?? 'object';

    if (type == 'string') {
      final rawEnum = schema['enum'];
      if (rawEnum is List && rawEnum.isNotEmpty) {
        final enumName = '${parentName}${_toPascalCase(propName)}';
        final enumDef = ResolvedEnum(
          name: enumName,
          values: rawEnum.map((e) => e.toString()).toList(),
        );
        final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
        return _PropertyResolveResult(
          property: ResolvedProperty(
            name: camelName,
            jsonKey: propName,
            dartType: '$enumName$nullableSuffix',
            isRequired: isRequired,
            isNullable: isNullable,
            enumDefinition: enumDef,
          ),
          enumDef: enumDef,
        );
      }

      final format = schema['format'] as String?;
      final dartType = format == 'date-time' ? 'DateTime' : 'String';
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: '$dartType$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
      );
    }

    if (type == 'integer') {
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: 'int$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
      );
    }

    if (type == 'number') {
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: 'double$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
      );
    }

    if (type == 'boolean') {
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: 'bool$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
      );
    }

    if (type == 'array') {
      var items = schema['items'];
      if (items is Map<String, dynamic>) {
        if (items.containsKey('allOf')) {
          final allOf = items['allOf'];
          if (allOf is List) {
            for (final item in allOf) {
              if (item is Map<String, dynamic> && item.containsKey(r'$ref')) {
                items = Map<String, dynamic>.from(items!)..addAll(item);
                break;
              }
            }
          }
        }
        if (items!.containsKey(r'$ref')) {
          final ref = items[r'$ref'] as String;
          final refName = ref.split('/').last;
          final subModelName = _normalizeModelName(refName);
          final resolvedSub = _resolveSchema(items, subModelName, visited);
          final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
          return _PropertyResolveResult(
            property: ResolvedProperty(
              name: camelName,
              jsonKey: propName,
              dartType: 'List<$subModelName>$nullableSuffix',
              isRequired: isRequired,
              isNullable: isNullable,
            ),
            subSchema: resolvedSub,
          );
        }

        final itemType = items['type'] as String? ?? 'dynamic';
        final itemDartType = switch (itemType) {
          'string' => 'String',
          'integer' => 'int',
          'number' => 'double',
          'boolean' => 'bool',
          _ => 'dynamic',
        };
        final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
        return _PropertyResolveResult(
          property: ResolvedProperty(
            name: camelName,
            jsonKey: propName,
            dartType: 'List<$itemDartType>$nullableSuffix',
            isRequired: isRequired,
            isNullable: isNullable,
          ),
        );
      }
      final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
      return _PropertyResolveResult(
        property: ResolvedProperty(
          name: camelName,
          jsonKey: propName,
          dartType: 'List<dynamic>$nullableSuffix',
          isRequired: isRequired,
          isNullable: isNullable,
        ),
      );
    }

    // Default object or unknown
    final nullableSuffix = (!isRequired || isNullable) ? '?' : '';
    return _PropertyResolveResult(
      property: ResolvedProperty(
        name: camelName,
        jsonKey: propName,
        dartType: 'Map<String, dynamic>$nullableSuffix',
        isRequired: isRequired,
        isNullable: isNullable,
      ),
    );
  }

  Map<String, dynamic> _lookupRef(String ref) {
    if (ref.startsWith('#/components/schemas/')) {
      final key = ref.substring('#/components/schemas/'.length);
      final found = _componentsSchemas[key];
      if (found is Map<String, dynamic>) {
        return found;
      }
    }
    return const {};
  }

  static String _normalizeModelName(String rawName) {
    var name = rawName;
    if (name.endsWith('Dto')) {
      name = name.substring(0, name.length - 3);
    }
    if (!name.endsWith('Model')) {
      name = '${name}Model';
    }
    return _toPascalCase(name);
  }

  static String _sanitizeName(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
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
        final rest =
            isAllCaps ? part.substring(1).toLowerCase() : part.substring(1);
        buffer.write(rest);
      }
    }
    return buffer.toString();
  }
}

class _PropertyResolveResult {
  const _PropertyResolveResult({
    required this.property,
    this.subSchema,
    this.enumDef,
  });

  final ResolvedProperty property;
  final ResolvedSchema? subSchema;
  final ResolvedEnum? enumDef;
}

dynamic _deepConvert(dynamic value) {
  if (value is YamlMap) {
    return value.map((k, v) => MapEntry(k.toString(), _deepConvert(v)));
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _deepConvert(v)));
  }
  if (value is YamlList) {
    return value.map(_deepConvert).toList();
  }
  if (value is List) {
    return value.map(_deepConvert).toList();
  }
  return value;
}
