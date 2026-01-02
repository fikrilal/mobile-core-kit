import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../utilities/log_utils.dart';
import '../navigation/navigation_service.dart';
import 'deep_link_parser.dart';
import 'deep_link_telemetry.dart';
import 'pending_deep_link_controller.dart';
import 'deep_link_source.dart';

/// Listens to platform deep link sources and drives router navigation.
///
/// This should be started once after the first frame (non-blocking).
///
/// Behavior:
/// - HTTPS links are forwarded to the router; `appRedirect` handles gating and
///   capture/resume semantics.
/// - If navigation is not yet possible (no navigator context), fall back to
///   persisting the intent so it can resume later.
class DeepLinkListener {
  DeepLinkListener({
    required DeepLinkSource source,
    required NavigationService navigation,
    required PendingDeepLinkController deepLinks,
    required DeepLinkParser parser,
    DeepLinkTelemetry? telemetry,
  }) : _source = source,
       _navigation = navigation,
       _deepLinks = deepLinks,
       _parser = parser,
       _telemetry = telemetry;

  final DeepLinkSource _source;
  final NavigationService _navigation;
  final PendingDeepLinkController _deepLinks;
  final DeepLinkParser _parser;
  final DeepLinkTelemetry? _telemetry;

  StreamSubscription<Uri>? _subscription;
  Future<void>? _startFuture;

  Future<void> start() {
    final existing = _startFuture;
    if (existing != null) return existing;

    final future = _startInternal();
    _startFuture = future;
    return future;
  }

  Future<void> _startInternal() async {
    if (kIsWeb) return;

    _subscription = _source.uriStream.listen(
      (uri) => unawaited(_handleUri(uri)),
      onError: (Object e, StackTrace st) {
        Log.error('Deep link stream error', e, st, false, 'DeepLink');
      },
    );
  }

  Future<void> _handleUri(Uri uri) async {
    if (uri.hasScheme && uri.scheme != 'https') return;

    final canNavigate = _navigation.rootNavigatorKey.currentContext != null;
    final rawLocation = uri.toString();

    if (uri.hasScheme) {
      final mapped = _parser.parseExternalUri(uri);
      if (mapped == null) {
        final telemetry = _telemetry;
        if (telemetry != null) {
          unawaited(
            telemetry.trackRejectedExternalUri(
              uri,
              source: 'https',
              reason: 'not_allowlisted',
            ),
          );
        }
        return;
      }

      final telemetry = _telemetry;
      if (telemetry != null) {
        unawaited(telemetry.trackReceivedExternalUri(uri, source: 'https'));
      }

      if (canNavigate) {
        // Preserve the absolute URI so redirect logic can apply canonicalization
        // and gating semantics (startup/onboarding/auth).
        _navigation.go(rawLocation);
        return;
      }

      await _deepLinks.setPendingLocation(
        mapped,
        source: 'https',
        reason: 'no_navigator',
      );
      return;
    }

    if (!_parser.isAllowedInternalLocation(rawLocation)) {
      return;
    }

    if (canNavigate) {
      _navigation.go(rawLocation);
      return;
    }

    await _deepLinks.setPendingLocation(
      rawLocation,
      source: 'router',
      reason: 'no_navigator',
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
