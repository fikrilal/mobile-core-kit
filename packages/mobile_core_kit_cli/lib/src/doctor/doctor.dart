import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/doctor/residual_defaults.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';
import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:path/path.dart' as p;

enum DoctorCheckStatus {
  ok,
  warning,
  error;

  String get label => switch (this) {
    DoctorCheckStatus.ok => 'OK',
    DoctorCheckStatus.warning => 'WARN',
    DoctorCheckStatus.error => 'ERROR',
  };
}

class DoctorCheck {
  const DoctorCheck({
    required this.label,
    required this.status,
    required this.detail,
  });

  final String label;
  final DoctorCheckStatus status;
  final String detail;
}

class DoctorReport {
  const DoctorReport({required this.repositoryPath, required this.checks});

  final String? repositoryPath;
  final List<DoctorCheck> checks;

  bool get hasErrors =>
      checks.any((check) => check.status == DoctorCheckStatus.error);

  void writeTo(StringSink output) {
    output.writeln('mobilekit doctor');
    output.writeln('Repository: ${repositoryPath ?? 'not found'}');

    for (final check in checks) {
      output.writeln(
        '- [${check.status.label}] ${check.label}: ${check.detail}',
      );
    }

    output.writeln();
    output.writeln(
      hasErrors ? 'Doctor found problems.' : 'Doctor checks passed.',
    );
  }
}

class Doctor {
  Doctor({
    RepositoryRootLocator? rootLocator,
    ExecutableFinder? executableFinder,
    CommandPlatform? platform,
  }) : _rootLocator = rootLocator ?? const RepositoryRootLocator(),
       _executableFinder = executableFinder ?? ExecutableFinder(),
       _platform = platform ?? CommandPlatform.host();

  final RepositoryRootLocator _rootLocator;
  final ExecutableFinder _executableFinder;
  final CommandPlatform _platform;

  DoctorReport inspect({Directory? startDirectory}) {
    final root = _rootLocator.find(startDirectory: startDirectory);
    if (root == null) {
      return const DoctorReport(
        repositoryPath: null,
        checks: [
          DoctorCheck(
            label: 'repository root',
            status: DoctorCheckStatus.error,
            detail: 'Run this command from inside the repository.',
          ),
        ],
      );
    }

    final checks = <DoctorCheck>[
      DoctorCheck(
        label: 'repository root',
        status: DoctorCheckStatus.ok,
        detail: root.path,
      ),
      _fvmrcCheck(root),
    ];
    checks.addAll(_templateIntegrationChecks(root));

    final commandRunner = CommandRunner(
      rootDirectory: root,
      platform: _platform,
    );
    for (final executable in ['dart', 'flutter']) {
      checks.add(_sdkCommandCheck(executable, commandRunner));
    }
    for (final executable in ['git', 'npx']) {
      checks.add(_pathCommandCheck(executable));
    }

    return DoctorReport(repositoryPath: root.path, checks: checks);
  }

  List<DoctorCheck> _templateIntegrationChecks(Directory root) {
    final manifestFile = File(p.join(root.path, projectManifestRelativePath));
    if (!manifestFile.existsSync()) return const [];

    final TemplateManifest manifest;
    try {
      manifest = TemplateManifest.fromFile(manifestFile);
    } on FormatException catch (error) {
      return [
        DoctorCheck(
          label: 'template manifest',
          status: DoctorCheckStatus.error,
          detail: error.message,
        ),
      ];
    }

    return [
      ..._residualDefaultChecks(root, manifest.customization),
      _deepLinkPolicyCheck(root, manifest.customization),
      _firebasePolicyCheck(root, manifest.customization),
    ];
  }

  List<DoctorCheck> _residualDefaultChecks(
    Directory root,
    TemplateCustomization customization,
  ) {
    final findings = ResidualDefaultScanner().scan(root, customization);
    if (findings.isEmpty) {
      return const [
        DoctorCheck(
          label: 'residual defaults',
          status: DoctorCheckStatus.ok,
          detail: 'No known template defaults remain in application surfaces.',
        ),
      ];
    }

    return [
      for (final severity in ResidualDefaultSeverity.values)
        if (findings.any((finding) => finding.severity == severity))
          _residualDefaultCheck(
            severity,
            findings.where((finding) => finding.severity == severity).toList(),
          ),
    ];
  }

  DoctorCheck _residualDefaultCheck(
    ResidualDefaultSeverity severity,
    List<ResidualDefaultFinding> findings,
  ) {
    final details = findings
        .map((finding) {
          final preview = finding.paths.take(3).join(', ');
          final suffix = finding.paths.length > 3
              ? ' (+${finding.paths.length - 3} more)'
              : '';
          return '${finding.marker}: ${finding.detail} [$preview$suffix]';
        })
        .join(' | ');
    return DoctorCheck(
      label: 'residual defaults (${severity.label})',
      status: switch (severity) {
        ResidualDefaultSeverity.blocking => DoctorCheckStatus.error,
        ResidualDefaultSeverity.reviewRequired => DoctorCheckStatus.warning,
        ResidualDefaultSeverity.historical => DoctorCheckStatus.ok,
      },
      detail: details,
    );
  }

