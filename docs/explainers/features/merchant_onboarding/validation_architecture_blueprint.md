# Merchant Onboarding: A Mobile-First Validation Case Study

**Status:** implementation blueprint

**Audience:** engineers learning or implementing this repository's validation architecture

**Scenario:** fictional policy for education; not legal, banking, or compliance advice

## Why This Case Exists

Merchant onboarding is more interesting than login without becoming an
enterprise workflow engine. This mobile-first version has four steps:

1. Business profile
2. Owners
3. Settlement
4. Review and submit

It demonstrates field rules, conditional requirements, repeated-row
invariants, cross-step relationships, a final domain gate, and dynamic checks
for which the server remains authoritative.

The flow has no file upload, geographic address, background draft sync, or
long-running compliance lifecycle. Its draft lives in memory while the route
is active. Leaving the route discards it after confirmation.

## Business Goal

A small business provides enough structured information to create a merchant
application and settlement destination. The client should:

- prevent obviously invalid submissions early;
- preserve input while the user moves between four steps;
- route failures to the exact step and field;
- submit stable reference-data IDs rather than display labels; and
- never imply that local validation guarantees server acceptance.

Successful submission means only that the server accepted the application.
Review, approval, rejection, and activation are outside this case.

## Scope and Non-Goals

In scope:

- a four-step wizard;
- one dynamic owner list;
- backend-provided dropdown values;
- synchronous local validation;
- one final use-case validation gate;
- minimal server error mapping; and
- unit, state, and boundary tests.

Out of scope:

- images or documents;
- country, province, city, or street address;
- persisted or cross-device drafts;
- offline submission;
- production compliance policy;
- identity verification;
- an actual OpenAPI contract; and
- post-submission application status.

## User Flow

The user can go back without losing in-memory input. `Next` validates the
current step. `Submit` validates the complete application again through the
use case, even if every step previously passed.

| Step | Purpose | Main validation lesson |
| --- | --- | --- |
| 1. Business | Identify and categorize the business | field VOs and conditional fields |
| 2. Owners | Describe ownership and a primary contact | dynamic rows and aggregate invariants |
| 3. Settlement | Choose where payouts are sent | cross-step references and server checks |
| 4. Review | Confirm and submit the application | declarations and final validation gate |

## Reference Data and Dropdowns

Before editing, the backend supplies an immutable reference-data snapshot with:

- business types;
- industries;
- monthly-sales ranges;
- owner roles;
- supported banks;
- account-holder types;
- payout schedules; and
- the current terms version.

Each option has a stable `id` and localized `label`. Presentation renders the
label, but draft state stores the ID and the request submits the ID. Labels are
not domain identity because they can be translated or renamed.

```text
ReferenceOption(id: "private_company", label: "Private company")
draft.businessTypeId = "private_company"
request.businessTypeId = "private_company"
```

Dropdowns improve consistency but do not eliminate validation:

- presentation prevents arbitrary text entry;
- final local validation rejects a missing ID or one absent from the snapshot;
- the server rejects an unknown, disabled, or newly unsupported ID.

If submission reports stale reference data, presentation reloads it, preserves
IDs that still exist, and asks the user to fix invalid selections.

## Step 1: Business Profile

### Fields

| Path | Draft type | Domain representation | Required | Local rules | Server-owned rules |
| --- | --- | --- | --- | --- | --- |
| `business.legalName` | `String` | `LegalBusinessName` | yes | trim; 2–100 characters | duplicate-business assessment |
| `business.businessTypeId` | `String?` | `BusinessTypeId` | yes | ID exists in reference snapshot | option is still enabled |
| `business.registrationNumber` | `String` | `RegistrationNumber?` | conditional | trim; uppercase; 4–30 ASCII letters, digits, or `-` | registry format and uniqueness |
| `business.industryId` | `String?` | `IndustryId` | yes | ID exists in reference snapshot | industry is still supported |
| `business.monthlySalesRangeId` | `String?` | `MonthlySalesRangeId` | yes | ID exists in reference snapshot | range is still enabled |
| `business.contactEmail` | `String` | `EmailAddress` | yes | trim; lowercase; valid email syntax | deliverability or account conflict |
| `business.contactPhone` | `String` | `PhoneNumber` | yes | normalize to E.164; supported length | reachability or account conflict |

### Conditional rule

The selected business type includes `requiresRegistrationNumber: bool`.

- When true, `registrationNumber` must be present and valid.
- When false, an empty value becomes `null`.
- When false but supplied, validate and preserve it. Do not silently discard
  optional user data.

`BusinessProfile.create(...)` owns this policy. The UI may show or hide the
field, but the aggregate owns the invariant.

### Error examples

