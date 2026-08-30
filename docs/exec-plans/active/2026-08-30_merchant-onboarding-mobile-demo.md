# Build Merchant Onboarding Mobile Demo

**Plan version:** 2
**Task ID:** merchant-onboarding-mobile-demo
**Status:** active
**Owner:** implementation agent
**Risk:** high
**Authority:** Implement and verify the complete four-step merchant-onboarding mobile demo on the current demo branch, including pure domain validation, raw form input, use-case and repository boundaries, a deterministic fake adapter, Cubit orchestration, production-quality UI, navigation, localization, and tests; do not add real backend integration or publish changes.
**Allowed paths:** docs/exec-plans/active/2026-08-30_merchant-onboarding-mobile-demo.md, docs/exec-plans/completed/2026-08-30_merchant-onboarding-mobile-demo.md, lib/features/merchant_onboarding/, lib/core/di/registrars/feature_modules_registrar.dart, lib/features/home/presentation/pages/home_page.dart, lib/navigation/app_router.dart, lib/navigation/merchant_onboarding/, lib/l10n/, test/features/merchant_onboarding/, test/features/home/, test/core/di/registrars/registrars_smoke_test.dart, test/navigation/merchant_onboarding/, integration_test/startup_deep_link_resume_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 6h
**Oracle IDs:** startup.integration, ui.human-review

Date: 2026-08-30
Related issue/PR: N/A

## Objective

Turn the accepted validation blueprint into a runnable reference feature that
demonstrates the repository's complete mobile validation architecture without
depending on an unfinished backend. One agent implements three ordered work
packages in the same task and session so domain, state, and UI decisions remain
coherent.

Primary specification:

`docs/explainers/features/merchant_onboarding/validation_architecture_blueprint.md`

The finished branch should be useful to developers as a hands-on example of:

```text
raw nested input
  -> field value objects
  -> validated child/root aggregates
  -> final use-case gate
  -> typed repository boundary
  -> deterministic fake adapter
  -> Cubit-driven four-step UI
```

## Constraints

- Architecture constraints:
  - Follow ADR 0017 and `docs/engineering/validation_architecture.md`.
  - Follow `docs/engineering/ui_state_architecture.md` for Cubit state and one-shot effects.
  - Keep presentation input, validated domain values, and data representations distinct.
  - The submit use case is the non-bypassable final local validation gate.
  - The repository submit method accepts only a fully validated application.
  - Keep business rules framework-free and independently testable.
  - Register dependencies through a feature module and the existing feature registrar.
  - Reuse existing design-system tokens, fields, buttons, cards, dialogs, and feedback components.
- Product/runtime constraints:
  - Implement exactly four steps: Business Profile, Owners, Settlement, and Review.
  - Keep the complete draft in memory only while the feature route is alive.
  - Preserve input when moving backward and forward between steps.
  - Confirm before discarding a materially edited draft.
  - Use stable reference-data IDs; labels are presentation-only.
  - Use stable owner row IDs for edits, reordering, validation paths, and settlement references.
  - Reset declarations after any material business, owner, or settlement edit.
  - Prevent duplicate submit calls while submission is in flight.
  - Never log or expose raw names, email, phone, registration, or bank-account values.
  - Mask the account number except for its last four digits on review.
- Simplicity constraints:
  - Use one feature Cubit; do not introduce Bloc, a workflow engine, or per-step Cubits.
  - Add only value objects with real normalization or invariants.
  - Use code-owned demo reference data; do not build generic catalog infrastructure.
  - Use one deterministic fake repository; do not add a second abstraction around it.
- Out of scope:
  - Real HTTP calls, Dio data sources, request/response models, OpenAPI mutation, or backend error mapping.
  - Authentication/session behavior changes.
  - Images, documents, country/city/address fields, or platform permissions.
  - Persisted drafts, database schemas, offline sync, autosave, background work, or analytics expansion.
  - Production bank verification, payout execution, compliance lifecycle, or admin workflows.
  - New dependencies, broad design-system changes, unrelated refactors, commit, push, or PR creation.

## Demo Reference Data

The fake adapter must return stable IDs compatible with the backend handoff.
Labels must be localized by presentation or supplied as demo display values;
domain decisions use IDs and metadata only.

