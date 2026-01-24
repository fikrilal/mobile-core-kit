import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> argv) async {
  exitCode = await _run(argv);
}

Future<int> _run(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Print outputs; does not write files.',
    )
    ..addOption(
      'feature',
      abbr: 'f',
      help: 'Feature name (snake_case), e.g. "review".',
    )
    ..addOption(
      'slice',
      abbr: 's',
      help:
          'Optional slice name (snake_case), e.g. "list". Defaults to feature name.',
    );

  final args = parser.parse(argv);
  if (args.flag('help')) {
    stdout.writeln(
      [
        'scaffold_feature.dart',
        '',
        'Creates a standard feature skeleton under lib/features/<feature>/ and',
        'lib/navigation/<feature>/ with a Cubit-first slice scaffold.',
        '',
        'Usage:',
        '  dart run tool/scaffold_feature.dart --feature review',
        '  dart run tool/scaffold_feature.dart --feature review --slice list',
        '',
        'Options:',
        parser.usage,
      ].join('\n'),
    );
    return 0;
  }

  final dryRun = args.flag('dry-run');
  final feature = (args.option('feature') ?? '').trim();
  final slice = (args.option('slice') ?? '').trim();

  if (feature.isEmpty) {
    stderr.writeln('Missing required option: --feature');
    stderr.writeln('');
    stderr.writeln(
      'Example: dart run tool/scaffold_feature.dart --feature review',
    );
    return 2;
  }

  if (!_isValidSnakeCase(feature)) {
    stderr.writeln('Invalid feature name "$feature". Expected snake_case.');
    stderr.writeln('Example: review, profile_draft, payment_methods');
    return 2;
  }

  final effectiveSlice = slice.isEmpty ? feature : slice;
  if (!_isValidSnakeCase(effectiveSlice)) {
    stderr.writeln(
      'Invalid slice name "$effectiveSlice". Expected snake_case.',
    );
    stderr.writeln('Example: list, details, edit_profile');
    return 2;
  }

  final featureDir = p.join('lib', 'features', feature);
  final navDir = p.join('lib', 'navigation', feature);
  if (Directory(featureDir).existsSync() || Directory(navDir).existsSync()) {
    stderr.writeln('Refusing to scaffold: feature already exists.');
    stderr.writeln('- $featureDir');
    stderr.writeln('- $navDir');
    return 2;
  }

  final baseSnake = effectiveSlice == feature
      ? feature
      : '${feature}_$effectiveSlice';
  final basePascal = _toPascalCase(baseSnake);
  final featurePascal = _toPascalCase(feature);
  final featureRoutesClass = '${featurePascal}Routes';
  final featureModuleClass = '${featurePascal}Module';

  final routeConstName = _toCamelCase(effectiveSlice);
  final routePath = effectiveSlice == feature
      ? '/$feature'
      : '/$feature/$effectiveSlice';
  final routeName = effectiveSlice == feature
      ? feature
      : '$feature-$effectiveSlice';

  final cubitClass = '${basePascal}Cubit';
  final stateClass = '${basePascal}State';
  final statusEnum = '${basePascal}Status';
  final pageClass = '${basePascal}Page';

  final cubitDir = p.join(featureDir, 'presentation', 'cubit', effectiveSlice);

  final moduleFile = p.join(featureDir, 'di', '${feature}_module.dart');
  final routesFile = p.join(navDir, '${feature}_routes.dart');
  final routesListFile = p.join(navDir, '${feature}_routes_list.dart');
  final pageFile = p.join(
    featureDir,
    'presentation',
    'pages',
    '${baseSnake}_page.dart',
  );
  final cubitFile = p.join(cubitDir, '${baseSnake}_cubit.dart');
  final stateFile = p.join(cubitDir, '${baseSnake}_state.dart');

  final failureFile = p.join(
    featureDir,
    'domain',
    'failure',
    '${feature}_failure.dart',
  );
  final repositoryFile = p.join(
    featureDir,
    'domain',
    'repository',
    '${feature}_repository.dart',
  );
  final remoteDatasourceFile = p.join(
    featureDir,
    'data',
    'datasource',
    'remote',
    '${feature}_remote_datasource.dart',
  );
  final repositoryImplFile = p.join(
    featureDir,
    'data',
    'repository',
    '${feature}_repository_impl.dart',
  );

  final cubitTestFile = p.join(
    'test',
    'features',
    feature,
    'presentation',
    'cubit',
    effectiveSlice,
    '${baseSnake}_cubit_test.dart',
  );

  final cubitImport = _toPackageImport(cubitFile);
  final stateImport = _toPackageImport(stateFile);
  final pageImport = _toPackageImport(pageFile);
  final routesImport = _toPackageImport(routesFile);
  final failureImport = _toPackageImport(failureFile);
  final repositoryImport = _toPackageImport(repositoryFile);
  final remoteDatasourceImport = _toPackageImport(remoteDatasourceFile);

  final outputs = <String, String>{
    // Feature DI
    moduleFile: _featureModuleStub(
      moduleClass: featureModuleClass,
      cubitClass: cubitClass,
      cubitImport: cubitImport,
    ),

    // Navigation
    routesFile: _routesStub(
      featureRoutesClass: featureRoutesClass,
      routeConstName: routeConstName,
      routePath: routePath,
    ),
    routesListFile: _routesListStub(
      feature: feature,
      featureRoutesClass: featureRoutesClass,
      routeConstName: routeConstName,
      routeName: routeName,
      cubitClass: cubitClass,
      cubitImport: cubitImport,
      pageClass: pageClass,
      pageImport: pageImport,
      routesImport: routesImport,
    ),

    // Presentation
    pageFile: _pageStub(
      pageClass: pageClass,
      cubitClass: cubitClass,
      stateClass: stateClass,
      statusEnum: statusEnum,
      cubitImport: cubitImport,
      stateImport: stateImport,
    ),
    cubitFile: _cubitStub(
      cubitClass: cubitClass,
      stateClass: stateClass,
      statusEnum: statusEnum,
      stateImport: stateImport,
    ),
    stateFile: _stateStub(stateClass: stateClass, statusEnum: statusEnum),

    // Domain (minimal placeholders)
    failureFile: _failureStub(featurePascal),
    repositoryFile: _repositoryStub(
      featurePascal: featurePascal,
      feature: feature,
      failureImport: failureImport,
    ),

    // Data (minimal placeholders)
    remoteDatasourceFile: _remoteDatasourceStub(featurePascal),
    repositoryImplFile: _repositoryImplStub(
      featurePascal: featurePascal,
      feature: feature,
      remoteDatasourceImport: remoteDatasourceImport,
      failureImport: failureImport,
      repositoryImport: repositoryImport,
    ),

    // Tests (minimal skeleton)
    cubitTestFile: _cubitTestStub(
      cubitClass: cubitClass,
      statusEnum: statusEnum,
      cubitImport: cubitImport,
    ),
  };

  final directories = <String>[
    featureDir,
    p.join(featureDir, 'analytics'),
    p.join(featureDir, 'data', 'datasource', 'local'),
    p.join(featureDir, 'data', 'datasource', 'remote'),
    p.join(featureDir, 'data', 'error'),
    p.join(featureDir, 'data', 'model', 'local'),
    p.join(featureDir, 'data', 'model', 'remote'),
    p.join(featureDir, 'data', 'repository'),
    p.join(featureDir, 'di'),
    p.join(featureDir, 'domain', 'entity'),
    p.join(featureDir, 'domain', 'failure'),
    p.join(featureDir, 'domain', 'repository'),
    p.join(featureDir, 'domain', 'usecase'),
    p.join(featureDir, 'domain', 'value'),
    p.join(featureDir, 'presentation', 'cubit'),
    cubitDir,
    p.join(featureDir, 'presentation', 'pages'),
    p.join(featureDir, 'presentation', 'widgets', 'skeleton'),
    navDir,
    p.join(
      'test',
      'features',
      feature,
      'presentation',
      'cubit',
      effectiveSlice,
    ),
  ];

  // Preflight: refuse if any file already exists.
  for (final path in outputs.keys) {
    if (File(path).existsSync()) {
      stderr.writeln('Refusing to scaffold: file already exists: $path');
      return 2;
    }
  }

  if (dryRun) {
    stdout.writeln(
      'Dry run: would scaffold feature "$feature" (slice: "$effectiveSlice").',
    );
    stdout.writeln('');
    stdout.writeln('Directories:');
    for (final dir in directories) {
      stdout.writeln('- $dir');
    }
    stdout.writeln('');
    stdout.writeln('Files:');
    final files = outputs.keys.toList()..sort();
    for (final file in files) {
      stdout.writeln('- $file');
    }
    return 0;
  }

  for (final dir in directories) {
    Directory(dir).createSync(recursive: true);
  }
  for (final entry in outputs.entries) {
    File(entry.key).writeAsStringSync(entry.value);
  }

  stdout.writeln('Scaffolded feature "$feature" (slice: "$effectiveSlice").');
  stdout.writeln('');
  stdout.writeln('Generated:');
  stdout.writeln('- $featureDir');
  stdout.writeln('- $navDir');
  stdout.writeln('');
  stdout.writeln('Next steps:');
  stdout.writeln(
    '- Register DI: call `$featureModuleClass.register(getIt)` from `lib/core/di/service_locator.dart`.',
  );
  stdout.writeln(
    '- Add routes: include `${feature}Routes` from `$navDir/${feature}_routes_list.dart` in `lib/navigation/app_router.dart`.',
  );
  stdout.writeln('- Run verify: `dart run tool/verify.dart --env dev`.');
  stdout.writeln('');
  final l10nPrefix = _toCamelCase(baseSnake);
  stdout.writeln(
    'L10n checklist (add keys in all locales, then `flutter gen-l10n`):',
  );
  stdout.writeln('- ${l10nPrefix}Title');
  stdout.writeln('- ${l10nPrefix}Body');

  return 0;
}

