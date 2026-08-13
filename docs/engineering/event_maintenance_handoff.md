# Event Intake, Maintenance, CI, And Handoff

These controls extend the repository harness used by the current conversational
agent. They do not launch agents, accept arbitrary event payloads, or replace
Codex/Claude Code with another coding platform.

## One-shot event intake

Prepare a fully reviewed V2 plan under `docs/exec-plans/queued/` with
`**Status:** queued`, including all paths, actions, risk, impact areas, and
oracles. When no unrelated V2 task is active, run:

```bash
dart run mobile_core_kit_cli:mobilekit event intake --once
```

The command accepts no payload, issue text, command text, path, risk, action,
credential, or publication input. It sorts the checked-in queue, selects one
plan, derives a stable event ID from the task ID and queued source hash,
atomically promotes the plan to `active/`, and invokes the normal `task begin`
authority boundary.

Receipts under `.tmp/mobilekit/events/` are schema-validated, bounded, atomic,
and owner-only on POSIX. A claim exists before promotion so a single
interrupted activation can be recovered. Multiple claims, an unrelated active
V2 plan, changed plan content, or mismatched task state fail closed. Repeated
one-shot delivery returns the already accepted active event and does not begin
a second task.

This is intentionally not a webhook daemon. An external scheduler may invoke
the command, but it cannot use its payload to manufacture work or authority.

## Read-only maintenance

Run the fixed registry once:

```bash
dart run mobile_core_kit_cli:mobilekit maintenance run --once
```

The registry is owned in
`packages/mobile_core_kit_cli/lib/src/maintenance/maintenance_service.dart` and
does not accept commands from arguments or events. It covers:

- knowledge and V2 plan lifecycle;
- architecture/analyzer/custom-lint policy;
- core and small-helper duplication observations;
- production dependency drift;
- codegen drift in a disposable local clone;
- CLI and custom-lint harness fixtures;
- active/queued V2 plans and stale runtime-evidence observations.

Every command has a deadline. The service snapshots Git status before and
after the run and refuses a maintenance result if tracked or untracked source
state changed. Codegen runs in an ignored disposable checkout because the
underlying verifier necessarily generates files. The bounded sanitized report
is written to `.tmp/mobilekit/maintenance/latest.json`; command logs and
absolute paths are not persisted in it.

`.github/workflows/maintenance.yml` invokes this command weekly with read-only
repository permission, immutable action SHAs, no persisted checkout
credential, a bounded timeout, and seven-day report retention. A failed report
may motivate a separately authorized V2 task; maintenance itself never edits
source.

## Independent required CI

`.github/workflows/required.yml` is the branch-protection surface:

| Stable job | Evidence |
| --- | --- |
| `CI Risk` | Clean base/head Git diff plus changed V2 plan risk/impact classification |
| `CI Full` | Canonical `mobilekit verify --profile ci` from a clean checkout |
| `CI Runtime` | Risk-selected portable golden evidence and Android debug assembly |
| `CI Governance` | Dependency review and committed-history secret scan |
| `CI Required` | One stable aggregate over every selected lane |

The risk lane reads plans from the exact head revision, or from base when a
plan was deleted. Malformed changed V2 plans fail closed. Runtime may be
skipped only when the classifier says mobile behavior evidence is unnecessary;
the aggregate accepts only a successful or intentional skip.

Required CI never reads `.tmp/mobilekit` task state as pass evidence. All
third-party actions in the repository workflows are pinned to full reviewed
commit SHAs. Required jobs have explicit permissions, timeouts, cancellation,
credential-free checkout, and short artifact retention. A hosted passing run
cannot be claimed until the branch is separately authorized for push.

## Verified handoff

Local `verified` means ready for review, not authority to publish. Before one
handoff action, render its fresh boundary:

```bash
mobilekit handoff dry-run --task <task-id> --action commit
mobilekit handoff dry-run --task <task-id> --action push
mobilekit handoff dry-run --task <task-id> --action draft-pr
```

Dry-run revalidates:

- the task is verified at its exact current fingerprint;
- the latest episode ends in `verification-passed`;
- the plan explicitly grants that one action;
- no pre-existing dirty baseline would be captured;
- exact task-owned paths and, when used, the owned worktree;
- a non-protected branch and credential-free normalized origin remote;
- no pre-staged content and the action-specific clean/dirty shape.

It makes no Git or GitHub mutation. It emits a random one-time approval that
expires after 15 minutes; only its SHA-256 hash is stored in strict owner-only
local state. Because a repository cannot authenticate whether a human or agent
typed a shell command, the agent may execute the next command only after the
user separately and explicitly authorizes that exact action:

```bash
MOBILEKIT_HANDOFF_APPROVAL=<approval> \
  mobilekit handoff commit --task <task-id> --message "type(scope): summary"

MOBILEKIT_HANDOFF_APPROVAL=<approval> \
  mobilekit handoff push --task <task-id>

MOBILEKIT_HANDOFF_APPROVAL=<approval> \
  mobilekit handoff draft-pr --task <task-id> --base main \
  --title "Establish the Mobile Agent Harness and Controlled Engineering Loops"
```

Commit stages only the exact verified paths and checks exact staged equality.
Push uses one explicit same-name ref and has no force option. PR creation is
draft-only with explicit repository/head/base/title and a sanitized generated
body. The approval environment value is removed from every child process.

Approval is persisted as `executing` before mutation. Any thrown or interrupted
mutation becomes `uncertain`, is never replayed, and requires human inspection
of Git/GitHub state. Commit, push, and draft PR require separate approvals.
Merge, marking ready, deployment, signing, migrations, release, branch
deletion, and force push do not exist in the adapter API.

For this proposal implementation, only local commits were authorized. No push
or draft PR is performed.
