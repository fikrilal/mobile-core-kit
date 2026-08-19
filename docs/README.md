# Documentation Index

This repo is intended to be **cloned by product teams**. To keep docs scalable and easy to navigate, use the folder taxonomy below and avoid placing new docs directly under `docs/`.

## Where should this doc go?

- `docs/engineering/` — day-to-day guides and patterns you apply while building (UI state, testing, validation, Clean Architecture).
  High-signal examples:
  - `docs/engineering/testing_strategy.md`
  - `docs/engineering/agent_pr_loop.md`
  - `docs/engineering/mobilekit_cli_reference.md`
  - `docs/engineering/parallel_agent_workflow.md`
  - agent harness measurements: `docs/engineering/harness_baseline.md`
  - structured task authority and preflight: `docs/engineering/task_authority.md`
  - bounded task verification and repair: `docs/engineering/controlled_verification_loop.md`
  - isolated current-agent worktrees: `docs/engineering/current_agent_workspaces.md`
  - registered independent acceptance evidence: `docs/engineering/behavioral_oracles.md`
  - task-bound sanitized device evidence: `docs/engineering/mobile_runtime_harness.md`
  - queued event intake, read-only maintenance, independent CI, and verified handoff: `docs/engineering/event_maintenance_handoff.md`
  - duplication harness overview, profiles, and commands: `docs/engineering/duplication_harness.md`
- `docs/template/` — “what to change when cloning” setup and customization guides (env, deep links, rebrand, and backend integration).
- `docs/contracts/` — cross-team contracts and guarantees (backend/API semantics, auth rules, error codes, idempotency expectations).
- `docs/explainers/` — deep dives on “how this works” that are not daily guides (complex flows, tricky components, feature internals).
- `docs/core/` — deep dives on **core runtime systems** (session, startup, networking policies) intended to be stable across cloned products.
- `docs/exec-plans/` — active/completed execution plans and technical debt tracking for non-trivial tasks.
- `docs/_WIP/` — drafts and notes that are not ready to be treated as reference.

## Suggested conventions

- Prefer short, descriptive filenames in `snake_case.md`.
- Keep docs self-contained: include key assumptions, invariants, and where the relevant code lives.
- If a doc is meant for another team (backend/infra), put it under `docs/contracts/` and keep the language “contract-style” (MUST/SHOULD, clear definitions).
