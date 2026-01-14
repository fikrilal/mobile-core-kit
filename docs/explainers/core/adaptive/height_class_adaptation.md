# Height-Class Adaptation (Mobile-First)

This note documents **how to use `WindowHeightClass`** (`layout.heightClass`) to keep screens usable when vertical space is constrained.

Height constraints happen more often than teams expect:
- landscape phones (short height, medium-ish width)
- split-screen / picture-in-picture
- small tablets in landscape
- “floating keyboard” / input overlays (pair this with `InsetsSpec.viewInsets`)

The adaptive system already computes `layout.heightClass` from constraints; this document is about **how to apply it** consistently.

---

## What height class is (and is not)

- `layout.heightClass` is derived from **layout constraints height in dp**.
- It is **not** a keyboard signal. Keyboard is `context.adaptiveInsets.viewInsets.bottom`.
- Height class should be treated as a **layout capability** (how much vertical real estate you can count on).

---

## Rules (non-negotiable)

1) **Never add custom height breakpoints** in features (no `if (height < 600)`).
2) Use `layout.heightClass` + `context.adaptiveInsets.viewInsets` together:
   - height class tells you “screen is short”
   - view insets tell you “keyboard is eating space”
3) Prefer **scroll + sticky actions** over multi-row toolbars.
4) Prefer **single primary header**; avoid stacked app bars + toolbars + tabs when height is compact.

---

## Recommended patterns

### Pattern A — Collapse secondary chrome in `compact` height

When `layout.heightClass == WindowHeightClass.compact`:
- Avoid extra header rows (filters/toolbars) that steal content height.
- Move secondary actions behind overflow menus, inline icon buttons, or collapsible sections.
- Prefer 1-line titles (truncate) over multi-line titles.

### Pattern B — Make forms “scroll-first”

Forms should be resilient to:
- compact height
- keyboard open (`viewInsets.bottom > 0`)

Practices:
- Use a single scroll container for the form body.
- Keep the primary CTA accessible using one of:
  - pinned bottom action bar with `SafeArea` + `viewInsets`
  - a sticky footer inside the scroll view
- Avoid fixed-height columns that can overflow when text scaling is high.

### Pattern C — Prefer master/detail via width, not height

On mobile-first products, two-pane layouts should primarily come from:
- width class (`expanded+`)
- foldables (`foldable.isSpanned`)

Height class is typically used to **reduce vertical chrome**, not to decide “two-pane vs one-pane”.

### Pattern D — Treat `compact` height as “no spare space”

If height is compact, assume:
- only one primary surface (list OR detail OR editor) should be “full fidelity”
- everything else should be:
  - collapsible
  - behind navigation
  - or moved to secondary routes/modals

---

## Practical decision table

| Condition | Guideline |
|----------|-----------|
| `heightClass == compact` | collapse secondary headers/toolbars |
| `viewInsets.bottom > 0` | avoid fixed bottom UI; inset/pin actions |
| `heightClass == compact` + `textScale >= 1.5` | prefer scroll; reduce dense layouts |
| `widthClass >= medium` + `heightClass == compact` | navigation rail is usually fine; avoid bottom bars if they steal height |

---

## What to do when this isn’t enough

If teams repeatedly need “height-aware tokens” (e.g., toolbar heights, vertical spacing scales), add them as **first-class tokens** in `lib/core/adaptive/tokens/` and cover them with unit tests.

