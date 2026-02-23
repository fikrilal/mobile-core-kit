# Agent PR Loop

This document defines the default delivery loop for agent-authored changes in this repository.

Goal:
- keep PRs predictable
- keep review cost low
- preserve production safety while moving fast

## Scope

Use this loop for any change authored by an AI coding agent.

For non-trivial changes, create an execution plan first:
- `docs/exec-plans/README.md`
- `docs/exec-plans/active/`

## Loop Contract

1. Task intake
- Write a clear task statement with acceptance criteria.
- If work is non-trivial, create a plan file in `docs/exec-plans/active/` from `docs/exec-plans/_template.md`.
- Set a risk class before implementation starts:
  - `low`: local UI/refactor/tests/docs with no auth/network/session/runtime/release impact
  - `medium`: feature behavior change, navigation change, data mapping/API usage changes
  - `high`: auth/session/security, payment/billing, data migration, CI/release/infra changes

2. Implement
- Keep changes small and reversible.
- Follow architecture boundaries and lint policy from:
  - `AGENTS.md`
  - `docs/engineering/guardrails.md`

3. Preflight (required before PR)
- Run:

```bash
tool/agent/pr_ready_check.sh --env dev
```

- Optional:

```bash
tool/agent/pr_ready_check.sh --env dev --check-codegen
tool/agent/pr_ready_check.sh --env dev --skip-tests
```

4. Self-review (required)
- Verify:
  - acceptance criteria are fully met
  - no architecture boundary violations
  - no speculative refactors mixed into the change
  - tests are added/updated where behavior changed
  - failure paths are explicit and observable

5. Open PR with evidence
- Use `.github/pull_request_template.md`.
- Include:
  - risk class and impact
  - checks executed and results
  - runtime evidence when relevant (screenshots/log traces/test outputs)
  - known follow-ups (if any)

6. Review iteration loop
- Address review comments in small deltas.
- Re-run `tool/agent/pr_ready_check.sh --env dev` after substantive changes.
- Repeat until all required checks and reviewers are satisfied.

7. Merge policy
- `low`: merge after required checks pass.
- `medium`: at least one reviewer sign-off is recommended.
- `high`: human reviewer sign-off is required.

## Failure -> Harness Upgrade Rule

If the same class of failure appears 2+ times, do not rely on repeated manual fixes.
Promote the fix into one of:
- lint rule
- verify script
- scaffolder/template update
- engineering doc update

Track the improvement in execution plans or technical debt tracker once introduced.

## Definition Of Done

A PR is done only when:
1. acceptance criteria are met
2. required checks pass
3. risk-class merge policy is satisfied
4. evidence is present in PR description
