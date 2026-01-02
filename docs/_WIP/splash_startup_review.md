# Splash & Startup Mechanism Review (mobile-core-kit)

Reviewed: 2026-01-01  
Branch/commit: `development` @ `02fd758503b4d92ba735f6ea984b0b6698a785c2`  
Working tree: clean (`git status` showed no local diffs at review time)

Scope:
- “Splash” UX and startup gating as described in `docs/engineering/splash_best_practices.md`
- App startup performance (time-to-first-frame and time-to-correct-route)
- Safety/solidity (crash risk, hangs, degraded-mode behavior)
- Design quality (SOLID principles, testability), without over-engineering

Non-scope:
- Deep link product requirements (only reviewed for startup side-effects)
- Feature-level business logic beyond what affects startup

---

## Executive Summary

Overall, the current implementation is **industry-aligned** and cleanly structured:
- Uses **native launch screen** as the only true “splash” (via `flutter_native_splash`) and avoids an in-app `/splash` route.
- Uses an **in-app startup overlay gate** (`AppStartupGate`) instead of a navigable route, matching the best-practices doc.
- Improves perceived startup by keeping **pre-`runApp()` work synchronous and minimal**, deferring IO-heavy initialization to **after the first Flutter frame**.
- Adds **early error buffering** so deferring Crashlytics doesn’t silently drop early crashes.

Biggest “enterprise-grade” risks are not architectural, but **edge-case safety + latency variability**:
1) **Potential startup hang** (rare but high-impact): awaited plugin calls in `AppStartupController.initialize()` have no timeout; if secure storage / prefs hang, `startup.isReady` may never flip, leaving the app gated.
2) **Startup gating cost is dominated by storage IO**: `TokenSecureStorage.read()` does 4 sequential platform reads, and session restore also touches SQLite. This can push “time-to-correct-route” past the `AppStartupGate` show delay on slower devices.
3) **Deep link side-effects during “not ready”**: `appRedirect()` intentionally returns `null` while not ready. This preserves deep links, but it also means protected pages could build before auth/onboarding are known (and the gate is only mounted after a delay).

None of these require big re-architecture, but they do benefit from a few targeted hardening/perf changes (recommended list below).

---

## What Exists Today (Code Map)

### 1) Entry point & first-frame strategy

Files:
- `lib/main_dev.dart`
- `lib/main_staging.dart`
- `lib/main_prod.dart`

Observed behavior:
- `WidgetsFlutterBinding.ensureInitialized()` early.
- `EarlyErrorBuffer.instance.install()` installed before any deferred Crashlytics init.
- `AppConfig.init(...)` happens before DI registration (needed by `ApiClient` baseUrl).
- `registerLocator()` runs **synchronously before `runApp()`**.
- `bootstrapLocator()` runs **after the first frame** via `WidgetsBinding.instance.addPostFrameCallback`.
- Startup instrumentation is present via `StartupMetrics`.

Why this matters:
- Anything awaited before `runApp()` extends **native launch screen time**.
- Deferring IO until after the first frame improves perceived startup (TTFF), at the cost of delaying some services’ readiness (Crashlytics, Firebase, analytics, connectivity).

### 2) Routing + startup gating (no splash route)

Files:
- `lib/navigation/app_router.dart`
- `lib/navigation/app_redirect.dart`
- `lib/app.dart`
- `lib/core/widgets/loading/app_startup_gate.dart`

Observed behavior:
- GoRouter `initialLocation` is `/` (`AppRoutes.root`), with a real `GoRoute` for `/` that renders `SizedBox.shrink()`.
- GoRouter uses `refreshListenable: startup` and `redirect: (context, state) => appRedirect(state, startup)`.
- While `!startup.isReady`, `appRedirect()` returns `null` (no forced navigation). This is the “no splash route” best practice.
- UI blocking is done by `AppStartupGate` overlay in `MaterialApp.router(builder: ...)`.
  - Overlay appears only if startup is still not ready after `MotionDurations.startupGateShowDelay` (200ms).
  - Overlay enforces a minimum visible duration and fade to avoid blink.
  - Overlay blocks interaction via `ModalBarrier` and blocks back navigation via `PopScope` (while visible).

