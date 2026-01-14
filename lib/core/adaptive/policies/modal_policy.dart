import '../adaptive_spec.dart';
import '../size_classes.dart';

enum AdaptiveModalPresentation { bottomSheet, dialog }

enum AdaptiveSideSheetPresentation { sideSheet, modalFallback }

sealed class ModalPolicy {
  const ModalPolicy();

  const factory ModalPolicy.standard() = _StandardModalPolicy;

  AdaptiveModalPresentation modalPresentation({required LayoutSpec layout});

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
