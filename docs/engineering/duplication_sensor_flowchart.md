# Duplication Sensor Harness — Corrected Flowchart

Source of truth:
- `packages/mobile_core_kit_cli/lib/src/duplication/duplication_runner.dart`
- `packages/mobile_core_kit_cli/lib/src/duplication/duplication_report_filter.dart`
- `.jscpd.json`, `.jscpd.small_helpers.json`, `.jscpd.presentation.json`
- `duplication/*_allowlist.json`
- `docs/engineering/mobilekit_cli_reference.md` (`duplication check`)
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

    Exit0["EXIT 0 — ALWAYS (review signal)<br/>message: add to allowlist (with review reason)<br/>or refactor.<br/>fatalFound flag exists but is NEVER set by the CLI;<br/>only unit tests exercise exit 1"]

    FailPaths["Actual non-zero exits:<br/>jscpd itself fails -> its exit code passes through<br/>report missing / invalid JSON -> exit 2"]

    R1 --> Exit0
    R2 --> Exit0
    A1 --> Exit0
    A2 --> Exit0
    Cmd -.-> FailPaths

    VerifyWiring["Runs inside verify --profile full / ci as steps:<br/>verify.duplication.core + verify.duplication.small-helpers<br/>(same review-signal behavior; skip flags emit a warning)"]

    Policy["Enforcement is POLICY-level, not mechanical:<br/>AGENTS.md requires these checks for non-trivial changes;<br/>agents are expected to refactor/reuse or allowlist<br/>with a written review reason"]

    Exit0 --- VerifyWiring
    Exit0 --- Policy
```

## Compact version

```mermaid
flowchart LR
    Cmd["mobilekit duplication check<br/>(default: core + small-helpers)"] --> Jscpd["jscpd token scan per profile<br/>core: minTokens 60 · helpers: minTokens 20<br/>(generated/l10n/presentation excluded)"]

    Jscpd --> Report[".tmp/jscpd-*/jscpd-report.json"]
    Report --> Filter{"DuplicationReportFilter<br/>drop same-file clones ·<br/>match canonical file pair against<br/>PROFILE-SPECIFIC duplication/*_allowlist.json"}

    Filter -->|"allowlisted"| Reviewed["Reviewed acceptable group<br/>(reported, not actionable)"]
    Filter -->|"unregistered"| Actionable["Actionable groups reported:<br/>file pair + occurrences/maxLines/maxTokens<br/>(no line ranges)"]

    Reviewed --> Zero["EXIT 0"]
    Actionable --> Zero

    Zero --- Note["Review signal only —<br/>fatalFound is never set by CLI;<br/>exit 1 requires programmatic use.<br/>exit 2 = broken/missing report"]
```

## Corrections vs. the original flowchart

1. **"FAIL (exit 1) on new/wild duplication" removed** — factually wrong as wired. `DuplicationReportFilter.run()` returns `fatalFound ? 1 : 0`, and no CLI path sets `fatalFound`. Actionable duplication exits **0** with a remediation hint ("add to allowlist with a review reason or refactor"). The test suite names this explicitly: *"lists actionable groups but returns 0 by default (review signal)"*. Real failures: jscpd's own exit code, or exit 2 for missing/invalid reports.
2. **Single shared allowlist node split into per-profile files**: core → `duplication/duplication_allowlist.json`, small-helpers → `duplication/small_helper_duplication_allowlist.json`, presentation → `duplication/presentation_duplication_allowlist.json`.
3. **"Emits Cloned Line Ranges" corrected** — output prints grouped file-pair statistics (`occurrences`, `maxLines`, `maxTokens`) only; line data stays inside the raw jscpd JSON report.
4. **Profile descriptions made literal** — actual scan roots, thresholds (`60/20` tokens), and ignore lists replace impressionistic labels ("mappers/models", "date/currency/string utils").
5. **Added omitted pieces**: third `presentation` profile (explicit-opt-in only), same-file clone filtering, order-insensitive canonical pair matching, wiring into `verify --profile full/ci`, and the policy-level (AGENTS.md) nature of the actual enforcement.
