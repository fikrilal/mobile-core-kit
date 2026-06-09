# MobTrace Improvement Roadmap

Date: 2026-06-08
Status: WIP roadmap
Owner: unassigned

## Goal

Make MobTrace useful as an agent-loop feedback tool.

The target experience is:

```bash
./mobtrace verify login-logout --device emulator-5554
```

The agent should immediately see:

- whether the flow passed or failed,
- whether the failure is infrastructure, harness, backend, or app related,
- the failed command/selector when available,
- the most suspicious changed files,
- the next concrete debugging action,
- links to the full markdown and JSON reports.

MobTrace should stay above existing runners. It should not become a mobile
automation engine.

## Current Baseline

Implemented commands:

```bash
./mobtrace doctor
./mobtrace report latest
./mobtrace report _artifacts/mobile/<run>
./mobtrace verify login-logout --device <id>
./mobtrace verify --flow <path> --device <id>
```

Current outputs:

- `_artifacts/mobile/<run>/failure_report.md`
- `_artifacts/mobile/<run>/failure_report.json`

Current analysis inputs:

- Maestro JUnit
- Maestro command JSON
- Maestro/device/runner logs
- screenshots
- current changed and untracked git files

## Phase 1: Inline Agent Diagnosis

Status: implemented on 2026-06-08

Problem:

`./mobtrace verify ...` currently prints report paths, but agents should not
need to open the markdown for the first diagnosis.

Implement:

- after report generation, print a compact diagnosis to stdout,
- include flow, status, failure class, failed selector, top suspicious files,
  report path, JSON path, and suggested action,
- preserve the underlying runner exit code.

Example:

```text
FAILED login-logout
Class: selector_mismatch
Failed selector: auth_sign_in_pending_deep_link

Most suspicious:
1. .maestro/flows/auth/login_logout.yaml
2. lib/features/auth/presentation/login_page.dart

Next action:
Compare the expected selector with the final hierarchy text.

Report: _artifacts/mobile/.../failure_report.md
JSON: _artifacts/mobile/.../failure_report.json
```

Exit criteria:

- [x] `./mobtrace report latest` prints the compact diagnosis.
- [x] `./mobtrace verify ...` prints the compact diagnosis after the run.
- [x] command exit status still reflects the evidence runner result.

## Phase 2: Machine-Friendly Summary

Status: implemented on 2026-06-09

Problem:

Agents should be able to consume MobTrace output without parsing markdown.

Implement:

- add `./mobtrace report latest --summary`,
- add `./mobtrace report <run> --summary`,
- print compact JSON to stdout,
- keep the full `failure_report.json` artifact.

Example:

```json
{
  "status": "ERROR",
  "runResult": "failed",
  "failureClass": "selector_mismatch",
  "failedSelector": "auth_sign_in_pending_deep_link",
  "failureDomain": "test_harness",
  "report": "_artifacts/mobile/.../failure_report.md",
  "json": "_artifacts/mobile/.../failure_report.json",
  "suggestedAction": "Compare the expected selector with the final hierarchy text."
}
```

Exit criteria:

- [x] summary JSON is valid and stable enough for agents to parse.
- [x] summary mode does not print prose.
- [x] normal report mode remains human-readable.

## Phase 3: Failure Domain Classification

Status: implemented on 2026-06-09

Problem:

Agents need to know whether to edit app code, test code, fixture code, backend
setup, or device setup.

Implement:

- add `failureDomain` to `failure_report.json`,
- print it in markdown and inline diagnosis,
- classify into:
  - `infrastructure`
  - `test_harness`
  - `backend`
  - `app`
  - `unknown`

Initial mapping:

- `device_not_ready` -> `infrastructure`
- `fixture_cleanup_failed` -> `backend` or `test_harness`, based on log signal
- `backend_http_error` -> `backend`
- `selector_mismatch` -> `test_harness`
- `input_not_applied` -> `test_harness`
- `app_did_not_navigate` -> `app`
- `none` -> `none`
- `unknown` -> `unknown`

Exit criteria:

- [x] app failures are distinguishable from infrastructure failures.
- [x] selector/test flow failures do not push agents toward app code by default.
- [x] pass reports use `failureDomain: none`.

## Phase 4: Diff Hunk Inspection

Status: implemented on 2026-06-09

Problem:

Current suspicious-file ranking uses file paths only. This is useful but too
coarse.

Implement deterministic diff inspection:

- read `git diff --no-ext-diff --unified=80`,
- detect changed Maestro selectors,
- detect changed route names and route constants,
- detect changed semantics/test IDs,
- detect changed auth/session/API payload mapping,
- detect changed fixture or cleanup behavior.

Do not add AI summarization in this phase.

Exit criteria:

- [x] changed selector lines rank Maestro flow files higher for selector failures.
- [x] changed API payload/endpoint lines rank data/repository files higher for
  backend HTTP failures.
- [x] changed navigation/session lines rank app code higher for navigation failures.

## Phase 5: Flow Metadata Correlation

Status: implemented on 2026-06-09

Problem:

MobTrace should correlate flows to code ownership without guessing from file
names only.

Implement a lightweight metadata convention in Maestro flows:

```yaml
# mobtrace:
#   area: auth
#   owns:
#     - lib/features/auth/
#     - lib/core/runtime/session/
#     - lib/navigation/
```

Parser requirements:

- comments only, so Maestro remains unaffected,
- optional metadata,
- no failure if metadata is missing,
- use metadata to bias suspicious-file ranking.

Exit criteria:

- [x] login/logout flow can rank auth/session/navigation files higher when changed.
- [x] metadata absence keeps current deterministic fallback behavior.

## Phase 6: Known Failure Signatures

Status: implemented on 2026-06-09

Problem:

Useful debugging patterns should be captured in the harness instead of agent
memory.

Implement:

- `tool/agent/mobtrace_signatures.json`,
- deterministic matching against failure message, failed command, hierarchy,
  logs, and changed files,
- signature result included in markdown and JSON.

Example signatures:

- `assertion_false_missing_id`
- `input_stayed_on_login_screen`
- `backend_unauthorized_after_login_submit`
- `fixture_cleanup_empty_json_body`
- `device_offline_before_run`

Exit criteria:

- [x] at least three real historical failures are encoded.
- [x] signatures produce concrete next actions.
- [x] unmatched failures still produce the generic classification.

## Phase 7: Report Viewing Ergonomics

Problem:

Agents often need stdout, not file paths.

Implement:

```bash
./mobtrace show latest
./mobtrace show _artifacts/mobile/<run>
```

Behavior:

- generate the report if missing or stale enough,
- print markdown to stdout,
- return non-zero only for tool/report generation failures, not for the
  historical run status.

Exit criteria:

- agents can inspect the full report without remembering artifact paths.
- `show` does not accidentally rerun mobile evidence.

## Non-Goals

Do not add yet:

- SaaS or remote storage,
- autonomous AI testing,
- replacement runner for Maestro,
- iOS support,
- generic mobile automation abstractions,
- LLM-based diagnosis.

## Promotion Criteria

Promote MobTrace from WIP to stable harness only after it explains 3-5 real
failed local mobile runs with materially useful next actions.

Consider extracting to a separate open-source repo only after:

- the CLI shape proves stable,
- the report schema proves useful to agents,
- flow metadata and signatures are not tightly coupled to this app,
- the tool is clearly better than raw Maestro output plus manual `git diff`.
