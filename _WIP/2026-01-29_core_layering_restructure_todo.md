# TODO — Restructure `lib/core/**` into explicit layers (foundation/domain/infra/platform/runtime/design_system)

**Project:** `mobile-core-kit`  
**Date:** 2026-01-29  
**Status:** Planned (WIP)  
**Related proposal:** `_WIP/2026-01-29_core_architecture_proposal.md`  

This is the implementation checklist for reorganizing `lib/core/**` before the codebase grows.
The goal is to remove ambiguity (“shared feature stuff”) by making core layers explicit and
lint-enforced.

## Target outcomes (definition of done)

- [ ] **Core layering exists and is discoverable**: new folder tree under `lib/core/` matches the proposal.
- [ ] **Core dependency rules are enforced** by `custom_lint` (`tool/lints/architecture_lints.yaml`).
- [ ] **No catch-all `core/services/**` bucket** remains (classes may still be named `*Service`).
- [ ] **Feature architecture unchanged**: `lib/features/*/{data,domain,presentation,di}/` remains stable.
- [ ] **No new cross-feature imports** are introduced; existing TEMP allowlists do not expand.
- [ ] **Verification is green**: `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`.

## Working agreements

- This work is expected to be **mechanical** (moves + imports + lint path updates).
- Prefer multiple small PRs (phase-based) over one mega-PR unless there is a strong reason.
- Keep behavior changes out of this refactor. If behavior must change, capture it as a separate TODO.

## Phase 0 — Baseline & safety rails (no moves yet)

- [x] Confirm the target folder tree in `_WIP/2026-01-29_core_architecture_proposal.md`.
- [ ] Decide PR strategy:
  - [ ] Option A: one PR per phase (recommended)
  - [ ] Option B: one PR for all moves (faster, harder review)
- [ ] Run verification baseline (record result here):
  - [x] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

### Phase 0 output — verification baseline (dev)

Command:

```bash
tool/agent/dartw --no-stdin run tool/verify.dart --env dev
```

Result (fill in when run):

- [x] ✅ `flutter analyze`
- [x] ✅ `dart run custom_lint`
- [x] ✅ `flutter test`
- [x] ✅ `dart format --set-exit-if-changed .`

Notes:
- Ran on 2026-01-29. `tool/verify.dart` passed end-to-end for `--env dev`.

## Phase 1 — Prepare lint/config globs for new paths (still no moves)

Goal: ensure when we start moving folders, the lints/config don’t become unusable.

- [x] Update `analysis_options.yaml` path globs for custom lints that currently reference:
  - `lib/core/widgets/**`, `lib/core/adaptive/**`, `lib/core/theme/**`, `lib/core/services/**`, etc.
  - Adjust to new target paths under `lib/core/design_system/**`, `lib/core/runtime/**`, etc.
- [x] Update `analysis_options.yaml` `restricted_imports` allowlists to match new locations:
  - `dio` allowed only under `lib/core/infra/network/**` (or equivalent)
  - `firebase_*` wrappers allowed under their new `platform/` or `runtime/` homes
  - `flutter_secure_storage`, `shared_preferences`, etc. allowed under new `infra/storage/**` scopes
- [x] Update `tool/lints/architecture_lints.yaml`:
  - [x] Keep existing feature boundary rules (ported to new paths if needed)
  - [x] Add new core-layer rules from the proposal (foundation/domain/infra/platform/runtime/design_system)

Checkpoint:
- [x] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 2 — Create the new `lib/core/**` layer directories (no file moves yet)

- [ ] Create directories (empty) per proposal:
  - `lib/core/foundation/**`
  - `lib/core/domain/**`
  - `lib/core/infra/**`
  - `lib/core/platform/**`
  - `lib/core/runtime/**`
  - `lib/core/design_system/**`
- [ ] Add placeholder `README.md` files only if the repo convention wants them (optional).

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 3 — Move pure code first (lowest coupling)

Goal: move the least-dependent code first to reduce churn.

- [ ] Move `lib/core/validation/**` → `lib/core/foundation/validation/**`
- [ ] Move `lib/core/utilities/**` → `lib/core/foundation/utilities/**`
- [ ] Update imports across repo.

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 4 — Move design system (UI-only)

- [ ] Move `lib/core/theme/**` → `lib/core/design_system/theme/**`
- [ ] Move `lib/core/adaptive/**` → `lib/core/design_system/adaptive/**`
- [ ] Move `lib/core/widgets/**` → `lib/core/design_system/widgets/**`
- [ ] Move `lib/core/localization/**` → `lib/core/design_system/localization/**`
- [ ] Update imports in:
  - `lib/app.dart`
  - `lib/navigation/**`
  - `lib/features/**/presentation/**`
- [ ] Re-check design-token custom-lint include globs still cover new paths.

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 5 — Move infra (network/storage/database/config)

- [ ] Move `lib/core/network/**` → `lib/core/infra/network/**`
- [ ] Move `lib/core/storage/**` → `lib/core/infra/storage/**`
- [ ] Move `lib/core/database/**` → `lib/core/infra/database/**`
- [ ] Move `lib/core/configs/**` → `lib/core/infra/config/**` (or `infra/configs/**`, decide once)
- [ ] Update imports in:
  - `lib/core/di/**`
  - feature datasources (`lib/features/*/data/datasource/**`)
  - runtime/session/interceptors
- [ ] Update `restricted_imports` allowlists for `dio`, `sqflite`, storage packages.

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 6 — Split “services” into `platform/**` vs `runtime/**`

Goal: remove the `core/services/**` bucket by re-homing code based on intent.

- [ ] Identify and move plugin wrappers → `lib/core/platform/**`
  - connectivity, device identity, media picker, app links source, federated auth, push token provider
- [ ] Identify and move orchestrators/controllers → `lib/core/runtime/**`
  - app startup gate, user context, push token sync service, navigation service, deep link orchestration, analytics tracker/observer (decide runtime vs platform)
- [ ] Update DI wiring (`lib/core/di/service_locator.dart`) to import new homes.
- [ ] Ensure runtime does not depend on design system (enforced by lints).

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 7 — Split core domain vs runtime (session/user)

Goal: keep cross-cutting entities + ports pure while moving orchestration into runtime.

- [ ] Move pure session/user contracts:
  - `lib/core/user/**` → `lib/core/domain/user/**`
  - `lib/core/session/entity/**` + ports/interfaces → `lib/core/domain/session/**`
- [ ] Move orchestrators:
  - `SessionManager` → `lib/core/runtime/session/**`
  - startup/user_context/event bus → `lib/core/runtime/**`
- [ ] Re-wire DI and update imports.

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 8 — Update docs + project map (post-move)

- [ ] Update `docs/engineering/project_architecture.md` core tree.
- [ ] Update `README.md` “Project Structure” section.
- [ ] Update any deep docs referencing moved paths (especially `docs/core/session/**`).

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 9 — Clean up temporary architecture allowlists (separate, intentional)

Not part of the mechanical move, but enabled by it.

- [ ] Remove TEMP auth↔user allowlists in `tool/lints/architecture_lints.yaml` by promoting shared contracts into:
  - `lib/core/foundation/**` (generic failures/validation/value failures)
  - `lib/core/domain/**` (cross-cutting domain contracts)
  - `lib/core/design_system/**` (shared localizers/widgets)

Checkpoint:
- [ ] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Notes / Risks

- This refactor will touch many imports. Prefer phase-based PRs to keep review sane.
- `analysis_options.yaml` globs are likely to break early if not updated first (Phase 1).
- Avoid behavior changes (e.g., startup gating semantics) while moving files; do those in a follow-up.
