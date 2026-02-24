# Push Token Sync (FCM) — How it works

## Overview

This repo implements a **template-grade** push token system focused on one job:

- obtain an **FCM registration token** (best-effort)
- upsert it to the backend for the **current session**
- revoke it on logout (best-effort)
- avoid noisy/redundant calls (dedupe + cooldown)

Non-goals (intentionally out of scope here):

- notification permission UX (when to prompt is product-driven)
- foreground/background message handling
- push-driven deep-link routing

This is designed for **guest mode** (signed-out) + **single account** (no multi-account).

---

## Backend contract (reference only)

Source of truth:

- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

Endpoints (authenticated; scoped to the **current session**):

- `PUT /v1/me/push-token` → `204`
  - body:
    - `platform`: `ANDROID | IOS | WEB`
    - `token`: string (`minLength: 1`, `maxLength: 2048`)
  - errors include:
    - `VALIDATION_FAILED`
    - `UNAUTHORIZED`
    - `PUSH_NOT_CONFIGURED` (**501**, when push provider isn’t enabled server-side)
    - `INTERNAL`
- `DELETE /v1/me/push-token` → `204`
  - errors include:
    - `UNAUTHORIZED`
    - `INTERNAL`

Important nuance:

- These calls are retried implicitly by the app’s auth/session layer (when access tokens refresh).
- Therefore requests include an `Idempotency-Key` to make retries safe.

---

## What we persist (and what we don’t)

Persisted (SharedPreferences; UX-only state):

- last-sent **session hash** (hash of refresh token)
- last-sent **token hash** (hash of FCM token)
- optional cooldown timestamp for `PUSH_NOT_CONFIGURED`

Not persisted:

- raw FCM token (never stored on disk by this subsystem)

Why “hash only”:

- it’s sufficient for dedupe/cooldown behavior
- it avoids leaking tokens into preferences backups/logs

---

## System tree (where the code lives)

Core push subsystem:

```
lib/core/platform/push/
├─ fcm_token_provider.dart                  # port: SDK wrapper
├─ fcm_token_provider_impl.dart             # adapter: FirebaseMessaging
├─ push_permission_state.dart               # enum for permission result
└─ push_platform.dart                       # ANDROID|IOS|WEB mapping

lib/core/runtime/push/
├─ push_token_registrar.dart                # port: upsert/revoke for current session
├─ push_token_sync_service.dart             # orchestrator: session + token events
└─ session_push_token_revoker_impl.dart     # adapter: revoke via registrar (best-effort)

lib/core/infra/storage/prefs/push/
└─ push_token_sync_store.dart               # SharedPreferences: hashes + cooldown

lib/core/domain/session/
└─ session_push_token_revoker.dart          # port: domain-safe revoke hook for logout
```

User feature owns `/me/*` endpoint implementation:

```
lib/features/user/data/datasource/remote/
└─ me_push_token_remote_datasource.dart     # implements PushTokenRegistrar via ApiHelper

lib/features/user/data/model/remote/
└─ me_push_token_upsert_request_model.dart  # request DTO model
```

Wiring + startup:

```
lib/core/di/service_locator.dart            # registers + inits PushTokenSyncService
lib/features/user/di/user_module.dart       # binds PushTokenRegistrar implementation
```

Logout ordering (revocation must run while session is still authenticated):

```
lib/features/auth/domain/usecase/
└─ logout_flow_usecase.dart                 # revoke push token best-effort, then logout
```

Tests:

```
test/core/infra/storage/prefs/push/
└─ push_token_sync_store_test.dart

test/core/runtime/push/
└─ push_token_sync_service_test.dart

test/features/auth/domain/usecase/
└─ logout_flow_usecase_test.dart
```

---

## Runtime behavior (step-by-step)

### 1) App startup (bootstrap)

During `bootstrapLocator()`:

- Firebase is initialized first
- then `PushTokenSyncService.init()` is called

Reason: the FCM SDK (`FirebaseMessaging`) requires Firebase initialization.

### 2) Observers are attached

On `init()`, the sync service:

- listens to `SessionManager.sessionNotifier` (session changes)
- subscribes to `FcmTokenProvider.onTokenRefresh` (token rotations)
- performs an immediate best-effort sync if a session is already active

### 3) Session becomes active → attempt upsert

When a session exists (refresh token available):

1. check platform support (`ANDROID/iOS` only; web/desktop are no-op by default)
2. enforce `PUSH_NOT_CONFIGURED` cooldown (if set)
3. get the token (best-effort; may be null)
4. dedupe (skip if same session+token already sent)
5. call `PUT /v1/me/push-token`
6. on success: persist hashes as “last sent”

