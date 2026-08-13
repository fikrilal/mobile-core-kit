# Controlled Harness Improvement

Harness improvement is a read-only learning loop over independently reviewed
operating evidence. It is not an autonomous optimizer and cannot create work,
edit policy, launch an agent, commit, push, open a PR, merge, or deploy.

## Current State

Improvement analysis is disabled. The operating-evidence ledger has zero
records, below the required five reviewed tasks, two risk classes, and one
repair or escalation. Therefore
[`harness_improvements.json`](harness_improvements.json) must remain empty.

Inspect the state with:

```bash
dart run mobile_core_kit_cli:mobilekit improve check
dart run mobile_core_kit_cli:mobilekit improve analyze
dart run mobile_core_kit_cli:mobilekit improve shadow
```

All three commands are deterministic and read-only. `check` validates both
ledgers and every hypothesis contract. `analyze` reports reviewed-task count,
risk diversity, repair/escalation and blocked rates in basis points, plus
failed boundaries recurring in at least two tasks. `shadow` returns
`disabled`, `idle`, `inconclusive`, or `evaluated`, and only an evaluated result
has a `keep` or `revert` recommendation.

## Hypothesis Contract

Once operating evidence is eligible, a hypothesis may be proposed through a
normal reviewed source edit. It must declare:

- one recurring failed boundary and at least two affected baseline task IDs;
- a target component and exact target paths;
- the `repair-or-escalation-rate` metric;
- a minimum predicted effect in basis points;
- a maximum acceptable verification-duration increase;
- a later evaluation window of at least two reviewed tasks;
- one required risk class, exact rollback paths, and a separate V2 plan;
- a stable human owner and, after approval, a different human approver;
- every immutable invariant listed below.

The required invariants are:

- `authority.no-expansion`
- `evidence.no-sensitive-data`
- `publication.no-expansion`
- `risk.no-lowering`
- `verification.no-weakening`

The schema rejects extra fields and unrestricted notes. The hypothesis ledger
has a 256 KiB limit, at most 20 sorted unique hypotheses, and at most one in
`evaluating` status.

## Approval And Isolation

Lifecycle changes are reviewed source edits:

```text
proposed -> approved -> evaluating -> kept | reverted
```

Moving beyond `proposed` requires a separately authorized V2 plan. The plan
must be high risk, declare harness impact, contain the exact target and rollback
paths, and grant exactly `edit, verify`. It cannot grant commit, push, or draft
PR authority. Publication remains a later action-specific handoff under the
normal user approval contract.

Owner and approver IDs are categorical `human:<id>` markers. They identify the
review boundary; they are not authentication. Normal review must confirm the
people and hosted evidence are real.

## Shadow Evaluation

Shadow evaluation:

1. reads the approved timestamp and baseline task IDs;
2. excludes every baseline task;
3. selects only later independently reviewed records in the required risk
   class, sorted by review date then task ID;
4. takes exactly the declared evaluation window;
5. reports `inconclusive` until the window is complete;
6. compares baseline and observed repair/escalation rates and average lane
   duration;
7. recommends `keep` only when both minimum effect and duration ceiling pass,
   otherwise `revert`.

The command changes no enforcement. A terminal ledger entry records the exact
evaluated task IDs, measured rates, effect, duration delta, deterministic
recommendation, and explicit human decision. Validation rejects a terminal
record that contradicts recomputation. The human still owns keep/revert because
the schema cannot measure every product, security, or maintenance effect.

## Interpretation Rules

- Eligibility is not statistical significance and grants no authority.
- Absence of recurring boundaries is not proof that the harness is optimal.
- Do not cherry-pick later tasks; the declared ordered window is binding.
- Never weaken authority, risk, verification, privacy, architecture, or
  publication controls to improve a metric.
- A new target, metric, or invariant requires a new reviewed ADR/schema change,
  not an unrecognized ledger field.