bool _isValidSnakeCase(String value) {
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  if (!regex.hasMatch(value)) return false;
  if (value.contains('__')) return false;
  if (value.endsWith('_')) return false;
  return true;
}

String _toPascalCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty);
  return parts.map(_capitalize).join();
}

String _toCamelCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final first = parts.first;
  final rest = parts.skip(1).map(_capitalize);
  return [first, ...rest].join();
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String _normalizeImportPath(String value) => value.replaceAll('\\', '/');

String _toPackageImport(String filePath) {
  final normalized = _normalizeImportPath(filePath);
  final withoutLib = normalized.startsWith('lib/')
      ? normalized.substring('lib/'.length)
      : normalized;
  return 'package:mobile_core_kit/$withoutLib';
}

String _featureModuleStub({
  required String moduleClass,
  required String cubitClass,
  required String cubitImport,
}) {
  return '''
import 'package:get_it/get_it.dart';

import '$cubitImport';

class $moduleClass {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<$cubitClass>()) {
      getIt.registerFactory<$cubitClass>(() => $cubitClass());
    }
  }
}
''';
}

String _routesStub({
  required String featureRoutesClass,
  required String routeConstName,
  required String routePath,
}) {
  return '''
class $featureRoutesClass {
  $featureRoutesClass._();

  static const String $routeConstName = '$routePath';
}
''';
}

