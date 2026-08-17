# Controlled Verification And Repair Loop

`mobilekit task verify` is the bounded outer loop for an authorized task. It
does not implement code and does not launch an agent. Codex, Claude Code, or
another conversational coding agent remains the implementer; the repository
selects evidence, records outcomes, and stops unsafe repetition.

## Verify

```bash
dart run mobile_core_kit_cli:mobilekit task verify \
  --task <task-id> --env dev
```

The controller re-runs task preflight, computes effective risk, and selects one
canonical repository profile:

| Effective risk | Selected lane |
| --- | --- |
| `low` | `fast` |
| `medium` | `full` |
| `high` | `full` |

Runtime and CI evidence stay independent and explicit. The selected profile is
executed by the existing `VerifyWorkflow`; task verification does not maintain
a second list of commands. Execution is fail-fast and bounded by the timeout in
the authority plan. A timed-out subprocess is terminated and the task enters
`escalated` state.

Every attempt records its profile, candidate fingerprint, duration, and stable
failure boundary. Representative boundaries include `format.dart`,
`analysis.repository`, `codegen.drift`, `test.mobilekit_cli`,
`test.custom_lints`, `test.application`, `duplication.core`, and
`infrastructure.unavailable`. Categories and remediations are structured data,
not inferred by parsing console prose.

## Repair

On failure, use ordinary agent tools to make a scoped repair. Then record the
candidate result before verification runs again:

```bash
dart run mobile_core_kit_cli:mobilekit task repair --task <task-id>
```

The command does not edit code. It recomputes the task fingerprint:

- a changed candidate returns the task to `authorized`, allowing another
  verification attempt;
- an unchanged candidate consumes a repair opportunity and remains failed;
- exhaustion enters terminal `escalated` state;
- timeout, scope escape, changed authority, ambiguous interrupted state, or
  unavailable required infrastructure escalates immediately.

This makes retries explicit and finite. Request fresh human authority rather
than deleting state or weakening a gate after escalation.

## State And Diagnostics

Versioned state and the local episode live under ignored
`.tmp/mobilekit/tasks/<task-id>/`. Writes are atomic. State preserves lifecycle,
attempt and repair counters, selected lanes, transitions, current failure, and
escalation reason. The episode keeps at most 100 sanitized structured events.

Persisted diagnostics are capped, remove bearer credentials, token/secret/
password/API-key values, and email-shaped PII, and never copy environment
variables or raw agent transcripts. Unsupported or malformed state and episode
schemas fail closed.

Use `mobilekit task status --task <task-id>` after interruption or context
compaction. A state left in `verifying` is ambiguous and escalates on the next
controlled verification rather than assuming that the prior command passed.
