import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/responsive/spacing.dart';
import '../../theme/system/motion_durations.dart';
import '../../theme/typography/components/text.dart';
import 'app_dot_wave.dart';

typedef AppStartupGateIsReady = bool Function();

/// App-level startup gate that blocks interaction until startup is ready.
///
/// Why this exists:
/// - Avoids an in-app "splash route" (which often creates a double-splash UX).
/// - Allows the app to render its real route tree immediately, while optionally
///   covering it with a short-lived overlay until required startup checks finish.
///
/// Typical usage (root widget):
/// ```dart
/// AppStartupGate(
///   listenable: startupController,
///   isReady: () => startupController.isReady,
///   overlayBuilder: (_) => const AppStartupOverlay(title: 'My App'),
///   child: routerChild,
/// )
/// ```
class AppStartupGate extends StatefulWidget {
  const AppStartupGate({
    super.key,
    required this.listenable,
    required this.isReady,
    required this.child,
    this.overlayBuilder,
    this.backdropBuilder,
    this.showDelay = MotionDurations.startupGateShowDelay,
    this.minVisible = MotionDurations.startupGateMinVisible,
    this.fadeDuration = MotionDurations.startupGateFadeDuration,
    this.blockBackButton = true,
    this.disableChildTickers = true,
  });

  /// A [Listenable] that emits changes related to readiness (usually a
  /// `ChangeNotifier` like `AppStartupController`).
  final Listenable listenable;

  /// Returns whether startup is ready. This is read whenever [listenable]
  /// notifies to decide whether to show/hide the gate.
  final AppStartupGateIsReady isReady;

  final Widget child;

  /// Builder for the full-screen overlay. Defaults to [AppStartupOverlay].
  final WidgetBuilder? overlayBuilder;

  /// Builder for the immediate full-screen backdrop shown while startup is not
  /// ready. Defaults to [AppStartupBackdrop].
  ///
  /// This is mounted immediately (no delay) to avoid blank frames between the
  /// native splash and the delayed overlay. Interaction is blocked by the gate
  /// itself.
  final WidgetBuilder? backdropBuilder;

  /// How long to wait before showing the overlay (prevents flicker on fast starts).
  final Duration showDelay;

  /// Minimum time the overlay stays visible once shown (prevents blink).
  final Duration minVisible;

  /// Fade duration when showing/hiding the overlay.
  final Duration fadeDuration;

  /// When true, blocks back navigation while the gate is blocking UI.
  final bool blockBackButton;

  /// When true, disables tickers under [child] while the gate is blocking UI.
  final bool disableChildTickers;

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  DateTime? _becameVisibleAt;
  bool _mountedBackdrop = false;
  bool _mountedOverlay = false;
  bool _opaqueOverlay = false;

  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _unmountTimer;

