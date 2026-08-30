# OpenAPI Contract Verifier Harness — System Flowchart

Source of truth:
- `packages/mobile_core_kit_cli/lib/src/contracts/openapi_contract_workflow.dart`
- `packages/mobile_core_kit_cli/lib/src/verification/verification_profile.dart` (Step `verify.contracts`)
- `docs/contracts/openapi/README.md`
- `docs/engineering/behavioral_oracles.md`
- `harness/oracles.yaml`

---

## 1. Full Architecture & Execution Flow

```mermaid
flowchart TB
    subgraph External["1. External Backend Repository (Out of Scope)"]
        direction TB
        BECode["Backend Code / DTOs"] -->|"Code-first generation & internal backend CI"| BESpec["Committed Backend OpenAPI Spec<br/>(Git commit hash: 40-hex SHA)"]
    end

    subgraph ReviewGate["2. Human-in-the-Loop Contract Decision"]
        direction TB
        HumanDecision["Cross-Repository Human Review<br/>- Review backend contract changes<br/>- Explicit decision to adopt spec in mobile<br/>(--accept flag is strictly mandatory)"]
    end

    subgraph SyncWorkflow["3. Contract Sync Workflow (mobilekit contract openapi sync)"]
        direction TB
        SyncCmd["mobilekit contract openapi sync<br/>--source <path-to-spec><br/>--source-revision <40-hex-git-hash><br/>--accept"]
        
        ValidateSource{"Pre-validate Source Spec:<br/>1. File exists & non-empty?<br/>2. Valid UTF-8 YAML?<br/>3. openapi: 3.x, info, paths present?"}
        
        SyncInvalid["FAIL (exit 1)<br/>contract.openapi-source-invalid"]
        
        CheckCurrent{"Is snapshot & lock already<br/>identical to this source & revision?"}
        
        SyncNoop["Already Current (exit 0)<br/>No disk writes needed"]
        
        AtomicWrite["Atomic Pair-Write (via .tmp files):<br/>1. docs/contracts/openapi/backend.openapi.yaml<br/>2. docs/contracts/openapi/backend.openapi.lock.json<br/>(schemaVersion=1, artifact, sha256, sourceRevision)"]
        
        SyncCmd --> ValidateSource
        ValidateSource -->|"invalid"| SyncInvalid
        ValidateSource -->|"valid"| CheckCurrent
        CheckCurrent -->|"identical"| SyncNoop
        CheckCurrent -->|"new / changed"| AtomicWrite
    end

    subgraph Artifacts["4. Checked-in Mobile Contract Artifacts"]
        direction TB
        SnapFile["docs/contracts/openapi/backend.openapi.yaml<br/>(Committed reviewable OpenAPI 3 snapshot)"]
        LockFile["docs/contracts/openapi/backend.openapi.lock.json<br/>(Schema v1, sha256 digest, 40-hex sourceRevision)"]
        AtomicWrite --> SnapFile
        AtomicWrite --> LockFile
    end

    subgraph VerifyWorkflow["5. Contract Verify Workflow (mobilekit contract openapi verify)"]
        direction TB
        VerifyTrigger["Verify Invoked by:<br/>- Direct CLI: mobilekit contract openapi verify<br/>- Profile step: verify.contracts in verify --profile full / ci"]
        
        StepLock{"1. Read & Validate Lockfile<br/>(_readLock)"}
        FailLock["FAIL (exit 1)<br/>contract.openapi-lock-invalid<br/>(missing, unparseable, invalid schema)"]
        
        StepSnap{"2. Read Snapshot File<br/>(backend.openapi.yaml)"}
        FailIO["FAIL (exit 1)<br/>contract.openapi-io<br/>(snapshot missing or unreadable)"]
        
        StepOpenApi{"3. Validate OpenAPI 3 Structure<br/>(_validateOpenApi)"}
        FailSource["FAIL (exit 1)<br/>contract.openapi-source-invalid<br/>(invalid YAML, not 3.x, missing info/paths)"]
        
        StepDrift{"4. Check Cryptographic Digest Match<br/>sha256(snapshot bytes) == lock.sha256"}
        FailDrift["FAIL (exit 1)<br/>contract.openapi-drift<br/>(snapshot was mutated without lock update)"]
        
        VerifyPass["PASS (exit 0)<br/>Prints SHA-256 digest + 12-char sourceRevision prefix"]
        
        VerifyTrigger --> StepLock
        LockFile -.-> StepLock
        StepLock -->|"lock invalid"| FailLock
        StepLock -->|"lock OK"| StepSnap
        
        SnapFile -.-> StepSnap
        StepSnap -->|"read error"| FailIO
        StepSnap -->|"read OK"| StepOpenApi
        
        StepOpenApi -->|"invalid YAML / schema"| FailSource
        StepOpenApi -->|"valid OpenAPI 3"| StepDrift
        
        StepDrift -->|"mismatch"| FailDrift
        StepDrift -->|"match"| VerifyPass
    end

    subgraph Downstream["6. Downstream Integration & Consumers"]
        direction TB
        CIProfile["Verification Profiles<br/>verify --profile full / ci<br/>(Step verify.contracts passes)"]
        
        Oracle["Behavioral Oracle Registry<br/>contract.openapi.snapshot in harness/oracles.yaml<br/>(Satisfies api impact area for V2 plans)"]
        
        AgentUse["AI Agents & Engineers<br/>Read snapshot directly for endpoint paths,<br/>DTO schemas, query params, and auth headers<br/>(Zero OpenAPI codegen: no spec-derived client/DTO stubs)"]
        
        VerifyPass --> CIProfile
        VerifyPass --> Oracle
        VerifyPass --> AgentUse
    end

    BESpec -->|"source spec input"| SyncCmd
    HumanDecision -->|"grants --accept"| SyncCmd
```