| Catalog | Required IDs | Metadata |
| --- | --- | --- |
| business types | `sole_proprietorship`, `private_company` | registration required false/true |
| industries | `retail`, `food_beverage`, `professional_services`, `digital_services` | none |
| monthly sales | `under_10m_idr`, `10m_to_50m_idr`, `50m_to_250m_idr`, `above_250m_idr` | none |
| owner roles | `owner`, `director` | contributes ownership true/false |
| banks | `demo_bank_alpha`, `demo_bank_beta` | supported payout schedules |
| holder types | `business`, `owner` | owner reference required false/true |
| payout schedules | `daily`, `weekly` | none |

`demo_bank_alpha` supports daily and weekly. `demo_bank_beta` supports weekly
only. The demo terms version is `2026-08-30`.

The fake submit operation validates through the same use-case/domain boundary,
waits only if an injectable/testable fake behavior already fits the repository
conventions, and returns a deterministic non-sensitive application ID. It must
not pretend to perform remote bank or eligibility checks.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: yes
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given reference data is loading, when the route opens, then the form shows bounded loading/failure states and becomes editable only after a snapshot is available.
2. Given an invalid business profile, when `Next` is tapped, then the user remains on step one, all deterministic step failures are shown, and the first invalid field is focused.
3. Given a business type that requires registration, when the number is empty or malformed, then `business.registrationNumber` fails even if the widget visibility was manipulated.
4. Given one owner row, when it contributes exactly 10,000 basis points and is the sole primary contact, then the owners aggregate can be constructed.
5. Given multiple owners with duplicate normalized email, invalid ownership total, or multiple primary contacts, when `Next` is tapped, then stable row/aggregate paths render on the correct controls.
6. Given owner-held settlement, when the referenced owner is removed, then the reference clears and settlement becomes invalid.
7. Given a payout schedule unsupported by the selected bank, when settlement is validated, then the schedule field receives a deterministic failure.
8. Given declarations were accepted, when any material earlier value changes, then all declaration booleans reset while the entered draft remains intact.
9. Given every step previously passed, when submit is tapped, then the use case reconstructs the entire validated application before the fake repository is called.
10. Given final validation fails, when submit is attempted, then no repository call occurs and the UI navigates/focuses the earliest failing path.
11. Given valid final input, when submit is tapped twice rapidly, then one fake submission occurs and a localized success result is shown.
12. Given the review step, when it renders settlement information, then only the account number's last four digits are visible.
13. Given a materially edited draft, when system/app back would leave the feature, then a localized discard confirmation appears; an untouched or successfully submitted draft exits without confirmation.
14. Given a developer opens the demo branch, when the app reaches Home, then a discoverable localized entry opens the merchant-onboarding route without changing startup or deep-link behavior.

## Acceptance Criteria

1. The implementation follows every retained field and rule in the blueprint; deviations are recorded with repository evidence before code changes continue.
2. Raw draft input can represent empty, partial, and inconsistent form state without claiming domain validity.
3. Scalar VOs own normalization/invariants, child aggregates own step-local/cohesive rules, and the root owns cross-step relationships.
4. Validation returns stable codes and paths in deterministic step, field, and owner-row order.
5. The submit use case validates raw input plus the immutable reference snapshot and never calls the repository for invalid input.
6. The repository contract accepts only `MerchantOnboardingApplication`; the fake adapter never accepts raw form primitives.
7. Cubit state owns current step, raw input, reference status, touched paths, local failures, and submission status without one-shot effect flags.
8. Focus, discard confirmation, and success/failure navigation are handled through the established one-shot effect pattern.
9. The UI contains exactly four mobile-friendly steps, uses existing design-system primitives, supports scrolling/keyboard behavior, and has accessible labels and error semantics.
10. A localized Home entry and isolated GoRouter feature route make the demo discoverable.
11. No raw account number appears in review output, effects, diagnostics, test descriptions, or fake submission results.
12. Focused domain, use-case, Cubit, widget, DI, route, and Home-entry tests pass.
13. Controlled full verification, targeted presentation duplication review, startup integration evidence, and human UI review are recorded truthfully.

## Ordered Work Packages

