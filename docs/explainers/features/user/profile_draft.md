# Profile Draft (Complete Profile form) — How it works

## Overview

This repo uses **progressive profiling**:

- Auth flows (`POST /v1/auth/register`, OIDC exchange) return tokens early.
- The user can be authenticated while required profile fields are still missing.
- The app gates authenticated users with incomplete profile fields to the **Complete Profile** page (`PATCH /v1/me`).

If the user closes/kills the app mid-form, the app will gate them back correctly on next launch, but without persistence they would **lose their typed inputs**.

“Profile draft” is a **client-only** persistence layer for *unsent* Complete Profile inputs. It lets the user resume the form with their previous inputs restored.

This is **not** backend onboarding state, and it does not introduce `onboarding.status` / `nextStep` concepts.

---

## Backend contract (reference only)

Backend supports partial updates for the current user:

- Endpoint: `PATCH /v1/me`
- Payload: `PatchMeRequestDto.profile` (required)
- Fields (all optional, nullable):
  - `profile.givenName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)
  - `profile.familyName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)
  - `profile.displayName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)

Source of truth:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

---

## What we persist (and what we don’t)

Drafts are intentionally treated as *UI state*, not “user state”:

- Drafts can be invalid, partially typed, or untrimmed.
- Drafts are never used to render “current user” elsewhere in the app.
- Drafts are never sent to the backend as-is.

Drafts must be **user-scoped**:

- A saved draft for user A must not apply to user B after logout/login.

---

## Persistence strategy

Drafts are stored in `SharedPreferences` because:

- The payload is tiny and UX-only (not a system-of-record).
- It avoids sqflite schema changes and migrations.
- This repo already uses SharedPreferences for similar “resume/prefs” state (locale, theme mode, pending deep links).

---

## System tree (where the code lives)

```
lib/features/user/
├─ data/
│  ├─ datasource/
│  │  └─ local/
│  │     └─ profile_draft_local_datasource.dart   # SharedPreferences + TTL
│  ├─ model/
│  │  └─ local/
│  │     └─ profile_draft_local_model.dart        # JSON encode/decode
│  └─ repository/
│     └─ profile_draft_repository_impl.dart       # domain adapter
├─ domain/
│  ├─ entity/
│  │  └─ profile_draft_entity.dart                # client-only draft entity
│  ├─ repository/
│  │  └─ profile_draft_repository.dart
│  └─ usecase/
│     ├─ get_profile_draft_usecase.dart
│     ├─ save_profile_draft_usecase.dart
│     └─ clear_profile_draft_usecase.dart
├─ presentation/
│  └─ cubit/
│     └─ complete_profile/
│        └─ complete_profile_cubit.dart           # loads/saves/clears draft
└─ di/
   └─ user_module.dart                            # DI wiring

lib/navigation/user/
└─ user_routes_list.dart                           # cubit creation triggers loadDraft()
```

Tests:

```
test/features/user/
├─ data/datasource/local/profile_draft_local_datasource_test.dart
└─ presentation/cubit/complete_profile/complete_profile_cubit_test.dart
```

---

## Local data contract

### Keying

Drafts are stored per-user:

- Key prefix: `user_profile_draft:`
- Full key: `user_profile_draft:<userId>`

This prevents applying a draft to the wrong user after logout/login.

### TTL

Drafts expire on read:

- Default TTL: `Duration(days: 7)`
- If expired or payload is invalid JSON → the stored key is removed (fail safe).

---

## Runtime behavior (step-by-step)

### 1) Load: route entry

The draft is loaded when the Complete Profile route is built:

- In `lib/navigation/user/user_routes_list.dart`, we create the cubit and immediately call:
  - `locator<CompleteProfileCubit>()..loadDraft()`

No widget post-frame work is used; it matches the repo’s UI-state guide.

### 2) Apply: safety rules

In `CompleteProfileCubit.loadDraft()`:

- We read the current `userId` from the active session.
- We fetch the draft for that `userId`.
- Before applying, we enforce:
  - **Same-user guard:** if the session changed (different `userId`), do not apply.
  - **No overwrite guard:** if the user already typed into a field while the async read was in-flight, we don’t overwrite non-empty state.

### 3) Save: user typing (debounced)

On every `givenNameChanged` / `familyNameChanged`:

- Schedule a debounced write (uses `MotionDurations.long`).
- The draft saves the raw current text (even if invalid) so “what I typed” is preserved.

### 4) Clear: after success

On successful `PATCH /v1/me`:

- The cubit clears the draft for the current `userId`.

This ensures the draft doesn’t linger once profile completion is successful.

---

## Why drafts are not stored in the cached user table

The cached user (sqflite) table stores **authoritative** user state (“what we believe the backend returned”).

A profile draft is **unsent and potentially invalid** input. Mixing the two would:

- blur data ownership (backend state vs in-progress UI),
- complicate hydration logic (what should be shown as current user?),
- require additional guardrails around validation and overwrites.

Keeping drafts separate preserves clean separation of concerns.

---

## Troubleshooting (quick)

- “Draft doesn’t restore”: confirm the session has a non-null `userId` (drafts are per-user key).
- “Draft restores old data”: check TTL window (defaults to 7 days) and confirm successful submit calls `clearDraft`.
- “Draft applied to wrong account”: this should be prevented by userId scoping + same-user guard; if it happens, it’s a bug in the guard logic.

---

## Optional follow-ups

- Clear drafts on `SessionCleared` / `SessionExpired` events (hygiene; not required for safety).
- Add a debounce-save unit test (requires `fakeAsync`).
