# Harness Phase 1 — Truthful Canonical Profiles

Date: 2026-08-10
Owner: Codex
Status: completed
Risk class: high
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Make the existing repository harness truthful and establish one typed owner for
the `fast`, `full`, `runtime`, and `ci` verification profiles before any task
controller is introduced.

## Constraints

- architectural constraints: keep `mobilekit` as the only repository harness
  CLI; keep CLI code outside application `lib/`; preserve all Clean Architecture
  lints and current application behavior;
- product/runtime constraints: preserve the current `mobilekit verify --env`
  entry point as a compatibility alias; prefer the checkout-local FVM SDK and
  report any PATH fallback; make CI call the same profile owner as local use;
- out of scope: task mutation, risk-selected repair, worktree creation, event
  intake, publication, operating-ledger writes, and hill climbing.

## Acceptance Criteria

1. `mobilekit verify --profile fast|full|runtime|ci` is backed by one typed
   profile registry with tested step composition.
2. The compatibility command `mobilekit verify --env <env>` remains valid and
   maps to `full` unless a profile is supplied explicitly.
3. `full` runs root tests, CLI package tests, custom-lint package tests,
   code-generation freshness, and the documented duplication gates.
4. Knowledge verification fails on missing project-map policy, broken local
   Markdown links, invalid execution-plan lifecycle placement, or malformed
   required plan fields; it never reports a skipped success.
5. Flutter/Dart execution reports whether the pinned FVM SDK or PATH fallback
   was selected, and CI uses the pinned `.fvmrc` contract.
6. CI delegates canonical verification to `mobilekit --profile ci`; focused
   tests prove profile/CI parity and negative paths.
7. A checked-in baseline records profile duration, test inventory, coverage,
   duplication policy, and known blind spots without introducing speculative
   thresholds.
8. The accepted direction is recorded in a new ADR and relevant agent/CLI/docs
   guidance is consistent with the implemented profiles.

## Implementation Checklist

- [x] Capture the pre-change verification and test inventory baseline.
- [x] Add the accepted agent-first harness ADR.
- [x] Add deterministic knowledge and plan validation, including a parseable
      project map.
- [x] Introduce typed verification profiles and compatibility parsing.
- [x] Include CLI and custom-lint package tests in `full` and `ci`.
- [x] Surface pinned SDK resolution and PATH fallback.
- [x] Point CI canonical verification at the typed `ci` profile.
- [x] Add focused positive, negative, and parity tests.
- [x] Update AGENTS, CLI, guardrail, CI, and documentation-index guidance.
- [x] Capture the post-change baseline and complete verification.

## Decision Log

- 2026-08-10: Preserve `verify --env` as a `full` compatibility alias -> old
  agent instructions and cloned-project docs remain usable while profiles
  become explicit.
- 2026-08-10: Keep core and small-helper duplication advisory in `full` and
  `ci`, and presentation duplication targeted -> the measured baseline contains
  known actionable debt and the current filter deliberately returns success;
  Phase 7 may propose a gate only from a reviewed clean baseline.
- 2026-08-10: Keep `runtime` as a registered profile in Phase 1 but delegate to
  the existing explicit device-evidence workflow -> Phase 5 will bind runtime
  evidence to task authority and candidate identity.

## Verification

Record exact commands, durations, and outcomes as the phase proceeds.

```bash
dart test packages/mobile_core_kit_cli/test
dart test packages/mobile_core_kit_lints/test
dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
fvm flutter test
dart run mobile_core_kit_cli:mobilekit project-map verify
```

Evidence:

- pre-change CLI package: 82 tests passed in 3.71 seconds;
- pre-change custom-lint package: 11 tests passed in 6.38 seconds;
- pre-change canonical command: 553 root tests passed but the command failed
  formatting after 194.69 seconds;
- `dart test` in `packages/mobile_core_kit_cli`: passed after Phase 1 changes;
- `dart analyze packages/mobile_core_kit_cli`: passed;
- `mobilekit knowledge verify`: passed and confirms CI profile ownership;
- `mobilekit verify --profile fast --env dev`: passed in 65.04 seconds;
- `mobilekit verify --profile full --env dev`: passed on the exact final phase
  state in 136.99 seconds (553 application tests, 97 CLI tests, 11 lint-package
  tests);
- non-golden coverage run: 549 tests passed in 59.46 seconds, 62.78% line
  coverage (6,277 / 9,998);
- core and small-helper duplication ran in `full` and remained advisory at the
  measured 5 and 126 actionable groups.

## Runtime Evidence

Not required for Phase 1. This phase changes repository tooling and CI
selection but does not change application behavior. CLI integration tests and
clean command execution are the relevant runtime evidence.

## Risks And Mitigations

- Risk: a stronger default gate makes normal development unexpectedly slow.
- Mitigation: retain an explicit cheap `fast` profile and measure both profiles
  before documenting their intended use.
- Risk: package tests recurse through `mobilekit verify` or depend on generated
  root state.
- Mitigation: invoke package-owned test commands directly and cover the exact
  command registry with executor-based tests.
- Risk: knowledge validation rejects historical records that predate the new
  contract.
- Mitigation: validate current active/queued plans prospectively and keep
  completed legacy records readable without rewriting history.

## Completion Notes

Phase 1 established one typed profile registry, fail-closed repository
knowledge checks, harness-package proof, explicit toolchain diagnostics, and CI
delegation. The legacy verify shape remains available but labels skip flags as
weakened compatibility evidence. No task mutation or later-loop controller was
introduced.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`.
