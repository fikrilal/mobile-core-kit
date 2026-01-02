# Deep Linking (Template Guide)

This document explains **deep linking behavior and extension points** in this template:
- enterprise-grade safety (protected targets do not render before allowed),
- deterministic cold/warm start behavior,
- fail-safe parsing (unknown/malicious links don’t crash and don’t open arbitrary screens),
- minimal complexity (avoid over-engineering).

---

## TL;DR (What You Edit When Adding Deep Links)

1) **Allowlist the destination**
   - Update `lib/core/services/deep_link/deep_link_parser.dart`

2) **Claim the link at the OS level**
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Runner.entitlements`

3) **Host verification files**
   - Android: `https://orymu.com/.well-known/assetlinks.json`
   - iOS: `https://orymu.com/.well-known/apple-app-site-association`

4) **Add/adjust tests**
   - Parser: `test/core/services/deep_link/deep_link_parser_test.dart`
   - Redirect: `test/navigation/app_redirect_test.dart`

---

## Terms

- **Deep link**: a URL/URI that opens the app to a specific destination (screen + params).
- **Pending intent**: an internal representation of “navigate to X when allowed”.
- **Cold start**: app process not running.
- **Warm start**: app already running.
- **Prerequisites**: conditions required before showing a destination (startup ready, onboarding complete, authenticated).

---

## Policy: Intent-Based Deep Links (Deferred Navigation)

This template uses an **intent-based** approach:
- Incoming deep links are captured as a **pending intent** (in-memory + persisted with TTL).
- Navigation to the final target happens only when prerequisites are satisfied.

### Why this policy

This provides safe, predictable behavior:
- Resumes the deep link after onboarding/login reliably.
- Prevents protected targets from rendering before auth/onboarding are known.
- Scales to additional prerequisites later (forced upgrade, remote config, org selection) without changing link formats.

### Interaction safety

During startup, the app should block user interaction until readiness is known. This prevents edge-case races and makes behavior consistent across cold/warm starts.

---

## Policy Goals & Invariants

### Goals

1) **Protected targets never render before allowed**
   - If a deep link points to a protected screen, the app must not build/render that screen until:
     - `startup.isReady == true`, and
     - onboarding rules are satisfied, and
     - authentication rules are satisfied.

2) **Deep links are not lost**
   - If onboarding/login intervenes, the app should continue toward the original deep link once allowed.

3) **Deterministic, loop-free redirects**
   - Redirect rules must be idempotent and avoid oscillation.

4) **Fail safe**
   - Invalid/unrecognized/malicious links route to a safe default (e.g., home) without crashes.

### Invariants

- At most **one pending intent** at a time (default: last intent wins).
- A pending intent is cleared only when:
  - navigation to the resolved location has been triggered, or
  - it is explicitly discarded (invalid/expired), or
  - the user explicitly cancels the prerequisite flow.

### Defaults (this repo)

- Pending intent is **persisted** (so it can survive process death) with a **TTL of 1 hour**.
- External deep links support **HTTPS** for `orymu.com` only (strict allowlist).
- Multiple incoming links use **last-intent-wins**.

---

## High-Level Architecture

### Core components (recommended minimal set)

1) **DeepLinkSource**
   - A platform integration that emits incoming links:
     - initial link on cold start,
     - stream of links while running.
   - Examples (choose based on product needs): Android App Links, iOS Universal Links, custom scheme, push notification payloads.

2) **DeepLinkParser**
   - Converts raw `Uri` → internal `DeepLinkIntent`.
   - Must validate and normalize input (see Security section).

3) **DeepLinkIntent (value type)**
   - Minimal fields:
     - `location` (the GoRouter location string; path + query),
     - `source` (optional, for analytics/debugging),
     - `receivedAt` (for TTL/expiry).

4) **PendingDeepLinkController**
   - Holds the current pending intent (in-memory).
   - Exposes a `Listenable`/`ChangeNotifier` so the router can refresh when a new intent arrives.

5) **DeepLinkRoutingPolicy**
   - Defines how prerequisites apply to intents/targets (auth required, onboarding required).
   - Keep it data-driven and simple (allowlist + metadata).

### Router integration

The GoRouter redirect layer becomes the single orchestrator:
- It decides whether to:
  - hold the intent and route to a safe placeholder,
  - route to onboarding/auth prerequisites,
  - or finally route to the deep-linked target.

This keeps deep link behavior consistent with existing `appRedirect` logic.

---

## Redirect Algorithm (Conceptual)

This is the core logic the template relies on.

### Step 0: classify the current location

Use a route “zone” concept (root/auth/onboarding/other) like the existing `app_redirect.dart`.

### Step 1: if startup not ready, do not allow non-safe routes to build

- If `startup.isReady == false`:
  - If current location is a deep link candidate (not `/`, not auth, not onboarding) and there is no pending intent yet:
    - store intent for this location
  - redirect to a safe placeholder (recommended: `/`)

Result: protected targets are not built before readiness is known.

### Step 2: resolve prerequisites once startup is ready

When `startup.isReady == true`:

1) If onboarding must be shown:
   - redirect to onboarding (keep pending intent)
2) Else if auth is required and user is not authenticated:
   - redirect to sign-in (keep pending intent)