  bool get _isReady => widget.isReady();

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleListenableChanged);
    _handleListenableChanged();
  }

  @override
  void didUpdateWidget(covariant AppStartupGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_handleListenableChanged);
      widget.listenable.addListener(_handleListenableChanged);
      _resetOverlayState();
      _handleListenableChanged();
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleListenableChanged);
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _unmountTimer?.cancel();
    super.dispose();
  }

  void _resetOverlayState() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _unmountTimer?.cancel();
    _becameVisibleAt = null;
    _mountedBackdrop = false;
    _mountedOverlay = false;
    _opaqueOverlay = false;
  }

  void _handleListenableChanged() {
    if (!mounted) return;

    if (_isReady) {
      if (_mountedBackdrop) {
        setState(() {
          _mountedBackdrop = false;
        });
      }
      _scheduleHideIfNeeded();
      return;
    }

    // If we're in the middle of fading out, keep the overlay alive.
    _hideTimer?.cancel();
    _unmountTimer?.cancel();

    if (!_mountedBackdrop) {
      setState(() {
        _mountedBackdrop = true;
      });
    }

    if (_mountedOverlay) {
      if (!_opaqueOverlay) {
        setState(() {
          _becameVisibleAt = DateTime.now();
          _opaqueOverlay = true;
        });
      }
      return;
    }

    _scheduleShowIfNeeded();
  }

  void _scheduleShowIfNeeded() {
    if (_isReady) return;
    if (_mountedOverlay) return;

    if (_showTimer?.isActive ?? false) return;
    _showTimer = Timer(widget.showDelay, () {
      if (!mounted) return;
      if (_isReady) return;

      setState(() {
        _mountedOverlay = true;
        _opaqueOverlay = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isReady) return;
        if (!_mountedOverlay) return;
        setState(() {
          _becameVisibleAt = DateTime.now();
          _opaqueOverlay = true;
        });
      });
    });
  }

  void _scheduleHideIfNeeded() {
    _showTimer?.cancel();
    if (!_mountedOverlay) return;

    _hideTimer?.cancel();

    final shownAt = _becameVisibleAt;
    final now = DateTime.now();
    final remaining = shownAt == null
        ? Duration.zero
        : widget.minVisible - now.difference(shownAt);

    if (remaining > Duration.zero) {
      _hideTimer = Timer(remaining, _hideOverlay);
      return;
    }

    _hideOverlay();
  }

  void _hideOverlay() {
    if (!mounted) return;
    if (!_mountedOverlay) return;

    _hideTimer?.cancel();
    // If we're already fading out, avoid restarting the unmount timer.
    // Otherwise, repeated notifications from a noisy listenable can keep the
    // overlay mounted (and still blocking input) longer than intended.
    if (_unmountTimer?.isActive ?? false) return;

    if (_opaqueOverlay) {
      setState(() {
        _opaqueOverlay = false;
      });
    }

    _unmountTimer?.cancel();
    if (widget.fadeDuration == Duration.zero) {
      setState(() {
        _mountedOverlay = false;
        _becameVisibleAt = null;
      });
      return;
    }

    _unmountTimer = Timer(widget.fadeDuration, () {
      if (!mounted) return;
      setState(() {
        _mountedOverlay = false;
        _becameVisibleAt = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveChild =
        widget.disableChildTickers && (_mountedBackdrop || _mountedOverlay)
            ? TickerMode(enabled: false, child: widget.child)
            : widget.child;

    final backdrop = _mountedBackdrop
        ? Positioned.fill(
            child:
                (widget.backdropBuilder ?? (_) => const AppStartupBackdrop())(
                  context,
                ),
          )
        : null;

    final barrier = (_mountedBackdrop || _mountedOverlay)
        ? const Positioned.fill(
            child: ModalBarrier(
              dismissible: false,
              color: Colors.transparent,
            ),
          )
        : null;

    final overlay = _mountedOverlay
        ? Positioned.fill(
            child: AnimatedOpacity(
              opacity: _opaqueOverlay ? 1 : 0,
              duration: widget.fadeDuration,
              curve: Curves.easeOut,
              child: (widget.overlayBuilder ?? (_) => const AppStartupOverlay())(
                context,
              ),
            ),
          )
        : null;

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        effectiveChild,
        if (backdrop != null) backdrop,
        if (barrier != null) barrier,
        if (overlay != null) overlay,
      ],
    );

    if (!widget.blockBackButton || (!_mountedBackdrop && !_mountedOverlay)) {
      return stack;
    }

    return PopScope(canPop: false, child: stack);
  }
}

/// Immediate backdrop shown by [AppStartupGate] while startup is not ready.
class AppStartupBackdrop extends StatelessWidget {
  const AppStartupBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
    );
  }
}

/// Default startup overlay UI for [AppStartupGate].
///
/// Keep this simple and brand-neutral by default. Apps can override it via
/// [AppStartupGate.overlayBuilder] (e.g. show a logo instead of text).
class AppStartupOverlay extends StatelessWidget {
  const AppStartupOverlay({
    super.key,
    this.title,
    this.semanticLabel = 'Starting up',
  });

  final String? title;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ColoredBox(
        color: scheme.surface,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ModalBarrier(
                dismissible: false,
                color: Colors.transparent,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null && title!.isNotEmpty) ...[
                      AppText.titleLarge(
                        title!,
                        color: scheme.onSurface,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.space16),
                    ],
                    AppDotWave(color: scheme.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
