import '../../services/analytics/analytics_tracker.dart';
import '../../utilities/log_utils.dart';
import 'deep_link_intent.dart';

class DeepLinkTelemetry {
  DeepLinkTelemetry({
    required AnalyticsTracker analytics,
    DateTime Function()? now,
  }) : _analytics = analytics,
       _now = now ?? DateTime.now;

  static const String tag = 'DeepLink';

  final AnalyticsTracker _analytics;
  final DateTime Function() _now;

  Future<void> trackReceivedExternalUri(
    Uri uri, {
    required String source,
  }) async {
    final scheme = uri.scheme;
    final host = uri.host.toLowerCase();
    final path = _normalizePath(uri.path);
    final queryKeyCount = uri.queryParametersAll.keys.length;

    Log.debug(
      'Received external deep link: $scheme://$host$path (queryKeys=$queryKeyCount)',
      name: tag,
    );

    await _analytics.trackDeepLinkReceived(
      source: source,
      scheme: scheme,
      host: host,
      path: path,
      queryKeyCount: queryKeyCount,
    );
  }

  Future<void> trackRejectedExternalUri(
    Uri uri, {
    required String source,
    required String reason,
  }) async {
    final scheme = uri.scheme;
    final host = uri.host.toLowerCase();
    final path = _normalizePath(uri.path);
    final queryKeyCount = uri.queryParametersAll.keys.length;

    Log.warning(
      'Rejected external deep link: $scheme://$host$path (reason=$reason)',
      name: tag,
    );

    await _analytics.trackDeepLinkRejected(
      source: source,
      scheme: scheme,
      host: host,
      path: path,
      reason: reason,
      queryKeyCount: queryKeyCount,
    );
  }

  Future<void> trackPendingSet(
    DeepLinkIntent intent, {
    required String reason,
    DeepLinkIntent? previous,
  }) async {
    final source = intent.source ?? 'unknown';
    final path = _safePathFromLocation(intent.location);
    final wasReplaced =
        previous != null && previous.location.isNotEmpty && previous.location != intent.location;

    Log.debug(
      'Pending deep link set: $path (source=$source, reason=$reason, replaced=$wasReplaced)',
      name: tag,
    );

    await _analytics.trackDeepLinkPendingSet(
      source: source,
      path: path,
      reason: reason,
      wasReplaced: wasReplaced,
    );
  }

  Future<void> trackResumed(DeepLinkIntent intent) async {
    final source = intent.source ?? 'unknown';
    final path = _safePathFromLocation(intent.location);
    final latencyMs = _now().difference(intent.receivedAt).inMilliseconds;

    Log.info(
      'Resuming deep link: $path (source=$source, latencyMs=$latencyMs)',
      name: tag,
    );

    await _analytics.trackDeepLinkResumed(
      source: source,
      path: path,
      latencyMs: latencyMs,
    );
  }

  Future<void> trackCleared(
    DeepLinkIntent intent, {
    required String reason,
  }) async {
    final source = intent.source ?? 'unknown';
    final path = _safePathFromLocation(intent.location);

    Log.info(
      'Cleared pending deep link: $path (source=$source, reason=$reason)',
      name: tag,
    );

    await _analytics.trackDeepLinkCleared(
      source: source,
      path: path,
      reason: reason,
    );
  }

  static String _safePathFromLocation(String location) {
    final uri = Uri.parse(location);
    return _normalizePath(uri.path);
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    if (path == '/') return '/';
    if (path.endsWith('/')) return path.substring(0, path.length - 1);
    return path;
  }
}