The same agent executes these packages in order. Do not create a new task,
branch, or agent between packages. Do not proceed past a package whose exit
criteria fail.

### Work Package 1 — Domain Validation Foundation

Implement only the pure domain/input foundation and mirrored unit tests:

- immutable raw nested input types for business, owner rows, settlement, and declarations;
- immutable reference snapshot/options and typed catalog IDs where they prevent accidental mixing;
- scalar VOs for names, registration, contact values, ownership basis points, account holder/number, owner row ID, and terms version where justified;
- validated `BusinessProfile`, `OwnershipStructure`, `SettlementAccount`, `MerchantDeclarations`, and `MerchantOnboardingApplication` factories;
- stable validation failure code/path representation and deterministic aggregation;
- all conditional, repeated-row, and cross-step rules from the blueprint.

Do not import Flutter, Bloc, GetIt, Dio, JSON, or navigation packages into the
domain. Avoid one-file-per-trivial-boolean ceremony; colocate small cohesive
types when it improves readability and searchability.

Exit criteria:

- every domain rule has positive, boundary, and failure-path unit coverage;
- ownership uses integer basis points and sums exactly;
- account numbers preserve leading zeroes and never become numeric values;
- aggregate construction cannot produce an invalid application;
- domain tests pass before Work Package 2 starts.

### Work Package 2 — Application And State Orchestration

Build the application boundary without widgets or navigation:

- repository port for loading reference data and submitting a validated application;
- deterministic fake adapter with the documented catalog and safe result;
- load-reference-data and submit use cases;
- one feature DI module, wired through the existing feature registrar;
- `MerchantOnboardingCubit`, immutable state, and typed one-shot effects;
- explicit intents for all field edits, owner-row operations, step movement, declarations, retry, and submit;
- touched-field behavior, step preflight, final-gate routing, declaration reset, stable row references, and duplicate-submit suppression.

Presentation may reuse domain validation to derive feedback, but it must not
invent a second business-rule implementation. Widgets must not be introduced
in this package.

Exit criteria:

- invalid final input proves zero repository calls;
- valid input proves exactly one typed repository call;
- Cubit tests cover every acceptance transition and effect;
- owner IDs survive edits/reordering and deleted settlement references clear;
- declaration reset and deterministic first-failure routing are proven;
- DI registration smoke coverage passes before Work Package 3 starts.

### Work Package 3 — UI, Navigation, And Runtime Proof

Implement the discoverable four-step experience:

- feature route constants/list and app-router composition;
- localized Home entry into the demo;
- one route-owned Cubit with reference loading at entry;
- four step widgets/pages with shared shell, progress, Back/Next/Submit actions, and review edit actions;
- dynamic owner add/edit/remove UI with stable keys;
- dropdowns rendered from the reference snapshot and storing IDs;
- inline field/aggregate failures, focus/scroll handling, loading/retry/submitting states, and success feedback;
- review masking and discard confirmation;
- localization in every supported ARB plus generated output;
- focused widget, route, Home-entry, and accessibility-oriented tests.

Use small private widgets/helpers only when they reduce page complexity. Do not
create a reusable form framework, generic wizard abstraction, or new design
tokens for a single demo.

Exit criteria:

- all four steps are reachable and back navigation preserves draft values;
- widget tests cover the happy path plus representative field, aggregate,
  cross-step, submission, and discard behavior;
- narrow screens, keyboard visibility, scrolling, semantics, and error focus
  are manually inspected;
- startup/navigation regression evidence and manual UI review are captured;
- final controlled verification passes for the exact candidate fingerprint.

## Implementation Checklist

- [ ] Begin the task from the clean demo branch and record the baseline.
- [ ] Complete Work Package 1 and its focused domain tests.
- [ ] Complete Work Package 2 and its use-case/Cubit/DI tests.
- [ ] Complete Work Package 3 and its widget/navigation/localization tests.
- [ ] Run code generation and confirm generated files are current.
- [ ] Run presentation duplication self-review and controlled full verification.
- [ ] Collect registered startup and human UI evidence for the exact verified fingerprint.
- [ ] Self-review privacy, accessibility, architecture boundaries, and the complete diff.
- [ ] Record evidence, complete this plan, and stop before commit/push/PR.

## Decision Log

