# Proposal — Return “Me” snapshot on login/register (reduce `/me` calls + avoid post-login redirect blip)

**Repo:** `mobile-core-kit`  
**Backend:** `/mnt/c/Development/_CORE/backend-core-kit`  
**Date:** 2026-01-25  
**Status:** Proposal (backend-first)  

## Context (problem)

Today, auth endpoints return a **minimal user** payload (`AuthUserDto`) that is not sufficient to decide:

- “is the user hydrated?” (roles/profile completeness)
- “should we send the user to Complete Profile?”

In the current mobile implementation:

- `AuthUserDto` → `AuthUserModel` → `UserEntity` (id/email/emailVerified/authMethods only).
- `AppStartupController.needsUserHydration` treats `roles.isEmpty` as a hydration marker:
  - auth-derived user → `roles=[]` → triggers `GET /v1/me`
- Routing rules can momentarily decide “Home” before `/me` returns, then quickly redirect to:
  - `UserRoutes.completeProfile`

Result: **UX blip/glitch** (“home flash” → “complete profile”).

We also want to reduce redundant `/me` calls on login/register for template performance and backend efficiency.

---

## Goal

Return a **“Me-equivalent snapshot”** directly from:

- `POST /v1/auth/login`
- `POST /v1/auth/register`
- (and any auth entrypoint that establishes a new session: e.g. OIDC exchange)

So the client can:

- decide profile completion **immediately** after login/register
- avoid calling `GET /v1/me` in the common case

---

## Non-goals

- Multi-account support (template supports guest mode, not account switching).
- Server-side onboarding state (`onboarding.status`, `nextStep`, etc.). We intentionally rely on `/me` fields for progressive profiling.
- Changing “profile completion” definition (still client-driven based on `/me` fields).
- Removing `GET /v1/me` entirely (it remains canonical and is still used for refresh/hydration when needed).

---

## Recommended approach (contract)

### Backend (preferred): `AuthResultDto.user` becomes a “Me snapshot”

Change auth success responses so the returned `user` is **shape-compatible with `MeDto`** (or directly reuse `MeDto`):

- include: `id`, `email`, `emailVerified`, `roles`, `authMethods`, `profile`, `accountDeletion` (and any other fields `MeDto` guarantees)
- exclude: any sensitive/internal-only fields

Why this is best:

- avoids DTO drift (“auth user” vs “me user”)
- aligns with the client’s progressive profiling flow (client can check missing fields immediately)
- reduces `/me` calls without introducing “magic flags”

### Hydration marker compatibility

Current mobile uses `roles.isEmpty` as a hydration marker. For this proposal to fully eliminate the post-login blip without extra client refactors:

- Ensure auth responses include `roles` and that it is **non-empty** for normal users (e.g. at least `["USER"]`).

This makes:

- `needsUserHydration == false` immediately
- `needsProfileCompletion` evaluable immediately

> If you *don’t* want to rely on “roles non-empty”, an alternative is to introduce an explicit hydration marker (see “Alternatives” below). The “roles marker” is the smallest delta given the current template behavior.

---

## Mobile changes (to consume the new contract)

1) **Model alignment**

Update the auth result parsing so the auth `user` uses the **same structure** as `/v1/me`:

- Option A (preferred): reuse the existing `MeModel` in `AuthResultModel.user`
  - eliminates duplicate DTO maintenance
  - guarantees parity with `/me` mapping logic
- Option B: extend `AuthUserModel` to match `MeDto` exactly (higher drift risk)

2) **Entity mapping**

Ensure the session stored by `SessionManager.login(session)` contains the full `UserEntity`:

- `roles` populated
- `profile` populated (even if incomplete)

3) **Routing impact**

With “Me snapshot” present immediately:

- auth zone → redirect goes directly to:
  - `UserRoutes.completeProfile` (if incomplete), or
  - pending deep link, or
  - `AppRoutes.home`

No intermediate “home flash”.

4) **Tests (must-have)**

Update/add redirect tests to lock the UX:

- When authed + roles present + `givenName` missing → auth route redirects **directly** to `UserRoutes.completeProfile` (no `/home` intermediate decision).

---

## Backend implementation notes (high-level)

In backend-core-kit:

- Update OpenAPI schemas so `AuthResultDto.user` references `MeDto` (or a `MeSnapshotDto` that is identical).
- Ensure auth service builds the “me snapshot” from the same query/mapping used by `GET /v1/me`.
  - This is a best practice to prevent contract drift.
- Keep token refresh responses minimal (recommended):
  - token refresh can be frequent; avoid returning full user there unless you have a strong reason.

---

## Rollout plan

1) Backend:
   - update OpenAPI + server implementation
   - add/adjust tests for login/register response shape
2) Mobile:
   - update auth models + mapping to accept the new shape
   - add redirect test coverage
   - run `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`
3) Later (separate change):
   - implement the **post-auth gate route** to cover remaining edge cases (cold start/hydration failure/offline), even if auth payload is “full”.

---

## Risks & mitigations

### Risk: “auth user” and “me user” drift over time
Mitigation:

- use `MeDto` (or a shared “me snapshot” builder) as the *only* schema/mapping

### Risk: larger auth response payload
Mitigation:

- keep it limited to what `/me` already returns
- avoid returning full user on token refresh

### Risk: relying on `roles` being non-empty
Mitigation:

- backend guarantees a baseline role (e.g. `USER`)
- or move later to an explicit hydration marker (see below)

---

## Alternatives (rejected / later)

1) **Gate route only (no backend changes)**
   - Fixes the UX globally, but doesn’t reduce `/me` calls for login/register.
   - Still recommended later for cold-start edge cases, but not sufficient for the “reduce `/me` calls” goal.

2) **Introduce server onboarding state**
   - `onboarding: {status, nextStep}` etc.
   - Adds backend orchestration complexity and cross-platform coordination cost.
   - We prefer progressive profiling driven by `/me` fields (client decides UI).

3) **Add explicit hydration marker**
   - e.g. `userSnapshotVersion` / `isMeSnapshot=true`
   - More robust than the “roles marker”, but requires additional contract and client logic.
   - Consider this if roles can legitimately be empty.

