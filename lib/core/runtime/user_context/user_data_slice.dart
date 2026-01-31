// User-scoped data slice (template pattern) — documentation stub.
//
// This file intentionally contains NO implementation.
//
// Why it exists:
// - This repo is a template; teams tend to reinvent “user-scoped caches” in
//   slightly different ways.
// - `UserDataSlice<T>` is a recommended scaling pattern ONLY WHEN you have
//   2+ user-scoped data needs reused across screens/services.
//
// Current status:
// - Deferred by design (see `_WIP/examples/todo_document_example_auth_user_hardening.md`).
// - The system today intentionally stops at:
//   - `SessionManager` (session lifecycle)
//   - `CurrentUserFetcher` (core abstraction for GET /me)
//   - `UserContextService` (UI-friendly current user access + explicit refresh)
//
// ---------------------------------------------------------------------------
// When to introduce a slice
// ---------------------------------------------------------------------------
// Add a `UserDataSlice<T>` only if at least one of these is true:
//
// 1) Duplication exists:
//    - Multiple screens/services fetch the same user-scoped data and each
//      reimplements caching, TTL, and session race guards.
//
// 2) A shared policy is needed:
//    - You need consistent TTL/staleness behavior and invalidation rules across
//      the whole app (enterprise “predictable semantics” requirement).
//
// Examples that commonly benefit from slices:
// - entitlements/roles/permissions
// - unread inbox count (badge)
// - profile completeness
// - user-scoped feature flags
//
// Non-examples (do NOT make a slice):
// - screen-local data used by only one page
// - data that is already modeled as part of `UserEntity`
//
// ---------------------------------------------------------------------------
// What a real `UserDataSlice<T>` should guarantee
// ---------------------------------------------------------------------------
// A production-grade slice should provide:
//
// - A state listenable (UI/services can subscribe):
//   - data: `T?`
//   - status: idle / loading / available / failure
//   - timestamps: lastRefreshedAt, lastFailureAt (optional)
//   - lastFailure: `SessionFailure` (or a slice-specific failure if needed)
//
// - Single-flight refresh:
//   - concurrent `refresh()` calls share one in-flight future
//
// - TTL / staleness semantics:
//   - `ensureFresh()` returns cached data if still “fresh enough”
//   - otherwise triggers `refresh()`
//
// - Session safety:
//   - A “session key” guard to avoid applying results after logout or session
//     expiry.
//   - Recommended guard: capture `SessionManager.refreshToken` at start of
//     refresh, ignore result if it changed before applying.
//
// - Invalidation on session end:
//   - Reset/clear data on `SessionCleared` and `SessionExpired` events
//
// - Guest mode behavior:
//   - Guest mode exists in this template, represented by `session == null`
//     (signed-out).
//   - A slice must not keep or display a previous user’s data in guest mode.
//   - Therefore, session end must clear slice state.
//
// ---------------------------------------------------------------------------
// How to implement without breaking architecture boundaries
// ---------------------------------------------------------------------------
// Constraint: `lib/core/**` must not import `lib/features/**`.
//
// So a slice implementation in `core` must depend on:
// - `SessionManager` / `AppEventBus`
// - core failure types (`SessionFailure`)
// - a core interface (or injected callback) to fetch the slice’s remote data
//
// Pattern options:
// 1) Define a core fetch interface per slice:
//    - `abstract class UserEntitlementsFetcher { Future<Either<SessionFailure, Entitlements>> fetch(); }`
//    - Provide adapter implementation in the relevant feature module.
//
// 2) Inject a fetch callback at DI time:
//    - `UserDataSlice<T>(fetch: () => locator<SomeCoreFetcher>().fetch())`
//
// Keep the core slice generic and policy-driven; keep business mapping inside
// features/usecases.
//
// ---------------------------------------------------------------------------
// Minimal usage example (conceptual)
// ---------------------------------------------------------------------------
//
// // Core:
// final entitlementsSlice = UserEntitlementsSlice(
//   sessionManager: locator<SessionManager>(),
//   events: locator<AppEventBus>(),
//   fetcher: locator<UserEntitlementsFetcher>(),
//   ttl: const Duration(minutes: 5),
// );
//
// // UI:
// ValueListenableBuilder<UserDataSliceState<Entitlements>>(
//   valueListenable: entitlementsSlice,
//   builder: (_, state, __) {
//     if (state.isLoading) return const AppDotWave();
//     if (state.data == null) return const SizedBox.shrink();
//     return Text(state.data!.planName);
//   },
// );
//
// ---------------------------------------------------------------------------
// Related docs
// ---------------------------------------------------------------------------
// - Core session system: `docs/core/session/README.md`
// - Current user mechanism: `docs/template/current_user.md`
