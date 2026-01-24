# TODO — Implement FCM Push Token Sync (mobile-core-kit)

**Repo:** `mobile-core-kit`  
**Backend:** `/mnt/c/Development/_CORE/backend-core-kit`  
**Date:** 2026-01-24  
**Status:** In progress (Phases 0–4 complete)  

Implements the proposal:
- `_WIP/2026-01-24_fcm_system_proposal.md`

## Objective

Implement a template-grade FCM token system that:

- obtains the device FCM registration token (best-effort)
- registers/updates it to backend-core-kit for the **current session**
- revokes the token for the current session on logout (best-effort)
- avoids noisy repeated calls (dedupe + cooldown)

Non-goals for this TODO:
- foreground/background push message handling
- push-driven deep-link routing
- product UX for notification permission prompts

---

## Phase 0 — Confirm contracts + decisions

- [x] Re-check OpenAPI contract (source of truth):
  - [x] `PUT /v1/me/push-token` (`204`, body `{platform, token}`)
  - [x] `DELETE /v1/me/push-token` (`204`)
  - [x] Error codes include `PUSH_NOT_CONFIGURED` (501)
  - [x] File: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
- [x] Confirm mobile host choice:
  - [x] Use `ApiHost.profile` for `/me/push-token` (matches existing `/me` usage)
- [x] Confirm default behavior:
  - [x] Do **not** prompt for notification permissions at startup (product decides when/where)
- [x] Confirm `PUSH_NOT_CONFIGURED` cooldown duration:
  - [x] Default: 24 hours (template-level; can be tuned by downstream apps)
- [x] Confirm web policy:
  - [x] Disabled-by-default on web (best-effort no-op) unless a downstream app explicitly configures web push

---

## Phase 1 — Networking surface (API contract)

- [x] Add endpoint constant:
  - [x] `lib/core/network/endpoints/user_endpoint.dart`
    - [x] `static const String mePushToken = '/me/push-token';`
- [x] Add core abstraction + feature implementation:
  - [x] Core interface: `lib/core/services/push/push_token_registrar.dart`
  - [x] User feature impl: `lib/features/user/data/datasource/remote/me_push_token_remote_datasource.dart`
  - [x] DI binding: `lib/features/user/di/user_module.dart`
- [x] Add simple backend platform mapping:
  - [x] `lib/core/services/push/push_platform.dart` (`ANDROID|IOS|WEB`)

---

## Phase 2 — FCM SDK wrapper

- [x] Add provider:
  - [x] `lib/core/services/push/fcm_token_provider.dart`
    - [x] wraps `FirebaseMessaging`
    - [x] `Future<String?> getToken()`
    - [x] `Stream<String> onTokenRefresh`
    - [x] `Future<PushPermissionState> requestPermission()` (optional; no UX wiring yet)
- [x] Add a `restricted_imports` rule for `firebase_messaging`:
  - [x] Allow only `lib/core/services/push/**` and `lib/main*.dart`

---

## Phase 3 — Dedupe store (SharedPreferences)

- [x] Add store:
  - [x] `lib/core/services/push/push_token_sync_store.dart`
    - [x] Store `lastSentSessionHash` (hash only)
    - [x] Store `lastSentTokenHash` (hash only)
    - [x] Store optional `pushNotConfiguredUntilMs`
  - [x] Hash policy:
    - [x] Use a stable deterministic hash (FNV-1a 64-bit)
    - [x] Never store raw FCM token

---

## Phase 4 — Orchestration service

- [x] Add `PushTokenSyncService`:
  - [x] `lib/core/services/push/push_token_sync_service.dart`
  - [x] Listens to `SessionManager.sessionNotifier` (session active/cleared)
  - [x] Subscribes to `FcmTokenProvider.onTokenRefresh`
  - [x] On session active:
    - [x] fetch token (best-effort)
    - [x] if token != null and not deduped → `PUT /me/push-token`
  - [x] On token refresh:
    - [x] if session active → `PUT /me/push-token`
  - [x] Error policy:
    - [x] `UNAUTHORIZED` → stop quietly for the current session key
    - [x] `PUSH_NOT_CONFIGURED` → store cooldown and stop until expiry
    - [x] other errors → log + retry later (no last-sent persisted)

---

## Phase 5 — DI + bootstrap

- [ ] Register in DI:
  - [ ] `lib/core/di/service_locator.dart`
    - [ ] register `FcmTokenProvider`
    - [ ] register (or rely on user module binding) `PushTokenRegistrar`
    - [ ] register `PushTokenSyncStore`
    - [ ] register `PushTokenSyncService`
- [ ] Bootstrap in `bootstrapLocator()`:
  - [ ] call `PushTokenSyncService.init()` after:
    - [ ] Firebase initialization
    - [ ] `SessionManager.init()`

---

## Phase 6 — Logout revocation (best-effort)

- [ ] Update `LogoutFlowUseCase`:
  - [ ] `lib/features/auth/domain/usecase/logout_flow_usecase.dart`
  - [ ] Order:
    1. [ ] best-effort `DELETE /me/push-token` (requiresAuth: true)
    2. [ ] existing best-effort `POST /auth/logout`
    3. [ ] always `SessionManager.logout()`
- [ ] Ensure failures never block local logout.

---

## Phase 7 — Tests

- [ ] Unit tests:
  - [ ] `PushTokenSyncStore` (dedupe + cooldown)
  - [ ] `PushTokenSyncService`:
    - [ ] session active + token present → upsert once
    - [ ] token refresh while session active → upsert
    - [ ] `PUSH_NOT_CONFIGURED` sets cooldown
  - [ ] `LogoutFlowUseCase`:
    - [ ] revoke failure doesn’t prevent local logout

---

## Phase 8 — Verification

- [ ] `tool/agent/flutterw --no-stdin analyze`
- [ ] `tool/agent/dartw --no-stdin run custom_lint`
- [ ] `tool/agent/flutterw --no-stdin test`
- [ ] (Optional full gate) `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`