String _routesListStub({
  required String feature,
  required String featureRoutesClass,
  required String routeConstName,
  required String routeName,
  required String cubitClass,
  required String cubitImport,
  required String pageClass,
  required String pageImport,
  required String routesImport,
}) {
  return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/di/service_locator.dart';
import '$cubitImport';
import '$pageImport';
import '$routesImport';

final List<GoRoute> ${feature}Routes = [
  GoRoute(
    path: $featureRoutesClass.$routeConstName,
    name: '$routeName',
    builder: (context, state) => BlocProvider<$cubitClass>(
      create: (_) => locator<$cubitClass>()..load(),
      child: const $pageClass(),
    ),
  ),
];
''';
}

String _pageStub({
  required String pageClass,
  required String cubitClass,
  required String stateClass,
  required String statusEnum,
  required String cubitImport,
  required String stateImport,
}) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
import '$cubitImport';
import '$stateImport';

class $pageClass extends StatelessWidget {
  const $pageClass({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      surface: SurfaceKind.dashboard,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: BlocBuilder<$cubitClass, $stateClass>(
          builder: (context, state) {
            switch (state.status) {
              case $statusEnum.initial:
              case $statusEnum.loading:
                return _buildLoadingState(context);
              case $statusEnum.success:
                return _buildSuccessState(context);
              case $statusEnum.failure:
                return _buildErrorState(context, state.errorMessage);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppDotWave(),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodyMedium(context.l10n.commonLoading),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText.titleLarge(context.l10n.commonOk),
        const SizedBox(height: AppSpacing.space12),
        AppButton.primary(
          text: context.l10n.commonOk,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText.titleLarge(context.l10n.errorsUnexpected),
        const SizedBox(height: AppSpacing.space8),
        AppText.bodyMedium(message, textAlign: TextAlign.center),
      ],
    );
  }
}
''';
}