| Code | Path | Meaning |
| --- | --- | --- |
| `business.legal_name.required` | `business.legalName` | empty after trimming |
| `business.type.required` | `business.businessTypeId` | no type selected |
| `business.registration.required` | `business.registrationNumber` | selected type requires a number |
| `business.industry.unsupported` | `business.industryId` | ID absent from the snapshot |
| `contact.email.invalid` | `business.contactEmail` | invalid email syntax |
| `contact.phone.invalid` | `business.contactPhone` | cannot normalize to supported E.164 |

## Step 2: Owners

The list contains one to five rows. Each row receives a stable local
`ownerRowId` when added. Reordering or deleting rows must not change IDs,
because validation paths and settlement references use them.

### Fields per row

| Path suffix | Draft type | Domain representation | Required | Local rules |
| --- | --- | --- | --- | --- |
| `ownerRowId` | UUID string | `OwnerRowId` | generated | non-empty and unique within draft |
| `fullName` | `String` | `PersonName` | yes | trim; 2–100 characters |
| `roleId` | `String?` | `OwnerRoleId` | yes | ID exists in reference snapshot |
| `ownershipPercentage` | `String` | `OwnershipPercentage?` | conditional | 0.01–100.00; at most two fractional digits |
| `email` | `String` | `EmailAddress` | yes | same normalization as business email |
| `isPrimaryContact` | `bool` | `bool` | yes | participates in exactly-one rule |

The role option includes `contributesOwnership: bool`. A percentage is required
only when this is true; a non-owning role must leave it empty.

`OwnershipPercentage` stores basis points, not floating point. For example,
`33.33` becomes `3333`, making aggregate totals exact.

### Aggregate rules

`OwnershipStructure.create(rows)` owns these invariants:

1. One to five rows exist.
2. `ownerRowId` values are unique.
3. Normalized owner emails are unique.
4. Exactly one row is the primary contact.
5. Ownership-contributing rows total exactly 10,000 basis points.
6. At least one row contributes ownership.

Row errors use stable paths:

```text
owners.<ownerRowId>.fullName
owners.<ownerRowId>.ownershipPercentage
owners.<ownerRowId>.email
```

Aggregate errors use `owners` when no row is solely responsible. A duplicate
email attaches to the later row using deterministic input order.

### Error examples

| Code | Path | Meaning |
| --- | --- | --- |
| `owners.required` | `owners` | no rows exist |
| `owners.limit.exceeded` | `owners` | more than five rows |
| `owner.name.required` | `owners.<id>.fullName` | empty row name |
| `owner.percentage.required` | `owners.<id>.ownershipPercentage` | owning role lacks percentage |
| `owner.percentage.not_allowed` | `owners.<id>.ownershipPercentage` | non-owning role has percentage |
| `owners.email.duplicate` | `owners.<id>.email` | duplicates an earlier normalized email |
| `owners.primary.invalid` | `owners` | zero or multiple primary contacts |
| `owners.total.invalid` | `owners` | ownership does not total 100% |

## Step 3: Settlement

### Fields

| Path | Draft type | Domain representation | Required | Local rules | Server-owned rules |
| --- | --- | --- | --- | --- | --- |
| `settlement.bankId` | `String?` | `BankId` | yes | ID exists in reference snapshot | bank enabled for merchant |
| `settlement.accountHolderName` | `String` | `BankAccountHolderName` | yes | trim; 2–100 characters | holder match or verification |
| `settlement.accountNumber` | `String` | `BankAccountNumber` | yes | remove spaces; 6–24 digits; preserve leading zeroes | existence and payout eligibility |
| `settlement.holderTypeId` | `String?` | `AccountHolderTypeId` | yes | ID exists in reference snapshot | option still enabled |
| `settlement.ownerRowId` | `String?` | `OwnerRowId?` | conditional | required for owner-held account | referenced owner acceptable |
| `settlement.payoutScheduleId` | `String?` | `PayoutScheduleId` | yes | ID exists in reference snapshot | schedule available for bank |

`accountNumber` is text, never an integer. Numeric conversion would remove
leading zeroes and can exceed platform integer ranges.

### Cross-step rule

The selected holder type includes `requiresOwnerReference: bool`.

- When false, `ownerRowId` must be `null`.
- When true, it is required and must reference an existing owner row.
- Deleting a referenced owner clears it and exposes
  `settlement.owner.required`.

`MerchantOnboardingApplication.create(...)` validates this again because the
relationship spans independently valid owner and settlement aggregates.

The client does not use name comparison as proof of account ownership. Names
can legitimately vary; the server performs authoritative bank verification.

### Error examples