### 3) Startup readiness source of truth

Files:
- `lib/core/services/app_startup/app_startup_controller.dart`
- `lib/core/di/service_locator.dart`
- `lib/core/session/session_manager.dart`
- `lib/core/services/app_launch/app_launch_service_impl.dart`

Observed behavior:
- `AppStartupController.initialize()`:
  - Awaits `SessionManager.init()` (secure storage + local DB restore).
  - Awaits onboarding flag from `SharedPreferences` via `AppLaunchServiceImpl`.
  - Marks `ready` and notifies listeners (router refresh + UI gate dismiss path).
  - Then triggers best-effort user hydration (`GetMeUseCase`) only when session is “auth pending” (tokens present, user null), with cooldown and unauthenticated-logout behavior.
- `bootstrapLocator()` explicitly runs `startup.initialize()` early (before Firebase/Crashlytics/Intl) so routing can resolve promptly.

### 4) Crash-safety while deferring Crashlytics

Files:
- `lib/core/services/early_errors/early_error_buffer.dart`
- `lib/core/services/early_errors/crashlytics_error_reporter.dart`
- `lib/core/di/service_locator.dart` (`EarlyErrorBuffer.activate(...)`)

Observed behavior:
- Early errors are buffered (up to 20) until Crashlytics is initialized post-first-frame, then flushed.
- `FlutterError.onError` and `PlatformDispatcher.instance.onError` are hooked to capture early unhandled errors.

---

## Alignment With `docs/engineering/splash_best_practices.md`

This implementation matches the doc’s intended “industry-aligned” direction:
- Native splash is the primary splash: configured via `flutter_native_splash` in `pubspec.yaml` and generated into Android/iOS launch screen resources.
- No dedicated `/splash` route exists.
- Startup gate is an overlay (not a route) and is attached at `MaterialApp.router(builder: ...)`.
- Startup gating is done via a listenable controller (`AppStartupController`) that also triggers GoRouter refresh for redirects.
- Heavy init is deferred until after the first frame to reduce native splash duration.

---

## Startup Performance Review

### What you did well (high impact, low complexity)

- **Minimized pre-`runApp()` work**: `registerLocator()` is sync-only and avoids platform IO. This directly reduces native launch screen time.
- **Deferred heavy init**: Firebase/Crashlytics/Intl/analytics/connectivity initialize after the first frame (in `bootstrapLocator()`), which is a standard approach for perceived performance.
- **Added instrumentation**: `StartupMetrics` provides TTFF + readiness markers and analytics reporting hooks.

### Where the time likely goes (cold start)

Key observation: “native splash duration” is improved, but “time to correct first route” is dominated by storage IO that happens after the first frame:

- Secure storage restore:
  - `TokenSecureStorage.read()` performs **4 sequential platform reads** (`access`, `refresh`, `expires_in`, `expires_at_ms`).
  - On slower devices, this can be noticeable and may push readiness past 200ms.
- SQLite read on startup:
  - `SessionRepositoryImpl.loadSession()` reads cached user from SQLite (`AuthLocalDataSource.getCachedUser()` → `AppDatabase().database` open + query).
  - This is expensive compared to “tokens-only” restore, and it is **not required** to decide initial routing (routing only needs “has tokens?” + onboarding flag).

### AppStartupGate timing

- `showDelay` (200ms) is good for avoiding flicker, but it implies:
  - If readiness frequently exceeds ~200ms on real devices, users will see the in-app gate regularly (still acceptable, but it becomes part of perceived startup UX).
  - If readiness is “usually <200ms but sometimes >200ms”, users may see occasional “white/blank then gate” transitions (especially because `/` renders `SizedBox.shrink()`).

### Suggested measurement approach (before changing anything)

