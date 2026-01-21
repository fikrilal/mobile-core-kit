# AI Agent Guardrails — High ROI Additions (mobile-core-kit)
**Date:** 2026-01-21  
**Goal:** Make PR review “boring” by pushing correctness + consistency into automated guardrails (lints + verify scripts + scaffolding).  
**Scope:** This report focuses on *additional* high-ROI guardrails beyond what already exists in this template.

## What I looked at (evidence-based)

- Repo overview + bootstrap docs: `README.md`, `docs/README.md`, `docs/engineering/*.md`
- Existing enforcement points:
  - Analyzer config: `analysis_options.yaml`
  - Custom lint plugin: `packages/mobile_core_kit_lints/`
  - Architecture rules config: `tool/lints/architecture_lints.yaml`
  - Verify pipeline: `tool/verify.dart`, `tool/verify_*`
  - CI workflow: `.github/workflows/android.yml`
- Spot-checked feature slices:
  - `lib/features/auth/**` (end-to-end example)
  - `lib/features/user/**` (exposes a real cross-feature dependency)

I also executed the repo’s verification script (WSL-safe):

`tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Current guardrails (already strong)

You already have an above-average base for AI-heavy development:

- **Architecture import boundaries** (IDE + CI): `architecture_imports` via `custom_lint` + `tool/lints/architecture_lints.yaml`.
- **UI token drift prevention** (as errors): hardcoded colors, font sizes, spacing tokens, state opacities, motion durations, manual text scaling.
- **Modal governance** enforced via both custom lint and `tool/verify_modal_entrypoints.dart`.
- **“One command” quality gate**: `tool/verify.dart` runs analyze + custom_lint + tests + format check, and is WSL-aware.
- **Localization toolchain** is configured for enterprise hygiene (`required-resource-attributes`, `untranslated-messages-file`).

The biggest remaining wins are mostly about:
1) closing a few “agent-shaped” loopholes (imports, DI usage, low-level deps), and  
2) enforcing *structure/consistency* rules that reduce reviewer cognitive load (localization, routing, API usage defaults).

---

## Recommendations (prioritized)

### P0 — Close the biggest AI-shaped loopholes

#### 1) Enforce **domain purity** (imports) beyond “no data/presentation”
**Why it’s high ROI:** AI agents will eventually leak UI/framework concerns into domain (Flutter imports, navigation, networking, storage, DI). This is subtle, reviewers miss it, and it accumulates long-term architecture debt.

**What to add**

Extend `tool/lints/architecture_lints.yaml` so `lib/features/*/domain/**` cannot import:
- `lib/navigation/**` (already denied ✅)
- `lib/core/network/**`
- `lib/core/services/**`
- `lib/core/storage/**`
- `lib/core/database/**`
- `lib/core/theme/**`
- `lib/core/widgets/**`
- `lib/core/adaptive/**`
- `lib/core/di/**`
- `lib/core/dev_tools/**`
- `lib/l10n/**` (domain must not depend on generated localization)

And (implicitly) allow only the “domain-safe” core surfaces (you already have these patterns):
- `lib/core/validation/**`
- `lib/core/session/entity/**`
- `lib/core/user/entity/**`

**Implementation approach:** config-only. Either:
- extend the existing `feature_domain_no_data_or_presentation` rule, or
- add a new rule `feature_domain_no_infra`.

**Evidence of need:** `lib/features/user/domain/**` currently depends on `lib/features/auth/domain/failure/auth_failure.dart`, which suggests “feature purity” isn’t enforced and will get worse with AI unless you codify it.

---

#### 2) Add a **restricted imports** meta-lint (“don’t use low-level deps outside approved places”)
**Why it’s high ROI:** Agents often import the “first thing that works” (e.g., `firebase_analytics`, `firebase_crashlytics`, `dio`, `shared_preferences`) directly in features. This bypasses your wrappers and makes migration/refactor painful.

**What to add**

Create a new custom lint rule (suggested name: `restricted_imports`) configured in `analysis_options.yaml`.

Examples of rules (config-driven):
- Ban `package:dio/dio.dart` everywhere except `lib/core/network/**`.
- Ban `package:firebase_analytics/firebase_analytics.dart` everywhere except `lib/core/services/analytics/**`.
- Ban `package:firebase_crashlytics/firebase_crashlytics.dart` everywhere except:
  - `lib/core/utilities/log_utils.dart`
  - `lib/core/services/early_errors/**`
- Ban `package:shared_preferences/shared_preferences.dart` everywhere except core storage/store implementations.
- Ban `package:flutter_secure_storage/flutter_secure_storage.dart` everywhere except `lib/core/storage/secure/**`.
- Optionally ban `dart:developer` everywhere except `lib/core/utilities/log_utils.dart`.

**Implementation approach:** a `DartLintRule` that inspects `ImportDirective`s:
- match by URI prefix (`dart:` / `package:`)
- check source file path against allowlisted globs (same glob pattern approach you already use)

This becomes your general-purpose “dependency boundary” tool.

---

#### 3) Service locator boundary: forbid `locator<...>()` usage outside composition roots
**Why it’s high ROI:** AI agents love service locators (“easy DI”), but it silently injects hidden dependencies into business logic and destroys testability.

**What to add**

Option A (cheap, config-only): extend `architecture_imports` rules to forbid importing `lib/core/di/service_locator.dart` except in:
- `lib/core/di/**`
- `lib/navigation/**`
- `lib/app.dart` and `lib/main_*.dart` (composition)
- `lib/features/*/di/**`

Option B (stronger): a custom lint that flags direct identifier usage (`locator<...>`, `getIt`) outside those locations.

This keeps “composition at the edges” stable as the codebase grows.

---

#### 4) Prevent cross-feature imports (feature boundaries)
**Why it’s high ROI:** Cross-feature imports are a classic “it’s fine for now” trap. AI will absolutely create new ones because it’s the shortest path to “works”.

**What to add**
- Add a rule to `tool/lints/architecture_lints.yaml` that prevents `lib/features/<A>/**` importing `lib/features/<B>/**` (unless explicitly allowlisted).

**Reality check:** This will require cleanup or allowlists because the template currently has at least one cross-feature domain dependency (`user` → `auth`).

**Implementation approach:** Use explicit allowlists. It’s annoying, but that’s the point: when a new cross-feature dependency is introduced, reviewers should be forced to consciously approve it.

---

### P1 — Make UX/content consistency enforceable (localization + navigation)

#### 5) Add a `hardcoded_ui_strings` lint (UI copy must come from l10n)
**Why it’s high ROI:** AI output commonly includes raw strings. Reviewers catch some, but not all. Hardcoded copy is also a localization killer.

**What to enforce (suggested, low-noise)**
- Flag string literals in common UI contexts:
  - `Text('...')`, `AppText.*('...')`
  - `SnackBar(content: Text('...'))`
  - `AppButton(text: '...')`, `TextButton(child: Text('...'))`
  - `AppBar(title: Text('...'))`
- Require using `context.l10n.*` (or passing already-localized strings into shared widgets).

**Avoid false positives**
- Exclude dev-only/showcase screens:
  - `lib/core/dev_tools/**`
  - `**/*showcase*`
- Allow analytics IDs / semantics IDs via allowlisted constants or by scoping the lint to widget constructors only.

---

#### 6) Navigation hygiene: forbid route string literals in `context.go/push` and `GoRoute(path: ...)`
**Why it’s high ROI:** Agents will sprinkle raw `'/some/path'`. It becomes unsearchable and breaks refactor safety.

**What to add**
- Lint calls like `context.go('/...')` / `context.push('/...')` when the argument is a string literal.
- Lint `GoRoute(path: '/...')` when `path:` is a string literal.
- Encourage `AppRoutes.*` / `<feature>Routes.*` constants only.

This is one of the easiest “boring review” rules: it doesn’t change product behavior, it just standardizes routing.

---

### P2 — Expand design-token enforcement where AI often drifts

#### 7) Border radius / shape tokens
**Why it’s high ROI:** UI polish drift is extremely common with AI. You already prevent hardcoded spacing, colors, font sizes, durations—radius is the next big one.

**What to add**
- Introduce tokens (recommended): `lib/core/theme/tokens/radii.dart` (e.g., `AppRadii.sm/md/lg/xl`).
- Add a lint that flags:
  - `BorderRadius.circular(<number>)`
  - `Radius.circular(<number>)`
  - `RoundedRectangleBorder(borderRadius: ...)` with numeric radii
  - `ClipRRect(borderRadius: ...)` with numeric radii

**Alternative (lighter):** expand `spacing_tokens` to also flag numeric args passed to `Radius.circular` / `BorderRadius.circular`.

---

#### 8) Component sizing tokens (icons, avatars, button heights)
**Why it’s high ROI:** AI-generated UI often picks arbitrary `size: 18`, `height: 44`, etc. You already have `AppSizing`—enforce it.

**What to add**
- Lint `Icon(size: <number>)` (very high signal, low noise) and require `AppSizing.iconSize*`.
- Optionally lint other fixed-size contexts:
  - `Container(height: <number>)`, `SizedBox(height/width: <number>)`
  - `BoxConstraints.tightFor(height/width: <number>)`

**Note:** This can get noisy; start narrow (Icon size only) or as warning first.

---

### P3 — Networking correctness guardrails (stop “works locally” mistakes)

#### 9) ApiHelper policy lint for datasources
**Why it’s high ROI:** A subtle agent mistake is relying on defaults that are *wrong for your architecture*.

For example, `ApiHelper` defaults:
- `throwOnError = true`
- `host = ApiHost.core`
- `requiresAuth = true`

In this template, datasources almost always want:
- `throwOnError: false` (so repositories map `ApiResponse` → `Either` deterministically)
- explicit `host:` (avoid silent wrong-host bugs)
- explicit `requiresAuth:` (avoid accidental auth header on public endpoints)

**What to add**
- Lint `ApiHelper.*(...)` invocations in `lib/features/*/data/datasource/**`:
  - Require an explicit `host:` argument.
  - Require `throwOnError: false`.
  - (Optional) require explicit `requiresAuth:` (true/false), so the decision is visible.

This is extremely effective at making reviews boring because diffs become self-explanatory and consistent.

---

### P4 — Workflow guardrails (cheap + leverage)

#### 10) Verify “no untranslated messages”
**Why it’s high ROI:** You already generate `tool/untranslated_messages.json`. Enforce it is `{}` in CI so teams can’t accidentally ship missing keys.

**What to add**
- Add `tool/verify_untranslated_messages.dart` that fails if `tool/untranslated_messages.json` is not `{}`.
- Call it from `tool/verify.dart` and CI after `flutter gen-l10n`.

---

#### 11) Build runner freshness gate (optional, but powerful for boring reviews)
**Why it’s high ROI:** AI often updates `@freezed`/`@JsonSerializable` sources and forgets generated outputs.

**Options**
- Option A: Add a `tool/verify_codegen.dart` that runs build_runner and fails if git diff is non-empty (best in CI).
- Option B: In `tool/verify.dart`, run build_runner conditionally only if relevant files changed (more complex).

**Tradeoff:** Increased runtime, but huge review savings.

---

#### 12) Add a “feature scaffolder” tool (structure by construction)
**Why it’s high ROI:** Even with perfect lints, AI will still waste time re-deriving boilerplate (folders, DI module, route list, failure types, tests). A scaffolder makes the “happy path” the fastest path.

**What to add**
- A script like `tool/scaffold_feature.dart` (or `tool/new_slice.dart`) that:
  - creates the standard vertical slice folders (`data/`, `domain/`, `presentation/`, `di/`, `analytics/`, optional `presentation/widgets/skeleton/`)
  - generates stub files with correct imports/parts (Bloc/Cubit skeleton, State + status enum, Failure, Repository interface, Repository impl, Remote datasource)
  - updates navigation lists (`lib/navigation/<feature>/*_routes_list.dart`) with a TODO route stub
  - optionally adds placeholder l10n keys to `lib/l10n/app_en.arb` + mirrored locales (or at least emits a checklist)
  - generates test skeletons under `test/` mirroring the slice path

**Guardrail angle (important):** make the script refuse to run if:
- the feature name is not `snake_case`
- a feature already exists
- required docs/contract placeholders aren’t created (if you want strictness)

This is one of the few guardrails that pays off immediately for both humans and agents.

---

## Suggested rollout plan (low disruption)

1) **P0 config-only wins first** (same-day):
   - Strengthen `tool/lints/architecture_lints.yaml` (domain purity, service-locator boundary, cross-feature boundary).
2) Add the **restricted imports** meta-lint (high leverage, reusable).
3) Add **hardcoded UI strings** lint (exclude dev tools/showcases).
4) Add **ApiHelper datasource policy** lint (explicit host + throwOnError false).
5) Expand token enforcement (radii, icon sizes) once tokens exist.
6) Add verify scripts for untranslated messages + codegen freshness as CI gates.

If you want, I can follow up with concrete PR-sized changes (one lint at a time) starting with (1) architecture config hardening + (3) service-locator boundary, since those are mostly low-risk and immediately valuable.
