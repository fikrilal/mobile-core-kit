# Model & Entity Guide — Freezed + json_serializable

This codebase standardizes how you define **domain entities** and **data models** using
`freezed` and `json_serializable`. New code should follow these patterns to stay consistent.

---

## 1. Libraries & Codegen

We use:

- `freezed_annotation` for immutable value types and copyWith, equality, etc.
- `freezed` (dev) as the generator.
- `json_annotation` for JSON annotations.
- `json_serializable` (dev) to generate `fromJson` / `toJson` where appropriate.
- `build_runner` as the codegen runner.

Generated files are **committed**:

- `*.freezed.dart`
- `*.g.dart`

Whenever you change a Freezed or JSON‑annotated type, run:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Domain Entities (lib/features/<feature>/domain/entity)

Domain entities are:

- Freezed classes.
- UI‑agnostic.
- Do **not** depend on Dio/HTTP, database, or Flutter widgets.
- Usually **do not** have JSON methods (only data layer models do).

Pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _UserEntity;
}
```

Rules:

- Put entities under `lib/features/<feature>/domain/entity/`.
- Prefer Freezed for anything that benefits from immutability + equality.
- Do **not** add `fromJson` / `toJson` here; that lives in data models.

---

## 3. Remote Models (lib/features/<feature>/data/model/remote)

Remote models (DTOs) represent API payloads:

- Freezed + json_serializable.
- Contain `fromJson` (and generated `toJson`).
- Own the mapping to/from domain entities via extensions or helpers.

Pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entity/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        displayName: entity.displayName,
        emailVerified: entity.emailVerified,
        createdAt: entity.createdAt,
        avatarUrl: entity.avatarUrl,
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresIn: entity.expiresIn,
      );
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
      );
}
```

Usage with `ApiHelper`:

```dart
final response = await _apiHelper.post<UserModel>(
  AuthEndpoint.login,
  data: requestModel.toJson(),
  host: ApiHost.auth,
  parser: UserModel.fromJson,
);

final user = response.data!.toEntity();
```

Rules:

- Place under `lib/features/<feature>/data/model/remote/`.
- Always include both `part 'x.freezed.dart';` and `part 'x.g.dart';`.
- Use `factory X.fromJson(...) => _$XFromJson(json);` (let json_serializable generate it).
- Keep model→entity mapping close to the model (extension or helper).

---

## 4. Local Models (lib/features/<feature>/data/model/local)

Local models represent database or cache rows:

- Also Freezed.
- May or may not use json_serializable (often we just use `fromMap` / `toMap`).

Pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entity/user_entity.dart';

part 'user_local_model.freezed.dart';

@freezed
abstract class UserLocalModel with _$UserLocalModel {
  static const tableName = 'users';
  static const createTableQuery =
      'CREATE TABLE users ('
      'id TEXT PRIMARY KEY,'
      'email TEXT,'
      'displayName TEXT,'
      'emailVerified INTEGER,'
      'createdAt TEXT,'
      'avatarUrl TEXT'
      ');';

  const factory UserLocalModel({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
  }) = _UserLocalModel;

  const UserLocalModel._();

  factory UserLocalModel.fromMap(Map<String, dynamic> m) => UserLocalModel(
        id: m['id'] as String?,
        email: m['email'] as String?,
        displayName: m['displayName'] as String?,
        emailVerified: m['emailVerified'] == null
            ? null
            : (m['emailVerified'] as int) == 1,
        createdAt: m['createdAt'] as String?,
        avatarUrl: m['avatarUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'emailVerified':
            emailVerified == null ? null : (emailVerified! ? 1 : 0),
        'createdAt': createdAt,
        'avatarUrl': avatarUrl,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
      );
}

extension UserEntityLocalX on UserEntity {
  UserLocalModel toLocalModel() => UserLocalModel(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
      );
}
```

Rules:

- Keep DB specifics (table names, SQL) in local models or DAOs.
- Map local models ↔ domain entities here, not in repositories.

---

## 5. Request Models

Request DTOs (what you send to APIs) also live in `data/model/remote` and follow the same pattern:

```dart
@freezed
abstract class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String email,
    required String password,
  }) = _LoginRequestModel;

  const LoginRequestModel._();

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  factory LoginRequestModel.fromEntity(LoginRequestEntity entity) =>
      LoginRequestModel(email: entity.email, password: entity.password);
}
```

These then call `toJson()` directly when passing `data` into `ApiHelper`.

---

## 6. When to Write Custom fromJson

Default: let `json_serializable` generate `fromJson` and `toJson`.

Only write a custom `fromJson` when:

- The payload shape is non‑standard (e.g., variant keys, nested envelopes), **and**
- You cannot adapt it easily with annotations alone.

Even then, keep the model Freezed and still use `json_serializable` for `toJson` where possible.

---

## 7. Quick Checklist for New Code

When adding a new entity/model:

1. **Domain entity** → `lib/features/<feature>/domain/entity/`  
   - Freezed, no JSON, business‑meaningful fields.
2. **Remote model** → `lib/features/<feature>/data/model/remote/`  
   - Freezed + json_serializable, `fromJson`, `toJson`, `toEntity`/`fromEntity`.
3. **Local model** → `lib/features/<feature>/data/model/local/`  
   - Freezed, `fromMap` / `toMap`, `toEntity`/`fromEntity`.
4. Run codegen:
   - `fvm dart run build_runner build --delete-conflicting-outputs`.
5. Use `ApiHelper` with `parser: Model.fromJson` for remote calls.