### 4) Token refresh while session active → attempt upsert

When FCM rotates the token, `onTokenRefresh` emits a new token:

- if session is active → do a forced upsert (still guarded by cooldown and session-key race checks)

### 5) Error policy and safety guards

The sync is deliberately conservative:

- `UNAUTHORIZED` (`401` or `code=UNAUTHORIZED`)
  - set an in-memory “unauthorized for this session key” flag
  - stop attempting until the session changes
- `PUSH_NOT_CONFIGURED` (`501` or `code=PUSH_NOT_CONFIGURED`)
  - store a cooldown timestamp (default: 24 hours)
  - stop attempting until cooldown expires
- other errors
  - log and rely on:
    - token refresh events
    - session changes
    - a small retry cooldown (default: 15 seconds)

Race-safety:

- if the session changes while an HTTP request is in-flight, the result is ignored (prevents overwriting a new session’s state).

### 6) Logout ordering: revoke before clearing session

`DELETE /v1/me/push-token` is authenticated, so it must run **before** local tokens are cleared.

`LogoutFlowUseCase` does:

1. best-effort push token revoke (`DELETE /me/push-token`)
2. best-effort backend logout (`POST /auth/logout`)
3. always clear local session (`SessionManager.logout()`)

This is enforced via a domain-safe port:

- `lib/core/domain/session/session_push_token_revoker.dart` (port)
- `lib/core/runtime/push/session_push_token_revoker_impl.dart` (adapter)

That keeps feature domain code from importing infra/platform/runtime (`core/infra/**`, `core/platform/**`, `core/runtime/**`) directly.

---

## ASCII flow diagram

### Sync (session active / token refresh)

```
SessionManager.sessionNotifier
        |
        v
PushTokenSyncService -----------------------> PushTokenSyncStore
        |                                         |
        | (get token)                              | (dedupe + cooldown)
        v                                         v
FcmTokenProvider (port)                  SharedPreferences (hashes only)
        |
        v
FcmTokenProviderImpl
  (FirebaseMessaging)
        |
        v
PushTokenRegistrar (port)
        |
        v
MePushTokenRemoteDataSource (user feature)
        |
        v
ApiHelper -> PUT/DELETE /v1/me/push-token (backend-core-kit)
```

### Logout (revoke while still authenticated)

```
LogoutFlowUseCase (auth/domain)
        |
        v
SessionPushTokenRevoker (port in core/domain/session)
        |
        v
SessionPushTokenRevokerImpl (core/runtime)
        |
        v
PushTokenRegistrar.revoke()  ->  DELETE /v1/me/push-token
        |
        v
LogoutRemoteUseCase          ->  POST /v1/auth/logout
        |
        v
SessionManager.logout()      ->  clears local session + emits SessionCleared
```

---

## Guardrails (lint-enforced rules)

This subsystem is protected by lints so template clones don’t accidentally violate boundaries:

- `restricted_imports` bans direct `package:firebase_messaging/firebase_messaging.dart` imports
  outside of:
  - `lib/core/platform/push/**`
  - `lib/main*.dart`
- `architecture_imports` forbids feature domain imports of infra/platform/runtime (e.g. `core/infra/**`, `core/platform/**`, `core/runtime/**`).

See:

- `analysis_options.yaml` (`restricted_imports`)
- `tool/lints/architecture_lints.yaml` (Clean Architecture boundaries)

---

## Testing + verification

Fast checks:

- `flutter analyze`
- `dart run custom_lint`
- `flutter test`

Subsystem tests:

- store behavior (hash-only, dedupe, cooldown):
  - `test/core/infra/storage/prefs/push/push_token_sync_store_test.dart`
- service orchestration (session active, token refresh, cooldown):
  - `test/core/runtime/push/push_token_sync_service_test.dart`
- logout ordering and best-effort behavior:
  - `test/features/auth/domain/usecase/logout_flow_usecase_test.dart`

---

## Extension points (what to do next)

If a downstream app wants more push features, layer them without breaking this contract:

- Permission UX:
  - call `FcmTokenProvider.requestPermission()` behind a product decision (onboarding/settings)
- Message handling:
  - add a separate service for `FirebaseMessaging.onMessage` / background handlers
  - keep routing policy out of this sync layer (avoid mixing concerns)
- Web push:
  - implement a different provider that returns tokens on web, then flip the `FcmTokenProvider` binding (or add a dedicated web provider)