  DoctorCheck _deepLinkPolicyCheck(
    Directory root,
    TemplateCustomization customization,
  ) {
    final android = File(
      p.join(root.path, 'android/app/src/main/AndroidManifest.xml'),
    );
    final ios = File(p.join(root.path, 'ios/Runner/Runner.entitlements'));
    final androidContents = android.existsSync()
        ? android.readAsStringSync()
        : '';
    final iosContents = ios.existsSync() ? ios.readAsStringSync() : '';
    final androidHost = RegExp(
      r'android:host="([^"]+)"',
    ).firstMatch(androidContents)?.group(1);
    final iosHost = RegExp(
      r'<string>applinks:([^<]+)</string>',
    ).firstMatch(iosContents)?.group(1);
    final androidClaim = androidContents.contains('android:autoVerify="true"');
    final iosClaim = iosContents.contains('applinks:');
    final runtimeEnv = File(p.join(root.path, '.env/dev.yaml'));
    final runtimeContents = runtimeEnv.existsSync()
        ? runtimeEnv.readAsStringSync()
        : '';
    final runtimeHasHost =
        customization.deepLinkHost != null &&
        runtimeContents.contains(customization.deepLinkHost!);

    if (customization.deepLinkMode == DeepLinkMode.disabled) {
      if (androidClaim || iosClaim) {
        return const DoctorCheck(
          label: 'deep-link policy',
          status: DoctorCheckStatus.error,
          detail: 'Disabled deep links still have native platform claims.',
        );
      }
      if (runtimeContents.contains('deepLinkAllowedHosts:') &&
          !runtimeContents.contains('deepLinkAllowedHosts: []')) {
        return const DoctorCheck(
          label: 'deep-link policy',
          status: DoctorCheckStatus.warning,
          detail:
              'Disabled deep links have a non-empty ignored runtime host list; clear .env/*.yaml and regenerate BuildConfig.',
        );
      }
      return const DoctorCheck(
        label: 'deep-link policy',
        status: DoctorCheckStatus.ok,
        detail: 'Disabled; no native deep-link claims are active.',
      );
    }

    final host = customization.deepLinkHost;
    if (host == null || androidHost != host || iosHost != host) {
      return DoctorCheck(
        label: 'deep-link policy',
        status: DoctorCheckStatus.error,
        detail:
            'Enabled host $host is not applied consistently to Android and iOS claims.',
      );
    }
    if (!runtimeHasHost) {
      return DoctorCheck(
        label: 'deep-link policy',
        status: DoctorCheckStatus.warning,
        detail:
            'Native claims use $host, but ignored .env/dev.yaml does not yet contain it.',
      );
    }
    return DoctorCheck(
      label: 'deep-link policy',
      status: DoctorCheckStatus.ok,
      detail: 'Enabled for $host across native claims and runtime policy.',
    );
  }

  DoctorCheck _firebasePolicyCheck(
    Directory root,
    TemplateCustomization customization,
  ) {
    final demo = const ['firebase.json', 'lib/firebase_options.dart'].any((
      path,
    ) {
      final file = File(p.join(root.path, path));
      return file.existsSync() &&
          file.readAsStringSync().contains('mobile-kit-5f1d6');
    });
    return switch (customization.firebaseMode) {
      FirebaseMode.keepDemo => DoctorCheck(
        label: 'Firebase policy',
        status: DoctorCheckStatus.error,
        detail: demo
            ? 'BLOCKING production readiness: Firebase still points to the template demo project.'
            : 'keep-demo is selected; verify the retained Firebase configuration before production.',
      ),
      FirebaseMode.configure => DoctorCheck(
        label: 'Firebase policy',
        status: demo ? DoctorCheckStatus.warning : DoctorCheckStatus.ok,
        detail: demo
            ? 'Run `flutterfire configure`; the template demo options are still present.'
            : 'External Firebase configuration is not managed by mobilekit.',
      ),
      FirebaseMode.disabled => const DoctorCheck(
        label: 'Firebase policy',
        status: DoctorCheckStatus.ok,
        detail: 'Disabled by policy; Firebase code and files were preserved.',
      ),
    };
  }

  DoctorCheck _fvmrcCheck(Directory root) {
    final file = File(p.join(root.path, '.fvmrc'));
    if (!file.existsSync()) {
      return const DoctorCheck(
        label: '.fvmrc',
        status: DoctorCheckStatus.warning,
        detail: 'Pinned Flutter version file is missing.',
      );
    }

    try {
      final decoded = jsonDecode(file.readAsStringSync());
      final version = decoded is Map ? decoded['flutter'] : null;
      if (version is String && version.trim().isNotEmpty) {
        return DoctorCheck(
          label: '.fvmrc',
          status: DoctorCheckStatus.ok,
          detail: 'Flutter ${version.trim()}',
        );
      }
    } on FormatException {
      // Fall through to the warning below.
    }

    return const DoctorCheck(
      label: '.fvmrc',
      status: DoctorCheckStatus.warning,
      detail: 'Flutter version could not be read.',
    );
  }

  DoctorCheck _sdkCommandCheck(String executable, CommandRunner commandRunner) {
    final resolved = commandRunner.resolve(executable);
    if (resolved.isPinned) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.ok,
        detail: 'Pinned SDK: ${resolved.executable}',
      );
    }

    final pathExecutable = _executableFinder.find(executable);
    if (pathExecutable != null) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.warning,
        detail: 'Using PATH fallback: $pathExecutable',
      );
    }

    return DoctorCheck(
      label: executable,
      status: DoctorCheckStatus.error,
      detail: 'Not found in the pinned SDK or PATH.',
    );
  }

  DoctorCheck _pathCommandCheck(String executable) {
    final resolved = _executableFinder.find(executable);
    if (resolved != null) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.ok,
        detail: resolved,
      );
    }

    return DoctorCheck(
      label: executable,
      status: DoctorCheckStatus.error,
      detail: 'Not found in PATH.',
    );
  }
}
