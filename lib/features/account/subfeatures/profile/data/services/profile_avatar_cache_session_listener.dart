import 'dart:async';

import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/local/profile_avatar_cache_local_datasource.dart';

/// Clears user-scoped avatar caches when the session ends.
///
/// This stays inside the profile slice because runtime session orchestration
/// should not import feature-owned cache code directly.
class ProfileAvatarCacheSessionListener {
  ProfileAvatarCacheSessionListener({
    required AppEventBus events,
    required ProfileAvatarCacheLocalDataSource cache,
  }) : _events = events,
       _cache = cache {
    _subscription = _events.stream.listen(_onEvent);
  }

  final String _tag = 'ProfileAvatarCacheSessionListener';
  final AppEventBus _events;
  final ProfileAvatarCacheLocalDataSource _cache;

  StreamSubscription<AppEvent>? _subscription;
  Future<void>? _inFlightClear;

  void _onEvent(AppEvent event) {
    if (event is SessionCleared || event is SessionExpired) {
      // Best-effort; session teardown should never block the app.
      _inFlightClear ??= _clearAll();
    }
  }

  Future<void> _clearAll() async {
    try {
      await _cache.clearAll();
      Log.debug('Cleared profile avatar caches', name: _tag);
    } catch (e, st) {
      Log.error('Failed to clear profile avatar caches', e, st, false, _tag);
    } finally {
      _inFlightClear = null;
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
