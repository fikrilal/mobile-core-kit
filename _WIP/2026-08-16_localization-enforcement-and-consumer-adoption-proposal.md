# Localization Enforcement And Consumer Adoption Proposal

**Date:** 2026-08-16

**Status:** Proposed

**Scope:** `mobile-core-kit` hardcoded UI string policy, custom-lint evidence,
template contract, and adoption by existing generated consumers such as
`awwabi-mobile`

## Recommendation

Strengthen `hardcoded_ui_strings` from a widget-name spot check into a
repository-owned user-visible string sink policy.

The rule should fail on direct string literals passed to known UI and
accessibility sinks, keep localization generation and translation completeness
as separate checks, and allow each consumer to declare a small set of
project-specific sink parameters in `analysis_options.yaml`.

Ship the stronger rule with behavioral lint fixtures and a new template
version. Migrate existing consumers through separate repository-owned changes.
Do not build a general template updater or make consumers depend on a local
`mobile-core-kit` checkout as part of this proposal.

This is a harness correction: repeated agent-generated hardcoded copy should be
prevented mechanically instead of addressed through more prompt text or review
memory.

## Context And Evidence

The documented policy already says user-facing copy belongs in ARB and custom
lints enforce hardcoded UI strings:

- `docs/engineering/project_architecture.md` defines localization-first as an
  architectural principle;
- `docs/engineering/localization.md` owns the ARB and runtime localization
  model;
- `docs/engineering/localization_playbook.md` directs presentation code to
  `context.l10n`;
- `analysis_options.yaml` enables `hardcoded_ui_strings` in production UI
  scopes;
- `mobilekit lint` runs `custom_lint` after Flutter analysis.

The implementation does not yet enforce that policy broadly. The current rule
reports only direct literals in:

- the first argument of `Text(...)`;
- the first argument of `AppText.*(...)`;
- the `text:` argument of `AppButton.*(...)`.

It does not recognize other user-visible sinks, including accessibility
labels, input decoration copy, rich text, snackbars, tooltips, navigation
labels, or product-specific presentation models.

This gap is observable in `awwabi-mobile`. A clean `dart run custom_lint`
reported no findings while production sources contained examples such as:

- `MoodChartItem(label: 'Happy', ...)` under
  `lib/features/chart/presentation/widgets/`;
- `RootShellCenterActionData(semanticLabel: 'Action', ...)` under
  `lib/navigation/`.

Both paths are included by the configured rule, so this is a detector coverage
gap rather than a disabled plugin or missing verification command.

The lint package also has no behavioral tests for `hardcoded_ui_strings`.
Existing lint-package tests cover configuration helpers for architecture and
restricted imports, but they do not prove which Dart expressions generate this
diagnostic.

Localization generation does not close this gap. `flutter gen-l10n` and
`mobilekit l10n verify` prove that declared ARB messages are structurally valid
and translated; they cannot detect visible copy that never entered an ARB
file.

Finally, existing consumers may contain a copied or renamed lint package.
`awwabi-mobile`, for example, owns `packages/awwabi_mobile_lints/`, while the
current core-kit initialization contract reserves the stable
`mobile_core_kit_lints` package identity. A core-kit fix therefore cannot be
assumed to propagate into an already-created repository.

## Goals

- Make direct hardcoded user-visible copy fail deterministically in production
  presentation and navigation scopes.
- Cover accessibility text with the same policy as visible text.
- Support core Flutter/design-system sinks and narrow consumer-specific sinks
  without scanning every string literal.
- Keep diagnostics precise enough that agents can repair violations without
  guessing which argument is user-visible.
- Prove lint behavior with positive and negative fixtures.
- Preserve the existing ARB, `context.l10n`, Clean Architecture, and
  `mobilekit lint` ownership model.
- Give existing consumers an explicit, reviewable adoption path.

## Non-Goals

- Inferring whether arbitrary prose anywhere in Dart is visible to a user.
- Implementing whole-program string taint or data-flow analysis.
- Requiring localization inside domain or infrastructure layers.
- Treating backend messages, analytics identifiers, route names, asset paths,
  debug output, or protocol constants as UI copy.
- Automatically creating ARB keys or machine-translating text.
- Building a general-purpose core-kit package registry, template updater, or
  consumer synchronization service.
- Automatically editing `awwabi-mobile` as part of the core-kit change.
- Removing intentional development showcases or documentation examples.

## Policy Boundary

The rule should enforce strings at **user-visible sinks**, not by guessing from
the literal text or parameter name alone.

A sink is a known constructor or method argument whose value is presented to a
user or assistive technology. The same argument name may remain valid outside a
registered sink. For example, `label: 'login_submit'` in analytics must not be
treated like `label: 'Happy'` in a chart legend merely because both use the name
`label`.

The initial rule remains intentionally local:

- inspect non-generated Dart inside configured UI/navigation scopes;
- report non-empty direct `StringLiteral` expressions at registered sinks;
- accept localized expressions, parameters, and other non-literal values;
- preserve explicit file/path exclusions for development tools and showcases;
- emit an error, not an advisory warning.