String _cubitStub({
  required String cubitClass,
  required String stateClass,
  required String statusEnum,
  required String stateImport,
}) {
  return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '$stateImport';

class $cubitClass extends Cubit<$stateClass> {
  $cubitClass() : super($stateClass.initial());

  Future<void> load() async {
    if (state.status == $statusEnum.loading) return;
    emit(state.copyWith(status: $statusEnum.loading, errorMessage: null));

    // TODO: Replace with real orchestration (use cases / repositories).
    emit(state.copyWith(status: $statusEnum.success));
  }
}
''';
}

String _stateStub({required String stateClass, required String statusEnum}) {
  return '''
enum $statusEnum { initial, loading, success, failure }

class $stateClass {
  const $stateClass({required this.status, this.errorMessage});

  final $statusEnum status;
  final String? errorMessage;

  factory $stateClass.initial() =>
      const $stateClass(status: $statusEnum.initial);

  $stateClass copyWith({$statusEnum? status, String? errorMessage}) {
    return $stateClass(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
''';
}

String _failureStub(String featurePascal) {
  final failureClass = '${featurePascal}Failure';
  return '''
sealed class $failureClass {
  const $failureClass();
}

final class ${failureClass}Unexpected extends $failureClass {
  const ${failureClass}Unexpected([this.message = '']);

  final String message;
}
''';
}

String _remoteDatasourceStub(String featurePascal) {
  final datasourceClass = '${featurePascal}RemoteDataSource';
  return '''
import 'package:mobile_core_kit/core/network/api/api_helper.dart';

class $datasourceClass {
  $datasourceClass(this._apiHelper);

  final ApiHelper _apiHelper;

  // TODO: Add real endpoints here.
}
''';
}

String _repositoryStub({
  required String featurePascal,
  required String feature,
  required String failureImport,
}) {
  final repositoryClass = '${featurePascal}Repository';
  return '''
import 'package:fpdart/fpdart.dart';

import '$failureImport';

abstract class $repositoryClass {
  Future<Either<${featurePascal}Failure, Unit>> placeholder();
}
''';
}

String _repositoryImplStub({
  required String featurePascal,
  required String feature,
  required String remoteDatasourceImport,
  required String failureImport,
  required String repositoryImport,
}) {
  final repositoryClass = '${featurePascal}Repository';
  final implClass = '${featurePascal}RepositoryImpl';
  final failureClass = '${featurePascal}Failure';
  final datasourceClass = '${featurePascal}RemoteDataSource';

  return '''
import 'package:fpdart/fpdart.dart';

import '$remoteDatasourceImport';
import '$failureImport';
import '$repositoryImport';

class $implClass implements $repositoryClass {
  $implClass(this._remote);

  final $datasourceClass _remote;

  @override
  Future<Either<$failureClass, Unit>> placeholder() async {
    try {
      // TODO: Call remote datasource + map results.
      return right(unit);
    } catch (e) {
      return left(${failureClass}Unexpected(e.toString()));
    }
  }
}
''';
}

String _cubitTestStub({
  required String cubitClass,
  required String statusEnum,
  required String cubitImport,
}) {
  return '''
import 'package:flutter_test/flutter_test.dart';

import '$cubitImport';

void main() {
  test('$cubitClass starts in initial state', () async {
    final cubit = $cubitClass();
    addTearDown(cubit.close);

    expect(cubit.state.status, $statusEnum.initial);
  });
}
''';
}
