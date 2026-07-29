# Flutter Presentation Duplication Detection

Date: 2026-04-19  
Owner: Dante  
Status: active (implementation complete, awaiting review)  
Risk class: medium  
Related issue/PR: N/A

## Objective

Add a separate, narrow duplication detector for Flutter presentation code so the harness can surface repeated presentation helpers and micro-components without turning generic widget structure into noisy clone spam.

This phase must:
1. inspect real presentation duplicate patterns in the current repo
2. implement a dedicated Flutter-presentation duplication profile instead of broad `presentation/**` scanning in the main harness
3. detect only high-value presentation duplication classes
4. optionally support reviewed-acceptable presentation duplicates if needed
5. document how and when to run the presentation duplication check

## Constraints

- architectural constraints:
  - keep this as a thin layer over `jscpd`; do not build a custom clone engine
  - keep the existing non-presentation duplication harness unchanged in purpose
  - presentation detection must be a separate profile/script, not a silent expansion of the current main duplication check
- product/runtime constraints:
  - tooling/docs only; no product behavior changes
- out of scope:
  - broad widget-tree similarity detection
  - CI hard-fail policy for presentation duplication
  - scanning `lib/core/design_system/**`

## Acceptance Criteria

1. The repo has a dedicated command for Flutter presentation duplication review.
2. The detector scopes to presentation-heavy paths and ignores known high-noise areas.
3. The detector reports narrow presentation categories such as display/format helpers, micro-widgets, or action-item patterns instead of generic clone output.
4. The report is useful enough for self-review without drowning in false positives.
5. The workflow docs explain when to run the presentation duplication check.

## Implementation Checklist

- [x] Inspect current presentation duplicates in the repo and decide the first narrow categories to support.
- [x] Add a separate jscpd config/profile for presentation duplication scanning.
- [x] Add a dedicated filter/runner for presentation duplication.
- [x] Keep categories narrow and explicit; likely candidates:
  - [x] display/format helper
  - [x] micro-widget
  - [x] action item / option row
- [x] Add reviewed-acceptable support only if the first pass proves necessary.
- [x] Document usage in `docs/engineering/agent_pr_loop.md`.
- [x] Run the presentation detector, analyze, and custom lints.

## Decision Log

- 2026-04-19: Presentation duplication must be a separate harness profile -> the main duplication detector stays focused on non-presentation maintainability debt, while presentation scanning remains opt-in and narrow.
- 2026-04-19: Initial presentation categories are based on observed repo patterns, not generic widget similarity -> first pass focuses on repeated cubit validation/failure helpers and repeated form-page sections because those were the dominant real duplicates in the current repo sample.
- 2026-04-19: Review the first presentation output by intent, not by similarity alone -> repeated auth/account form-page sections are reviewed acceptable parallel structure, while repeated cubit validation/failure handling remains actionable debt.

## Verification

List exact commands and outcomes.

```bash
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
# Passed
# Result: 0 actionable core duplicate groups, 1 reviewed acceptable core group

dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
# Passed
# Result: 7 actionable presentation duplicate groups, 8 reviewed acceptable groups
# Reviewed acceptable: form_page_section pairs
# Actionable: cubit_failure_handling + cubit_field_validation

dart run mobile_core_kit_cli:mobilekit lint
# Passed
```

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static verification is sufficient for this tooling/doc change.

## Risks And Mitigations

- Risk: presentation detection becomes noisy and loses trust quickly.
- Mitigation: keep categories narrow, exclude design system code, and make the script separate from the main duplication check.

- Risk: the filter encodes too much UI-specific cleverness.
- Mitigation: use simple file-path + fragment heuristics and iterate only on observed false positives.

## Completion Notes

Shipped a separate Flutter-presentation duplication profile:
- added `.jscpd.presentation.json`
- added the CLI presentation duplication profile in `packages/mobile_core_kit_cli/`
- extended the CLI duplication report filter with a `presentation` profile
- added `duplication/presentation_duplication_allowlist.json`
- documented usage in the PR/self-review workflow

Review outcome for the first presentation detector run:
- reviewed acceptable: repeated `form_page_section` groups across auth/account forms
- still actionable: repeated cubit validation/failure handling helpers

This means the presentation detector now highlights the cubit-level duplication that looks worth extracting later, without continuously surfacing the intentional parallel auth form pages as open debt.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