This design catches the dominant agent failure while keeping control flow and
cost simple. Constant propagation and cross-file data flow remain future work
unless operating evidence shows agents routinely evade the direct-literal
boundary through indirection.

## Proposed Sink Model

### Repository-owned sinks

`mobile_core_kit_lints` should own the baseline sink registry for Flutter and
the core design system. The first version should cover at least:

| Target | User-visible arguments |
| --- | --- |
| `Text` | positional text argument |
| `TextSpan` | `text`, `semanticsLabel` |
| `Semantics` | `label`, `value`, `hint`, increased/decreased values and action hints |
| `Tooltip` | `message`, rich-message literal surfaces when statically visible |
| `InputDecoration` | label, hint, helper, error, prefix, suffix, and counter text |
| `NavigationDestination` / `BottomNavigationBarItem` | `label`, `tooltip` |
| `AppText.*` | positional text argument |
| `AppButton.*` | `text`, `semanticLabel` |
| core text-input wrappers | label, hint, helper, error, and semantic text parameters |
| core snackbar/notification helpers | `message` and user-visible title parameters |

The implementation should identify the target API as well as the argument. It
must not flag every invocation containing `message:`, `label:`, or `title:`.

### Consumer-specific sinks

Consumers need a narrow extension point for presentation models that the core
kit cannot know, such as `MoodChartItem(label:)`.

Extend the existing `hardcoded_ui_strings` options with a strict sink list. A
conceptual configuration is:

```yaml
- hardcoded_ui_strings:
    include:
      - lib/features/**
      - lib/navigation/**
    exclude:
      - lib/core/dev_tools/**
      - "**/*showcase*"
    sinks:
      - target: MoodChartItem
        named_arguments: [label]
      - target: RootShellCenterActionData
        named_arguments: [semanticLabel]
```

The final schema should remain closed and validated:

- reject unknown fields;
- require a Dart identifier-like target;
- allow only non-empty unique named arguments and non-negative positional
  indexes;
- reject duplicate sink definitions;
- merge consumer sinks with repository defaults rather than replacing safety
  defaults.

Configuration is for genuine project APIs, not a broad allow/deny mechanism.

### Exceptions

Direct literals at registered sinks should be localized even when the current
product ships one language. This includes accessibility labels and product
names because ARB ownership keeps copy reviewable and future-safe.

Rare technical or legally fixed text may use a line-level
`hardcoded_ui_strings` suppression. Whole-directory or production-feature
exclusions are not an acceptable migration shortcut. The proposal does not add
a global literal allowlist; repeated legitimate exceptions should first prove
that such a contract is necessary.

## Diagnostic Contract

Each violation should identify:

- the diagnostic code `hardcoded_ui_strings`;
- the literal preview;
- the recognized target and argument;
- the preferred correction: use `context.l10n.*` or pass already-localized
  copy into the component.

The diagnostic should be attached to the literal expression so IDE and CI
locations remain precise. The rule must remain deterministic and must not call
an LLM or generate source changes.

## Verification Design

The lint needs behavioral evidence, not only configuration tests.

### Focused rule fixtures

Add fixtures that prove each default sink reports a direct literal and accepts
the equivalent localized expression. Include explicit negative cases for:

- technical strings outside registered sinks;
- excluded development/showcase paths;
- generated files;
- domain and infrastructure code outside configured presentation scopes;
- arguments with familiar names on unregistered APIs;
- empty strings and non-literal values.

At least one fixture must exercise consumer-configured sinks. The two Awwabi
examples should be represented as generic regression shapes without coupling
the core package to the Awwabi product.

### End-to-end harness fixture

Add a disposable fixture project that runs the actual custom-lint plugin and
asserts both outcomes:

1. a violating source exits non-zero with `hardcoded_ui_strings`;
2. the localized form exits successfully.

This catches failures in plugin registration, path-root discovery, options
parsing, and diagnostic severity that pure helper tests cannot see.

The existing `mobilekit lint` and full verification profiles remain the public
gate. No second localization command should duplicate custom-lint ownership.

### Separate ARB evidence

Keep the existing localization generation and untranslated-message checks.
Together the sensors prove different invariants:

| Sensor | Proves |
| --- | --- |
| `hardcoded_ui_strings` | recognized UI sinks do not receive direct literals |
| `flutter gen-l10n` | ARB schema and generated APIs are valid |
| `mobilekit l10n verify` | declared messages are present in required locale files |
| localization smoke/plural tests | generated messages resolve for supported locales |

## Ownership And Adoption

### Core-kit

`packages/mobile_core_kit_lints/` owns the rule implementation and focused
fixtures. Root `analysis_options.yaml` owns enabled paths and any core-specific
sink extensions. Localization documentation owns the stable policy and repair
guidance. `mobilekit` continues only to execute analyzer/custom-lint and
localization-generation sensors.

An accepted implementation should bump the checked-in template version so a
consumer can identify whether it originated before or after the stronger
policy. The version is evidence, not an automatic compatibility claim.

