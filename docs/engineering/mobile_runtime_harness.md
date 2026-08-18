# Mobile Runtime Harness

The runtime harness produces completion-grade device evidence for an exact
controlled task candidate. It does not replace Codex, Claude Code, or the
normal chat workflow; the current agent invokes it after static verification.

Use it when unit/static checks cannot credibly prove user-visible runtime
behavior: auth/session, startup/navigation/deep links, permissions, Firebase,
push, platform integrations, or medium/high-risk UI interactions.

## Preconditions

1. The V2 plan selects one or more registered `integration-test` oracle IDs.
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

The separate log bridge is diagnostic, not completion evidence:

```bash
dart run mobile_core_kit_cli:mobilekit runtime logs start \
  --session emulator --mode logs --device <device-id>
dart run mobile_core_kit_cli:mobilekit runtime logs tail \
  --session emulator --lines 200
dart run mobile_core_kit_cli:mobilekit runtime logs stop --session emulator
```

## Failure promotion

If the same runtime failure or setup gap appears twice, promote it into a
registered regression/integration oracle, a stable metric assertion, a CLI
preflight, or this operating guide. Do not rely on agent memory.

## Related docs

- `docs/engineering/behavioral_oracles.md`
- `docs/engineering/task_authority.md`
- `docs/engineering/agent_pr_loop.md`
- `docs/engineering/mobilekit_cli_reference.md`
