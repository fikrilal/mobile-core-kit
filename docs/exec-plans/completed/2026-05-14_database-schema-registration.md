# Database Schema Registration

Date: 2026-05-14  
Owner: Codex  
Status: completed  
Risk class: low  
Related issue/PR: N/A

## Objective

Move feature-owned database schema registration out of feature service wiring and into an explicit startup registration path, while preserving feature ownership of table creation.

## Constraints

- architectural constraints: `core/infra` must not import feature code; `core/di` may compose feature DI modules.
- product/runtime constraints: schema registration must run before `AppDatabase().database` is opened.
- out of scope: database version bumps, new migrations, DAO behavior changes, and broader database framework changes.

## Acceptance Criteria

1. Cached current-user table creation is registered from a feature-owned schema module.
2. App startup has one explicit database schema registration step.
3. Existing account current-user dependency registration no longer owns schema registration.
4. ADR records the ownership/orchestration decision.
5. Relevant checks pass.

## Implementation Checklist

- [x] Add account database schema module.
- [x] Add core DI database schema registrar.
- [x] Wire schema registrar early in `registerLocator()`.
- [x] Remove schema registration from `AccountCurrentUserModule`.
- [x] Add ADR and index entry.
- [x] Run verification.

## Decision Log

- 2026-05-14: Use modular schema registration via the composition root -> keeps feature schema ownership while making startup ordering explicit.

## Verification

```bash
dart run tool/fix.dart --apply
flutter test test/features/account/data/datasource/local/account_cached_user_local_datasource_test.dart
dart run tool/verify.dart --env dev
```

Outcome: passed.

## Runtime Evidence

Not required; low-risk startup wiring refactor covered by static checks and tests.

## Risks And Mitigations

- Risk: schema registration could still be forgotten for future features.
- Mitigation: ADR and central registrar provide one review target for future schema contributors.

## Completion Notes

Shipped modular database schema registration via the composition root. The
account feature now owns cached-user table registration through
`AccountDatabaseSchema`, and `registerLocator()` invokes the database schema
registrar before other dependency registration.

## Follow-ups

- [x] No unresolved follow-up debt from this change.
