# Optional `--task` on `runtime evidence`; drop `runtime logs`

Status: proposed. Decision input, not authority. Does not authorize
implementation, commit, or publication.
Date: 2026-09-09. Rewritten same day: no new kit verb; cut `runtime logs`.
Location: `_WIP/`

Related:
- `_WIP/2026-09-06_maestro-device-proof-proposal.md` (adopted locally;
  its “logs `--mode run` then evidence” interface is what this revises)
- `docs/engineering/mobile_runtime_harness.md`
- `docs/engineering/mobilekit_cli_reference.md`
- `docs/engineering/agent_pr_loop.md`
- `maestro/README.md`
- `packages/mobile_core_kit_cli/lib/src/runtime/runtime_evidence_workflow.dart`
- `packages/mobile_core_kit_cli/lib/src/runtime/runtime_log_session.dart`
- `packages/mobile_core_kit_cli/lib/src/runtime/runtime_log_workflow.dart`

## Recommendation

Keep **one** kit runtime command: `mobilekit runtime evidence`.

1. `--task` optional when `--target` is a Maestro YAML.
   - No `--task` → iterate. Maestro exit. Logs on disk. No
     `evidence.json`. Not handoff.
   - `--task` → prove. Same run + bound `evidence.json` if the task is
     live, active, and verified at the current fingerprint.
2. For YAML targets, evidence **itself** attaches `flutter logs -d`
   for the Maestro process, then stops. Best-effort. No extra flag.
3. **Delete the public `runtime logs` verb** (`start` / `tail` / `stop`
   / `status`, `--mode logs|run`). It is a thin wrap of `fvm flutter
   logs` and `fvm flutter run`. No bind. No proof. `--mode run` fights
   Maestro `launchApp`.

Humans who want a live app with no YAML: `fvm flutter run` /
`fvm flutter logs`. Not kit CLI.

Do not add `runtime journey` or `mobilekit maestro`. No CI/Cloud
Maestro. Dart `integration-test` still requires `--task`.

This revises the 2026-09-06 Maestro *interface*. It does not reopen
“Maestro as local proof, not CI.”

Net surface: **minus one verb**, not plus one.

## Current behavior

After plumbing (`13ba726`) and the durability fix (`8086ff6`):

**Prove** — `--task` is required today.

```bash
mobilekit runtime evidence --task <id> --device <udid> --flavor dev \
  --target maestro/<flow>.yaml
```

- Live V2 plan in `docs/exec-plans/active/` with `Status: active`.
- `task verify` at current fingerprint or `runtime.task-not-verified`.
- Shells `maestro test --udid <device> <yaml>`.
- Tees Maestro stdout to the agent and `_artifacts/mobile/<ts>/logs/`
  (1 MiB cap, gitignored).
- Writes sanitized `evidence.json` + `summary.md`. `handoff check`
  reads only that manifest for `maestro-flow`.
- Does not install the APK. Does not attach logcat. Does not scrape Nest.

**Iterate** — kit CLI cannot. Agent runs `maestro test` itself.

**Logs** — public verb `runtime logs start --mode logs|run`.
`--mode logs` = `flutter logs -d`. `--mode run` = `flutter run`.
Session pid + `_artifacts/runtime_logs/<session>/`. Diagnostic only.
`handoff check` ignores it. Maestro `launchApp` kills `--mode run`.

**Dart wiring** — same `runtime evidence --task` runs `flutter test`
for `integration-test` oracles. `--task` stays required for Dart.

**Completed tasks** — snapshotted `planPath`; move to `completed/` →
`task.plan-missing`. Unchanged. Not this proposal.

## Problem

Three tools to “run YAML and see a 4xx”:

1. `maestro test` to iterate
2. `runtime logs` to attach logcat (or wrongly `--mode run`)
3. `runtime evidence --task` to prove

`runtime logs` does not earn a kit verb. It does not bind fingerprints
or write `evidence.json`. Agents can already type `fvm flutter logs`.
Keeping it after evidence auto-attaches logcat is dead weight.

Adding `runtime journey` would be a **fourth** path. Rejected.

## Goals

1. Zero new kit verbs. **One fewer:** remove `runtime logs`.
2. `runtime evidence --device --flavor --target maestro/*.yaml` works
   without `--task` (iterate).
3. The same command with `--task` remains the only Maestro completion
   bind. `handoff check` still only reads `evidence.json`.
4. YAML path attaches `flutter logs -d <device>` for Maestro’s
   lifetime, then stops. No `--mode`. No `--no-logs`.
