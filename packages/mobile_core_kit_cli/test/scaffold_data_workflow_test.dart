import 'dart:io';

import 'package:mobile_core_kit_cli/src/contracts/openapi_schema_resolver.dart';
import 'package:mobile_core_kit_cli/src/workflows/scaffold_data_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ScaffoldDataWorkflow', () {
    late Directory tempDir;
    late List<List<String>> executedCommands;
    late StringBuffer output;
    late StringBuffer errorOutput;

    const testSpecYaml = '''
openapi: 3.0.0
paths:
  /v1/orders:
    post:
      operationId: orders.create
      summary: Create a new order
      tags:
        - Orders
      security:
        - access-token: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                customerId:
                  type: string
                amount:
                  type: number
                status:
                  type: string
                  enum:
                    - PENDING
                    - PAID
                    - CANCELLED
                items:
                  type: array
                  items:
                    \$ref: '#/components/schemas/OrderItem'
              required:
                - customerId
                - amount
                - status
                - items
      responses:
        "201":
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/OrderEnvelope'
  /v1/orders/{id}:
    get:
      operationId: orders.get
      summary: Get order details
      tags:
        - Orders
      responses:
        "200":
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                  status:
                    type: string
components:
  schemas:
    OrderItem:
      type: object
      properties:
        productId:
          type: string
        quantity:
          type: integer
      required:
        - productId
        - quantity
    OrderEnvelope:
      type: object
      properties:
        orderId:
          type: string
        createdAt:
          type: string
          format: date-time
      required:
        - orderId
        - createdAt
''';

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('scaffold_data_test_');
      executedCommands = [];
      output = StringBuffer();
      errorOutput = StringBuffer();

      // Write test OpenAPI spec
      final specFile = File(p.join(tempDir.path, 'openapi.yaml'));
      specFile.writeAsStringSync(testSpecYaml);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    WorkflowContext createContext() {
      return WorkflowContext(
        rootDirectory: tempDir,
        output: output,
        errorOutput: errorOutput,
        execute: (command) async {
          executedCommands.add(command);
          return 0;
        },
      );
    }

    test('prints usage when --help is passed', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run(['--help']);
      expect(code, 0);
      expect(output.toString(), contains('mobilekit scaffold data'));
      expect(output.toString(), contains('--feature'));
      expect(output.toString(), contains('--operation'));
    });

    test('lists operations with --list and optional --filter', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--list',
        '--filter',
        'create',
      ]);
      expect(code, 0);
      expect(output.toString(), contains('Found 1 operation(s)'));
      expect(output.toString(), contains('orders.create'));
      expect(output.toString(), isNot(contains('orders.get')));
    });

    test('fails with code 2 if required options are missing', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code1 = await workflow.run(['--openapi-spec', 'openapi.yaml']);
      expect(code1, 2);
      expect(errorOutput.toString(), contains('Missing required option: --feature'));

      errorOutput.clear();
      final code2 = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
      ]);
      expect(code2, 2);
      expect(errorOutput.toString(), contains('Missing required option: --operation'));
    });

    test('fails with code 1 if operation is not found in OpenAPI spec', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'nonexistent.op',
      ]);
      expect(code, 1);
      expect(errorOutput.toString(), contains("Operation 'nonexistent.op' not found"));
    });

    test('dry run prints planned files without writing to disk or running codegen', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--dry-run',
      ]);
      expect(code, 0);
      expect(output.toString(), contains('[DRY-RUN] Scaffolding data layer'));
      expect(output.toString(), contains('create_request_model.dart'));
      expect(output.toString(), contains('create_response_model.dart'));
      expect(executedCommands, isEmpty);

      // Verify no files written
      final modelDir = Directory(p.join(tempDir.path, 'lib', 'features', 'orders', 'data', 'model', 'remote'));
      expect(modelDir.existsSync(), isFalse);
    });

    test('generates Freezed models, core endpoint, and datasource method', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
      ]);
      expect(code, 0);

      // 1. Verify Request Model
      final reqFile = File(
        p.join(tempDir.path, 'lib', 'features', 'orders', 'data', 'model', 'remote', 'create_request_model.dart'),
      );
      expect(reqFile.existsSync(), isTrue);
      final reqContent = reqFile.readAsStringSync();
      expect(reqContent, contains("part 'create_request_model.freezed.dart';"));
      expect(reqContent, contains("part 'create_request_model.g.dart';"));
      expect(reqContent, contains('abstract class CreateRequestModel with _\$CreateRequestModel'));
      expect(reqContent, contains('required String customerId,'));
      expect(reqContent, contains('required double amount,'));
      expect(reqContent, contains('enum CreateRequestModelStatus {'));
      expect(reqContent, contains("@JsonValue('PENDING')"));
      expect(reqContent, contains('required List<OrderItemModel> items,'));
      expect(reqContent, contains('abstract class OrderItemModel with _\$OrderItemModel'));

      // 2. Verify Response Model
      final resFile = File(
        p.join(tempDir.path, 'lib', 'features', 'orders', 'data', 'model', 'remote', 'create_response_model.dart'),
      );
      expect(resFile.existsSync(), isTrue);
      final resContent = resFile.readAsStringSync();
      expect(resContent, contains('abstract class CreateResponseModel with _\$CreateResponseModel'));
      expect(resContent, contains('required String orderId,'));
      expect(resContent, contains('required DateTime createdAt,'));

      // 3. Verify Core Endpoint File
      final endpointFile = File(
        p.join(tempDir.path, 'lib', 'core', 'infra', 'network', 'endpoints', 'orders_endpoint.dart'),
      );
      expect(endpointFile.existsSync(), isTrue);
      final endpointContent = endpointFile.readAsStringSync();
      expect(endpointContent, contains('class OrdersEndpoint {'));
      expect(endpointContent, contains("static const String orders = '/orders';"));

      // 4. Verify Remote DataSource
      final dsFile = File(
        p.join(tempDir.path, 'lib', 'features', 'orders', 'data', 'datasource', 'remote', 'orders_remote_datasource.dart'),
      );
      expect(dsFile.existsSync(), isTrue);
      final dsContent = dsFile.readAsStringSync();
      expect(dsContent, contains('class OrdersRemoteDataSource {'));
      expect(dsContent, contains('Future<ApiResponse<CreateResponseModel>> create(CreateRequestModel requestModel) async'));
      expect(dsContent, contains('OrdersEndpoint.orders'));
      expect(dsContent, contains('requiresAuth: true'));

      // 5. Verify targeted build_runner was invoked
      expect(executedCommands.length, 1);
      final cmd = executedCommands.first;
      expect(cmd, contains('build_runner'));
      expect(cmd, contains('--build-filter=lib/features/orders/data/model/remote/**'));
    });

    test('refuses to overwrite existing model files unless --force is specified', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      // Run first time
      final code1 = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--no-codegen',
      ]);
      expect(code1, 0);

      // Run second time without --force
      errorOutput.clear();
      final code2 = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--no-codegen',
      ]);
      expect(code2, 1);
      expect(errorOutput.toString(), contains('already exists. Use --force to overwrite.'));

      // Run with --force
      errorOutput.clear();
      final code3 = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--force',
        '--no-codegen',
      ]);
      expect(code3, 0);
    });

    test('--no-codegen skips running build_runner', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--no-codegen',
      ]);
      expect(code, 0);
      expect(executedCommands, isEmpty);
      expect(output.toString(), contains('Codegen skipped (--no-codegen)'));
    });

    test('appends new endpoint constant and datasource method to existing files', () async {
      final context = createContext();
      final workflow = ScaffoldDataWorkflow(context);

      // Scaffold first operation (orders.create)
      await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--no-codegen',
      ]);

      // Scaffold second operation (orders.get)
      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.get',
        '--no-codegen',
      ]);
      expect(code, 0);

      // Verify endpoint file has both constants
      final endpointFile = File(
        p.join(tempDir.path, 'lib', 'core', 'infra', 'network', 'endpoints', 'orders_endpoint.dart'),
      );
      final endpointContent = endpointFile.readAsStringSync();
      expect(endpointContent, contains("static const String orders = '/orders';"));
      expect(
        endpointContent,
        contains("static String id(String id) => '/orders/\${Uri.encodeComponent(id)}';"),
      );

      // Verify datasource file has both methods
      final dsFile = File(
        p.join(tempDir.path, 'lib', 'features', 'orders', 'data', 'datasource', 'remote', 'orders_remote_datasource.dart'),
      );
      final dsContent = dsFile.readAsStringSync();
      expect(dsContent, contains('Future<ApiResponse<CreateResponseModel>> create('));
      expect(dsContent, contains('Future<ApiResponse<GetResponseModel>> get(String id)'));
    });
  });

  group('OpenApiSchemaResolver', () {
    test('resolves operations from backend.openapi.yaml', () {
      final file = File('docs/contracts/openapi/backend.openapi.yaml');
      expect(file.existsSync(), isTrue);

      final resolver = OpenApiSchemaResolver.fromYaml(file.readAsStringSync());
      final operations = resolver.allOperations();
      expect(operations, isNotEmpty);

      final loginOp = resolver.findOperation('auth.password.login');
      expect(loginOp, isNotNull);
      expect(loginOp!.httpMethod, 'post');
      expect(loginOp.path, '/v1/auth/password/login');
      expect(loginOp.requiresAuth, isFalse);
      expect(loginOp.requestSchema, isNotNull);
      expect(loginOp.requestSchema!.properties, isNotEmpty);
      expect(
        loginOp.requestSchema!.properties.any((p) => p.name == 'email'),
        isTrue,
      );

      final submitOp =
          resolver.findOperation('merchantOnboarding.applications.submit');
      expect(submitOp, isNotNull);
      expect(submitOp!.httpMethod, 'post');
      expect(submitOp.requiresAuth, isTrue);
      expect(submitOp.requestSchema, isNotNull);
      expect(submitOp.responseSchema, isNotNull);
    });

    test('resolves string enums into ResolvedEnum with type-safe properties', () {
      const sampleYaml = '''
openapi: 3.0.0
paths:
  /v1/test:
    post:
      operationId: test.create
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  enum:
                    - PENDING
                    - ACTIVE
                    - SUSPENDED
              required:
                - status
      responses:
        "200":
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
''';
      final resolver = OpenApiSchemaResolver.fromYaml(sampleYaml);
      final op = resolver.findOperation('test.create');
      expect(op, isNotNull);
      final req = op!.requestSchema!;
      expect(req.properties.length, 1);
      final statusProp = req.properties.first;
      expect(statusProp.name, 'status');
      expect(statusProp.dartType, 'TestCreateRequestModelStatus');
      expect(statusProp.enumDefinition, isNotNull);
      expect(statusProp.enumDefinition!.values,
          ['PENDING', 'ACTIVE', 'SUSPENDED']);
    });

    test('resolves transitive nested schemas and allOf references', () {
      final file = File('docs/contracts/openapi/backend.openapi.yaml');
      expect(file.existsSync(), isTrue);
      final resolver = OpenApiSchemaResolver.fromYaml(file.readAsStringSync());
      final op = resolver.findOperation('auth.password.login');
      expect(op, isNotNull);
      final res = op!.responseSchema!;
      expect(res.properties.first.name, 'data');
      expect(res.properties.first.dartType, 'AuthResultWithMeModel');

      // Check transitive sub-schemas exist
      final subNames = res.subSchemas.map((s) => s.name).toSet();
      expect(subNames.contains('AuthResultWithMeModel'), isTrue);
      final authResult = res.subSchemas.firstWhere((s) => s.name == 'AuthResultWithMeModel');
      final authResultSubNames = authResult.subSchemas.map((s) => s.name).toSet();
      expect(authResultSubNames.contains('MeModel'), isTrue);
    });
  });
}

