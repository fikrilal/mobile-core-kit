# Mobile Runtime Harness

The runtime harness produces completion-grade device evidence for an exact
controlled task candidate. It does not replace Codex, Claude Code, or the
normal chat workflow; the current agent invokes it after static verification.

Use it when unit/static checks cannot credibly prove user-visible runtime
behavior: auth/session, startup/navigation/deep links, permissions, Firebase,
push, platform integrations, or medium/high-risk UI interactions.

## Preconditions

1. The V2 plan selects one or more registered `integration-test` or
   `maestro-flow` oracle IDs.
2. `mobilekit task verify --task <id> --env <env>` passed for the exact current
   fingerprint.
3. One device or emulator is available. Device execution is single-flight.
4. Environment and platform configuration exists, or the explicit temporary
   preparation options can supply it.

An arbitrary `integration_test` path is not completion evidence. Register and
authorize the oracle first; see `docs/engineering/behavioral_oracles.md`.

## Deterministic evidence lane

Run all integration targets selected by the task:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <device-id> \
  --flavor dev
```

Narrow the run to one already selected target:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <device-id> \
  --target integration_test/auth_happy_path_test.dart
```

Local Maestro journey proof (not CI, not Cloud). Kit CLI is the only
completion run. Raw `maestro test` and Maestro MCP are iteration only.

The app package must already be installed on `--device`. `runtime evidence`
shells out to `maestro test`; it does not build or `flutter install`.
Maestro `launchApp` is the driver. YAML runs attach `flutter logs` for
that device, then stop. Do not `fvm flutter run` alongside Maestro:
`launchApp` kills it. YAML rules: `docs/engineering/maestro_flows.md`. Flow map: `maestro/README.md`.

```bash
# Iterate. Not handoff.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device <device-id> \
  --flavor dev \
  --target maestro/login.yaml

# Prove.
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <device-id> \
  --flavor dev \
  --target maestro/login.yaml
```

`maestro-flow` requires a real `.env/<flavor>.yaml` (no example fallback),
rejects `--flavor prod` and the CI Firebase fixture, and fails closed if
the `maestro` binary is missing. Install Maestro CLI on PATH; `mobilekit
doctor` warns when it is absent.

Use an explicit Firebase input transactionally when required:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task <task-id> \
  --device <device-id> \
  --flavor dev \
  --google-services-json <secure-path>/google-services.json
```

The command rejects an unverified/stale task fingerprint, unselected target,
or artifact directory outside the repository. Example environment fallback,
Firebase copying, and generated build config are restored on success and on
every failure path; runtime preparation must not become a candidate change.

## Evidence contract

Artifacts default to `_artifacts/mobile/<timestamp>/`:

- `evidence.json` — schema-versioned durable evidence;
- `summary.md` — sanitized human-readable result;
- `logs/*.log` — ignored local diagnostic logs, not PR evidence.

The durable manifest binds:

- task ID, plan path/hash, authority hash, base and candidate revisions;
- exact task fingerprint and selected oracle IDs;
- hashed device identifier, flavor, start/end/duration, outcome, exit code,
  and stable failure boundary;
- oracle/target results and repository-relative artifact paths, sizes, hashes;
- environment/Firebase preparation modes and log-retention policy.

It intentionally excludes raw device IDs, absolute repository paths,
environment values, credentials, authorization headers, request/response
bodies, raw trace contents, and full logs. Each local log is capped at 1 MiB,
created with owner-only permissions on POSIX, and ignored by Git. Do not upload
raw logs without a separate security/privacy review.

Only an `evidence.json` whose fingerprint equals the final reviewed candidate
is eligible for handoff. Any candidate change requires `task repair`, another
controlled verification, and refreshed runtime evidence.

## Interactive/manual lane

When automation cannot prove layout or context-sensitive interaction, select
the registered manual-review oracle and follow its procedure. Record only
sanitized screenshots/observations and the exact task fingerprint. Manual
review does not authorize an agent to weaken or bypass the deterministic gate.

## Live diagnostic logs

Maestro YAML evidence attaches `flutter logs` itself. For a human
session with no YAML, use Flutter directly:

```bash
fvm flutter logs -d <device-id>
fvm flutter run -d <device-id> --flavor dev -t lib/main_dev.dart
```

Those streams are diagnostic, not completion evidence.

## Failure promotion

If the same runtime failure or setup gap appears twice, promote it into a
registered regression/integration oracle, a stable metric assertion, a CLI
preflight, or this operating guide. Do not rely on agent memory.

## Related docs

- `docs/engineering/behavioral_oracles.md`
- `docs/engineering/task_authority.md`
- `docs/engineering/agent_pr_loop.md`
- `docs/engineering/mobilekit_cli_reference.md`
- `docs/engineering/maestro_flows.md`
- `maestro/README.md`

## Local acceptance gate

```bash
dart run mobile_core_kit_cli:mobilekit handoff check --task <task-id>
```

This read-only command returns nonzero while any selected oracle obligation is
outstanding. It first requires successful static verification for the current
task fingerprint. Full/CI verification supplies results for the pinned OpenAPI
contract and registered tests within the canonical test suites. Integration
oracles require passing runtime manifests and matching target identities;
procedure, manual-review, and metric assertions require explicit review receipts.

For automatic discovery, keep runtime artifacts below `_artifacts/mobile/`
(the default), including when selecting `--artifacts-dir`. Manifests elsewhere
remain diagnostic artifacts until moved with their repository-relative paths
and hashes correctly preserved. Every selected integration target must have
passing evidence. The latest timestamped result per oracle wins; a newer failed
run invalidates an earlier pass for the same candidate. A narrowed `--target` run does not satisfy other targets.
Durable summary size/hash checks reject missing or modified artifacts; transient
logs are deliberately not required for durable acceptance.

For a manual/procedure/metric oracle, a human reviews the selected procedure and
records `.tmp/mobilekit/tasks/<task-id>/manual-evidence.json` in the task control
root. Use this shape, replacing placeholders with real reviewed values:

```json
{
  "schemaVersion": 1,
  "task": {
    "id": "<task-id>",
    "authorityHash": "<authority-hash>",
    "baseRevision": "<base-revision>",
    "fingerprint": "<final-task-fingerprint>"
  },
  "reviews": [{
    "oracleId": "ui.human-review",
    "target": "docs/engineering/mobile_runtime_harness.md",
    "outcome": "passed",
    "reviewer": "human:reviewer-id",
    "reviewedAt": "2026-09-06T00:00:00Z",
    "artifacts": [{
      "path": "_artifacts/mobile/review/summary.md",
      "sha256": "<sha256-of-sanitized-summary>",
      "sizeBytes": 123,
      "durability": "durable-summary"
    }]
  }]
}
```

The summary identifies the acceptance scenario, observation, and result without
credentials, private logs, or user data. Do not write a human review receipt
unless that review happened. Reviewer markers identify an attestation; they do
not authenticate a person. Repository review must establish its independence.

`verified` task state describes the static lane only. A successful local
acceptance check still requires independent hosted `CI Required` and the
risk-appropriate human review before merge. Publication preflight and draft
bodies disclose outstanding evidence; a draft can remain incomplete.