5. Docs never tell agents to start a kit log session before Maestro.
6. Fail-closed gates stay: no prod, no example env, no CI
   `google-services.ci.json`, missing `maestro` binary fails.

## Non-goals

- New `runtime journey` / `mobilekit maestro`.
- Optional `--task` for Dart `integration-test`.
- Rebinding evidence for completed tasks.
- Scraping Nest process logs.
- Hosted CI / Maestro Cloud / device Maestro inside `verify --profile full`.
- `handoff check` accepting raw Maestro or logcat files.
- Replacing `integration_test` wiring oracles.
- iOS as the first cut.
- Auto-installing the APK.
- Deleting `RuntimeLogSession` if evidence still uses it internally.
- Shrinking the rest of `mobilekit` (`task`, `verify`, `oracle`, …).

## Invariants (unchanged)

- Prove still needs a selected `maestro-flow` oracle, verified
  fingerprint, flavor `dev` (staging allowed, prod rejected).
- `evidence.json` sanitization unchanged: hashed device id; no raw
  device ids, env values, credentials, headers, bodies, or full logs
  in the durable manifest / summary / PR body.
- `_artifacts/` and `.tmp/mobilekit` stay gitignored.
- Thin wrapper: still invoke the `maestro` binary.
- Unique identity stays a flow concern (`MAESTRO_TEST_*`).

## Proposed interface

Same command. `--task` optional for YAML. No `runtime logs`.

```bash
# Iterate. Not handoff.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device emulator-5554 \
  --flavor dev \
  --target maestro/register.yaml

# Prove.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task maestro-register-pilot \
  --device emulator-5554 \
  --flavor dev \
  --target maestro/register.yaml

# Human, no YAML (not kit CLI)
fvm flutter run -d emulator-5554 --flavor dev -t lib/main_dev.dart
fvm flutter logs -d emulator-5554
```

| | No `--task` (iterate) | `--task` (prove) |
|---|---|---|
| Live verified plan | not required | required, current fingerprint |
| `--target` | existing `maestro/*.yaml` | selected `maestro-flow` oracle |
| Process | attach `flutter logs -d`, then `maestro test --udid` | same |
| Streams | Maestro stdout + logcat (gitignored, 1 MiB) | those **plus** `_artifacts/mobile/<ts>/evidence.json` |
| `handoff check` | no | yes, on pass |
| Exit | Maestro exit | Maestro exit (failed manifest still written, latest-wins) |

Without `--task` and without a `maestro/*.yaml` target: usage error.
Dart `integration-test` without `--task`: usage error.

`mobilekit runtime logs …` → unknown command (or a one-line hint:
use `fvm flutter logs` / evidence YAML path).

Raw `maestro test` remains an escape hatch. Still never writes a bound
manifest.

### Agent loop

```text
edit maestro/<flow>.yaml
  → runtime evidence --device … --target maestro/<flow>.yaml
  → (fail) read stdout + attached logcat file
  → task verify --task <id> --env dev
  → runtime evidence --task <id> --device … --target maestro/<flow>.yaml
  → handoff check --task <id>
```

### Code change

`RuntimeEvidenceWorkflow`:

1. `--task` optional.
2. No `--task`: skip binder. Require `--device`, `--flavor`, `--target`
   = existing `maestro/*.yaml`. Same Maestro fail-closed gates.
3. Before `maestro test`, start `flutter logs -d` (reuse
   `RuntimeLogSession` **logs** mode internally, or a few lines of
   `Process.start`). `finally`: stop. Attach failure → warn, still run
   Maestro.
4. `--task`: today’s binder + `_writeManifest`, plus the same attach.

**Delete public `runtime logs`:**

- `RuntimeLogWorkflow` user-facing dispatch in `mobilekit_cli.dart`
- `writeUsage` / `start|tail|stop|status`
- CLI tests that only cover that verb
- Docs recipes (`--mode run` then evidence; `--mode logs` then tail)

Keep `RuntimeLogSession` if evidence still calls it. Do not keep a
hidden alias of `runtime logs` “for compatibility.” One cut.

`writeUsage` for evidence: `--task` required for Dart and for Maestro
proof; omit to iterate a YAML.

### Process graph

