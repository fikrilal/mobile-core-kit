# Harness Operating Evidence

This repository keeps operating evidence as a small reviewed source artifact,
not as agent telemetry. The purpose is to learn whether the harness is useful
across real work without collecting prompts, reasoning, logs, diffs, user data,
credentials, or machine state.

## Commands

```bash
dart run mobile_core_kit_cli:mobilekit evidence verify
dart run mobile_core_kit_cli:mobilekit evidence report
dart run mobile_core_kit_cli:mobilekit evidence mutation-pilot
```

`verify` checks the strict ledger and calibration data. Repository knowledge
validation owns this policy, so it runs in canonical `fast`, `full`, and `ci`
profiles. `report` prints deterministic aggregates
and missing eligibility conditions. Neither command writes source or changes
policy. The non-default mutation pilot proves that the eligibility examples
detect three representative weakenings; it does not mutate production files.

## Calibration

`harness/evidence_calibration.json` records the reviewed Phase 1 warm-checkout
observations already documented in `harness_baseline.md`:

| Signal | Observation | Policy |
| --- | ---: | ---: |
| Non-golden line coverage | 6,277 / 9,998 (62.78%) | existing CI floor 55% |
| `fast` profile | 65.04s | advisory budget 120s |
| `full` profile | 125.29s | advisory budget 240s |

The duration budgets are advisory and are intentionally not completion gates.
One slow machine is not evidence that a budget should change. Coverage remains
an independent hosted-CI gate; the operating ledger does not replace test
quality or behavioral oracles.

## Promotion Contract

The checked-in ledger is
[`harness_operating_evidence.json`](harness_operating_evidence.json). It starts
empty because the implementation phases have local evidence but have not yet
been independently reviewed and reproduced in hosted CI.

A record may be added only when all of these conditions are true:

1. A real task has a terminal outcome and a completed V2 execution plan.
2. A human independently reviews the outcome and its evidence.
3. Hosted CI reproduces the required lanes at the exact candidate revision.
4. A separate active V2 plan explicitly authorizes editing the ledger path.
5. The plan hash, effective risk, impact categories, lanes, durations, review
   marker, CI run ID, candidate revision, and harness revision pass
   `evidence verify`.
6. Normal source review accepts the ledger change.
7. `ci.revision` is a commit in this repository and is contained by a
   remote-tracking branch. An invented hash, or a commit that exists only
   on this machine, is rejected. `reproduced: true` is still required, and
   it does not by itself make the ledger eligible. Eligibility stays at
   five reviewed tasks, two risk classes, and one repair or escalation.

Promotion is an ordinary reviewed source edit. There is intentionally no
`evidence promote` command: accepting self-asserted review and CI flags through
a command would not create an independent trust boundary.

The schema rejects extra fields and accepts at most 100 records. Records must
be unique and sorted by task ID. They contain only stable identifiers, hashes,
enums, booleans, dates, bounded integer durations, and a numeric CI run ID.
Do not add prompts, chain-of-thought or reasoning, source diffs, raw output,
free-form notes, environment values, credentials, request data, user data,
review text, or private artifact contents.

When a template copy should not inherit core-kit operating history, leave the
schema and reset `records` to an empty array as part of template initialization
review. Never rewrite a historical record to make metrics look better; correct
material errors through normal source review.

## Eligibility Boundary

Later improvement analysis remains ineligible until the ledger contains:

- at least five unique reviewed tasks;
- at least two risk classes;
- at least one repair or escalation;
- independent review and hosted-CI reproduction for every record.

Eligibility means only that a human may consider a narrow engineering
proposal. It does not authorize work, alter a gate, select a task, expand agent
permissions, or permit publication. Phase 8 owns the read-only recommendation
protocol.

## Gate Honesty

`operating_evidence_test.dart` exercises valid and empty ledgers plus malformed,
extra-field, unreviewed, unreproduced, revision-mismatch, plan-hash, duration,
risk, duplicate, and oversized failure cases. The mutation pilot separately
checks that lowering the task floor, ignoring risk diversity, or ignoring
repair evidence changes an expected decision and is therefore detected.

This is deliberately narrow. A broad mutation-testing dependency or blocking
lane should be introduced only after reviewed operating evidence shows that
the pilot finds defects worth its cost.

## Collect the first operating cohort

The next improvement step is ordinary product work through the existing task
loop. Do not create synthetic tasks, induce failures, or reconstruct missing
results from memory to satisfy eligibility.

For each real task:

1. Before implementation, use a V2 plan with explicit acceptance scenarios,
   scope, risk, and suitable oracles.
2. Use `task verify` and record scoped repairs with `task repair`. Preserve
   the sanitized episode, attempt outcomes, selected lanes, and durations.
3. Run selected runtime/manual checks and `handoff check` at the final
   candidate. For an escalation, preserve the terminal failure instead of
   claiming success or weakening the gate.
4. Obtain separately authorized publication and exact-candidate hosted CI.
   Record the full candidate revision and numeric CI run ID. A local check or
   a run for another revision cannot substitute for hosted reproduction.
5. Ask the human reviewer to verify the task outcome and evidence independently.
   Preserve the review marker and review date, not review text or private logs.
6. Under a separate authorized V2 ledger-edit plan, add only the schema fields
   described above, sorted by task ID. Run `evidence verify`, `evidence report`,
   and normal verification before source review accepts the record.

After five qualifying tasks across at least two risk classes, including a real
repair or escalation, run `improve analyze`. If the cohort is still ineligible,
continue collecting real work; do not lower the thresholds. Choose one recurring
failure for a narrow hypothesis only when the data supports it. Report the
cohort and verification durations alongside any recommendation; a lower repair
rate alone is not proof of better product outcomes.

The ledger remains empty until independent review and hosted reproduction
actually exist. Completing harness implementation itself does not manufacture
those prerequisites.
