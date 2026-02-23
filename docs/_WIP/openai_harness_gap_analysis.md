# Agent Harness Gap Analysis (vs OpenAI Harness Engineering)

Date: 2026-02-23  
Source reference: `_WIP/harness-engineering.md`  
Repository: `mobile-core-kit`

## Purpose

Capture current-state gaps between this repo and the workflow model described in OpenAI's harness-engineering article, then define a practical closure plan.

## Current Strengths (Already in Place)

1. Strong mechanical guardrails and canonical verification.
   - `tool/verify.dart`
   - `tool/fix.dart`
   - `analysis_options.yaml`
   - `packages/mobile_core_kit_lints/lib/*`
2. CI enforces quality/security signals.
   - `.github/workflows/android.yml`
   - `.github/workflows/governance.yml`
3. Agent-aware repo guidance exists and is concise.
   - `AGENTS.md`
   - `docs/engineering/ai_agent_workflow.md`
4. Architecture constraints are codified, not aspirational.
   - `docs/engineering/guardrails.md`
   - `tool/lints/architecture_lints.yaml`
5. Basic end-to-end coverage exists.
   - `integration_test/auth_happy_path_test.dart`
   - `integration_test/startup_deep_link_resume_test.dart`

## Gap Matrix

| Dimension | OpenAI-style target | Current state | Gap |
|---|---|---|---|
| Delivery loop automation | Scripted agent PR lifecycle (`implement -> self-review -> request reviews -> iterate -> merge`) | No explicit in-repo loop orchestration with `gh`/review automation | High |
| Capability loop | Failures are systematically converted into reusable tools/rules/docs | Guardrails exist, but no explicit lifecycle policy or backlog for "failure -> harness upgrade" | Medium |
| App legibility for agents | Agent-operable UI and observability loop (repro, inspect, verify) | Runtime logs/metrics exist, but no dedicated agent-facing observability workflow/harness | High |
| Knowledge system operations | Structured docs + active/completed execution plans + debt register | Good docs taxonomy/ADRs, but no first-class `exec-plans/active|completed` workflow | Medium |
| Entropy/cleanup loop | Scheduled cleanup/doc gardening/quality scoring with recurring automation | No scheduled maintenance workflows (`schedule:` not present in CI) | High |
| Throughput merge philosophy | Fast iterative merges with cheap correction loops | Current stricter gates are safer for mobile prod; intentionally conservative | Low/Intentional |

## Evidence Notes

1. No scheduled workflows detected (`.github/workflows/*` has no `schedule:` trigger).
2. No explicit agent self-review/automerge scripts found in `tool/` or workflow files.
3. Docs and architecture guardrails are strong and already operational.
4. Observability primitives exist (logging, startup metrics, trace IDs), but not a dedicated agent-run verification loop.

## Gap Closure Plan (Phased)

## Phase 1: Codify Delivery Loop (highest leverage)

1. Add a documented PR loop contract for agent runs:
   - Inputs: task, acceptance criteria, risk class.
   - Required outputs: tests/evidence, changelog, unresolved risks.
2. Add script(s) under `tool/agent/` for repeatable loop steps:
   - local verify
   - prepare PR body template
   - structured self-review checklist
3. Add a short playbook:
   - `docs/engineering/agent_pr_loop.md`

Success metric:
- Every agent-authored PR follows one deterministic checklist and evidence format.

## Phase 2: Add Execution-Plan System of Record

1. Introduce directories:
   - `docs/exec-plans/active/`
   - `docs/exec-plans/completed/`
   - `docs/exec-plans/tech_debt_tracker.md`
2. Add a lightweight plan template with:
   - objective
   - constraints
   - acceptance checks
   - decision log
   - completion criteria

Success metric:
- Non-trivial work items have an execution plan file with status transitions.

## Phase 3: Establish Entropy and Doc-Gardening Loop

1. Add scheduled CI workflow (nightly/weekly) for:
   - doc freshness checks
   - stale guideline detection
   - quality snapshot generation
2. Start with non-blocking reports, then promote stable checks to blocking.

Success metric:
- Weekly quality drift report generated automatically.

## Phase 4: Improve Agent Legibility of Runtime Behavior

1. Define a minimum "agent-observable" debug pack:
   - reproducible integration test command(s)
   - standard log extraction path
   - startup metric thresholds
2. Capture run artifacts in CI for failed checks (logs, screenshots where possible).

Success metric:
- Bugfix tasks include reproducible runtime evidence, not only static code diffs.

## Human vs Agent Operating Split (Current Recommendation)

1. Human owns:
   - prioritization
   - risk acceptance
   - architecture tradeoffs
   - release go/no-go
2. Agent owns:
   - implementation/refactor
   - deterministic checks
   - guardrail codification
   - doc and script updates for repeatable tasks

## Suggested First Implementation Slice

1. Create `docs/engineering/agent_pr_loop.md`.
2. Create `docs/exec-plans/` structure + templates.
3. Add one scheduled maintenance workflow in `.github/workflows/`.
4. Pilot on one medium feature change and review friction metrics.

## Open Questions

1. What risk classes require mandatory human review?
2. Which checks can be non-blocking initially to increase flow without reducing safety?
3. What is the minimum acceptable artifact set for agent-generated PR evidence?