| Code | Path | Meaning |
| --- | --- | --- |
| `settlement.bank.required` | `settlement.bankId` | no bank selected |
| `settlement.account_number.invalid` | `settlement.accountNumber` | fails local syntax |
| `settlement.owner.required` | `settlement.ownerRowId` | owner-held account has no owner |
| `settlement.owner.unknown` | `settlement.ownerRowId` | row ID does not exist |
| `settlement.schedule.unsupported` | `settlement.payoutScheduleId` | schedule absent from snapshot |

## Step 4: Review and Submit

Review renders normalized values and reference labels. It does not create a
second editable copy. Tapping `Edit` returns to the owning step.

### Fields

| Path | Draft type | Domain representation | Required | Rule |
| --- | --- | --- | --- | --- |
| `declarations.informationAccurate` | `bool` | `bool` | yes | must be true |
| `declarations.authorizedToSubmit` | `bool` | `bool` | yes | must be true |
| `declarations.termsAccepted` | `bool` | `bool` | yes | must be true |
| `declarations.termsVersion` | system `String` | `TermsVersion` | yes | equals snapshot version |

Changing any business, owner, or settlement value after acceptance resets all
three booleans. Changing only the current step or expanding review does not.

A stale terms version uses `declarations.terms_version.stale`, reloads
reference data, and requires acceptance again.

## Type and Boundary Architecture

The complete path is:

```text
widgets
  -> MerchantOnboardingInput (raw and incomplete)
  -> MerchantOnboardingCubit (interaction and step preflight)
  -> SubmitMerchantOnboarding use case (final local gate)
  -> MerchantOnboardingApplication (validated domain aggregate)
  -> request mapper
  -> MerchantOnboardingRequestModel (wire representation)
  -> repository / server
```

### Presentation input

`MerchantOnboardingInput` mirrors editable values and can be empty, partial,
or inconsistent. It contains:

```text
MerchantOnboardingInput
  business: BusinessProfileInput
  owners: List<OwnerInput>
  settlement: SettlementInput
  declarations: DeclarationsInput
```

This grouping is justified by many fields, four steps, and a dynamic list.
Primitive parameters would make cubit and use-case signatures brittle. A
one-field flow should still use one normal parameter unless grouping adds
meaning.

### Value objects

Use a VO when a scalar has reusable normalization or an invariant, such as
`EmailAddress`, `PhoneNumber`, `OwnershipPercentage`, or
`BankAccountNumber`. Do not create one for every boolean or arbitrary string.

Reference IDs may use small domain types when that prevents mixing unrelated
catalogs. They do not need duplicated validation classes; a shared
catalog-membership helper can construct the typed IDs.

### Validated aggregates

```text
MerchantOnboardingApplication
  business: BusinessProfile
  owners: OwnershipStructure
  settlement: SettlementAccount
  declarations: MerchantDeclarations
```

Each child validates its fields and internal rules. The root validates
relationships between children. A constructed application is safe for request
mapping; the mapper never validates business rules.

### Request model

`MerchantOnboardingRequestModel` exists only at the data boundary and contains
server field names and serialized primitives. Widgets never use it. Conversion
is one-way and mechanical:

```text
EmailAddress.value -> contact_email
OwnershipPercentage.basisPoints -> ownership_basis_points
BankId.value -> bank_id
```

## Validation Ownership

| Concern | Primary owner | Why |
| --- | --- | --- |
| immediate feedback | presentation | responsive UX |
| scalar normalization/invariants | value object | reusable domain meaning |
| rules inside one step | child aggregate | cohesive invariant boundary |
| repeated owner rules | `OwnershipStructure` | needs complete row set |
| owner-to-settlement relation | root application | spans child aggregates |
| final local validation | use case | cannot be bypassed by other callers |
| serialization | mapper/request model | transport concern only |
| uniqueness, eligibility, current support | server | needs authoritative state |

Presentation validation is advisory. The use case reconstructs the validated
application from raw input on every submit. It does not trust a prior `Next`
result or disabled button.

## Validation Timing

While editing:

- normalize for comparison without unexpectedly rewriting visible text;
- validate touched fields after changes;
- recompute cheap dependent rules such as owner total; and
- hide errors for untouched future steps.

On `Next`:

- mark the current step's fields touched;
- run the step aggregate preflight;
- stay and focus the first invalid field when it fails; and
- advance only when locally valid.

On `Submit`:

1. The use case receives complete raw input and reference snapshot.
2. It creates all VOs and child aggregates.
3. It creates the root and checks cross-step invariants.
4. On failure it returns deterministic local errors with no repository call.
5. On success it passes only the application to the repository.

Error order is step order, visible field order, then owner row order. This makes
focus behavior and tests deterministic.

## Presentation State

One `MerchantOnboardingCubit` is sufficient. Its state contains:

```text
currentStep
input
referenceDataStatus
touchedPaths
localErrorsByPath
submissionStatus
submissionFailure
```

Its explicit intents include loading reference data; changing business,
owner, settlement, or declaration values; adding/removing owners; moving
between steps; and submitting.

