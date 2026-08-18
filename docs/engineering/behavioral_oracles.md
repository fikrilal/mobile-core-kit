# Behavioral Oracles

An oracle is an acceptance boundary whose identity and ownership are known
before an agent implements a task. It reduces circular validation: a newly
written test can be useful, but it is not automatically independent evidence
that the behavior request was understood correctly.

## Registry contract

`harness/oracles.yaml` is the checked-in registry. Each stable ID declares:

- a kind such as verification profile, pinned contract, integration test,
  golden, metric assertion, regression test, procedure, or manual review;
- one profile name or repository-relative target;
- the task impact areas it can credibly cover.

Medium/high-risk V2 plans must declare `Oracle IDs`. The selected set must
cover every `yes` impact. `mobilekit task begin`, task preflight, and the
registry verifier fail closed on unknown IDs, missing targets, or incomplete
coverage. Oracle declarations are included in the task authority hash, so a
changed acceptance boundary requires reauthorization.

Run the independent gate directly with:

```bash
dart run mobile_core_kit_cli:mobilekit oracle verify
dart run mobile_core_kit_cli:mobilekit contract openapi verify
```

Both also run in the `full` and `ci` verification profiles.

## Choosing evidence

Prefer the narrowest credible independent boundary:

1. an existing regression/unit/widget/Bloc test for deterministic behavior;
2. the pinned OpenAPI contract for endpoint, DTO, and auth-scheme shape;
3. a registered integration test for device/runtime behavior;
4. a registered golden or metric assertion when pixels or performance are the
   acceptance boundary;
5. an explicit manual-review procedure only when automation is not credible.

Do not register placeholder files, broad directories, arbitrary shell
commands, or a test solely because the implementing agent just authored it.
Registry changes are high-risk harness changes and require normal review.

## Mobile-owned OpenAPI snapshot

The mobile repository owns the reviewable snapshot at
`docs/contracts/openapi/backend.openapi.yaml`. Its lock records only the fixed
artifact path, SHA-256 digest, and accepted backend Git revision. It never
records a developer's checkout path.

After the backend team accepts and commits a contract change, explicitly sync
it from any available checkout:

```bash
dart run mobile_core_kit_cli:mobilekit contract openapi sync \
  --source <path-to-openapi.yaml> \
  --source-revision <full-backend-git-revision> \
  --accept
```

The command validates OpenAPI 3 structure before writing, updates snapshot and
canonical lock atomically per file, and is idempotent for the same bytes and
revision. `--accept` represents a human-reviewed cross-repository contract
decision; the harness does not infer compatibility or mutate backend state.

## Runtime selection

Completion-grade runtime evidence can execute only `integration-test` targets
selected by the verified task's oracle IDs. `--target` may narrow that set; it
cannot introduce an unregistered path. Device execution remains explicit and
single-flight. See `docs/engineering/mobile_runtime_harness.md`.
