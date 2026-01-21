import 'package:mobile_core_kit/core/services/analytics/analytics_events.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_service.dart';

/// Facade that exposes high-level, app-specific analytics events.
///
/// Features should depend on this tracker instead of calling
/// [IAnalyticsService] directly or using raw event names.
class AnalyticsTracker {
  AnalyticsTracker(this._analyticsService);

  final IAnalyticsService _analyticsService;

  /// Tracks a screen view.
  Future<void> trackScreen(
    String name, {
    String? previous,
    Map<String, Object?>? parameters,
  }) {
    return _analyticsService.logScreenView(
      name,
      previousScreenName: previous,
      parameters: parameters,
    );
  }

  /// Tracks a login event with the given method (e.g., email, google).
  Future<void> trackLogin({required String method}) {
    return _analyticsService.logEvent(
      AnalyticsEvents.login,
      parameters: {AnalyticsParams.method: method},
    );
  }

  /// Tracks a generic button click.
  ///
  /// [id] should be a stable identifier for the button, not a
  /// human-readable label.
  Future<void> trackButtonClick({
    required String id,
    String? screen,
    Map<String, Object?>? parameters,
  }) {
    final mergedParams = <String, Object?>{
      AnalyticsParams.buttonId: id,
      if (screen != null) AnalyticsParams.screenName: screen,
      if (parameters != null) ...parameters,
    };

    return _analyticsService.logEvent(
      AnalyticsEvents.buttonClick,
      parameters: mergedParams,
    );
  }

  /// Tracks a search interaction.
  Future<void> trackSearch({
    required String query,
    String? type,
    Map<String, Object?>? parameters,
  }) {
    final mergedParams = <String, Object?>{
      AnalyticsParams.searchQuery: query,
      if (type != null) AnalyticsParams.searchType: type,
      if (parameters != null) ...parameters,
    };

    return _analyticsService.logEvent(
      AnalyticsEvents.search,
      parameters: mergedParams,
    );
  }

  Future<void> trackDeepLinkReceived({
    required String source,
    required String scheme,
    required String host,
    required String path,
    int? queryKeyCount,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.deepLinkReceived,
      parameters: {
        AnalyticsParams.deepLinkSource: source,
        AnalyticsParams.deepLinkScheme: scheme,
        AnalyticsParams.deepLinkHost: host,
        AnalyticsParams.deepLinkPath: path,
        if (queryKeyCount != null)
          AnalyticsParams.deepLinkQueryKeyCount: queryKeyCount,
      },
    );
  }

  Future<void> trackDeepLinkRejected({
    required String source,
    required String scheme,
    required String host,
    required String path,
    required String reason,
    int? queryKeyCount,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.deepLinkRejected,
      parameters: {
        AnalyticsParams.deepLinkSource: source,
        AnalyticsParams.deepLinkScheme: scheme,
        AnalyticsParams.deepLinkHost: host,
        AnalyticsParams.deepLinkPath: path,
        AnalyticsParams.deepLinkReason: reason,
        if (queryKeyCount != null)
          AnalyticsParams.deepLinkQueryKeyCount: queryKeyCount,
      },
    );
  }

  Future<void> trackDeepLinkPendingSet({
    required String source,
    required String path,
    required String reason,
    bool wasReplaced = false,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.deepLinkPendingSet,
      parameters: {
        AnalyticsParams.deepLinkSource: source,
        AnalyticsParams.deepLinkPath: path,
        AnalyticsParams.deepLinkReason: reason,
        AnalyticsParams.deepLinkWasReplaced: wasReplaced ? 1 : 0,
      },
    );
  }

  Future<void> trackDeepLinkResumed({
    required String source,
    required String path,
    required int latencyMs,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.deepLinkResumed,
      parameters: {
        AnalyticsParams.deepLinkSource: source,
        AnalyticsParams.deepLinkPath: path,
        AnalyticsParams.deepLinkLatencyMs: latencyMs,
      },
    );
  }

  Future<void> trackDeepLinkCleared({
    required String source,
    required String path,
    required String reason,
  }) {
    return _analyticsService.logEvent(
      AnalyticsEvents.deepLinkCleared,
      parameters: {
        AnalyticsParams.deepLinkSource: source,
        AnalyticsParams.deepLinkPath: path,
        AnalyticsParams.deepLinkReason: reason,
      },
    );
  }
}
