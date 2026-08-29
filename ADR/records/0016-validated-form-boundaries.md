---
status: accepted
date: 2026-08-29
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [architecture, validation, value-objects, forms, repositories]
tracking: docs/exec-plans/completed/2026-08-29_register-validated-domain-boundary.md
---

# Use validated domain aggregates at form repository boundaries

## Context and Problem Statement

Form state must temporarily hold incomplete and invalid values, while domain
repositories should not accept data that violates deterministic client-side
invariants. The earlier login and registration flows passed primitive strings
through request entities, so their repository signatures did not express
whether validation had occurred and any caller could bypass the use-case gate.

We need one scalable boundary for simple and multi-field forms without moving
wire DTOs into the domain or requiring ceremonial types for every operation.

## Decision Drivers

* Preserve fast, field-level validation in Cubit/Bloc for user experience.
* Keep the use case as the final deterministic client-side validation gate.
* Make invalid repository calls difficult or impossible to express.
* Keep normalization and field invariants in domain Value Objects.
* Keep JSON and backend payload primitives in the data layer.
* Support aggregated errors for forms with multiple invalid fields.
* Avoid mandatory abstractions for operations that have no input invariants.

## Considered Options

* Raw input to a privately constructed validated aggregate, then to a request model.
* Primitive request entity accepted by both use case and repository.
* Validate inside the repository.
* Pass individual Value Objects as repository parameters.
* Use one generic validation helper or generic form aggregate for all flows.

## Decision Outcome

Chosen option: **raw input to a privately constructed validated aggregate,
then to a request model**.

For a form operation `X`, the default flow is:

```text
Presentation state
  -> XInput
  -> XUseCase
  -> XValidatedAggregate.create(...)
  -> XRepository(XValidatedAggregate)
  -> XRequestModel
  -> remote datasource
```

The responsibilities are:

* `XInput` is an immutable application input type containing raw form values.
  It may be incomplete or invalid and has no validation behavior.
* The use case invokes the aggregate factory and returns a domain validation
  failure when creation fails. This remains the final deterministic
  client-side gate even when presentation already performed pre-flight checks.
* The validated aggregate has no public unchecked constructor. It contains
  field Value Objects and may aggregate multiple `ValidationError` values.
* The repository contract accepts the validated aggregate, not raw form
  primitives. The type signature therefore records that deterministic
  validation has succeeded.
* The data layer unwraps Value Objects while constructing the request model.
  The request model alone owns JSON and backend payload shape.
* Server validation remains authoritative for dynamic rules such as uniqueness,
  credential correctness, authorization, account state, and rate limiting.

Login and registration are the reference implementations:

```text
LoginInput -> LoginCredentials -> LoginRequestModel
RegisterInput -> RegistrationCredentials -> RegisterRequestModel
```

This decision applies when an operation accepts user-controlled form values
with deterministic domain invariants. It does not require a validated aggregate
for parameterless operations, already-valid domain objects, identifiers with no
additional invariant, or pure repository pass-throughs. Ordinary domain
entities and request models remain valid patterns outside this boundary.

### Consequences

* Good, because repository signatures make validation state explicit.
* Good, because UI pre-flight checks and the use-case gate reuse the same field VOs.
* Good, because multi-field forms can return all deterministic errors at once.
* Good, because normalization happens once before the data boundary.
* Good, because DTO serialization remains isolated in the data layer.
* Neutral, because a validated form usually adds one raw input type and one
  aggregate type.
* Bad, because aggregate factories for similar forms may contain small amounts
  of structural duplication.
* Bad, because mocks and fakes must construct valid aggregates before calling
  repository methods.
* Bad, because changing an existing repository signature requires coordinated
  migration of implementations, tests, and integration fakes.

Small duplication between flow-specific aggregates is acceptable while their
field policies differ. A shared generic validator should be introduced only
after repeated use demonstrates a stable abstraction that preserves field
identity, error ordering, and concrete aggregate typing.

### Confirmation

Compliance is confirmed when:

* form presentation submits an `XInput` without normalizing it itself;
* the use case creates the validated aggregate and short-circuits on errors;
* the aggregate constructor is private and its fields are Value Objects;
* the repository accepts the aggregate and never accepts the corresponding raw
  form primitives;
* request-model tests prove normalization and wire serialization;
* use-case tests prove invalid input never reaches the repository; and
* repository tests prove device metadata and other transport concerns are
  unchanged.

## Pros and Cons of the Options

### Validated aggregate boundary

* Good, because validity is represented by a type rather than a comment or call order.
* Good, because it scales from two-field forms to larger cohesive submissions.
* Bad, because it introduces explicit mapping stages.

### Primitive request entity

* Good, because it requires fewer types.
* Bad, because its primitive fields do not prove that validation occurred.
* Bad, because repository callers can bypass the intended gate.

### Repository validation

* Good, because every repository call is checked at runtime.
* Bad, because repositories gain domain-rule ownership and repeat use-case work.
* Bad, because the contract still accepts invalid data.

### Individual Value Object parameters

* Good, because every parameter is valid by construction.
* Bad, because multi-field operations lose a cohesive named concept and become
  cumbersome as fields grow.

### Generic validation helper or aggregate

* Good, because it may reduce repeated folding code.
* Bad, because it can erase flow-specific meaning and couple unrelated field policies.
* Bad, because no stable generic abstraction has yet been demonstrated.

## More Information

* [Validation architecture](../../docs/engineering/validation_architecture.md)
* [Value Objects and form validation](../../docs/engineering/value_objects_validation.md)
* [Model and entity guide](../../docs/engineering/model_entity_guide.md)
* [Login boundary execution plan](../../docs/exec-plans/completed/2026-08-28_login-validated-domain-boundary.md)
* [Register boundary execution plan](../../docs/exec-plans/completed/2026-08-29_register-validated-domain-boundary.md)
