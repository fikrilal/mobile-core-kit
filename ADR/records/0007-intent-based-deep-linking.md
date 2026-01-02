---
status: "accepted"
date: 2026-01-02
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [navigation, deep-linking, startup, security]
---

# Intent‑Based Deep Linking (Option C) with Safe Startup Gating

## Context and Problem Statement

This template needs deep link support that remains correct and safe under real enterprise constraints:
- the app may cold-start from a deep link,
- onboarding and authentication may be required before accessing the target screen,
- startup state (session restore, onboarding flags) may be unknown for a short period,
- deep links must not allow accidental rendering/exposure of protected screens.

We need a predictable policy that:
1) preserves deep link intent,
2) does not render protected destinations until prerequisites are satisfied,
3) supports HTTPS universal/app links,
4) avoids over-engineering.

## Decision Drivers

* Enterprise safety: protected screens must not render early.
* Correctness: resume deep links after onboarding/login.
* Consistency: centralize navigation gating in GoRouter redirect logic.
* Observability: deterministic behavior that is testable and debuggable.
* Simplicity: minimal moving parts, no route-based “splash” detours.

## Considered Options

* Option A: Preserve deep links and allow early build while startup is unknown.
* Option B: Preserve deep links and block interaction immediately (but still allow early build).
* Option C: Treat deep links as intents; hold until prerequisites are satisfied, then navigate.

## Decision Outcome

Chosen option: **Option C (intent-based deep linking)**, augmented with **Option B’s immediate interaction blocking**, because it provides the best long-term correctness and enterprise-grade safety without introducing a splash-route anti-pattern.

Specific policy decisions:
- Deep links are captured as a **pending intent**, not always navigated immediately.
- Pending intent is **persisted with a TTL (1 hour)** so it can survive process death during prerequisite flows.
- **Last intent wins** when multiple intents arrive.
- External link support includes **HTTPS** (universal/app links) for `orymu.com`, mapped to an allowlisted set of in-app destinations.
- If the user explicitly cancels onboarding/auth while an intent is pending, the pending intent is **cleared (memory + persistence)** and **not** auto-resumed later.
- Protected destinations must **not render** until:
  - `startup.isReady == true`, and
  - onboarding rules are satisfied, and
  - authentication rules are satisfied.

### Consequences

* Good, because deep links can reliably resume after onboarding/login.
* Good, because protected screens are never rendered before prerequisites are known/satisfied.
* Good, because behavior remains centralized in routing policy/redirect logic and is testable.
* Neutral, because it introduces a small “pending intent” state machine and persistence with TTL.
* Bad, because it requires careful loop prevention and clear rules for cancel/expiry behavior.

### Confirmation

This ADR is considered correctly implemented when:
- There is a deep link intent model + allowlist parser.
- Router redirect logic:
  - captures/holds intents while startup is not ready,
  - routes to onboarding/auth as required,
  - resumes to the pending deep link when allowed,
  - clears pending intent exactly once.
- Unit tests cover:
  - parsing/validation for supported HTTPS links,
  - cold start + warm start flows,
  - onboarding/auth interception and resume,
  - intent TTL expiry and last-intent-wins behavior,
  - redirect loop prevention.

## Pros and Cons of the Options

### Option A: Preserve deep links and allow early build while startup is unknown

* Good, because it is simple and preserves the incoming location naturally.
* Bad, because protected screens can build/render before prerequisites are known.
* Bad, because “resume after login/onboarding” requires additional plumbing anyway.

### Option B: Preserve deep links and block interaction immediately

* Good, because it eliminates user interaction races during startup.
* Neutral, because it does not prevent early build side effects by itself.
* Bad, because protected screens can still render early unless combined with additional logic.

### Option C: Treat deep links as intents; hold until prerequisites are satisfied, then navigate

* Good, because it enables strict “no protected render before allowed” behavior.
* Good, because it supports “resume after prerequisites” cleanly.
* Neutral, because it adds a small state machine and persistence requirements.
* Bad, because incorrect implementation can create redirect loops without tests.

## More Information

- Deep link architecture and detailed policy: `docs/engineering/deep_link_architecture.md`
- Related navigation decision: `ADR/records/0004-go-router-navigation-composition.md`
