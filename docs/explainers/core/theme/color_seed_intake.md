# Color System Seed Intake (Design → Engineering)

This doc lists the minimal set of inputs we need to produce an enterprise-grade, role-based theme.

The contract is:
- UI uses **roles** (`ColorScheme` + `SemanticColors`)
- Engineering stores only **seeds** (small set of hex inputs)
- Accessibility is enforced by **contrast gates** (tests)

---

## 1) Required inputs

### 1.1 Brand + neutral seeds

Provide:

- `brandPrimarySeed` (required) — the brand’s primary accent hue
- `neutralSeed` (recommended) — a neutral seed that yields untinted surfaces/outlines

Why we want both:
- brand seed drives accents (`primary`, etc.)
- neutral seed keeps surfaces neutral (avoids tinted backgrounds)

### 1.2 Status seeds

Provide:

- `successSeed`
- `infoSeed`
- `warningSeed`

If you don’t have these yet, we can start with placeholders, but treat it as temporary: changing status seeds affects many UI surfaces, so it should be done deliberately.

---

## 2) Optional inputs (only if design needs strict control)

- `brandSecondarySeed`
- `brandTertiarySeed`

Default behavior is to let derived `secondary`/`tertiary` come from the primary seed. Only provide additional seeds if design explicitly requires distinct brand hues.

---

## 3) Contrast policy (defaults for this template)

We gate contrast via tests:

- Text-bearing pairs: **≥ 4.5:1** (WCAG AA normal text)
- Control boundaries: **≥ 3.0:1** (WCAG 1.4.11 non-text)

Enforced by:
- `test/core/theme/color_contrast_test.dart`

---

## 4) How the system uses these inputs

Pipeline:

1) Seeds in `lib/core/theme/system/app_color_seeds.dart`
2) `AppColorSchemeBuilder` derives:
   - `ColorScheme` (light + dark)
   - `SemanticColors` (success/info/warning roles)
3) Themes wire the derived roles into `ThemeData`
4) UI uses roles only (`Theme.of(context).colorScheme`, `context.semanticColors`)

See the deep dive:
- `docs/explainers/core/theme/color_system_under_the_hood.md`

---

## 5) Example seed sheet (copy/paste)

```text
brandPrimarySeed: #9FE870
neutralSeed: #868685

successSeed: #2F5711
infoSeed: #A0E1E1
warningSeed: #EDC843
```

Notes:
- `neutralSeed` should produce surfaces that look neutral in both light/dark (no green/blue tint).
- Status seeds are intent markers; the system derives accessible containers + on-colors from them.

---

## 6) Definition of done for a seed set

1) Update seeds
2) Run:
   - `tool/agent/flutterw --no-stdin analyze`
   - `tool/agent/flutterw --no-stdin test test/core/theme/color_contrast_test.dart`
3) QA:
   - light/dark surfaces and text hierarchy
   - status UI readability on both themes
