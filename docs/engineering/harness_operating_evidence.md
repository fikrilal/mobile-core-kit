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