### Existing consumers

Existing repositories own their copied lint implementation and must adopt the
change through their normal task and review workflow. For `awwabi-mobile`, the
migration should:

1. port the rule behavior and focused fixtures into
   `packages/awwabi_mobile_lints/` without renaming the package in the same
   change;
2. add Awwabi-specific registered sinks such as `MoodChartItem.label` and
   `RootShellCenterActionData.semanticLabel`;
3. inventory the resulting production violations;
4. move user-visible copy into ARB and pass localized values at presentation
   boundaries;
5. use only narrow reviewed suppressions for proven non-localizable literals;
6. run the consumer's full harness and relevant localization tests.

Package-name standardization is unrelated to copy enforcement and should not be
mixed into this migration.

### Future synchronization

This proposal deliberately stops short of a general updater. A consumer lint
fork is expected to diverge after generation, and overwriting it from another
checkout would risk deleting product policy. If the same missed-upgrade problem
appears in multiple consumers, record it as separate evidence for a versioned,
conflict-aware harness upgrade mechanism.

## Rollout

Use three independently reviewable stages:

1. **Core rule contract:** implement the sink registry, strict configuration,
   diagnostics, and behavioral fixtures without changing product copy.
2. **Core template enforcement:** enable all baseline/core-specific sinks,
   migrate core-kit violations, update localization guidance, and bump the
   template version.
3. **Consumer adoption:** port the accepted contract into Awwabi under a
   separate execution plan, fix its product violations, and verify the final
   localized UI.

The rollout unit is a repository commit. Rollback is a normal revert of the
rule/configuration and corresponding copy migration in that repository. ARB
keys introduced for migrated copy may remain temporarily if rollback would
otherwise mix unrelated cleanup into recovery.

## Risks And Tradeoffs

### False positives

An unrestricted scan of common names such as `label` or `message` would create
noise and encourage suppressions. Target-and-argument matching is more work
than a generic name list but preserves trust in the gate.

### False negatives through indirection

The proposed first version does not trace a literal through local variables,
fields, collections, or factory layers. That is a known boundary, not a claim
of complete localization proof. Extend it only after recurring evidence shows
that direct sink enforcement is insufficient.

### API identity

Textual target matching can be affected by import prefixes, aliases, or same-
named types. The implementation plan must choose and test one stable target
identity strategy supported by the current analyzer/custom-lint APIs. If
resolved library identity is reliable, prefer it for built-in sinks; consumer
configuration may remain simple-name based within narrow presentation scopes.

### Migration volume

Turning on broader enforcement may expose existing debt. The migration must
not hide that debt with broad excludes or generated allowlists. If the volume
is too large for one safe review, adopt sink families in bounded stages while
keeping each stage error-level once enabled.

### Consumer drift

Core-kit cannot prove that an independent consumer copied the new rule. Template
versioning and explicit consumer plans make drift visible but do not automate
upgrades. That is consistent with current repository ownership and avoids a new
distribution system without recurring evidence.

## Acceptance Criteria

1. Direct literals at every registered default sink fail with error-level
   `hardcoded_ui_strings` diagnostics in configured production scopes.
2. Localized expressions and already-localized parameters pass.
3. Accessibility strings are treated as user-facing copy.
4. Unregistered technical APIs and code outside configured UI scopes are not
   flagged merely because they use names such as `label` or `message`.
5. Consumer sink configuration is strict, additive, deterministic, and covered
   by positive and negative tests.
6. An end-to-end fixture proves the real custom-lint plugin fails and passes as
   expected.
7. ARB generation and untranslated-message checks remain separate and continue
   to pass.
8. Core-kit documentation describes the enforced sink boundary and its known
   non-data-flow limitation.
9. The template version identifies the stronger localization policy.
10. Awwabi adoption is performed separately, with its existing unrelated work
    preserved and no package rename bundled into the migration.
11. Core-kit and each adopting consumer pass their own canonical full
    verification before publication.

## Open Questions

### Target identity implementation

**Recommended default:** use resolved type/library identity for built-in
Flutter sinks when the current analyzer API exposes it reliably, with focused
tests for prefixed imports. Use simple target names only for consumer-declared
sinks inside narrow configured paths.

This should be confirmed during implementation against the pinned analyzer and
`custom_lint_builder` versions.

### First consumer-specific sink set

**Recommended default:** begin Awwabi with the two proven misses plus its
repo-owned input, snackbar, dialog, navigation, and chart model APIs discovered
during migration. Do not speculate about every future widget parameter in the
core package.

### Fixed product and brand copy

**Recommended default:** keep rendered brand/product copy in ARB. Use a narrow
suppression only when localization would be semantically wrong, not merely
because a string is currently identical in every locale.

## Decision Requested

Approve the user-visible sink model, strict additive consumer configuration,
behavioral fixture requirement, and separate Awwabi adoption. After approval,
record any durable lint-contract decision in an ADR and create independent V2
execution plans for core-kit implementation and consumer migration.
