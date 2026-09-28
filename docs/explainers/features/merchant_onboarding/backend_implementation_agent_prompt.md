# Backend Implementation Agent Prompt

Copy the prompt below into a new agent session. It intentionally separates
implementation authority from commit, push, PR, migration deployment, and
production deployment authority.

---

You are implementing the merchant-onboarding backend case study in:

```text
/home/fikrilal/devs/core/backend-core-kit
```

The complete backend behavior handoff is:

```text
/home/fikrilal/devs/core/backend-core-kit/docs/engineering/merchant-onboarding/implementation-handoff.md
```

The originating mobile blueprint is:

```text
/home/fikrilal/devs/core/mobile-core-kit/docs/explainers/features/merchant_onboarding/validation_architecture_blueprint.md
```

Implement the full backend scope defined by the handoff. Do not implement any
explicit non-goal.

## Mandatory repository isolation

The existing backend checkout is on `development` and may contain unrelated
`_WIP/` changes. Preserve them exactly. Do not clean, stash, stage, unstage,
edit, or delete them.

Before any backend source or plan edit:

1. Inspect `AGENTS.md`, the current branch, `git status --short --branch`, and
   existing worktrees.
2. Confirm the destination below does not exist and the branch name is unused.
3. From the original backend checkout, create this isolated worktree and branch:

```bash
git worktree add \
  /home/fikrilal/devs/core/backend-core-kit-merchant-onboarding \
  -b agent/merchant-onboarding \
  development
```

4. Continue the same agent session exclusively from:

```text
/home/fikrilal/devs/core/backend-core-kit-merchant-onboarding
```

If the path or branch already exists, or `development` is not the expected
base, stop and report the exact state. Do not overwrite, delete, reset, reuse,
or force anything.

After creating the worktree, verify that
`docs/engineering/merchant-onboarding/implementation-handoff.md` exists in the
candidate. If it is absent because the handoff has not yet been committed to
`development`, read it from the original checkout and add the same document at
the same repository-relative path in the candidate. Include that path and its
engineering-index entry in the execution-plan scope. Do not modify or remove
the original checkout's copy.

## Required reading

Read completely before implementation:

- backend `AGENTS.md`;
- both handoff documents above;
- `docs/README.md`;
- `docs/core/project-architecture.md`;
- `docs/standards/api-response-standard.md`;
- `docs/standards/error-codes.md`;
- `docs/standards/reliability.md`;
- `docs/standards/security.md`;
- `docs/standards/testing-strategy.md`;
- `docs/openapi/README.md`;
- `docs/engineering/agent-pr-loop.md`;
- `docs/engineering/backend-runtime-evidence.md`;
- `docs/exec-plans/README.md` and its V2 template.

Inspect, rather than guess, the existing users feature, auth guard/current
principal, problem filters, idempotency decorators/interceptor, Prisma
repository patterns, app module wiring, OpenAPI decorators, and e2e setup.

## Execution plan and risk

Before source edits, create a V2 active execution plan named:

```text
docs/exec-plans/active/2026-08-30_merchant-onboarding-backend.md
```

Use task ID `merchant-onboarding-backend`. Classify the task as high risk
because it changes Prisma/migrations, the public API/OpenAPI contract, and an
idempotent write. Declare at least these impacts:

```text
API/OpenAPI: yes
DB/Prisma/migrations: yes
Auth/session/RBAC: no
Queue/jobs: no
Env/config/secrets: no
Observability/logging/tracing: no
External integrations: no
CI/release/harness: no
```

Grant only `edit, verify`. Use narrow allowed paths covering the new feature,
app wiring, typed error registry, Prisma schema/migration, OpenAPI snapshot,
targeted tests, related backend docs, and the active/completed plan. Do not
grant commit, push, PR, migrate, or deploy.

Then run:

```bash
npm run backendkit -- task begin \
  --plan docs/exec-plans/active/2026-08-30_merchant-onboarding-backend.md
npm run backendkit -- task preflight \
  --task merchant-onboarding-backend --action edit
```

Do not change authority-bearing plan metadata after `task begin`.

## Implementation constraints

- Use a small `libs/features/merchant-onboarding/` capability slice.
- Keep business rules framework-free and Prisma behind a repository interface.
- Use `AccessTokenGuard` and `CurrentPrincipal`; do not alter authentication.
- Use the existing idempotency platform and require `Idempotency-Key` on submit.
- Use code-owned reference constants; do not create catalog tables or admin CRUD.
- Revalidate all mobile rules on the server.
- Use a database transaction and unique constraints for race-safe submission.
- Follow success-envelope and RFC 7807 standards.
- Add typed feature error codes to the existing application error registry.
- Generate OpenAPI from code; do not hand-edit the snapshot as the source.
- Use `Clock` for application time if a time dependency is injected.
- Never use `any`, type assertions to silence errors, raw production error-code
  strings, native Nest HTTP exceptions, or cross-layer shortcuts.
- Do not add queues, workers, external services, environment variables, feature
  flags, generic validators, or speculative abstractions.

The submitted bank account number is sensitive transient input. Normalize and
validate it, derive `accountNumberLast4`, and then discard it. It must not be
persisted, returned, logged, traced, or included in error messages. Do not add
plaintext storage. Do not invent tokenization or encryption infrastructure;
those are explicitly outside this exercise.

## Implementation order

1. Add pure reference-data constants, input types, validation policy, stable
   issues, and exhaustive unit tests.
2. Add the Prisma models, migration, repository interface/adapter, atomic
   create behavior, and persistence tests.
3. Add the service, typed errors/filter, DTOs, controller, module wiring, and
   authenticated reference-data endpoint.
4. Add the required idempotent submit endpoint and map race-safe conflicts.
5. Add targeted HTTP/e2e coverage, including replay and sensitive-data checks.
6. Generate and verify the OpenAPI snapshot.
7. Update only backend documentation that is required to rediscover the new
   feature and contract.

Keep the implementation minimal. If the handoff conflicts with observed
repository behavior, report concrete evidence before changing the product
contract. You may make small naming/layout adjustments that preserve behavior
and existing conventions; record them in the plan decision log.

## Verification

Run targeted tests during development. Before declaring completion, run at
least:

```bash
npm run format:check
npm run lint
npm run typecheck
npm run deps:check
npm test
npm run verify:prisma
npm run openapi:generate
npm run openapi:check
npm run openapi:lint
npm run duplication:report
npm run backendkit -- task preflight \
  --task merchant-onboarding-backend --action verify
npm run backendkit -- task verify --task merchant-onboarding-backend
npm run verify:e2e
```

The high-risk runtime evidence must include the existing
`http.idempotent-write` oracle plus a merchant-onboarding e2e flow proving one
database mutation across an identical replay. Record exact commands, results,
artifact paths, and sanitized request/trace IDs in the execution plan.

After a controlled verification failure, repair with normal editing tools,
record the changed candidate with `npm run backendkit -- task repair`, and then
re-run verification. Do not claim success from an unchanged retry.

## Completion and publication boundary

On success:

- self-review the complete diff and generated artifacts;
- confirm the original backend checkout and its `_WIP/` files are unchanged;
- complete and archive the execution plan;
- report the branch name, worktree path, changed files, behavior, migration,
  OpenAPI changes, checks, runtime evidence, and residual risks.

Do not commit, push, open a PR, run a migration against a shared/production
database, merge, deploy, or delete the worktree/branch. Each action requires a
fresh explicit user authorization.

---
