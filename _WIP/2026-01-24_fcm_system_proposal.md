# Proposal — FCM Push Token Registration (mobile-core-kit ↔ backend-core-kit)

**Repo:** `mobile-core-kit`  
**Backend contract source:** `backend-core-kit` (`/mnt/c/Development/_CORE/backend-core-kit`)  
**Date:** 2026-01-24  
**Status:** Proposal (ready to implement)  

## Summary

Implement a **template-grade** FCM system that:

- Obtains the **FCM registration token** on device (best-effort).
- Syncs that token to the backend **for the current session**.
- Revokes the token for the current session on logout (best-effort).
- Avoids noisy / redundant network calls (session-scoped + “last-sent” cache).
- Avoids opinionated UX (no forced permission prompts at startup).

This proposal focuses on **token registration + backend sync** (not message UI/handlers).

---

## Backend contract (source of truth)

From OpenAPI:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

Endpoints (authenticated; access-token required; scoped to the **current session**):

### `PUT /v1/me/push-token` → `204`

- Description: stores FCM registration token for the current session; idempotent; replaces existing.
- Body: `MePushTokenUpsertRequestDto`
  - `platform`: `ANDROID | IOS | WEB`
  - `token`: string (`minLength: 1`, `maxLength: 2048`)
- Errors:
  - `VALIDATION_FAILED`
  - `UNAUTHORIZED`
  - `PUSH_NOT_CONFIGURED` (**501**, when backend push provider isn’t enabled)
  - `INTERNAL`

### `DELETE /v1/me/push-token` → `204`

- Description: clears stored push token for the current session; idempotent.
- Errors:
  - `UNAUTHORIZED`
  - `INTERNAL`

Implementation reference in backend:
- Controller: `/mnt/c/Development/_CORE/backend-core-kit/libs/features/auth/infra/http/me-push-token.controller.ts`
- DTO validation: `/mnt/c/Development/_CORE/backend-core-kit/libs/features/auth/infra/http/dtos/me-push-token.dto.ts`

