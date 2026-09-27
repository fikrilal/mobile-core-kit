import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:mobile_core_kit_cli/src/workflows/scaffold_all_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ScaffoldAllWorkflow', () {
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
              required:
                - customerId
                - amount
      responses:
        "201":
          content:
            application/json:
              schema:
                type: object
                properties:
                  orderId:
                    type: string
                required:
                  - orderId
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
''';

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('scaffold_all_test_');
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
      final workflow = ScaffoldAllWorkflow(context);

      final code = await workflow.run(['--help']);
      expect(code, 0);
      expect(output.toString(), contains('mobilekit scaffold all'));
      expect(output.toString(), contains('--feature'));
      expect(output.toString(), contains('--operation'));
    });

    test('fails with code 2 if required options are missing', () async {
      final context = createContext();
      final workflow = ScaffoldAllWorkflow(context);

      final code1 = await workflow.run(['--openapi-spec', 'openapi.yaml']);
      expect(code1, 2);
      expect(
        errorOutput.toString(),
        contains('Missing required option: --feature'),
      );

      errorOutput.clear();
      final code2 = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
      ]);
      expect(code2, 2);
      expect(
        errorOutput.toString(),
        contains('Missing required option: --operation'),
      );
    });

    test(
      'dry run previews both feature and data layer without writing files',
      () async {
        final context = createContext();
        final workflow = ScaffoldAllWorkflow(context);

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
        final out = output.toString();
        expect(out, contains('[1/2] Checking Feature Architecture Skeleton'));
        expect(out, contains('Dry run: would scaffold feature "orders"'));
        expect(out, contains('[2/2] Scaffolding OpenAPI Data Layer'));
        expect(
          out,
          contains(
            '[DRY-RUN] Scaffolding data layer for operation: orders.create',
          ),
        );
        expect(out, contains('Dry run completed. No files were written.'));

        // Check no files were created
        expect(
          Directory(p.join(tempDir.path, 'lib', 'features', 'orders'))
              .existsSync(),
          isFalse,
        );
        expect(executedCommands, isEmpty);
      },
    );

    test(
      'scaffolds new feature skeleton and OpenAPI data layer end-to-end',
      () async {
        final context = createContext();
        final workflow = ScaffoldAllWorkflow(context);

        final code = await workflow.run([
          '--openapi-spec',
          'openapi.yaml',
          '--feature',
          'orders',
          '--operation',
          'orders.create',
        ]);

        expect(code, 0);
        final out = output.toString();
        expect(out, contains('Scaffolding feature skeleton for "orders"...'));
        expect(
          out,
          contains('Scaffolding data layer for operation: orders.create'),
        );
        expect(out, contains('All scaffolding completed successfully'));

        // Verify Feature Skeleton files
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'features',
              'orders',
              'presentation',
              'pages',
              'orders_page.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'features',
              'orders',
              'di',
              'orders_module.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'navigation',
              'orders',
              'orders_routes.dart',
            ),
          ).existsSync(),
          isTrue,
        );

        // Verify OpenAPI Data Layer files
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'features',
              'orders',
              'data',
              'model',
              'remote',
              'create_request_model.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'features',
              'orders',
              'data',
              'model',
              'remote',
              'create_response_model.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'core',
              'infra',
              'network',
              'endpoints',
              'orders_endpoint.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib',
              'features',
              'orders',
              'data',
              'datasource',
              'remote',
              'orders_remote_datasource.dart',
            ),
          ).existsSync(),
          isTrue,
        );

        // Verify codegen was invoked
        expect(executedCommands, isNotEmpty);
        expect(executedCommands.first, contains('build_runner'));
      },
    );

    test('skips feature skeleton if feature already exists and only scaffolds data', () async {
      final context = createContext();

      // Pre-create the feature directory
      final featureDir = Directory(
        p.join(tempDir.path, 'lib', 'features', 'orders'),
      );
      featureDir.createSync(recursive: true);
      File(p.join(featureDir.path, 'existing_file.txt'))
          .writeAsStringSync('keep me');

      final workflow = ScaffoldAllWorkflow(context);
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
      final out = output.toString();
      expect(
        out,
        contains(
          'Feature "lib/features/orders" already exists; skipping skeleton creation.',
        ),
      );
      expect(out, contains('Scaffolding data layer for operation: orders.get'));

      // Check existing file was not deleted
      expect(
        File(p.join(featureDir.path, 'existing_file.txt')).existsSync(),
        isTrue,
      );

      // Check data layer file was created
      expect(
        File(
          p.join(
            tempDir.path,
            'lib',
            'features',
            'orders',
            'data',
            'model',
            'remote',
            'get_response_model.dart',
          ),
        ).existsSync(),
        isTrue,
      );

      // No codegen because of --no-codegen
      expect(executedCommands, isEmpty);
    });

    test('fails if operation is not found in OpenAPI spec', () async {
      final context = createContext();
      final workflow = ScaffoldAllWorkflow(context);

      final code = await workflow.run([
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'nonexistent.op',
      ]);

      expect(code, 1);
      expect(
        errorOutput.toString(),
        contains(
          "Operation 'nonexistent.op' not found in OpenAPI specification",
        ),
      );
    });

    test('MobilekitCli dispatches scaffold all subcommand', () async {
      File(p.join(tempDir.path, 'pubspec.yaml'))
          .writeAsStringSync('name: test_repo\n');
      File(p.join(tempDir.path, '.mobilekit', 'template.yaml'))
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
        );

      final cli = MobilekitCli(
        currentDirectory: tempDir,
        output: output,
        errorOutput: errorOutput,
        commandExecutor: (command) async {
          executedCommands.add(command);
          return 0;
        },
      );

      final code = await cli.run([
        'scaffold',
        'all',
        '--openapi-spec',
        'openapi.yaml',
        '--feature',
        'orders',
        '--operation',
        'orders.create',
        '--dry-run',
      ]);

      expect(code, 0);
      expect(
        output.toString(),
        contains('Dry run: would scaffold feature "orders"'),
      );
      expect(
        output.toString(),
        contains(
          '[DRY-RUN] Scaffolding data layer for operation: orders.create',
        ),
      );
    });
  });
}
