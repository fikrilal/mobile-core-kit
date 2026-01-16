# Color System Review (Current State → Industry Standard)
**Scope:** `lib/core/theme/**`  
**Goal:** identify misalignments, risks, and a best-practice target architecture (breaking changes are acceptable)  
**Last updated:** 2026-01-15

> Status update (2026-01-16): the repo has moved to a **seed-driven, role-based** system
> (`ColorScheme` + `SemanticColors`) and removed legacy palette token files.
>
> Start here for usage rules: `docs/explainers/core/theme/color_usage_guide.md`
> (seeds live in `lib/core/theme/system/app_color_seeds.dart`).

---

## 1) Executive summary

The current color system is structurally close to the right shape (token palettes + `ColorScheme` + `ThemeExtension`), but it is **not enterprise-grade yet** because:

1) **Accessibility is not enforced**: key `on*` pairs fail WCAG contrast (including semantic status colors).
2) **Dark mode mapping is incorrect for neutrals**: `ColorScheme.dark.surface` is currently white (inverted), which is a major conceptual/visual bug.
3) **Token semantics are inconsistent**: the dark palettes are an *exact reversal* of the light palettes, which makes numeric steps (`100…1000`) mean opposite things across themes and invites mistakes.
4) **`ColorScheme` is incomplete**: many roles (tertiary roles, error roles, background roles, etc.) are left to defaults, which guarantees drift and inconsistency at scale.

If we want “top org / enterprise” quality, the system needs to be rebuilt around **semantic roles** with **contrast gating** and a **deterministic derivation** strategy (Material 3 tonal mapping or equivalent).

---

## 2) Current implementation inventory

### 2.1 Base token palettes (ThemeExtensions)

Located under `lib/core/theme/tokens/*_colors.dart`:

- `PrimaryColors`, `SecondaryColors`, `TertiaryColors`
- `GreyColors`
- `GreenColors`, `RedColors`, `YellowColors`, `BlueColors`

Each palette defines steps `100…1000`.

**Important observation:** every `*.dark` palette is an exact reversal of `*.light`.

Example pattern (true for all palettes):
- `XColors.dark.x100 == XColors.light.x1000`
- `XColors.dark.x1000 == XColors.light.x100`

This is the opposite of how most mature design systems model palettes (see §4).

### 2.2 Theme roles

- `ThemeData` is built in `lib/core/theme/light_theme.dart` and `lib/core/theme/dark_theme.dart`.
- Roles are partially configured using `ColorScheme.light(...)` / `ColorScheme.dark(...)`.
- Additional non-M3 semantic roles are exposed via `SemanticColors` (`ThemeExtension`) in `lib/core/theme/extensions/semantic_colors.dart`.
- Accessors are provided by `ThemeColorAccess` and `ThemeRoleColors` in `lib/core/theme/extensions/theme_extensions_utils.dart`.

### 2.3 Documentation mismatch

`lib/core/theme/theme-system-doc.md` describes a `50–900` scale, but code uses `100–1000`. This suggests the docs and implementation have already diverged.

---

## 3) What’s wrong (with evidence)

### 3.1 Dark mode neutrals are inverted (major bug)

In `lib/core/theme/dark_theme.dart`, the scheme is currently:
- `surface: GreyColors.dark.grey1000` (this is **white**)
- `onSurface: GreyColors.dark.grey100` (this is **near-black**)

This produces light surfaces in dark mode and flips expected semantics. It also makes `context.bgSurface` and `CardTheme.color` inconsistent with the app’s dark scaffold background.

This is not an “opinion” issue; it’s a mapping error.

### 3.2 Key `on*` pairs fail WCAG contrast

Contrast ratios (computed from current hex values; WCAG AA for normal text is **≥ 4.5:1**):

**Light theme**

| Pair | Value | Result |
|---|---:|---|
| `primary` / `onPrimary` | `#4F7CA8` / `#FFFFFF` | **4.39:1** (fails for normal text) |
| `secondary` / `onSecondary` | `#718682` / `#FFFFFF` | **3.86:1** (fails) |

**Semantic status colors**

| Pair | Value | Result |
|---|---:|---|
| `success` / `onSuccess` | `#02C82B` / `#EFFCF0` | **2.13:1** (fails badly) |
| `info` / `onInfo` | `#4FA4FF` / `#F3F9FF` | **2.45:1** (fails badly) |
| `warning` / `onWarning` | `#FFCD00` / `#FEEDB1` | **1.28:1** (fails badly) |

Even in dark mode, the current semantic pairs are still often below 4.5:1.