Navigation, focus, and success snackbars belong in `BlocListener` on state
transitions, not in `builder`. Submit is disabled only in flight; correctness
still comes from the use-case gate.

Bloc becomes reasonable if later requirements add concurrent loads, autosave,
external verification callbacks, or event ordering. It does not improve this
four-step synchronous flow today.

## Failure Routing

Local and server validation failures normalize to:

```text
ValidationFailure(
  code: stable machine-readable code,
  path: optional field or aggregate path,
  messageKey: localizable key,
)
```

For submission failures:

- a known field path navigates to its step and focuses the field;
- `owners` navigates to the owners summary;
- an unknown or form-level failure stays on review in a banner; and
- all input remains in memory.

Server field names map explicitly to client paths. Unknown paths are not
dropped; they become form-level failures and are logged without entered values.

## Minimal Server Boundary

These operations are illustrative, not changes to the OpenAPI contract:

```text
GET  /merchant-onboarding/reference-data
POST /merchant-onboarding/applications
```

Submission uses one idempotency key so a timeout retry cannot create a second
application. Relevant outcomes are success, structured field errors, duplicate
application, stale reference IDs, auth failure, and retryable failure.

The server owns registration uniqueness, duplicate detection, current catalog
support, bank verification, payout eligibility, and current terms. Local rules
improve UX but cannot replace these checks.

## Privacy and Observability

- Never log names, email, phone, registration, or bank-account values.
- Do not put raw values in analytics, crash metadata, routes, or error strings.
- Analytics may record step, validation code/path, owner count, duration bucket,
  and result category.
- Mask the account number on review except for its last four digits.
- Clear the in-memory draft when the route is discarded or submit succeeds.

## Testing Strategy

### Value-object tests

Cover boundaries and normalization for names, email, phone, registration
number, decimal-to-basis-point conversion, and account-number leading zeroes.

### Aggregate tests

`BusinessProfile` covers conditional registration and unknown reference IDs.
`OwnershipStructure` covers row bounds, exact totals, one primary contact,
normalized email uniqueness, and deterministic paths. The root covers valid
owner references, holder-type conditions, declarations, and terms version.

### Cubit tests

- `Next` stays on invalid step and requests first-field focus.
- Owner edits preserve stable row IDs.
- Deleting the settlement owner clears the reference.
- Material edits reset declarations.
- Server failures route to the correct step.
- Duplicate submit taps make one repository call.

### Use-case and boundary tests

- Invalid input never reaches the repository.
- A valid application reaches it once.
- Mapper output contains normalized primitives and stable IDs.
- Structured server paths map to presentation paths.
- Unknown server paths become form-level failures.

## End-to-End Acceptance Scenarios

1. A sole owner with 100%, one primary contact, valid settlement, and all
   declarations submits successfully.
2. A registered business cannot omit its registration number.
3. Two owners totaling 99.99% cannot leave the owner step.
4. Duplicate normalized owner emails identify the later row.
5. Removing the selected account owner invalidates settlement.
6. An unknown dropdown ID cannot pass the final gate.
7. Editing business data resets accepted declarations.
8. A server registration conflict returns to the business field without losing
   other input.
9. A bank verification failure returns to settlement.
10. Retrying after timeout reuses the idempotency key.

## Suggested Implementation Sequence

### Phase 1: Domain

- Add only VOs with real normalization or invariants.
- Add the child/root aggregates and unit tests.
- Keep failure codes and paths stable from the start.

### Phase 2: Presentation

- Add raw inputs, state, and cubit.
- Build four steps and dynamic owner rows.
- Add touched-field behavior, error routing, and declaration reset.

### Phase 3: Boundary

- Add request model, mapper, repository method, and failure mapping.
- Start with a fake repository if the backend contract is not approved.
- Adopt endpoints only through a separately reviewed contract change.

## Definition of Done

- The flow has exactly four steps.
- Every editable value has one clear validation owner.
- Dropdowns store and submit stable IDs.
- Owner errors survive edits and reordering.
- The use case is the final local gate.
- The mapper contains no business decisions.
- Server failures route without losing in-memory input.
- Sensitive values never appear in logs or analytics.
- Tests pass through the repository's normal verification workflow.

## Related Repository Decisions

- [Validation architecture](../../../engineering/validation_architecture.md)
- [UI state architecture](../../../engineering/ui_state_architecture.md)
- [Testing strategy](../../../engineering/testing_strategy.md)
- [ADR 0017: Input cardinality and validation boundaries](../../../../ADR/records/0017-input-cardinality-and-validation-boundaries.md)

This case applies the architecture selectively: raw input is justified by form
size, VOs by real scalar rules, aggregates by cohesive invariants, and the use
case remains the non-bypassable final gate.