Backend configuration prerequisites:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/configuration.md` (“Push (FCM)”)

---

## Current mobile status (verified)

As of 2026-01-24, mobile has **no FCM system implementation**:

- `firebase_messaging` is in `pubspec.yaml`, but there are **no Dart references** to:
  - `FirebaseMessaging`
  - `getToken()`
  - `onTokenRefresh`
  - `requestPermission()`
- No endpoint constant for `/me/push-token`:
  - `lib/core/network/endpoints/user_endpoint.dart` only exposes `me = '/me'`.
- No datasource/repo/usecase calling `PUT/DELETE /me/push-token`.
- No session hook that syncs push token on login/session restore/logout.

Therefore the app **never registers** its push token with backend-core-kit today.

---

## Goals

- Implement push token registration **correctly** (session-scoped; idempotent).
- Support guest mode (no session) by simply doing nothing.
- Avoid multi-account complexity (explicitly out of scope; template has guest mode, not multi-account).
- Keep changes:
  - small and reversible
  - aligned with Clean Architecture boundaries
  - aligned with existing core session system (`SessionManager`)
  - aligned with the existing API layer (`ApiHelper`, `ApiHost`)

---

## Non-goals (for this proposal)

- Push notification UI/UX (permissions prompts, onboarding flows, settings screens).
- Foreground/background message handling & deep-link routing from push payloads.
- Rich notification features (channels, categories, custom sounds, etc.).

Those can be layered later, once token sync is stable.

---

## Recommended approach (architecture)

### Why orchestration is core, but `/me/*` API calls are user-owned

Push token sync is **cross-cutting**:
- It depends on the session lifecycle (login/restore/logout).
- It must be kept consistent regardless of which feature is on screen.
- It should not introduce feature-to-feature imports.

So the **orchestration** belongs under `lib/core/services/` (template-level infrastructure).

However, the backend endpoint is `/v1/me/push-token`, which belongs to the **User** surface (`/me/*`).
To keep ownership clear and avoid “core becomes a god layer”, we follow the existing pattern used by
`TokenRefresher` and `CurrentUserFetcher`:

- Core defines an abstraction (`PushTokenRegistrar`).
- The user feature provides the implementation via DI (so `/me/*` stays feature-owned).

### Proposed components

#### 1) `FcmTokenProvider` (SDK wrapper)

Location: `lib/core/services/push/fcm_token_provider.dart`  
Responsibilities:
- Read the current FCM token:
  - `Future<String?> getToken()`
- Token refresh stream:
  - `Stream<String> onTokenRefresh`
- Optional permission operations (platform-dependent):
  - `Future<PushPermissionState> requestPermission()`

Policy:
- No networking.
- No session logic.
- Best-effort: a null token is acceptable (especially on iOS until APNS/permission is configured).

#### 2) `PushTokenRegistrar` (core abstraction) + user feature implementation

Core interface:
- `lib/core/services/push/push_token_registrar.dart`

User feature implementation:
- `lib/features/user/data/datasource/remote/me_push_token_remote_datasource.dart`
  - uses `ApiHelper` with:
    - `host: ApiHost.profile` (matches other `/me` calls)
    - `requiresAuth: true`
    - `throwOnError: false` (matches our datasource policy guardrail)
  - endpoint constant:
    - `UserEndpoint.mePushToken = '/me/push-token'`

#### 3) `PushTokenSyncStore` (dedupe + cooldown)

Location: `lib/core/services/push/push_token_sync_store.dart`  
Storage: `SharedPreferences` (fits: small, UX-only, template-friendly).

Stores:
- `lastSentSessionId` (string)
- `lastSentTokenHash` (string; hash only, do not store raw token)
- optional: `pushNotConfiguredUntilEpochMs` (cooldown for `PUSH_NOT_CONFIGURED`)

Why:
- Avoid PUT on every cold start when nothing changed.
- Avoid spamming backend when push is disabled server-side.

#### 4) `PushTokenSyncService` (orchestration)

Location: `lib/core/services/push/push_token_sync_service.dart`  
Responsibilities:
- Observe session lifecycle:
  - listen to `SessionManager.stream` (or `sessionNotifier`)
  - when session becomes authenticated → attempt upsert (if token available and not already sent)
  - when session cleared → cancel listeners (no backend call here; too late for auth)
- Observe token refresh:
  - subscribe to `FcmTokenProvider.onTokenRefresh`
  - if session active → upsert
- Decide “when to call backend”:
  - if `PUSH_NOT_CONFIGURED` → store cooldown and stop until cooldown passes
  - if `UNAUTHORIZED` → stop quietly (session already invalid)
  - other errors → log + retry later (next refresh / next session event)

#### Logout revocation (important)

Backend revoke is authenticated → we must revoke **before** local session is cleared.

Recommended: update `LogoutFlowUseCase` (`lib/features/auth/domain/usecase/logout_flow_usecase.dart`) to run:
1) best-effort `DELETE /me/push-token` (`requiresAuth: true`)
2) existing best-effort `POST /auth/logout` (already present)
3) always `SessionManager.logout()`

This keeps the revoke possible without changing `SessionManager` semantics.

---

## Platform mapping (backend `platform`)

Backend expects `ANDROID | IOS | WEB`. In Flutter template:
- Android → `ANDROID`
- iOS → `IOS`
- Web → `WEB` (template includes web folder; if web push isn’t supported, we can no-op or disable on web)

Recommendation: implement a single helper:
- `PushPlatform.current` that returns the enum/string expected by the backend.

---

## Permission strategy (enterprise default)

Default behavior (recommended for a template):

- Do **not** auto-prompt notification permission at app startup.
- Token sync service can still:
  - attempt `getToken()` best-effort
  - no-op if null (common on iOS before permission/APNS token)
- Provide a separate “permission request” surface later (onboarding/settings) when product decides.

This avoids hardcoding product UX into the template.

---

## Observability & logging

Log policy:
- Log only coarse outcomes (success/failure), never full token.
- Prefer hashed token when needed for debugging.
- Use existing `Log.*` utilities.

---

## Testing strategy (must-have for template)

Unit tests:
- `PushTokenSyncStore`:
  - stores and compares last sent sessionId + tokenHash
  - cooldown behavior for `PUSH_NOT_CONFIGURED`
- `PushTokenSyncService`:
  - session becomes active + token present → calls upsert once
  - token refresh event while session active → upsert
  - session cleared → stops syncing
  - `PUSH_NOT_CONFIGURED` triggers cooldown
- `LogoutFlowUseCase`:
  - best-effort revoke does not block local logout

Integration tests:
- Optional later (requires emulator + FCM setup).

---

## Rollout plan (phased)

**Phase 1 (recommended now):** token sync + revoke only.  
**Phase 2 (later):** foreground/background handlers and push payload routing.  
**Phase 3 (later):** UI flows (permission prompts, settings toggles, etc.).

---

## Open decisions (need confirmation before implementation)

1) Scope:
   - Token sync + revoke only (recommended), or also message handlers now?
2) Cooldown duration for `PUSH_NOT_CONFIGURED`:
   - Suggested default: 24 hours.
3) Web:
   - Treat as supported platform with best-effort (likely null token), or disable entirely for web builds?
