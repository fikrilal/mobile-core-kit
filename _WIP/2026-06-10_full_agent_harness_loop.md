# Full Agent Harness Loop

Status: WIP

This diagram describes the current local, evidence-driven development loop in
`mobile-core-kit`. It connects human task intake, agent execution planning,
implementation, mechanical verification, compiled-app runtime evidence,
failure diagnosis, review, and harness improvement.

## End-To-End Loop

```mermaid
flowchart TD
    H[Human provides task and acceptance criteria]
    I[Agent inspects repository contracts and relevant code]
    R{Classify risk and scope}
    P[Create or update execution plan<br/>docs/exec-plans/active]
    C[Implement focused code changes]
    T[Add or update automated tests]
    V[Run mechanical verification<br/>dart run tool/verify.dart --env dev]
    VS{Mechanical checks pass?}
    E{Runtime evidence required?}
    B[Prepare runtime baseline<br/>backend + emulator + flavor config]
    M[Run MobTrace journey<br/>./mobtrace verify FLOW --device ID --flavor dev]
    MS{Runtime journey passes?}
    A[Collect evidence<br/>JUnit + logs + screenshots + hierarchy + summaries]
    D[MobTrace deterministic diagnosis<br/>failure class + domain + selector + suspicious files]
    F[Agent inspects evidence and fixes code, test, fixture, or infrastructure]
    S[Agent self-review<br/>acceptance criteria + architecture + diff scope]
    HR{Human review required or requested?}
    HC[Human reviews behavior and code]
    K[Create scope-separated conventional commits]
    DONE[Task complete with reproducible evidence]
    REPEAT{Same failure class seen 2+ times?}
    U[Promote learning into harness<br/>lint, verify script, signature, fixture, template, or docs]

    H --> I --> R
    R -->|Non-trivial| P --> C
    R -->|Trivial| C
    C --> T --> V --> VS
    VS -->|No| F --> C
    VS -->|Yes| E
    E -->|No, low risk| S
    E -->|Yes, medium/high risk| B --> M --> MS
    MS -->|Yes| A --> S
    MS -->|No| A --> D --> REPEAT
    REPEAT -->|No| F
    REPEAT -->|Yes| U --> F
    S --> HR
    HR -->|Yes| HC
    HC -->|Changes requested| C
    HC -->|Approved| K
    HR -->|No| K
    K --> DONE
```

## Mechanical Verification Gate

`dart run tool/verify.dart --env dev` currently orchestrates:

```mermaid
flowchart LR
    V0[verify.dart]
    V1[Dependency resolution]
    V2[Environment schema and generated config]
    V3[Localization generation and checks]
    V4[Project-map drift]
    V5[Flutter analyze]
    V6[Custom lints]
    V7[Core and small-helper duplication checks]
    V8[Modal and hardcoded-color guardrails]
    V9[Flutter tests]
    V10[Formatting check]

    V0 --> V1 --> V2 --> V3 --> V4 --> V5 --> V6 --> V7 --> V8 --> V9 --> V10
```

The gate stops on failure. The agent must fix the failure and rerun the
relevant checks before claiming completion.

## Runtime Evidence And Diagnosis

```mermaid
flowchart LR
    CMD[MobTrace CLI]
    TARGET[Named journey or explicit Maestro flow]
    FIXTURE[Run-scoped fixture setup]
    BUILD[Build and install compiled APK]
    RUN[Maestro drives emulator/device]
    CLEAN[Cleanup and fixture verification]
    ART[_artifacts/mobile/RUN]
    REPORT[Human report.md]
    JSON[Machine failure_report.json]
    STDOUT[Compact stdout diagnosis]

    CMD --> TARGET --> FIXTURE --> BUILD --> RUN --> CLEAN --> ART
    ART --> REPORT
    ART --> JSON
    JSON --> STDOUT
```

MobTrace does not replace Maestro or Flutter tests. It coordinates the
compiled-app journey and adds diff-aware failure forensics for the agent:

- stable run status and exit code
- failure class and failure domain
- failed selector or command
- changed-file and diff-hunk correlation
- flow ownership metadata
- known failure signatures
- suggested next action
- retained logs, screenshots, hierarchy, JUnit, Markdown, and JSON

## Current Entry Points

| Purpose | Command or path |
| --- | --- |
| Agent operating contract | `AGENTS.md` |
| Non-trivial task plan | `docs/exec-plans/active/` |
| Full mechanical gate | `dart run tool/verify.dart --env dev` |
| Flutter/analysis fixes | `dart run tool/fix.dart --apply` |
| Unified runtime lanes | `tool/agent/mobile_evidence_check.sh --lane flutter\|maestro\|all ...` |
| Named mobile journey | `./mobtrace verify <flow> --device <id> --flavor dev` |
| Compact machine result | `./mobtrace report latest --summary` |
| Full report on stdout | `./mobtrace show latest` |
| Runtime artifacts | `_artifacts/mobile/<run>/` |
| Delivery policy | `docs/engineering/agent_pr_loop.md` |
| Runtime policy | `docs/engineering/mobile_runtime_harness.md` |
| Maestro flow policy | `docs/engineering/maestro_testing.md` |

## Definition Of Done

A task is complete when:

1. Acceptance criteria are implemented.
2. Relevant automated tests exist and pass.
3. Mechanical verification passes.
4. Required runtime journey passes on the documented baseline.
5. Runtime artifacts are retained and readable by humans and agents.
6. The agent self-reviews architecture, scope, and failure paths.
7. Human review expectations for the risk class are satisfied.
8. Changes are committed in coherent, dependency-ordered scopes when requested.

## Intentional Boundaries

The harness proves reproducible technical evidence. It does not replace:

- human product judgment
- UX quality review
- security review for high-risk changes
- production observability
- broad device and OS compatibility testing

Those remain explicit review or release concerns rather than hidden assumptions
inside the local agent loop.
