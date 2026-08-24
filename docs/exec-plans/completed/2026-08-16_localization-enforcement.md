# Localization Enforcement

**Plan version:** 2
**Task ID:** localization-enforcement
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Implement the approved localization enforcement proposal end to end in mobile-core-kit, including the lint contract, behavioral evidence, template policy, version marker, ADR, and documentation; do not modify downstream consumers.
**Allowed paths:** docs/exec-plans/active/2026-08-16_localization-enforcement.md, docs/exec-plans/completed/2026-08-16_localization-enforcement.md, packages/mobile_core_kit_lints/, packages/mobile_core_kit_cli/lib/src/template/template_manifest.dart, analysis_options.yaml, docs/engineering/localization.md, docs/engineering/localization_playbook.md, ADR/records/0015-localization-user-visible-sinks.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 4
**Task timeout:** 6h
**Oracle IDs:** harness.full

Date: 2026-08-16
Related issue/PR: N/A

## Objective

Make direct hardcoded user-visible and accessibility strings mechanically fail
at registered UI sinks, while retaining precise scope, supporting strict
consumer-specific sink configuration, and proving the real custom-lint path.

## Constraints

- Architecture constraints: localization remains presentation-owned; ARB
  generation and completeness remain separate sensors; the lint package owns
  literal-at-sink detection.
- Product/runtime constraints: do not change app runtime behavior or product
  copy; diagnostics must be deterministic and local.
- Out of scope: whole-program data-flow analysis, automatic ARB generation,
  consumer repository edits, package renames, and a template updater.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given a direct string literal at a registered Flutter or core design-system
   sink in an included source path, when custom lint runs, then it reports an
   error on that literal with the target and argument identified.
2. Given localized expressions, non-literal values, excluded/generated paths,
   or familiar argument names on unregistered APIs, when custom lint runs,
   then the localization rule does not report them.
3. Given a valid consumer-specific sink declaration, when a matching literal
   is analyzed, then the default and consumer sink registries both apply.
4. Given malformed consumer sink configuration, when configuration is parsed,
   then it is rejected deterministically rather than weakening defaults.
5. Given the actual custom-lint plugin in a disposable fixture, when violating
   and compliant sources are checked, then the command observes the expected
   failure and success outcomes.

## Acceptance Criteria

1. The approved baseline sink families are target-and-argument aware.
2. Consumer sink options are additive, closed, validated, and tested.
3. Direct literals are covered by focused positive and negative tests.
4. At least one end-to-end test exercises plugin registration, configuration,
   path handling, severity, and process outcome.
5. Core analysis options enable any required core-specific sink extensions.
6. Localization docs explain the enforced boundary and its direct-literal
   limitation.
7. An accepted ADR records the durable sink-policy decision.
8. A separate atomic follow-up is identified for the template constant and
   checked-in marker after targeted verification proves they cannot be changed
   independently under this task's path authority.
9. Canonical full verification passes.

## Implementation Checklist

- [x] Record the localization sink policy in ADR 0015.
- [x] Refactor the rule around a small target-and-argument sink registry.
- [x] Add strict additive parsing for consumer-defined sinks.
- [x] Cover built-in, core, configured, and negative cases with tests.
- [x] Add an end-to-end custom-lint fixture test.
- [x] Enable the final core policy and update localization guidance.
- [x] Identify the synchronized template-version follow-up.
- [x] Run controlled full verification and record evidence.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-16: Enforce at registered target/argument sinks -> common argument
  names alone are too noisy, while direct sink literals cover the observed
  recurring agent failure without speculative data-flow analysis.
- 2026-08-16: Keep consumer configuration additive -> project-specific UI APIs
  need coverage but must not replace baseline safety defaults.
- 2026-08-16: Keep downstream adoption separate -> generated consumers own
  their copied lint packages and product localization migrations.
- 2026-08-16: Do not advance only `currentTemplateVersion` -> its targeted test
  proved the checked-in `.mobilekit/template.yaml` marker must change in the
  same atomic follow-up, and that marker is outside this task's immutable path
  authority.

## Verification

Completed on 2026-08-16:

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task localization-enforcement --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task localization-enforcement
```

- Preflight passed with six task-owned paths, effective risk `high`, and the
  protected proposal/tool work unchanged.
- Controlled verification selected `full` and passed on attempt 1.
- Flutter analysis and custom lint reported no issues.
- The custom-lint package completed 19 tests, including the installed-plugin
  violating/compliant fixture.
- The application suite completed 553 tests.
- Environment, generated output, localization, knowledge, oracle, OpenAPI,
  formatting, CLI tests, and duplication lanes all completed under `OK
  [verify.full]`.

## Runtime Evidence

Runtime evidence is unnecessary because this task changes static analysis,
tests, and documentation only. The registered full harness oracle verifies the
executable policy; no application UI or accessibility tree changes.

## Rollback

Revert the lint registry/configuration, tests, docs, ADR, and template-version
change as one repository change. No persisted or external state requires
restoration.

## Risks And Mitigations

- Risk: common argument names cause false positives.
- Mitigation: match the owning target and exact argument position/name.
- Risk: analyzer AST shapes differ for constructors and static factories.
- Mitigation: focused fixtures cover both invocation forms and prefixed types.
- Risk: configuration silently weakens the default rule.
- Mitigation: merge validated declarations into immutable defaults and reject
  malformed declarations.
- Risk: unit-level helpers pass while the plugin is not wired correctly.
- Mitigation: exercise the installed custom-lint plugin end to end.

## Completion Notes

The rule now treats localization as a registered user-visible sink contract,
supports strict additive consumer sinks, and produces target/argument-specific
errors. Core-kit is clean under the expanded registry. No runtime evidence was
required because application behavior did not change.

## Follow-ups

- [x] Atomically advance `currentTemplateVersion` and
  `.mobilekit/template.yaml` in a separate scoped task.
- [x] No unresolved debt requires the tech debt tracker.