**Why this matters:** at enterprise scale these failures show up as accessibility defects, unreadable badges/toasts, and inconsistent component behavior across surfaces.

### 3.3 Numeric steps are not stable semantics

Because `.dark` is an exact reversal of `.light`, a numeric token changes meaning across themes:

- `context.grey.grey200` is a very light neutral in light mode, but a very dark neutral in dark mode.

This can be workable only if numeric steps are treated as **relative** (“step 200 of the current theme”), but then:
- the naming should not look like a universal palette, and
- mapping mistakes become extremely likely (as in §3.1).

Industry practice is to keep palettes stable and derive role mapping per theme (see §4).

### 3.4 The neutral ramps are not fit for Material 3 surfaces

Material 3 expects subtle elevation deltas between:
- `surface`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`

In `light_theme.dart`, `surfaceContainerHighest` is currently `grey300 = #92979C` which is far too dark to be a surface container on a light surface. This alone guarantees “muddy” elevation and poor text hierarchy unless every component hardcodes overrides.

### 3.5 `ColorScheme` is only partially defined

The themes set a subset of roles (`primary`, `secondary`, some `surface*`, `outline*`, etc.). Many roles are left to defaults:
- `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`
- `error`, `onError`, `errorContainer`, `onErrorContainer`
- background roles, surfaceTint, etc.

This is a drift vector: Material components will use defaults and your brand tokens will be bypassed unpredictably.

---

## 4) What “industry standard” looks like (practical)

Top orgs generally converge on this pattern:

1) **Role tokens are the contract**  
   - `ColorScheme` (Material roles) + a small extension for extra semantic roles (success/warning/info) if needed.
2) **Palette tokens are a primitive, not the API**  
   - Palettes exist for charts/illustrations/marketing, but app UI consumes roles.
3) **Tonal mapping across light/dark**  
   - Light and dark themes pick different tones from the same palette rather than reversing the palette.
   - Material 3’s tonal approach is a proven default.
4) **Contrast is gated**  
   - `onPrimary` etc are selected to meet contrast targets.
   - This is verified with automated checks (tests or a verify tool).

This is the difference between “looks okay locally” and “stays correct for years.”

---

## 5) Recommended target architecture (breaking-change friendly)

### 5.1 Canonical API

- Treat `Theme.of(context).colorScheme` as the canonical UI API.
- Keep `SemanticColors` but rebuild it using the same principles as `ColorScheme`:
  - `success`, `onSuccess`, `successContainer`, `onSuccessContainer`
  - `warning`, `onWarning`, `warningContainer`, `onWarningContainer`
  - `info`, `onInfo`, `infoContainer`, `onInfoContainer`

Feature code should not use `context.green.green500` etc for UI.

### 5.2 Palette model

Pick one:

**Option A (fastest, high quality, no external deps):** `ColorScheme.fromSeed`

- Define one or more brand seed colors.
- Generate full `ColorScheme` for light/dark via Flutter’s built-in Material 3 algorithm:
  - `ColorScheme.fromSeed(seedColor: brandPrimary, brightness: Brightness.light)`
  - `ColorScheme.fromSeed(seedColor: brandPrimary, brightness: Brightness.dark)`

For semantic success/warning/info:
- generate mini-schemes from their seed colors and map `primary` → `success`, etc.

Pros: proven, accessible defaults, complete schemes, minimal custom code.  
Cons: derived secondary/tertiary may not match strict brand requirements without overrides.

**Option B (max control): internal tonal palettes + tone mapping**

- Implement an in-house `TonalPalette` representation (tone 0–100).
- Define tone mapping tables for light/dark roles (Material-like).
- Derive `ColorScheme` + `SemanticColors` from those tones.

Pros: maximum brand control, perfect determinism.  
Cons: requires implementing/owning a perceptual color model (HCT/OKLCH-like) and validation tooling.

### 5.3 Enforce contrast

Add an automated check that fails CI if:
- any `on*` role falls below 4.5:1 against its background for normal text
- semantic colors fail the same constraints (at least for default text sizes)

This is non-negotiable for enterprise quality.

---

## 6) Suggested next steps (if you want a hard reset)

1) Fix the dark neutral mapping immediately (stop shipping inverted dark surfaces).
2) Decide target architecture: Option A (fromSeed) vs Option B (tonal palettes).
3) Regenerate/redefine:
   - `ColorScheme` for light/dark (complete, explicit roles)
   - `SemanticColors` with correct `on*` pairings
4) Add contrast verification (tests or `tool/verify_colors.dart`).
5) Only then consider whether raw palettes are still needed as ThemeExtensions.
