# Profile Draft (Complete Profile form) — Engineering Proposal

## Context

We use **progressive profiling**:

- `POST /v1/auth/register` (or OIDC exchange) yields tokens and the user can be authenticated **before** profile fields are filled.
- The app gates authenticated users with missing required profile fields to **Complete Profile** (`PATCH /v1/me`).

Today, the Complete Profile form state is **in-memory only**. If the user closes/kills the app mid-form, the app will correctly gate them back to Complete Profile on next launch, but **their typed inputs are lost**.

This proposal adds a **client-only “profile draft”**: persist unsent form inputs locally so the user can resume cleanly after an interruption.

### Backend contract (source of truth)

Backend supports partial profile updates via `PATCH /v1/me`:

- Request: `PatchMeRequestDto.profile` (required)
- `PatchMeProfileDto` fields (all optional, all nullable):
  - `givenName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)
  - `familyName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)
  - `displayName` (`minLength: 1`, `maxLength: 100`, `nullable: true`)

OpenAPI reference:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

---

## Goals

- Persist unsent Complete Profile inputs (e.g. `givenName`, `familyName`) locally.
- Restore the draft automatically when the Complete Profile page is opened.
- Ensure no cross-user leakage (draft must not apply to another authenticated user).
- Keep implementation aligned with:
  - Clean Architecture boundaries (presentation ↔ domain ↔ data)
  - existing repo patterns (`SharedPreferences` stores already exist)
  - custom lints (`architecture_imports`, UI token lints, etc.)
- Keep the change **small and reversible** (template-friendly).

## Non-goals

- No backend onboarding state changes (this is not `onboarding.status`/`nextStep`).
- No “draft profile” stored on backend.
- No multi-account support (explicitly out of scope; logout/login as different user is allowed).

---

## Storage Decision

### Recommended: `SharedPreferences` (local store)

**Why it fits:**
- Draft data is small and UX-only (not a system-of-record).
- We already store similar “resume” state in `SharedPreferences`:
  - locale preference (`LocaleStore`)
  - theme mode (`ThemeModeStore`)
  - pending deep links (`PendingDeepLinkStore`)
- Avoids DB schema changes / migrations in a template repo.

### Alternatives considered

1) **SQLite (sqflite)**
- Pros: structured, queryable, durable.
- Cons: requires schema evolution and migration strategy; adds overhead for a tiny UX feature.
- Decision: not worth it for a template baseline.

2) **Secure storage**
- Pros: encrypted at rest.
- Cons: this is not sensitive data; unnecessary latency/complexity.
- Decision: reject.

---

## Data Model

### Draft entity (domain)

Create a small domain entity under user feature:

- `ProfileDraftEntity`
  - `givenName` (String)
  - `familyName` (String?) — optional
  - `updatedAt` (DateTime) — for TTL/diagnostics

Optional but recommended:
- `schemaVersion` (int) — for forward compatibility if fields evolve.

### Draft DTO (data)

`ProfileDraftLocalModel` (Freezed or simple `Map<String, dynamic>`):
- Handles JSON encode/decode and TTL validation.

### Keying and scoping

Draft must be **user-scoped**:
- Key format: `user_profile_draft:<userId>`

This ensures:
- Logout/login as a different user won’t apply the previous user’s draft.
- Leftover drafts become harmless “garbage” (optional cleanup discussed below).

### TTL (recommended)

Add TTL so drafts don’t live forever:
- Example: expire drafts after **7 days** (configurable constant).

---

## Interfaces (Clean Architecture)

### Domain

`ProfileDraftRepository`:
- `Future<ProfileDraftEntity?> getDraft({required String userId});`
- `Future<void> saveDraft({required String userId, required ProfileDraftEntity draft});`
- `Future<void> clearDraft({required String userId});`

Use cases (thin wrappers; keep boundaries + test seams):
- `GetProfileDraftUseCase`
- `SaveProfileDraftUseCase`
- `ClearProfileDraftUseCase`

### Data

`ProfileDraftLocalDataSource` (SharedPreferences):
- `Future<ProfileDraftEntity?> getDraft({required String userId});`
- `Future<void> saveDraft({required String userId, required ProfileDraftEntity draft});`
- `Future<void> clearDraft({required String userId});`

`ProfileDraftRepositoryImpl` delegates to the datasource.

### Presentation

`CompleteProfileCubit`:

1) **Load draft** on page entry:
   - Provide a `loadDraft()` method that reads draft and emits initial state.
   - Trigger it at provider creation (route builder), not in widget post-frame:
     - `BlocProvider(create: (_) => cubit..loadDraft())`

2) **Save draft** on user input (debounced):
   - On each `givenNameChanged` / `familyNameChanged`, schedule a debounced save (e.g., 300–500ms).
   - Save even when invalid (user expects “what I typed” to persist).

3) **Clear draft** after success:
   - After successful `PATCH /v1/me`, clear draft for that user.

### Race safety (session guard)

Follow the same “don’t apply stale results” pattern used in session hydration:
- Capture `accessTokenAtStart = _sessionManager.accessToken` before any async read.
- After read, confirm:
  - session still exists
  - `_sessionManager.accessToken == accessTokenAtStart`
- Only then apply draft to state.

---

## Proposed File Placement (system tree)

```
lib/features/user/
├─ data/
│  ├─ datasource/
│  │  └─ local/
│  │     └─ profile_draft_local_datasource.dart
│  ├─ model/
│  │  └─ local/
│  │     └─ profile_draft_local_model.dart
│  └─ repository/
│     └─ profile_draft_repository_impl.dart
├─ domain/
│  ├─ entity/
│  │  └─ profile_draft_entity.dart
│  ├─ repository/
│  │  └─ profile_draft_repository.dart
│  └─ usecase/
│     ├─ get_profile_draft_usecase.dart
│     ├─ save_profile_draft_usecase.dart
│     └─ clear_profile_draft_usecase.dart
├─ presentation/
│  └─ cubit/
│     └─ complete_profile/
│        └─ complete_profile_cubit.dart  # wire load/save/clear draft
└─ di/
   └─ user_module.dart                  # register datasource/repo/usecases
```

---

## Cleanup Strategy (optional)

Minimum viable behavior:
- Draft is keyed by `userId` → safe against cross-user application.
- Clear on successful profile completion.

Optional improvements:
- TTL auto-expiration (recommended).
- Clear all drafts on `SessionCleared` (requires a cross-feature hook; can be deferred).

---

## Testing Strategy

Minimum tests:
- `ProfileDraftLocalDataSource`:
  - `saveDraft` then `getDraft` returns expected values
  - `clearDraft` removes entry
  - TTL expiry returns null

Optional tests:
- `CompleteProfileCubit`:
  - `loadDraft` populates inputs and triggers validation state
  - debounce-save calls repository (using `fakeAsync`)

---

## Rollout Plan

1) Implement domain + data + DI registration (no UI changes yet).
2) Add `loadDraft()` into cubit and route wiring.
3) Add debounced save on field changes.
4) Clear on successful submit.
5) Add tests.

---

## Open Questions

- Do we want to include `displayName` in the draft now, or only after backend/client supports it in the Complete Profile UI?
- TTL duration: 7 days vs 30 days (template default)?