```text
  runtime evidence --target maestro/foo.yaml [--task id]
       │
       ├─ flutter logs -d <udid>     (best-effort, always for YAML)
       │        └─► gitignored logcat file (1 MiB cap)
       │
       └─ maestro test --udid <udid> maestro/foo.yaml
                ├─► agent stdout (tee)
                └─► gitignored maestro stdout
                      │
                      └─ if --task: _artifacts/mobile/<ts>/evidence.json
       stop logcat when Maestro exits (success or fail)
```

Kit runtime verbs after:

```text
  runtime evidence     YAML iterate/prove + Dart prove
  (gone) runtime logs
  doctor               still warns if maestro missing
```

## Ownership

| Piece | Owner | Change |
|---|---|---|
| `RuntimeEvidenceWorkflow` | CLI | optional `--task`; YAML logcat attach |
| Binder / manifest | CLI | skip when no `--task`; else unchanged |
| `RuntimeLogSession` | CLI | internal helper only, or inline `flutter logs` |
| `RuntimeLogWorkflow` | CLI | **delete** public command |
| Docs | harness | drop `runtime logs` from reference, harness, agent_pr_loop, maestro README |

No second evidence schema. No second durable artifact root.

## Docs this fixes

- `docs/engineering/agent_pr_loop.md` — `--mode run` then evidence
- `docs/engineering/mobilekit_cli_reference.md` — remove `runtime logs`
  row; `--task` not always required
- `docs/engineering/mobile_runtime_harness.md` — iterate = evidence
  without `--task`; no kit log session
- `maestro/README.md` — same
- `_WIP/2026-09-06_maestro-device-proof-proposal.md` — interface
  section superseded

## Risks and tradeoffs

- **Humans lose `runtime logs start --mode run`.** They already have
  `fvm flutter run`. That is the actual app driver. Accept the cut.
- **`--task` meaning two things.** Usage text + invariant: no `--task`
  never writes `evidence.json`, even on exit 0.
- **Logcat volume.** 1 MiB cap, gitignored, not copied into
  `evidence.json`.
- **Attach fails.** Warn; Maestro still runs. Do not fail the Maestro
  exit because logcat died.
- **Leftover sessions** from today’s `runtime logs start`. Evidence
  does not manage them. Humans `kill` or ignore. No migration command.
- **Completed-task proof.** Still impossible. Re-open the plan as the
  single active V2 to bind again.
- **Secrets in logcat.** Local, gitignored. Do not paste into plans
  or commits.

## Acceptance

1. `runtime evidence --device … --flavor dev --target maestro/login.yaml`
   (no `--task`) runs Maestro, writes iterate logs, exits with Maestro’s
   code, writes **no** `evidence.json`.
2. The same command with `--task` on a verified plan that selects that
   YAML writes `evidence.json` that `handoff check` accepts, with
   `summary.md` tagged `durable-summary`.
3. `flutter run` is never spawned by `runtime evidence`.
4. YAML path starts `flutter logs -d` before Maestro and stops it after,
   including on failure. No `--no-logs` flag.
5. `mobilekit runtime logs` is not a command (help does not list it).
6. `--flavor prod`, example env, CI google-services, missing `maestro`
   still fail closed with or without `--task`.
7. Prove still rejects a `--target` that is not a selected
   `maestro-flow` oracle. Iterate accepts any existing `maestro/*.yaml`.
8. No `--task` and no YAML target → usage (2). Dart target without
   `--task` → usage (2).
9. CLI tests: no `--task` skips bind; `--task` + stale fingerprint
   fails; logcat stopped on Maestro failure; durability tag still path
   equality; `runtime logs` dispatch tests removed or expect unknown
   command.
10. `agent_pr_loop.md` and `mobilekit_cli_reference.md` do not mention
    `runtime logs` as a Maestro prerequisite. No new `mobilekit`
    subcommand.

## Open questions

1. **Iterate target policy.** Any existing `maestro/*.yaml` vs only
   registered oracles. Recommendation: any existing YAML (author a
   flow before `oracles.yaml` exists). Prove stays registered-only.
2. **When to land.** After `maestro-register-pilot` is parked or
   completed (one active V2). This is harness CLI + docs, not another
   YAML.

## Follow-up if accepted

Queued V2 plan, Oracle ID `harness.full`, allowed paths:

- `packages/mobile_core_kit_cli/lib/src/runtime/`
- `packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart`
- matching tests
- the docs listed above

Gate: CLI unit tests. Optional smoke: iterate
`runtime evidence --target maestro/login.yaml` on an emulator if up,
without `--task`, confirm no `evidence.json`. Confirm
`mobilekit runtime logs` errors as unknown.
