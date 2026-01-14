import '../adaptive_spec.dart';
import '../size_classes.dart';

/// Primary modal presentation decision.
enum AdaptiveModalPresentation { bottomSheet, dialog }

/// Side sheet decision (present or fall back to modal).
enum AdaptiveSideSheetPresentation { sideSheet, modalFallback }

/// Policy for adaptive modal presentation (sheet vs dialog vs side sheet).
///
/// Feature code should call `showAdaptiveModal(...)` / `showAdaptiveSideSheet(...)`
/// and never implement its own breakpoint logic.
sealed class ModalPolicy {
  const ModalPolicy();

  /// Standard policy:
  /// - `compact` → bottom sheet
  /// - `medium+` → dialog
  const factory ModalPolicy.standard() = _StandardModalPolicy;

  /// Chooses bottom sheet vs dialog given the current [LayoutSpec].
  AdaptiveModalPresentation modalPresentation({required LayoutSpec layout});

  /// Chooses side sheet vs modal fallback given the current [LayoutSpec].
  AdaptiveSideSheetPresentation sideSheetPresentation({required LayoutSpec layout});
}

class _StandardModalPolicy extends ModalPolicy {
  const _StandardModalPolicy();

  @override
  AdaptiveModalPresentation modalPresentation({required LayoutSpec layout}) {
    if (layout.widthClass == WindowWidthClass.compact) {
      return AdaptiveModalPresentation.bottomSheet;
    }
    return AdaptiveModalPresentation.dialog;
  }

  @override
  AdaptiveSideSheetPresentation sideSheetPresentation({required LayoutSpec layout}) {
    if (layout.widthClass == WindowWidthClass.compact) {
      return AdaptiveSideSheetPresentation.modalFallback;
    }
    return AdaptiveSideSheetPresentation.sideSheet;
  }
}
