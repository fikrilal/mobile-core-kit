/// Motion duration tokens used across the app.
///
/// These are intentionally small, fixed values (design tokens) so animations
/// feel consistent and can be tuned in one place.
///
/// Prefer using these constants over inline `Duration(...)` literals.
class MotionDurations {
  MotionDurations._();

  /// Fast motion for subtle UI feedback.
  static const Duration quick = Duration(milliseconds: 100);

  /// Default motion for most interactions.
  static const Duration short = Duration(milliseconds: 150);

  /// Standard motion for UI transitions.
  static const Duration medium = Duration(milliseconds: 200);

  /// Emphasized motion for larger UI transitions.
  static const Duration long = Duration(milliseconds: 250);

  /// Side sheet transition duration (slide-in/out).
  static const Duration sideSheetTransition = Duration(milliseconds: 220);

  /// Period for shimmer animations.
  static const Duration shimmerPeriod = Duration(milliseconds: 1500);

  /// Period for dot-wave loading animations.
  static const Duration dotWavePeriod = Duration(milliseconds: 1200);

  /// Delay before showing the app startup gate overlay.
  ///
  /// Used by: `AppStartupGate` in `lib/core/widgets/loading/app_startup_gate.dart`.
  ///
  /// Why: avoids a "flash" on fast startups by only showing the overlay if
  /// startup is still not ready after this delay.
  static const Duration startupGateShowDelay = Duration(milliseconds: 200);

  /// Minimum time the startup gate overlay stays visible once shown.
  ///
  /// Used by: `AppStartupGate` in `lib/core/widgets/loading/app_startup_gate.dart`.
  ///
  /// Why: prevents a quick show/hide blink if startup becomes ready right after
  /// the overlay appears.
  static const Duration startupGateMinVisible = Duration(milliseconds: 250);

  /// Fade duration for the startup gate overlay.
  ///
  /// Used by: `AppStartupGate` in `lib/core/widgets/loading/app_startup_gate.dart`.
  ///
  /// Why: smooth transition to/from the overlay.
  static const Duration startupGateFadeDuration = Duration(milliseconds: 180);
}
