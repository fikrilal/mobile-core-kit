---
status: accepted
date: 2026-08-29
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [architecture, validation, value-objects, inputs, repositories]
tracking: docs/exec-plans/completed/2026-08-29_document-input-cardinality-policy.md
supersedes: ADR/records/0016-validated-form-boundaries.md
---

# Choose input boundaries by cardinality, cohesion, and invariants

## Context and Problem Statement

ADR 0016 established a valid raw-input to domain-aggregate repository boundary
for login and registration. Its default `XInput -> XValidatedAggregate` flow is
appropriate for cohesive multi-field forms with deterministic invariants, but
it does not say what to do with one field, many fields without invariants, or
an already-valid domain value.

Applying that default universally creates types that add no semantic proof.
Avoiding named input types universally creates long, unstable parameter lists.
We need a policy that treats grouping and validation as separate decisions.

## Decision Drivers

* Keep invalid values from crossing repository boundaries when deterministic
  invariants exist.
* Keep use cases as the final gate for raw values that require validation.
* Avoid one-field wrapper inputs and aggregates that add no meaning.
* Avoid long parameter lists for cohesive submissions.
* Preserve searchable, named boundaries for humans and coding agents.
* Keep wire payloads and JSON ownership in the data layer.

## Considered Options

* Require `XInput -> XValidatedAggregate` for every request.
* Always use primitive or named parameters and validate procedurally.
* Choose scalar, VO, named input/command, or aggregate from cardinality,
  cohesion, and deterministic invariants.

## Decision Outcome

Chosen option: **choose the smallest type shape that expresses grouping and
validity separately**.

Two independent questions govern the boundary:

1. Does the operation need a named input to group a cohesive submission?
2. Does the repository need a type that proves deterministic validation?

Parameter count is a heuristic, not a hard rule. Cohesion and semantic meaning
take precedence.

| Input shape | Deterministic invariants | Default boundary |
| --- | --- | --- |
| No parameters | None | No input or aggregate type |
| One raw value | None | Scalar, enum, identifier, or existing domain type |
| One raw value | Present | Raw scalar to use case -> field VO -> repository |
| Multiple cohesive values | None | Named `XInput`/command when it improves the signature; no validated aggregate |
| Multiple unrelated values | None | Named parameters or split responsibilities; do not create a misleading aggregate |
| Multiple cohesive values | Field or cross-field invariants | Raw `XInput` -> private validated aggregate -> repository |
| Already-valid domain value | Already enforced | Pass the VO/entity directly |

### Ownership rules

* A raw `XInput` groups an application submission. It is not proof of validity
  and may contain primitives that have no domain invariant.
* A field VO proves one field invariant. For a single validated value, the
  repository accepts that VO directly; a one-field aggregate is unnecessary.
* A validated aggregate proves several field and/or cross-field invariants and
  has no public unchecked constructor.
* A named command/entity with multiple primitives is acceptable when the values
  are cohesive but no deterministic invariant needs proof.
* A repository may accept a primitive only when no deterministic invariant is
  being represented. Sensitive or opaque data alone does not automatically
  require a VO.
* A use case owns the raw-to-valid transition when validation is required. A
  pure pass-through operation should not gain a use case or aggregate merely
  for layering symmetry.
* A request model maps the chosen domain/application type into wire primitives
  and remains the only owner of JSON/backend payload shape.

Reference flows:

```text
Multi-field with invariants:
LoginInput -> LoginCredentials -> LoginRequestModel

Single field with an invariant:
raw email -> EmailAddress -> PasswordResetRequestModel

Multiple fields without invariants:
ListOptions/input command -> ListRequestModel

Already valid:
EmailVerificationToken -> VerifyEmailRequestModel
```

The raw email-verification token still enters its use case as a `String`; the
use case creates `EmailVerificationToken` before the repository call.

### Consequences

* Good, because every added type has either grouping or validity semantics.
* Good, because single-field flows avoid duplicate wrapper types.
* Good, because large cohesive forms avoid long parameter lists.
* Good, because repository signatures still expose validated state when needed.
* Good, because the policy scales without a generic form abstraction.
* Neutral, because superficially similar requests may use different type shapes.
* Bad, because contributors must evaluate cohesion and invariants rather than
  following one mechanical pipeline.
* Bad, because reviews must catch primitives that hide real invariants.

### Confirmation

Compliance is confirmed when:

* each input/command type states whether it groups raw values or proves validity;
* one-field validation uses a VO directly at the repository boundary;
* multi-field aggregates have private constructors and test field/cross-field failures;
* multi-parameter commands without invariants do not introduce ceremonial VOs;
* request models alone unwrap values and serialize payloads; and
* tests prove invalid raw values never reach repositories when invariants exist.

## Pros and Cons of the Options

### Universal input and aggregate pipeline

* Good, because every flow looks structurally identical.
* Bad, because one-field and invariant-free operations gain types without new guarantees.
* Bad, because structural consistency is mistaken for semantic consistency.

### Primitive parameters everywhere

* Good, because small signatures are direct.
* Bad, because large cohesive submissions become difficult to evolve and review.
* Bad, because repository contracts cannot prove validation when invariants exist.

### Cardinality, cohesion, and invariant policy

* Good, because it balances explicit boundaries with minimum necessary code.
* Good, because grouping and validation can evolve independently.
* Bad, because it requires engineering judgment at each new operation.

## More Information

* [Superseded ADR 0016](0016-validated-form-boundaries.md)
* [Validation architecture](../../docs/engineering/validation_architecture.md)
* [Value Objects and form validation](../../docs/engineering/value_objects_validation.md)
* [Validation cookbook](../../docs/engineering/validation_cookbook.md)