Use the existing `StartupMetrics` instrumentation to establish baselines:
- Track distributions for:
  - `startup_ttff_ms`
  - `startup_ready_ms`
  - `startup_bootstrap_ms`
- Segment by device class if possible (low-end Android vs flagship) to see if secure storage/SQLite dominates readiness.

---

## Safety & Crash/Freeze Risk Review

### Strengths

- **EarlyErrorBuffer** significantly reduces the “silent crash before Crashlytics init” gap introduced by deferring Firebase.
- Startup bootstrapping is **best-effort**:
  - Failures in startup controller init, Firebase, analytics, connectivity do not crash the app by default.
  - Onboarding flag read failure fails open to “show onboarding” (safe, avoids deadlock).

### Key risks & edge cases

1) **Potential indefinite gating due to hung awaits**
   - `AppStartupController.initialize()` awaits:
     - `SessionManager.init()` (secure storage + SQLite via plugins)
     - `AppLaunchService.shouldShowOnboarding()` (SharedPreferences via plugin)
   - Exceptions are handled, but **hangs/timeouts are not**. If a plugin Future never completes, `startup.isReady` never flips → the UI may remain gated indefinitely.

2) **Deep link behavior while not ready**
   - `appRedirect()` returns `null` while not ready (good for deep link preservation).
   - Side-effect: the deep-linked page can build before auth/onboarding are known.
   - Because `AppStartupGate` is only mounted after 200ms, there’s a small window where a deep-linked page could be interactive (rare for humans, but relevant for automation/accessibility and for pages that trigger eager side effects during `build`/`initState`).

3) **Service lifecycle & disposal**
   - Several long-lived services expose `dispose()` (`AppStartupController`, `SessionManager`, `ConnectivityServiceImpl`, etc.) but GetIt registrations do not provide disposal hooks.
   - In production this is usually fine (process lifetime), but it increases the risk of:
     - flaky tests / leaked listeners when using `resetLocator()`
     - confusing behavior in widget tests that reuse the process

4) **Security/logging footnote**
   - Token masking logs (`SessionManager._mask`) still prints the first 5 chars + length in dev/stage.
   - Enterprise guidance typically avoids logging any token material at all (even partial), because logs can end up in bug reports, CI artifacts, or shared consoles.

5) **Error swallowing tradeoff**
   - `PlatformDispatcher.onError` returns `kReleaseMode`, which means “handled” in release builds.
   - This reduces user-facing crashes but can leave the app in an unknown state after a truly fatal error. Some orgs prefer to crash-and-restart for correctness.

---

## SOLID / Design Review (Enterprise-grade, not over-engineered)

### What’s solid

- **Single Responsibility is mostly respected**:
  - `main_*` focuses on boot sequence + first-frame strategy.
  - `service_locator.dart` centralizes DI and bootstrapping.
  - `AppStartupController` owns “startup readiness state”.
  - `AppStartupGate` owns “UI interaction gating without route pollution”.
  - `app_redirect.dart` owns routing rules.
- **Dependency Inversion** is used in key places:
  - `ConnectivityService` and `AppLaunchService` are abstractions.
  - Domain use case (`GetMeUseCase`) is injected rather than called via network layer directly.
- **Open/Closed**: `AppStartupGate` supports swapping overlay UI via `overlayBuilder` without changing core logic.

### Where it may get “too much” later (watchlist)

- `AppStartupController` currently manages:
  1) startup readiness (session + onboarding)
  2) session change listening
  3) connectivity-triggered hydration
  4) hydration cooldown + unauthenticated logout policy

This is still cohesive today (“startup/session orchestration”), but if hydration logic grows (retries, backoff, forced upgrade, remote config, etc.), consider splitting into:
- `AppStartupController` (readiness + onboarding)
- `UserHydrationOrchestrator` (session/network-driven hydration)

Only do this if complexity grows; current size is acceptable and not over-engineered.

---

## Recommendations (Prioritized)

### P0 — Hardening (prevents rare but high-impact failures)

