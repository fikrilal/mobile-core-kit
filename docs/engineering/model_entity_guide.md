# Model & Entity Guide

This guide defines how this repository writes:
- domain entities
- remote models
- local models
- request models
- model/entity mapping helpers

Use this document when the question is:
- how should this type be written?

Use `docs/engineering/data_domain_guide.md` when the question is:
- where should this code live, and who should own the behavior?

## 1. Core Rules

### Entities

Entities are domain-facing types.

They should be:
- UI-agnostic
- framework-light or pure Dart
- meaningful in business terms
- stable enough to be consumed by use cases and presentation

They should not be:
- raw API payload mirrors
- database row mirrors
- JSON/SQL serialization containers

### Models

Models are data-facing types.

They should represent:
- remote payloads
- request DTOs
- local cache/database rows

They may know about:
- JSON
- map serialization
- backend field naming
- database row shape

They should not leak into presentation as the feature contract.

## 2. Libraries & Codegen

We use:
- `freezed_annotation`
- `freezed`
- `json_annotation`
- `json_serializable`
- `build_runner`

Generated files are committed:
- `*.freezed.dart`
- `*.g.dart`

When a Freezed or JSON-annotated type changes, run:

```bash
dart run build_runner build
```

## 3. Domain Entities

Location:
- `lib/features/<feature>/domain/entity/`
- or `lib/core/domain/.../entity/` for shared kernel entities

Typical rules:
- prefer Freezed when immutability/equality matter
- avoid JSON helpers here
- keep field names business-meaningful
- do not import Dio, sqflite, or widget code

Pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required bool emailVerified,
    required List<String> roles,
    required UserProfileEntity profile,
  }) = _UserEntity;
}
```

## 4. Remote Response Models

Location:
- `lib/features/<feature>/data/model/remote/`
- some shared remote models live in `lib/core/infra/network/model/remote/` when multiple features need them and feature-to-feature imports would be wrong

Typical rules:
- use Freezed + json_serializable
- include both `part '*.freezed.dart'` and `part '*.g.dart'`
- expose `fromJson`
- keep model-owned structural `toEntity()` close to the model when the mapping is straightforward

Pattern:

```dart
@freezed
abstract class UserResponseModel with _$UserResponseModel {
  const factory UserResponseModel({
    required String id,
    required String email,
    required bool emailVerified,
    required UserProfileResponseModel profile,
  }) = _UserResponseModel;

  const UserResponseModel._();

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    emailVerified: emailVerified,
    profile: profile.toEntity(),
  );
}
```

### When a remote model may live in `core`

Only do this when the type is truly shared and architecture boundaries require it.

Example:
- a current-user payload model may live in a shared location when runtime and
  multiple features need it, and feature-to-feature imports would be wrong

This should stay an exception, not the default.

## 5. Request Models

Request DTOs also live in `data/model/remote/`.

Use them when the backend payload shape matters.

Typical rules:
- mirror the backend payload exactly
- use `toJson()` for request bodies
- for one validated field, provide a factory from its VO; for several cohesive
  invariants, provide a factory from the validated aggregate and unwrap Value
  Objects there (for example, `fromCredentials(...)`)
- for invariant-free requests, map the smallest cohesive scalar/input/command;
  do not add VOs or an aggregate solely for the request-model factory
- use `fromEntity(...)` when a genuine domain entity already owns valid input
  and the conversion improves clarity
- add `@JsonSerializable(includeIfNull: false)` when omitted vs null fields matter for the backend contract

Pattern:

```dart
@freezed
abstract class UpdateProfileRequestModel with _$UpdateProfileRequestModel {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory UpdateProfileRequestModel({
    required UpdateProfileBodyModel profile,
  }) = _UpdateProfileRequestModel;

