# Dependency Inversion Principle (DIP)

This explainer teaches the **Dependency Inversion Principle (DIP)** and how this repo applies it
in day-to-day architecture decisions.

> TL;DR: **domain policy must not depend on infrastructure details**. Both depend on **abstractions**
> (ports). Infrastructure implements those abstractions (adapters).

---

## 1) What DIP is (in plain language)

The Dependency Inversion Principle has three core statements:

1. **High-level policy** code should not depend on **low-level detail** code.
2. Both should depend on **abstractions**.
3. Abstractions should not depend on details; **details depend on abstractions**.

This is about **dependency direction**, not “importance”.

---

## 2) Why we care (template-grade reasons)

This repo is a **template**. DIP keeps clones maintainable because it:

- **Stabilizes** business/policy code when infra changes (SDK upgrades, backend changes, storage swaps).
- Improves **testability** (domain use cases can be unit-tested without platform channels).
- Enables **portability** (domain code remains Dart-first and can move to packages).
- Reduces **refactor cost** (changing network/storage doesn’t force edits in use cases).
- Keeps responsibilities clear (“what we do” vs “how we do it”).

---

## 3) What “high-level” vs “low-level” means here

### High-level (policy / intent / stable)

Typically:
- `lib/features/*/domain/**`
    - use cases (`*_usecase.dart`)
    - entities / value objects
    - repository interfaces

Examples:
- “When logging out, clear the local session.”
- “When completing profile, validate inputs and submit.”

### Low-level (mechanisms / details / volatile)

Typically:
- `lib/core/network/**` (HTTP, interceptors, retries)
- `lib/core/storage/**` (secure storage / preferences wrappers)
- `lib/core/database/**` (sqflite)
- `lib/core/services/**` (SDK wrappers: Firebase, Google sign-in, device info, etc.)
- `lib/features/*/data/**` (remote/local datasources, DTO models, repository implementations)

Examples:
- “How do we attach auth headers?”
- “How do we persist tokens?”
- “How do we call `PUT /me/push-token`?”

---

## 4) How the repo enforces DIP (guardrails)

This repo enforces the dependency direction via custom lints:

- Architecture import boundaries:
    - `tool/lints/architecture_lints.yaml`
    - Notably: `feature_domain_no_infra` blocks feature domain code from importing:
        - `lib/core/services/**`
        - `lib/core/network/**`
        - `lib/core/storage/**`
        - `lib/core/database/**`

- Restricted imports (low-level packages):
    - `analysis_options.yaml` (`restricted_imports`)
    - Example: feature code can’t import `dio`, `shared_preferences`, Firebase SDKs, etc. directly.

This is intentional: **the lints encode the architecture**, so it stays consistent across cloned
projects and across reviewers.

---

## 5) The practical pattern: ports and adapters

When domain needs an IO capability, you do **not** import infra.

Instead:

1) Define a **port** (interface) that expresses what domain wants.
2) Implement it in the **data/infra edge** (adapter).
3) Wire it together in DI (`lib/core/di/service_locator.dart` and feature modules).

### Vocabulary mapping

- **Port** = interface (abstraction) that domain depends on.
- **Adapter** = implementation of that interface using HTTP/SDK/storage.

---

## 6) Example from this repo: push token revoke on logout

Goal:
- On logout, revoke the current session’s push token on the backend (`DELETE /me/push-token`).

Constraints:
- Logout orchestration is a feature **domain** use case:
    - `lib/features/auth/domain/usecase/logout_flow_usecase.dart`
- Domain cannot import `lib/core/services/**` (enforced by `feature_domain_no_infra`).

Solution (DIP):

### Port (domain-safe contract)

- `lib/core/session/session_push_token_revoker.dart`

This interface is placed under `core/session/**` because it models **session teardown policy** and
because feature domain is allowed to depend on `core/session` but not on `core/services`.

### Adapter (infra implementation)

- `lib/core/services/push/session_push_token_revoker_impl.dart`

This implementation can depend on infra (HTTP wrapper / registrar) because it’s in `core/services`.

### Consumer (policy)

- `lib/features/auth/domain/usecase/logout_flow_usecase.dart`

The use case depends only on the **port**:
- it calls `SessionPushTokenRevoker.revoke()` best-effort
- then calls remote logout best-effort
- then always clears local session

That keeps logout policy stable even if:
- the push provider changes (FCM/APNs/web push),
- the endpoint changes,
- we add backoff/queueing in the implementation.

---

## 7) Another common example: token refresh orchestration

Token refresh touches HTTP and storage, but session policy should remain stable.

Pattern:

- Policy/orchestration:
    - `lib/core/session/session_manager.dart` (session lifecycle)
- Port:
    - `lib/core/session/token_refresher.dart` (interface)
- Adapter:
    - Provided by feature data/repo (e.g. auth repository implements refresh using backend endpoints)

The session manager doesn’t “know” how refresh is implemented; it knows only “I can request a refresh”.

---

## 8) Rules of thumb (what to do when you’re coding)

### ✅ Do

- Keep `features/*/domain/**` pure (no SDKs, no HTTP, no DB).
- Model domain needs via **interfaces**.
- Put the implementation at the edges:
    - feature `data/**` for feature-owned endpoints/storage
    - `core/services/**` for SDK/platform wrappers
    - `core/network/**` for HTTP infrastructure
- Wire dependencies in DI, not inside domain constructors.
- When in doubt: follow existing patterns:
    - `GoogleFederatedAuthService` / `GoogleFederatedAuthServiceImpl`
    - `TokenRefresher` (port)
    - `CurrentUserFetcher` (port)

### ❌ Don’t

- Don’t import `ApiHelper` / `Dio` / Firebase SDK / `SharedPreferences` inside domain use cases.
- Don’t let business/policy code depend on platform details.
- Don’t “just add an exception” to lints unless there is a strong, documented reason.

---

## 9) Quick check (how to verify you’re following DIP)

- Run:
    - `tool/agent/dartw --no-stdin run custom_lint`
- If you violated the boundary, you’ll typically see:
    - `architecture_imports` error like `feature_domain_no_infra`
    - `restricted_imports` error if you imported a banned low-level package

---

## 10) Where to put new ports in this repo (convention)

This repo uses a pragmatic “core kernel” approach:

- If the port is about **session lifecycle** (logout, refresh, hydration), prefer:
    - `lib/core/session/**`
- If it is a pure “core contract” used by many features, consider adding a dedicated folder:
    - `lib/core/contracts/**` (only if we see recurring need; propose before adding)
- Implementations typically live in:
    - `lib/core/services/**` (SDK/platform)
    - `lib/features/*/data/**` (feature-owned backend/data)

---

## 11) Related docs

- Guardrails / boundaries:
    - `docs/engineering/architecture_linting.md`
    - `tool/lints/architecture_lints.yaml`
- Data/Domain responsibilities:
    - `docs/engineering/data_domain_guide.md`
