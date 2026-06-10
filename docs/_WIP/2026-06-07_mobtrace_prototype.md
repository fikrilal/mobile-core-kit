# MobTrace Prototype: Mobile Failure Forensics

Date: 2026-06-07
Status: proposal
Owner: unassigned

## Thesis

MobTrace should start as a local repo tool that explains failed mobile evidence
runs for AI agents.

It should not run mobile automation itself. The existing harness already owns
running Flutter, Maestro, device setup, logs, JUnit, screenshots, and fixture
cleanup. MobTrace should read those artifacts plus the current Git diff and
answer:

> What failed, what was actually on screen, which changed files are most
> suspicious, and what should the next agent inspect?

## First Form

Start inside this repo with an agent-facing command:

```bash
./mobtrace report latest
./mobtrace report _artifacts/mobile/<run>
./mobtrace verify login-logout --device <id>
./mobtrace verify --flow .maestro/flows/auth/login_logout.yaml --device <id>
```

Generated outputs:

```text
_artifacts/mobile/<run>/failure_report.md
_artifacts/mobile/<run>/failure_report.json
```

Do not create a separate repository until this internal prototype proves it
saves time on real failed runs.

Internal layering:

- `./mobtrace` is the stable entrypoint agents should discover and run.
- `tool/agent/mobtrace.sh` owns command routing.
- `tool/agent/mobile_failure_report.sh` owns artifact forensics.
- Existing evidence scripts still own device setup, app build, Maestro
  execution, fixture provisioning, and cleanup.

## Inputs

The prototype reads only local artifacts:

- Maestro JUnit: `maestro/junit.xml`
- Maestro command/debug JSON under `maestro/artifacts/`
- final failure screenshot path
- `maestro/device.log`
- `maestro/maestro.log`
- `metadata.txt`
- `status.env`
- current `git diff --name-only`
- current `git diff`

## MVP Failure Classes

Classify one primary failure class:

- `selector_mismatch`
- `input_not_applied`
- `backend_http_error`
- `fixture_cleanup_failed`
- `device_not_ready`
- `app_did_not_navigate`
- `unknown`

The first version should prefer being precise over being broad.

## Useful Report Shape

```md
# Mobile Failure Report

Flow: Login and logout with run-scoped identity
Status: FAILED
Failure class: selector_mismatch

## Failure

Expected selector:
`Log out`

Maestro failure:
`No visible element found: "Log out"`

## Actual Screen Evidence

Final hierarchy contains:
`Log out\nLog out`

Screenshot:
`maestro/artifacts/screenshot-...png`

## Most Suspicious Changed Files

1. `.maestro/flows/auth/login_logout.yaml`
   - Flow selector uses an exact text regex.
   - Actual accessibility text includes a newline and duplicate label.

## Suggested Agent Action

Use a full-string regex that matches the merged semantics label:

```yaml
text: "(?s)Log out.*"
```
```

## Real Failures It Should Explain

The prototype should initially target failures already observed while building
the auth harness:

1. Tapping the `Email` label instead of the editable text field.
2. Matching `Profile` when the hierarchy exposes `Profile\nTab 2 of 2`.
3. Matching `Log out` when the hierarchy exposes `Log out\nLog out`.
4. Treating a backend cleanup `400` as opaque instead of surfacing:
   `Body cannot be empty when content-type is set to application/json`.
5. Reporting device-not-ready before fixture provisioning.

## Ranking Heuristics

Rank changed files with simple deterministic signals:

- Maestro flow changed and failure is selector/input related.
- `tool/agent/*` changed and failure is setup, cleanup, redaction, or device
  readiness related.
- `lib/features/auth/**` changed and failure happens during login/session.
- `lib/features/account/**` changed and failure happens on profile/account UI.
- logs contain HTTP status/error codes related to a changed data/repository
  area.

Avoid AI-generated guesses in the first version. The report can include
`unknown` when evidence is insufficient.

## Success Criteria

Continue only if the report is clearly more useful than raw Maestro output plus
manual `git diff`.

The prototype succeeds when it can repeatedly save 10-20 minutes on failed
local mobile runs by identifying:

- the failed command,
- the actual final screen/hierarchy state,
- the likely failure class,
- 1-3 suspicious changed files,
- one concrete next debugging action.

## Kill Criteria

Stop if it becomes any of:

- a thin `maestro test` wrapper,
- a pretty artifact index with no diagnosis,
- a generic mobile automation CLI,
- a speculative AI test generator,
- a tool that ranks files without explaining the evidence.

## Extraction Criteria

Consider a separate open-source `mobtrace` repository only after the internal
tool explains at least 3-5 real failed runs with useful next actions.

The external story should be:

> MobTrace is a local, diff-aware mobile failure forensics layer for AI coding
> agents. It sits above existing runners and turns failed mobile evidence into
> actionable debugging reports.
