import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/text_scale_policy.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// Standard test app shell for integration tests.
///
/// Keeps localization wiring consistent with the production app so widgets that
/// access `context.l10n` always have delegates available in test runtime.
Widget buildIntegrationTestApp({
  required RouterConfig<Object> routerConfig,
  TransitionBuilder? builder,
}) {
  return MaterialApp.router(
    routerConfig: routerConfig,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) {
      final adaptiveChild = AdaptiveScope(
        navigationPolicy: const NavigationPolicy.standard(),
        textScalePolicy: const TextScalePolicy.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 2.0,
        ),
        child: child ?? const SizedBox.shrink(),
      );

      return builder?.call(context, adaptiveChild) ?? adaptiveChild;
    },
  );
}
