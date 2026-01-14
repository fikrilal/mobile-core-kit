# Documentation Index

This repo is intended to be **cloned by product teams**. To keep docs scalable and easy to navigate, use the folder taxonomy below and avoid placing new docs directly under `docs/`.

## Where should this doc go?

- `docs/engineering/` — day-to-day guides and patterns you apply while building (UI state, testing, validation, Clean Architecture).
- `docs/template/` — “what to change when cloning” setup and customization guides (env, deep links, rebrand, etc.).
- `docs/contracts/` — cross-team contracts and guarantees (backend/API semantics, auth rules, error codes, idempotency expectations).
- `docs/explainers/` — deep dives on “how this works” that are not daily guides (complex flows, tricky components, feature internals).
- `docs/_WIP/` — drafts and notes that are not ready to be treated as reference.

## Suggested conventions

- Prefer short, descriptive filenames in `snake_case.md`.
- Keep docs self-contained: include key assumptions, invariants, and where the relevant code lives.
- If a doc is meant for another team (backend/infra), put it under `docs/contracts/` and keep the language “contract-style” (MUST/SHOULD, clear definitions).

