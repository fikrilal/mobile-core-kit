# Duplication Sensor Harness — Corrected Flowchart

Source of truth:
- `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart`
- `packages/mobile_core_kit_cli/lib/src/duplication/duplication_report_filter.dart`
- `.jscpd.json`, `.jscpd.small_helpers.json`, `.jscpd.presentation.json`
- `duplication/*_allowlist.json`
- `docs/engineering/harness/mobilekit_cli_reference.md` (`duplication check`)
- Test evidence: `test/duplication_report_filter_test.dart`

## Full version

```mermaid
flowchart TB
    Cmd["mobilekit duplication check<br/>--profile core | small-helpers | presentation<br/>no --profile: core then small-helpers sequentially"]

    subgraph CoreLane["Profile: core (.jscpd.json)"]
        CScan["npx jscpd token scan<br/>minTokens=60 · minLines=7 · mode=mild<br/>roots: lib/features, lib/core/foundation,<br/>lib/core/runtime, lib/core/infra, lib/navigation<br/>excludes: presentation/**, design_system, l10n,<br/>*.g.dart / *.freezed.dart / *.gen.dart / generated/**"]
    end

    subgraph HelperLane["Profile: small-helpers (.jscpd.small_helpers.json)"]
        HScan["npx jscpd token scan (lower thresholds)<br/>minTokens=20 · minLines=4<br/>roots: same as core MINUS lib/core/infra"]
    end

    P3["Profile: presentation (not in default run)<br/>targeted self-review tool only<br/>scans every */presentation dir under lib/features"]

    CReport[".tmp/jscpd-phase1/jscpd-report.json"]
    HReport[".tmp/jscpd-small-helpers/jscpd-report.json"]

    Cmd --> CoreLane --> CReport
    Cmd --> HelperLane --> HReport
    Cmd -.->|"explicit --profile only"| P3

    CReport --> FCore
    HReport --> FHelper

    subgraph Filtering["Report filter semantics (per profile)"]
        direction TB
        FCore{"core filter:<br/>self-file clone? -> dropped<br/>cross-file pair canonicalized<br/>matched vs duplication/<br/>duplication_allowlist.json"}
        FHelper{"small-helpers filter:<br/>same logic vs duplication/<br/>small_helper_duplication_allowlist.json"}

        FCore -->|"pair listed in reviewedAcceptable"| R1["Reviewed acceptable group<br/>(printed with occurrences / maxLines / maxTokens)"]
        FHelper -->|"pair listed"| R2["Reviewed acceptable group"]
        FCore -->|"unregistered pair"| A1["Actionable duplicate group<br/>(file PAIR stats printed:<br/>occurrences, maxLines, maxTokens)<br/>NO cloned line ranges are emitted"]
        FHelper -->|"unregistered pair"| A2["Actionable duplicate group"]
    end

    ExitCore["EXIT 1 — core actionable groups<br/>the runner sets fatalFound for core"]
    ExitAdvisory["EXIT 0 — reviewed groups, and<br/>actionable small-helpers or presentation<br/>message: add to allowlist (with review reason)<br/>or refactor"]

    FailPaths["Other non-zero exits:<br/>jscpd itself fails -> its exit code passes through<br/>report missing / invalid JSON -> exit 2"]

    R1 --> ExitAdvisory
    R2 --> ExitAdvisory
    A1 --> ExitCore
    A2 --> ExitAdvisory
    Cmd -.-> FailPaths

    VerifyWiring["Runs inside verify --profile full and ci,<br/>which are fail-fast:<br/>verify.duplication.core exits 1 on actionable groups<br/>verify.duplication.small-helpers stays a report"]

    Policy["Core enforcement is the process exit.<br/>small-helpers and presentation stay advisory.<br/>AGENTS.md states the same exit behavior."]

    ExitCore --- VerifyWiring
    ExitAdvisory --- Policy
```

## Compact version

```mermaid
flowchart LR
    Cmd["mobilekit duplication check<br/>(default: core + small-helpers)"] --> Jscpd["jscpd token scan per profile<br/>core: minTokens 60 · helpers: minTokens 20<br/>(generated/l10n/presentation excluded)"]

    Jscpd --> Report[".tmp/jscpd-*/jscpd-report.json"]
    Report --> Filter{"DuplicationReportFilter<br/>drop same-file clones ·<br/>match canonical file pair against<br/>PROFILE-SPECIFIC duplication/*_allowlist.json"}

    Filter -->|"allowlisted"| Reviewed["Reviewed acceptable group<br/>(reported, not actionable)"]
    Filter -->|"core unregistered"| CoreFail["EXIT 1<br/>fatalFound is set for core"]
    Filter -->|"small-helpers or presentation<br/>unregistered"| Advisory["EXIT 0<br/>actionable groups stay a report"]

    Reviewed --> Advisory

    CoreFail --- Note["exit 2 = broken or missing report.<br/>jscpd's own failure passes through.<br/>verify --profile full and ci fail-fast<br/>on verify.duplication.core"]
```

## Corrections vs. the original flowchart

1. **`core` exits 1 on actionable groups.** The runner sets `fatalFound` for `core`. `small-helpers` and `presentation` still report actionable groups and exit 0. A missing or invalid report exits 2. jscpd's own failure passes through.
2. **Single shared allowlist node split into per-profile files**: core → `duplication/duplication_allowlist.json`, small-helpers → `duplication/small_helper_duplication_allowlist.json`, presentation → `duplication/presentation_duplication_allowlist.json`.
3. **"Emits Cloned Line Ranges" corrected** — output prints grouped file-pair statistics (`occurrences`, `maxLines`, `maxTokens`) only; line data stays inside the raw jscpd JSON report.
4. **Profile descriptions made literal** — actual scan roots, thresholds (`60/20` tokens), and ignore lists replace impressionistic labels ("mappers/models", "date/currency/string utils").
5. **Added omitted pieces**: third `presentation` profile (explicit-opt-in only), same-file clone filtering, order-insensitive canonical pair matching, and wiring into `verify --profile full` and `ci`. Core enforcement is the process exit inside those fail-fast profiles. `small-helpers` and `presentation` stay advisory.