1) Add **timeouts + fail-open behavior** for readiness-critical awaits
   - Apply timeouts to:
     - `SessionManager.init()`
     - `AppLaunchService.shouldShowOnboarding()`
   - On timeout: treat as signed-out and/or “show onboarding”, then mark startup ready.
   - This prevents “stuck behind gate forever” scenarios caused by plugin hangs.

2) Decide and document the **deep link + not-ready policy**
   - Option A (current): preserve deep links, accept that pages may build while startup is unknown; require feature pages to be resilient (no eager auth-required calls before readiness).
   - Option B: still preserve deep links but **block interactions immediately** (mount a transparent barrier immediately, fade visuals after delay).
   - Option C (more complex): capture intended deep link and temporarily route to `/` until ready, then restore.
   - For “enterprise-grade safety”, Option B is often the best ROI (minimal complexity, stronger gating semantics).

### P1 — Performance (reduces “time to correct route”)

3) Reduce secure storage channel round-trips
   - Consider reading tokens in **one call** (e.g., `readAll`) or storing a single serialized payload.
   - Goal: reduce variability and keep `startup_ready_ms` consistently < `AppStartupGate.showDelay`.

4) Avoid SQLite work on the critical readiness path (if possible)
   - Routing decisions only need “has tokens?” + onboarding flag.
   - Consider restoring tokens first (fast), mark startup ready, then load cached user/hydrate in background.
   - This reduces startup gate duration and also reduces startup jank risk.

5) Disable GoRouter diagnostics outside debug
   - `debugLogDiagnostics: true` should typically be `kDebugMode` (or equivalent) to avoid noisy logging/perf overhead in release.

### P2 — Maintainability & test robustness

6) Provide GetIt disposal hooks for services with resources
   - Register with `dispose:` where appropriate (not everything needs it).
   - This improves test isolation and prevents leaked listeners/subscriptions during `resetLocator()`.

7) Tighten token logging policy
   - Remove/limit masked token logs even in non-prod, or guard them behind a dedicated “dangerous logging” flag.

### P3 — UX polish (nice-to-have)

8) Avoid “blank root” visuals during gating
   - `/` currently renders `SizedBox.shrink()`. If `startup_ready_ms` exceeds 200ms, users may briefly see a blank frame before the gate appears.
   - Consider making the root route paint a background matching the startup overlay (or matching native splash) so transitions are seamless.

---

## Suggested Tests (High Value)

1) `app_redirect` unit tests
   - Validate redirect outcomes across:
     - `startup.isReady` false/true
     - onboarding required vs not
     - authenticated vs not
     - zone transitions (root/auth/onboarding/other)

2) `AppStartupController` unit tests
   - `initialize()` sets `ready` and populates `shouldShowOnboarding`.
   - Failures in session restore and onboarding read do not prevent `ready`.
   - Hydration triggers only when `isAuthPending` and onboarding is complete.
   - Cooldown prevents noisy re-hydration.

3) `AppStartupGate` widget tests
   - Overlay does not appear before `showDelay`.
   - Once shown, respects `minVisible` and `fadeDuration`.
   - Blocks back navigation while visible (`PopScope`).
   - Disables child tickers while visible (`TickerMode`).

---

## Appendix: Key Files Reviewed

- Best practices: `docs/engineering/splash_best_practices.md`
- Entry points: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`
- App root: `lib/app.dart`
- Startup gate UI: `lib/core/widgets/loading/app_startup_gate.dart`
- Startup controller: `lib/core/services/app_startup/app_startup_controller.dart`
- Router + redirect: `lib/navigation/app_router.dart`, `lib/navigation/app_redirect.dart`
- DI bootstrap: `lib/core/di/service_locator.dart`
- Session restore: `lib/core/session/session_manager.dart`, `lib/core/session/session_repository_impl.dart`, `lib/core/storage/secure/token_secure_storage.dart`, `lib/core/database/app_database.dart`
- Early error buffering: `lib/core/services/early_errors/early_error_buffer.dart`

