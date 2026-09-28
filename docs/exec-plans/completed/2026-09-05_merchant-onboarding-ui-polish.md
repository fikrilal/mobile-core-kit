# Polish Merchant Onboarding UI and Layout

**Plan version:** 2
**Task ID:** merchant-onboarding-ui-polish
**Status:** completed
**Owner:** Antigravity
**Risk:** medium
**Authority:** Polish the merchant onboarding presentation layout and visual design: fix nested padding in AppPageContainer, restore persistent AppBar with step progress bar, unify MerchantDropdownField with AppTextField styling, modernize owner cards with compact actions, elevate Review step with section containers, and improve vertical rhythm without changing domain logic, state models, or wire contracts.
**Allowed paths:** docs/exec-plans/active/2026-09-05_merchant-onboarding-ui-polish.md, docs/exec-plans/completed/2026-09-05_merchant-onboarding-ui-polish.md, lib/features/merchant_onboarding/presentation/, test/features/merchant_onboarding/presentation/
**Allowed actions:** edit, verify
**Maximum risk:** medium
**Repair limit:** 3
**Task timeout:** 3h
**Oracle IDs:** ui.human-review

Date: 2026-09-05
Related issue/PR: N/A

## Objective

Polish the merchant onboarding UI to look cohesive, modern, and aligned with the mobile design system:
1. Fix nested padding: Configure `AppPageContainer` with `surface: SurfaceKind.form`, remove redundant internal horizontal paddings that caused double-padding squishing.
2. Restore persistent `AppBar` on `MerchantOnboardingPage` across all loaded states, including close/back leading buttons and a sleek `LinearProgressIndicator` step bar.
3. Unify `MerchantDropdownField` styling with `AppTextField` (use `FieldStyles.getInputDecoration`, design tokens `AppRadii.radius12`, matching typography, and rounded dropdown arrow).
4. Refine `MerchantOwnerRowCard`: Clean bordered container, compact icon action buttons (`AppSizing.iconSizeCompact`), consistent spacing.
5. Elevate `ReviewStepWidget`: Container-grouped review sections with edit buttons and distinct declaration callout.
6. Improve vertical rhythm: 16px field spacing throughout forms.
7. Maintain zero comments in code per user directive.
8. Verify via lints, widget tests, and full verification pipeline.

## Constraints

- Zero comments policy: No single-line (`//`) or doc (`///`) comments in `merchant_onboarding` code.
- Out of scope: Backend contracts, domain aggregates/entities, value objects.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given `MerchantOnboardingPage`, when reference data loads, then the `AppBar` remains visible with the title and progress bar.
2. Given `MerchantDropdownField`, when rendered, then it matches `AppTextField` borders, corner radii, and label styling.
3. Given `MerchantOnboardingStepShell`, when rendered, then horizontal padding is clean and not doubled.
4. Given `MerchantOwnerRowCard`, when rendered, then it displays a clean card layout with compact action icons.
5. Given `ReviewStepWidget`, when rendered, then sections are cleanly boxed with edit buttons.
6. Given all tests and lints, when run, then all pass cleanly.

## Acceptance Criteria

1. `MerchantOnboardingStepShell` uses `SurfaceKind.form` and single-source horizontal padding from `AppPageContainer`.
2. `MerchantOnboardingPage` maintains persistent `AppBar` and progress bar.
3. `MerchantDropdownField` uses `FieldStyles.getInputDecoration`.
4. All existing tests in `test/features/merchant_onboarding/presentation/` pass.
5. `mobilekit lint` passes with 0 issues.

## Implementation Checklist

- [x] Check risk with `mobilekit risk classify`.
- [x] Initialize task baseline with `mobilekit task begin`.
- [x] Update `MerchantDropdownField` to use `FieldStyles.getInputDecoration`.
- [x] Update `MerchantOnboardingStepShell` layout, padding, and button bar.
- [x] Update `MerchantOnboardingPage` with persistent `AppBar` and progress indicator.
- [x] Update `BusinessStepWidget` and `SettlementStepWidget` spacing.
- [x] Update `MerchantOwnerRowCard` with polished container and compact actions.
- [x] Update `ReviewStepWidget` with boxed sections and declaration container.
- [x] Run `mobilekit fix --apply` and `mobilekit lint`.
- [x] Run `fvm flutter test test/features/merchant_onboarding/presentation/`.
- [x] Run `mobilekit task verify --task merchant-onboarding-ui-polish --env dev`.
- [x] Move plan to `completed/` and record completion notes.

## Decision Log

- 2026-09-05: Single-source horizontal padding -> Let `AppPageContainer` provide `layout.pagePadding`; remove nested 16px horizontal paddings from inner scroll view and headers.
- 2026-09-05: Unify dropdown styling with `FieldStyles` -> Ensures visual parity with `AppTextField`.
- 2026-09-05: Design tokens adherence -> Used `AppRadii.radius12`, `AppSizing.iconSizeCompact`, `AppSizing.iconSizeSmall`, and `MotionDurations.medium` to strictly pass custom lints.

## Verification

```bash
fvm flutter test test/features/merchant_onboarding/presentation/
dart run mobile_core_kit_cli:mobilekit task verify --task merchant-onboarding-ui-polish --env dev
```

## Runtime Evidence

Polished presentation components verified through widget tests and full test pipeline (663/663 passed).

## Rollback

Revert working tree to baseline revision.

## Risks And Mitigations

- Risk: Widget finder mismatches in existing tests.
  Mitigation: Preserve existing ValueKeys and text content across all polished widgets.

## Completion Notes

- Resolved padding nesting: `AppPageContainer` now applies canonical page padding (`SurfaceKind.form`), while inner widgets and `MerchantOnboardingStepShell` avoid duplicate horizontal insets.
- Restored persistent top `AppBar` with `LinearProgressIndicator` step progress across all steps (business, owners, settlement, review).
- Re-styled `MerchantDropdownField` to use `FieldStyles.getInputDecoration` matching `AppTextField` with `AppRadii.radius12`.
- Polished `MerchantOwnerRowCard` and `ReviewStepWidget` with surface container cards, dividers, and compact action buttons.
- Fixed text truncation in `ReviewStepWidget`: updated `_ReviewRow` with `overflow: TextOverflow.visible` and adjusted flex distribution (5:6) so labels like `Ownership percentage` and multi-line values like `adfa — owner • Primary contact` wrap gracefully without ellipsis truncation.
- Fixed label truncation in `AppCheckboxTile`: added `overflow: TextOverflow.visible` so multi-line declaration labels and helper texts wrap properly.
- Full verification passed (`mobilekit task verify --task merchant-onboarding-ui-polish --env dev`).
- Strictly maintained zero comments in all `merchant_onboarding` source files.

## Follow-ups

- [x] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none. (None)
