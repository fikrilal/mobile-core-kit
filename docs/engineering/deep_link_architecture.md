# Deep Linking Architecture (Intent-Based, Enterprise-Safe)

This document defines the deep link approach for this repo with a focus on:
- enterprise-grade safety (no accidental exposure of protected screens),
- predictable behavior across cold/warm starts,
- minimal UX regressions,
- minimal complexity (avoid over-engineering).

It is designed to work with the existing startup architecture:
- `AppStartupController` as the source of truth for `isReady`, onboarding, and auth state.
- GoRouter redirect (`lib/navigation/app_redirect.dart`) as the central navigation gate.
- `AppStartupGate` overlay as the UI interaction gate during startup.

---

## Terms

- **Deep link**: a URL/URI that opens the app to a specific destination (screen + params).
- **Intent**: an internal representation of “navigate to X when allowed”.
- **Cold start**: app process not running.
- **Warm start**: app already running.
- **Prerequisites**: conditions required before showing a destination (startup ready, onboarding complete, authenticated).

---

## Decision: Option C (Intent-Based Deep Links)

We adopt an **intent-based** approach:
- Deep links are captured as a **pending intent** and are not necessarily navigated immediately.
- Routing to the final target happens only when prerequisites are satisfied.

### Why Option C

Option C provides the cleanest long-term behavior for enterprise apps:
- Supports “resume deep link after onboarding/login” reliably.
- Prevents protected screens from rendering before auth/onboarding are known.
- Scales to additional prerequisites later (forced upgrade, remote config, org selection).

### Additional safety rule (recommended)

To eliminate startup races, we also enforce:
- **No user interaction before `startup.isReady`** (Option B’s interaction-blocking concept).

This can be implemented as an immediate (invisible) input barrier, while the visible overlay still respects the `showDelay` to avoid flicker.

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

This is the core logic Option C relies on.

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

Even with Option C (which redirects to `/` while not ready), we still recommend:
- block interaction immediately while not ready (invisible barrier),
- show a visible overlay only after a short delay (to avoid flicker).

Reason: it prevents edge cases where something becomes briefly interactive during startup transitions, and it avoids test flakiness.

### “Opening link…” experience (optional)

If a deep link is pending and prerequisites are being satisfied (e.g., user must sign in):
- show a small message in the auth/onboarding UI: “Continue to requested link after sign-in”.

This reduces confusion and increases trust.

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

## Recommended Implementation Phases (Pragmatic)

1) **Phase 1: Internal intent + redirect wiring**
   - Define `DeepLinkIntent` + allowlist-based parser.
   - Add `PendingDeepLinkController`.
   - Integrate with GoRouter redirect with the “not-ready → `/`” rule.

2) **Phase 2: Platform sources**
   - Add the specific platform deep link sources needed by the product:
     - universal/app links,
     - custom scheme,
     - push notification routing.
   - This repo uses `app_links` and a `DeepLinkListener` to listen for:
     - the initial cold-start link,
     - subsequent links while the app is running.
   - Platform setup (HTTPS `orymu.com`):
     - Android: disable Flutter deep linking (`flutter_deeplinking_enabled=false`), add an `intent-filter` (with `android:autoVerify="true"`) and host `/.well-known/assetlinks.json`.
     - iOS: disable Flutter deep linking (`FlutterDeepLinkingEnabled=false`), enable Associated Domains (`applinks:orymu.com`) and host `/.well-known/apple-app-site-association`.
     - Keep `DeepLinkParser` allowlists in sync with what the app claims to handle.

3) **Phase 3: Deferred resume**
   - Ensure “resume after onboarding/login” is airtight.
   - Add UX messaging and analytics if required.

---

## Product Rules (Confirmed)

1) **Cancel behavior (auth/onboarding)**
   - If a deep link is pending and the user explicitly cancels a prerequisite flow:
     - clear the pending intent (memory + persistence),
     - do **not** auto-resume it later,
     - require a *new* deep link to try again.
   - “Explicit cancel” includes **system back/exit** on the login screen (and equivalent back/close gestures on onboarding/auth).