3) Else if there is a pending intent:
   - redirect to the pending intent’s `location` and clear it
4) Else:
   - fall back to normal app redirect rules (root → home/auth/onboarding)

### Step 3: warm links while app is running

When a new deep link arrives while the app is running:
- Store it as the pending intent.
- Trigger a router refresh (via `refreshListenable`).
- The same prerequisite rules apply (onboarding/auth may intercept).

---

## UX Rules

### Startup interaction safety

Block interaction immediately while startup readiness is unknown. If you show a visible splash/overlay, delay visuals slightly to avoid flicker, but keep the input barrier immediate.

---

## Security & Validation (Enterprise Requirements)

1) **Allowlist destinations**
   - Only support deep links to explicitly allowed routes.
   - Unknown paths must not crash and must not navigate to arbitrary internal screens.

2) **Strict parsing & normalization**
   - Normalize path casing and trailing slashes.
   - Validate required params and types.
   - Reject invalid IDs (length/format).

3) **No open redirects**
   - Never accept a deep link parameter that becomes a free-form internal navigation target.
   - Always map external input → a known `DeepLinkIntent`.

4) **PII-safe logging**
   - Avoid logging full incoming URLs if they can contain personal data (email, phone, tokens, referral codes).
   - If logging is needed, log only the deep link type + redacted identifiers.

5) **Re-entrancy & abuse protection**
   - Last-intent-wins is usually fine; optionally add throttling/TTL to prevent loops from repeated external triggers.

---

## Testing Strategy (Must-Have)

1) **Parser unit tests**
   - Valid links map to correct `DeepLinkIntent.location`.
   - Invalid links are rejected or mapped to a safe fallback.

2) **Redirect policy tests**
   - Cold start deep link:
     - while not ready → redirect to `/` and store pending
     - after ready + prerequisites satisfied → redirect to pending
   - Onboarding interception:
     - pending survives onboarding completion and resumes afterward
   - Auth interception:
     - pending survives sign-in and resumes afterward

3) **Loop prevention tests**
   - Ensure redirect does not oscillate between auth/onboarding/target.
   - Ensure pending intent is cleared exactly once.

---

## Product Rules (Confirmed)

1) **Cancel behavior (auth/onboarding)**
   - If a deep link is pending and the user explicitly cancels a prerequisite flow:
     - clear the pending intent (memory + persistence),
     - do **not** auto-resume it later,
     - require a *new* deep link to try again.
   - “Explicit cancel” includes **system back/exit** on the login screen (and equivalent back/close gestures on onboarding/auth).

---

## Where the Code Lives (Template Extension Points)

**Core deep link services**
- Parser allowlist: `lib/core/services/deep_link/deep_link_parser.dart`
- Pending intent persistence (TTL): `lib/core/services/deep_link/pending_deep_link_store.dart`
- Pending intent state + “resume/clear” hooks: `lib/core/services/deep_link/pending_deep_link_controller.dart`
- Platform listener (app_links): `lib/core/services/deep_link/deep_link_listener.dart`

**Routing**
- Central gate: `lib/navigation/app_redirect.dart`

**UX cancel behavior**
- Cancel on back/exit clears pending intent:
  - Guard widget: `lib/core/widgets/navigation/pending_deep_link_cancel_on_pop.dart`
  - Applied to routes: `lib/navigation/auth/auth_routes_list.dart`, `lib/navigation/onboarding/onboarding_routes_list.dart`

---

## Adding a New Deep Link Destination (Checklist)

Example: you want to support `https://orymu.com/settings/security` → `/settings/security`.

1) **Add the route**
   - Add route constant under `lib/navigation/*` (or feature route list).
   - Register the route in `createRouter()` (or the feature’s route list included there).

2) **Allowlist it (Dart)**
   - Add the internal path to `DeepLinkParser.allowedPaths` in `lib/core/services/deep_link/deep_link_parser.dart`.
   - Add/extend unit tests in `test/core/services/deep_link/deep_link_parser_test.dart`.

3) **Claim it (Android)**
   - Update the App Links `<intent-filter>` in `android/app/src/main/AndroidManifest.xml`:
     - add a `<data android:scheme="https" android:host="orymu.com" android:pathPrefix="/settings/security" />`
   - Keep this in sync with the Dart allowlist.

4) **Claim it (iOS)**
   - Ensure `ios/Runner/Runner.entitlements` includes:
     - `applinks:orymu.com`
   - Update the hosted AASA file path allowlist to include `/settings/security`.

5) **Update hosted verification**
   - Android `assetlinks.json` must include:
     - the package name(s) you ship,
     - signing certificate SHA-256 fingerprints,
     - correct relation targets.
   - iOS AASA must include:
     - `appID` = `TeamID.BundleID`,
     - allowed paths patterns.

6) **Redirect behavior**
   - No change is usually needed as long as:
     - the route is allowlisted, and
     - the app’s prerequisites (startup/onboarding/auth) are correctly represented in `app_redirect.dart`.

7) **Test the redirect rules**
   - Add/extend tests in `test/navigation/app_redirect_test.dart` to cover:
     - startup-not-ready capture,
     - onboarding/auth interception,
     - resume after prerequisites.

---
