# Startup & Splash (Template Mechanism)

This template uses a **native splash → first Flutter frame → in-app startup gate overlay** approach.
It aims to be enterprise-safe (no “stuck forever” gates), fast (minimize time on native splash),
and easy to customize without over-engineering.

## Goals

- **Fast first frame:** call `runApp()` as early as possible.
- **Safe readiness:** startup must always reach “ready” (timeouts + fail-open defaults).
- **No double-splash:** avoid routing to an in-app `/splash` page.
- **Good UX:** block interaction immediately while startup is unknown; show a spinner only when the wait is noticeable.

## High-Level Flow

1) **Native splash** shows while Flutter starts.
2) Flutter renders the **first frame** (TTFF).
3) App runs with the real route tree; `AppStartupGate`:
   - mounts an immediate **backdrop + interaction barrier** while not ready
   - shows a **spinner overlay after a short delay** (default `200ms`) to avoid flicker on fast starts
4) In parallel, startup services run (session restore + onboarding decision). When ready, the gate unblocks.

## Key Components (Where to Look)

- Entry point: `lib/main_dev.dart` (and `lib/main_staging.dart`, `lib/main_prod.dart`)
  - `registerLocator()` runs before `runApp()` to keep first frame fast.
  - `bootstrapLocator()` runs after first frame for heavier init (Firebase, etc.).
- Startup orchestration: `lib/core/services/app_startup/app_startup_controller.dart`
  - Controls readiness + onboarding decision.
  - Uses timeouts and fail-open defaults for safety.
- UI gate: `lib/core/widgets/loading/app_startup_gate.dart`
  - Immediate backdrop + barrier while not ready.
  - Delayed spinner overlay (`showDelay`) to prevent flicker.
- Router gating: `lib/navigation/app_redirect.dart`
  - During startup not-ready, protected locations are captured and redirected to `/`.
  - `AppStartupGate` prevents interaction during that period.
- Metrics: `lib/core/services/startup_metrics/startup_metrics.dart`
  - Logs startup milestones (TTFF, ready, bootstrap steps).

## How the Gate Works (UX Semantics)

`AppStartupGate` has two layers when startup is not ready:

1) **Backdrop (immediate)**
   - Painted immediately after the first Flutter frame.
   - Default: `AppStartupBackdrop` uses `Theme.of(context).colorScheme.surface`.

2) **Overlay (delayed)**
   - Only mounted after `showDelay` (default 200ms) if still not ready.
   - Default: `AppStartupOverlay` (title + dot-wave spinner).

Interaction blocking:
- A transparent `ModalBarrier` blocks touches while the gate is active.
- `PopScope(canPop: false)` prevents back navigation while the gate is active.
- Optional: `TickerMode(enabled: false, ...)` reduces wasted animations under the gate.

## Why the Spinner Is Delayed (Default 200ms)

Showing a spinner immediately often creates a **flash** on fast startups (spinner appears then disappears),
which reads as visual instability. A short delay means “only show the busy indicator when the wait is real”.

## Startup Readiness Rules (Safety)

Readiness is controlled by `AppStartupController.initialize()`:

- **Session restore** (`SessionManager.init()`) has a timeout; on timeout/error the app continues as signed-out.
- **Onboarding decision** (`AppLaunchService.shouldShowOnboarding()`) has a timeout; on timeout/error default to “show onboarding”.

This prevents “stuck behind gate forever” scenarios (e.g., plugin hangs).

## How to Customize (Common Template Changes)

### 1) Change branding (logo/text/spinner)

Update the `MaterialApp.router` builder in `lib/app.dart`:

- `overlayBuilder`: customize the delayed overlay UI (logo/title/spinner).
- `backdropBuilder`: customize the immediate backdrop (match native splash color/gradient).

Guideline: keep these builders **pure UI** (no IO, no async, no service calls).

### 2) Tune timing (delay/fade/min-visible)

Default tokens live in `lib/core/theme/system/motion_durations.dart`:

- `startupGateShowDelay` (spinner delay)
- `startupGateMinVisible` (avoid blink)
- `startupGateFadeDuration`

### 3) Add a new readiness prerequisite

If something truly must be known before the app becomes interactive:

- Add it inside `AppStartupController.initialize()`.
- Always apply a **timeout** and define a **fail-open default**.
- Ensure the controller still reaches `ready` and notifies listeners.

If it does not need to block interaction, prefer initializing it in `bootstrapLocator()` instead.

### 4) Adjust routing decisions

Update policies in `lib/navigation/app_redirect.dart`:

- what should be accessible before readiness (`/`, onboarding, auth routes)
- how protected locations are captured/resumed

## Android 12+ (Logo Cropping / Dark “Box” Behind Icon)

Android 12+ uses the platform SplashScreen API and renders
`android:windowSplashScreenAnimatedIcon` (`@drawable/android12splash`).

Common pitfalls:

- **Logo looks cropped:** the Android 12 icon is treated like an app icon (safe area/masking).
  Use a dedicated padded asset for `flutter_native_splash.android_12.image`.
- **Dark box behind the icon:** pre-Android 12 `launch_background.xml` often includes a centered
  `@drawable/splash`. On Android 12+, this can render behind the system icon and look like a dark
  square. The template includes `drawable-v31/launch_background.xml` without the centered logo to
  avoid “double-logo” rendering.

## Tests & Verification

- Startup safety: `test/core/services/app_startup/app_startup_controller_test.dart`
- Gate behavior: `test/core/widgets/loading/app_startup_gate_test.dart`