- 2026-08-30: Use one V2 plan with three ordered packages -> preserves one agent context and task fingerprint without creating cross-plan dirty ownership or repeated commit boundaries.
- 2026-08-30: Implement the UI-facing vertical slice rather than widgets alone -> the demo must actually teach the validation architecture it presents.
- 2026-08-30: Use a fake adapter until the backend contract is generated -> enables parallel work without inventing remote DTOs or coupling UI to an unstable wire contract.
- 2026-08-30: Use one Cubit -> current flow is synchronous and does not justify Bloc event orchestration.
- 2026-08-30: Keep remote integration as a later plan -> OpenAPI sync and server failure mapping require backend evidence not currently available.

## Verification

Run the narrowest relevant tests at each package boundary. The receiving agent
must replace placeholders below with actual created paths and record outcomes.

```bash
# Work Package 1
fvm flutter test test/features/merchant_onboarding/domain

# Work Package 2
fvm flutter test test/features/merchant_onboarding/domain \
  test/features/merchant_onboarding/domain/usecase \
  test/features/merchant_onboarding/presentation/cubit \
  test/core/di/registrars/registrars_smoke_test.dart

# Work Package 3
fvm flutter test test/features/merchant_onboarding \
  test/features/home \
  test/navigation/merchant_onboarding

dart run build_runner build
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-mobile-demo --action verify
dart run mobile_core_kit_cli:mobilekit task verify \
  --task merchant-onboarding-mobile-demo --env dev
```

Do not use skipped lanes or arbitrary new tests as completion evidence. If a
path layout differs, run equivalent focused targets and record the exact paths.

## Runtime Evidence

Runtime/manual evidence is required because the final package changes
navigation and a complex user-facing form.

After controlled verification passes for the exact fingerprint:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task merchant-onboarding-mobile-demo \
  --device <android-or-ios-device> \
  --flavor dev
```

The registered `startup.integration` oracle must prove existing startup,
deep-link, and resume behavior remains intact. The registered
`ui.human-review` procedure must inspect at least:

- Home entry and first-step loading/content;
- invalid business field focus/error semantics;
- dynamic owner rows and invalid ownership total;
- conditional settlement owner and unsupported schedule behavior;
- review masking, declaration reset, submission-in-flight, and success state;
- backward navigation, keyboard/scroll behavior, and discard confirmation;
- narrow phone layout in Indonesian and English; and
- no raw sensitive values in screenshots, logs, or recorded artifacts.

Store only sanitized evidence allowed by
`docs/engineering/mobile_runtime_harness.md`. If no compatible device exists,
record the exact limitation and do not claim runtime success.

## Rollback

Remove the merchant-onboarding feature, its tests, route list, Home entry,
feature-module registration, and feature localization keys/generated output.
Restore app-router composition and move this plan to completed with rollback
evidence if implementation is intentionally abandoned. No database, remote
contract, account, or persisted draft requires cleanup.

## Risks And Mitigations

- Risk: three layers grow into repetitive validation implementations.
- Mitigation: domain factories own rules; presentation only controls timing, touched state, and routing.
- Risk: a large Cubit becomes a form-wide god object.
- Mitigation: keep state transitions explicit, delegate pure validation to domain types, and split widgets rather than state owners.
- Risk: dynamic row errors attach to the wrong owner after deletion or reorder.
- Mitigation: use stable row IDs in state, keys, paths, and settlement references; test every mutation.
- Risk: fake behavior drifts from the backend under development.
- Mitigation: limit the fake to documented catalogs and success/failure categories; defer all wire mapping to the later integration plan.
- Risk: review or diagnostics leak sensitive input.
- Mitigation: mask review output, avoid value-bearing logs/effects, and inspect tests/runtime artifacts.
- Risk: the new demo route regresses startup/navigation behavior.
- Mitigation: isolate route composition and execute the registered startup oracle.
- Risk: the UI becomes over-abstracted as a reusable wizard.
- Mitigation: build the minimum feature-specific composition and reject speculative framework extraction.

## Completion Notes

Pending.

## Follow-ups

- [ ] After the backend implementation and generated contract stabilize, create a separate plan for OpenAPI sync, remote DTOs/data source, repository replacement, server failure mapping, and mobile-backend integration evidence.