---

## 2. Compact / Overview Flowchart

```mermaid
flowchart LR
    BE["External Backend Spec<br/>(Committed with 40-hex Git SHA)"] -->|"Human review: --accept<br/>mobilekit contract openapi sync"| Artifacts["Checked-in Artifacts:<br/>1. backend.openapi.yaml<br/>2. backend.openapi.lock.json"]

    Artifacts --> Verify{"mobilekit contract openapi verify<br/>(runs in verify.contracts step)"}

    Verify -->|"lock malformed"| F1["FAIL: contract.openapi-lock-invalid"]
    Verify -->|"source invalid YAML/3.x"| F2["FAIL: contract.openapi-source-invalid"]
    Verify -->|"digest != lock.sha256"| F3["FAIL: contract.openapi-drift"]

    Verify -->|"all checks pass"| Pass["PASS (exit 0)"]

    Pass --> Profiles["verify --profile full & ci"]
    Pass --> Oracle["Oracle: contract.openapi.snapshot<br/>covers api impact area"]
    Pass --> Consumers["Agents read snapshot directly<br/>(Zero OpenAPI codegen)"]
```

---

## 3. Failure Taxonomy & Invariants

| Failure Code | Trigger Condition | Remediation |
| :--- | :--- | :--- |
| `contract.openapi-lock-invalid` | `backend.openapi.lock.json` is missing, unparseable JSON, `schemaVersion != 1`, missing `artifact` target, `sha256` not 64-hex string, or `sourceRevision` not 40-hex string. | Re-sync from the accepted backend commit using `mobilekit contract openapi sync`. |
| `contract.openapi-source-invalid` | `backend.openapi.yaml` is not valid UTF-8 YAML, `openapi` version doesn't start with `'3.'`, or is missing top-level `info` or `paths` mappings. | Fix the YAML structure or obtain a valid OpenAPI 3 spec from backend. |
| `contract.openapi-drift` | SHA-256 hash of `backend.openapi.yaml` does not match the `sha256` recorded in `backend.openapi.lock.json`. | Snapshot was modified without human-reviewed sync. Re-sync with `--accept` or revert unauthorized modifications. |
| `contract.openapi-io` | File system read error when attempting to read the snapshot or lockfile. | Check directory permissions or restore missing files. |

### Key Architectural Invariants

1. **Mobile Repository Ownership**: The mobile repo owns its reviewable snapshot (`docs/contracts/openapi/backend.openapi.yaml`) and lockfile (`backend.openapi.lock.json`). It does not depend on an active backend server or local absolute paths.
2. **No Developer Path Leakage**: The lockfile records only the relative artifact path, SHA-256 digest, and 40-hex Git commit hash from the backend repo. Developer checkout paths are never committed.
3. **Atomic Operations**: All writes in `sync` use temporary files (`.tmp`) and atomic renames to prevent partial or corrupted file states on failure or cancellation.
4. **Direct Consumption (Zero OpenAPI Codegen)**: No client SDK or DTO generator is run against the OpenAPI specification. AI coding agents and engineers read the snapshot directly as the contract source of truth. (Internal Freezed / JSON serialization via `build_runner` remains standard for app models, but is decoupled from any OpenAPI generator tooling).
