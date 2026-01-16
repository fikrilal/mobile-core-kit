part of 'app_snackbar.dart';

class _TopSnackBarOverlayController {
  OverlayEntry? _entry;
  AnimationController? _controller;
  Timer? _autoDismissTimer;

  Future<void> show(
    BuildContext context, {
    required String message,
    required _AppSnackBarTone tone,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final colors = _resolveColors(context, tone);
    final media = _mediaQueryData(context);

    await dismiss();

    final controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: overlay,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    VoidCallback? resolvedAction;
    if (actionLabel != null && onAction != null) {
      resolvedAction = () {
        onAction();
        unawaited(dismiss());
      };
    }

    final topInset = [
      media.viewPadding.top,
      media.padding.top,
      media.systemGestureInsets.top,
    ].reduce((a, b) => a > b ? a : b);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: topInset + AppSpacing.space16,
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, child) {
            final value = animation.value;
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * -20),
                child: child,
              ),
            );
          },
          child: _TopSnackBarCard(
            message: message,
            colors: colors,
            actionLabel: actionLabel,
            onAction: resolvedAction,
          ),
        ),
      ),
    );

    _entry = entry;
    _controller = controller;
    overlay.insert(entry);
    await controller.forward();

    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(duration, () {
      unawaited(_dismissInternal(controller, entry));
    });
  }

  Future<void> dismiss() async {
    final entry = _entry;
    final controller = _controller;
    if (entry == null || controller == null) return;

    _entry = null;
    _controller = null;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    try {
      await controller.reverse();
    } catch (_) {
      // ignore animation cancellation
    } finally {
      entry.remove();
      controller.dispose();
    }
  }

  Future<void> _dismissInternal(
    AnimationController controller,
    OverlayEntry entry,
  ) async {
    if (_controller != controller) return;

    _entry = null;
    _controller = null;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    try {
      await controller.reverse();
    } catch (_) {
      // ignore animation cancellation
    } finally {
      entry.remove();
      controller.dispose();
    }
  }
}

class _TopSnackBarCard extends StatelessWidget {
  const _TopSnackBarCard({
    required this.message,
    required this.colors,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final _AppSnackBarColors colors;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final media = _mediaQueryData(context);
    final shadow = Theme.of(context).colorScheme.shadow;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppSpacing.space12),
          boxShadow: [
            BoxShadow(
              color: shadow.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: shadow.withValues(alpha: 0.04),
              blurRadius: 48,
              offset: Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        constraints: BoxConstraints(
          maxWidth: media.size.width - (AppSpacing.space16 * 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText.bodyMedium(
                message,
                color: colors.foreground,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: colors.foreground,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                    vertical: AppSpacing.space4,
                  ),
                ),
                child: AppText.labelMedium(
                  actionLabel!,
                  color: colors.foreground,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