  const UpdateProfileRequestModel._();

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestModelFromJson(json);
}
```

Guideline:
- if omitted fields and `null` have different backend meaning, document that in the model file
- do not make a request model extend a domain entity or aggregate; wire and
  domain types have different ownership

## 6. Local Models

Location:
- `lib/features/<feature>/data/model/local/`

Use local models for:
- sqflite rows
- cached payload snapshots
- serialized local-only state

Typical rules:
- Freezed is fine when it improves readability/equality
- `fromMap` / `toMap` is often enough
- keep table/column/storage specifics close to the local model or DAO
- keep `toEntity()` and `fromEntity()` near the model when the mapping is straightforward

Pattern:

```dart
@freezed
abstract class CachedUserLocalModel with _$CachedUserLocalModel {
  const factory CachedUserLocalModel({
    String? id,
    String? email,
  }) = _CachedUserLocalModel;

  const CachedUserLocalModel._();

  factory CachedUserLocalModel.fromMap(Map<String, dynamic> map) =>
      CachedUserLocalModel(
        id: map['id'] as String?,
        email: map['email'] as String?,
      );

  Map<String, dynamic> toMap() => {'id': id, 'email': email};

  UserEntity? toEntity() {
    if (id == null || id!.isEmpty || email == null || email!.isEmpty) {
      return null;
    }
    return UserEntity(id: id!, email: email!);
  }
}
```

Real implementations often persist more fields than the shortened example above.
That is fine. The important rule is to keep storage-shape concerns local and
return `null` when the row is too incomplete to become a valid domain object.

## 7. Mapping Rules

### Preferred default

Keep simple structural mapping close to the model.

Examples:
- `UserResponseModel.toEntity()`
- `CachedUserLocalModel.toEntity()`
- `UserEntity.toLocalModel()`

### When not to keep mapping only on the model

Use a repository-local helper when the mapping needs:
- multiple models combined into one entity
- paginated metadata interpretation
- endpoint-specific derived state
- repository-only orchestration context

Rule:
- one model -> one entity = model-owned mapping
- many models/meta -> one result = repository-owned mapping

## 8. Naming Conventions

Use names that expose role clearly:
- domain: `*_entity.dart`
- remote model: `*_model.dart`
- local model: `*_local_model.dart`
- request model: `*_request_model.dart`

Avoid ambiguous names like:
- `UserData`
- `UserDtoModelEntity`
- `Payload`

## 9. Nullability And Optionality

Be explicit about what null means.

Questions to answer when writing a model:
- is the field optional because the backend omits it?
- is it nullable because null is a meaningful value?
- should omitted fields be excluded from `toJson()`?

For request models, this matters a lot.
The current profile patch models already document this clearly in code comments.

## 10. When To Write Custom `fromJson`

Default:
- let `json_serializable` generate `fromJson` and `toJson`

Write custom parsing only when:
- the payload shape is irregular
- annotations are not enough
- a small adapter object would be more confusing than a focused custom parser

Even then:
- keep the model itself readable
- keep custom parsing localized

## 11. Anti-Patterns

Do not:
- add `fromJson` / `toJson` to domain entities by default
- make repositories own all structural field-by-field mapping when the model can own it
- leak raw API response shapes into presentation
- use model names as if they were domain contracts
- create separate mapper files for every model/entity conversion when an extension on the model is enough

## 12. Quick Checklist

When adding a new type:

1. Is this a business-facing type?
- make it an entity or value object in `domain/`

2. Is this an API payload or request body?
- make it a remote model in `data/model/remote/`

If raw values require deterministic validation:
- use a raw scalar for one field or `XInput` for several cohesive fields
- validate one field into its VO or several invariants into a private aggregate
- make the request model unwrap that validated type in the data layer

If no deterministic invariant exists:
- use a scalar, named input/command, or genuine entity based on cohesion
- do not create ceremonial VOs or a validated aggregate

3. Is this a cache/database row?
- make it a local model in `data/model/local/`

4. Is the mapping one model to one entity?
- keep `toEntity()` near the model

5. Does omitted vs null matter to the backend?
- configure JSON serialization explicitly

6. Did Freezed/JSON types change?
- run build_runner

## 13. Related Docs

- `docs/engineering/data_domain_guide.md`
- `docs/engineering/project_architecture.md`
- `docs/engineering/validation_architecture.md`
- [ADR 0017](../../ADR/records/0017-input-cardinality-and-validation-boundaries.md)
- `lib/core/domain/README.md`
