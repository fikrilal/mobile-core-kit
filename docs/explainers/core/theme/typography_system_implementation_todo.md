# Typography Proposal → Implementation TODO (Phased, Safe)

This checklist translates `typography_system_proposal.md` into concrete implementation work. It is intentionally phased so we can land improvements without destabilizing the app.

## Phase 0 — Align on decisions (requires a quick call)

1) Canonical API choice
   - Confirm: canonical = `Theme.of(context).textTheme.*` (recommended).
2) Bold-text preference strategy
   - Choose one:
     - A) ignore `MediaQuery.boldText` for now
     - B) apply controlled “weight bump” policy (body/label only)
3) “Responsive typography” scope
   - Confirm: no breakpoint-based ramp changes for now; tablet readability solved via layout + paragraph width constraints.

## Phase 1 — Make the current system match the proposal (no behavior change)

### 1.1 Docs clean-up (truthful + non-duplicative)

- Update or replace `lib/core/theme/typography/typography-guide.md`
  - Remove claims about breakpoint-driven typography (unless implemented).
  - Point to:
    - `docs/explainers/core/theme/typography_system_proposal.md`
    - `docs/explainers/core/theme/typography_system_review.md`

### 1.2 Remove parallel “style pipelines” (deprecation-first)

Goal: stop presenting multiple “sources of truth” to feature developers.

- Deprecate `lib/core/theme/typography/styles/responsive_text_styles.dart`
  - Replace with theme-driven access (`Theme.of(context).textTheme.*`).
  - If you keep a helper, it must simply proxy to `textTheme` (no new styles).
- Deprecate `lib/core/theme/typography/utils/typography_extensions.dart`
  - Replace with either:
    - direct `Theme.of(context).textTheme.*`, or
    - a narrow extension that just returns `Theme.of(context).textTheme.*` (no independent ramp).

Deliverable: a clear README section that says “use textTheme; don’t use ResponsiveTextStyles”.

### 1.3 Ensure wrappers don’t bypass root text policy

- Audit `AppText` / `Heading` / `Paragraph` parameters:
  - discourage / deprecate per-widget `textScaler`
  - discourage / deprecate font-size mutations (`fontSize`, `lineHeight`, `letterSpacing`) in DS widgets
  - keep only safe overrides (color, align, maxLines, overflow, selectable, semantics)

## Phase 2 — Implement the “slim DS components” surface area

### 2.1 Create “v2” wrappers (new files, then migrate callers)

Create new slim components (don’t break existing usage yet):

- `lib/core/theme/typography/components/app_text.dart`
  - API:
    - role selection: `AppText.bodyMedium(...)` OR `AppText(text, role: AppTextRole.bodyMedium)`
    - overrides: `color`, `textAlign`, `maxLines`, `overflow`, `selectable`, `semanticsLabel`
  - Implementation: always reads `Theme.of(context).textTheme` as the style source.

- `lib/core/theme/typography/components/heading.dart`
  - Reduce to `h1/h2/h3` (optional: keep h4-h6 if needed)
  - Use `Semantics(header: true, ...)`
  - Map to `TextTheme` roles (document mapping)

- `lib/core/theme/typography/components/paragraph.dart`
  - Always uses `TextTheme.body*`
  - Constrain readable width on tablet/large widths:
    - use `LayoutBuilder` to clamp maxWidth to `TypeMetrics.maxCharactersPerLine` heuristic
  - Keep selection optional

Deliverable: wrappers that are easy to understand in one screen of code.

### 2.2 Mark legacy wrappers for deprecation

- Keep existing `text.dart` / `heading.dart` / `paragraph.dart` temporarily.
- Add `@Deprecated(...)` annotations with a migration message pointing to the new wrappers.

## Phase 3 — Add governance guardrails (lint + tests)

### 3.1 Custom lints

Find the existing lint infrastructure (likely under `packages/` or `tool/` depending on how `hardcoded_ui_colors` is implemented) and add:

1) `hardcoded_font_sizes`
   - Disallow `TextStyle(fontSize: ...)` in:
     - `lib/features/**`
     - `lib/core/widgets/**`
     - optionally `lib/presentation/**`
2) `manual_text_scaling`
   - Disallow `TextScaler.linear(...)` usage outside:
     - `lib/core/adaptive/**`
     - policy code paths
3) `typography_style_mutation` (optional)
   - Disallow `.copyWith(fontSize: ...)` and `.apply(fontSizeFactor: ...)` in UI layers.

Each lint needs:

- a clear error message (“Use TextTheme role instead”)
- suppression escape hatch (`// ignore: ...`) for exceptional cases

### 3.2 Contract tests

Add tests that prevent silent drift:

- `test/core/theme/typography/typography_tokens_test.dart`
  - asserts `TypeScale` values (or at least key ones)
  - asserts `TypeMetrics` invariants (lineHeight ranges, etc.)
- `test/core/theme/typography/typography_theme_binding_test.dart`
  - builds `AppTheme.light()` and verifies:
    - appBarTheme.titleTextStyle == textTheme.titleLarge (or whatever mapping you choose)
    - other bindings you rely on (TabBar, BottomNav label)

## Phase 4 — Adaptive hooks (optional, only if chosen in Phase 0)

### 4.1 Bold-text policy (if enabled)

- Implement `TypographyPolicy` that takes:
  - `bool boldText`
  - returns a transformed `TextTheme` or provides derived weights for a small subset of roles
- Apply it in one place only:
  - either at theme creation time (context-free) by taking boldText as an explicit flag from app shell, or
  - at widget build time through wrapper selection (still centralized).

Important: do not sprinkle `.bolder` calls throughout the app.

## Phase 5 — Migration plan (when ready)

This is the “next sprint” step once the new system is landed and stable.

1) Migrate all feature code to:
   - `Theme.of(context).textTheme.*` OR the slim DS wrappers.
2) Remove usage of:
   - `ResponsiveTextStyles`
   - `TypographyExtensions`
   - large legacy wrappers
3) Delete deprecated files once grep shows 0 usage.

## Deliverables checklist (definition of done)

- `ThemeData` typography remains context-free.
- Text scaling is clamped once at root (`AdaptiveScope`) and not overridden per widget.
- A single canonical typography API is documented and enforced.
- DS wrappers exist, small and predictable (90% cases).
- Lints prevent ad-hoc font sizes and manual scaling in UI layers.
- Contract tests cover token values + theme bindings.

