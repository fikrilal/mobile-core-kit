# Color System: Rationale, Guardrails, and Extension Guide
**Scope:** `lib/core/design_system/theme/**`  
**Goal:** keep colors accessible, consistent, and governable at enterprise scale  
**Last updated:** 2026-01-16

This repo uses a **seed-driven, role-based** system:

- `ColorScheme` (Material roles) is the canonical UI API.
- `SemanticColors` (success/info/warning) is the canonical status API.
- WCAG contrast is **gated by tests**.

Start here for day-to-day usage:
- `docs/explainers/core/theme/color_usage_guide.md`

See pipeline details:
- `docs/explainers/core/theme/color_system_under_the_hood.md`

---

## 1) What we optimize for (enterprise defaults)

1) **Accessibility**: predictable, test-enforced contrast for text and core controls.
2) **Consistency**: the same roles mean the same thing across the app (no per-feature color forks).
3) **Scalability**: adding new surfaces/components doesn’t require inventing new colors.
4) **Platform parity**: roles map cleanly to Material widgets while remaining brandable on iOS too.

This is intentionally not “a palette library”. It’s a **contract**.

---

## 2) The contract (what UI code is allowed to use)

UI code consumes **roles**, not palette steps:

- `Theme.of(context).colorScheme` / `context.cs.*`
- `context.semanticColors.*`
- Convenience aliases in `ThemeRoleColors` (e.g. `context.textPrimary`, `context.bgSurface`, `context.border`)

Hard rules:

- No hardcoded hex values in UI (`Color(0xFF...)`, `Colors.*`) except debug tooling.
- No palette-step usage in UI (e.g. “neutral/200”, “green/500”). If design hands off ramps, translate intent to roles.

---

## 3) Seeds: the only “inputs” we keep in code

Seeds are the source of truth for color derivation:

- Brand: `brandPrimarySeed` (required)
- Neutral: `neutralSeed` (recommended for neutral surfaces)
- Status: `successSeed`, `infoSeed`, `warningSeed`

Seeds live in:
- `lib/core/design_system/theme/system/app_color_seeds.dart`

Design guidance:

- Prefer a **neutral** seed that yields surfaces without tint.
- Prefer a **brand** seed that can generate accents with stable `onPrimary` contrast.
- Status seeds should represent intent, not a final “badge background” color (the roles handle that).

---

## 4) Derivation strategy (why this is the best default)

We use Flutter’s built-in Material 3 tonal mapping via `ColorScheme.fromSeed`:

- It produces a **complete scheme** (reduces drift).
- It maps tones to roles (`primary`, `onPrimary`, `surface`, `outline`, etc.) consistently across light/dark.
- It tracks platform evolution without pulling in third-party packages.

We intentionally generate:

- a **brand scheme** (accent roles)
- a **neutral scheme** (surface + outline roles)
- **status schemes** (success/info/warning → `SemanticColors`)

Policy decision (this template):

- **Neutral elevation**: `ColorScheme.surfaceTint` is sourced from the neutral scheme so elevated surfaces don’t pick up a brand tint.

Derivation happens in:
- `lib/core/design_system/theme/system/app_color_scheme_builder.dart`

---

## 5) Contrast policy (what we guarantee)

We do not rely on “looks okay” judgment calls. We gate contrast via automated tests:

- **Text-bearing pairs**: ≥ **4.5:1** (WCAG AA normal text)
- **Control boundaries** (`outline` on `surface`): ≥ **3.0:1** (WCAG 1.4.11 non-text)

Enforced in:
- `test/core/theme/color_contrast_test.dart`

If the gate fails:

- Fix by adjusting seeds (preferred), or add a narrowly-scoped override in the builder.
- Do not patch widget-level colors to “make it pass” (that creates drift).

## 5.1) High contrast mode (OS accessibility)

When the user enables high contrast at the OS level, Flutter exposes it via:

- `MediaQuery.highContrastOf(context)`

Our app shell can switch to a high-contrast theme variant (still seed-driven, still role-based).
Current policy:

- strengthen subtle separators by setting `ColorScheme.outlineVariant = ColorScheme.outline`

This keeps borders/dividers more perceivable without requiring widget-level conditionals.

---

## 6) Extension rules (how we avoid color sprawl)

### 6.1 Adding a new semantic role

Add a role only if it is:

- cross-cutting (used by multiple features), and
- has clear accessibility expectations (on-color + container variants), and
- can be enforced in tests.

Examples that might qualify:
- “danger” / “negative” (distinct from `error` usage)
- “brandSecondary” only if design requires strict separation from generated `secondary`

Prefer extending `SemanticColors` over introducing new ad-hoc `ThemeExtension`s.

### 6.2 Charts, illustrations, and marketing colors

If you need palette ramps, keep them **out of app UI**:

- define them as non-UI primitives (e.g. `lib/core/charts/...`), or
- define them in a design-exported asset mapping, not as theme roles.

The theme layer remains role-first.

---

## 7) Figma handoff (recommended naming)

Design can keep ramps for exploration, but handoff should be role-based.

Suggested variable groups:

- `seed/brand/primary`
- `seed/neutral/base`
- `seed/status/success`, `seed/status/info`, `seed/status/warning`
- `role/surface`, `role/on-surface`, `role/outline`, `role/primary`, `role/on-primary`
- `role/status/success-container`, `role/status/on-success-container`, etc.

Rule: if a spec mentions a ramp step (e.g. `neutral/200`), it must include intent (“divider”, “border”, “surface”) so engineering can map to roles.

---

## 8) Change protocol (safe updates over time)

1) Update seeds: `lib/core/design_system/theme/system/app_color_seeds.dart`
2) Run:
   - `flutter analyze`
   - `flutter test test/core/theme/color_contrast_test.dart`
3) Manual QA:
   - light/dark: surfaces and text hierarchy
   - status UI: success/info/warning readability on both themes
   - high contrast mode (if relevant to your product)

If design ever rejects the tonal output for strict brand reasons, the controlled escalation path is:

1) add minimal overrides in the builder (reviewable diffs)
2) only then consider moving to an in-house tonal palette/mapping system
