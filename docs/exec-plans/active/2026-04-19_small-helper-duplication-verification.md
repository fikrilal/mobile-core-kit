# Small Helper Duplication Detection And Verification Integration

## Goal

Improve the duplication harness so it catches the highest-pain duplication class in this repository:
- tiny local helpers
- especially formatter/display/parser/normalization helpers
- especially presentation-local helpers such as `_firstFieldError(...)`, `_formatX(...)`, `_labelForX(...)`, and `_messageForX(...)`

Also make this check part of the standard agent verification flow so agents surface helper duplication during self-review instead of relying on reviewer memory.

## Why

The current harness is already effective for medium-sized duplication:
- failure mappers
- bridge translations
- workflow tails
- some presentation/cubit duplication

But it is still underweighted for the most common agent failure mode in practice:
- tiny helper duplication spread across pages, widgets, and cubits

That means the harness direction is right, but the verification loop is still missing the highest-ROI signal.

## Scope

In scope:
- add a dedicated small-helper duplication profile with lower thresholds than the main profiles
- focus categorization on helper-shaped duplication rather than broad page/widget similarity
- support reviewed-acceptable allowlisting for this profile
- add the small-helper check to the canonical verification flow
- document when and how to use it

Out of scope:
- broad general clone detection for all presentation code
- CI hard-fail behavior for duplication
- automatic refactoring or automatic abstraction decisions
- replacing the existing core or presentation duplication profiles

## Plan

1. Add a dedicated small-helper duplication profile
- create a separate `jscpd` config tuned for short helper blocks
- create a dedicated runner and allowlist file
- keep it separate from the broader presentation profile to avoid noise coupling

2. Extend the duplication filter with a `small_helpers` profile
- detect helper-focused categories such as:
  - display helpers
  - formatter helpers
  - parser helpers
  - normalization helpers
  - field-error helpers
- keep grouping and reviewed-acceptable behavior consistent with the existing harness

3. Integrate the small-helper check into agent verification
- add it to the internal verifier used by `mobilekit verify`
- keep it as a surfaced signal, not a hard fail for existing duplication debt
- preserve a way to skip duplication checks if needed for exceptional cases

4. Update docs
- duplication harness guide
- agent PR loop guide
- docs index if needed

## Success Criteria

- a dedicated small-helper duplication command exists
- the new profile surfaces real helper duplication already present in the repo
- `mobilekit verify` runs the small-helper check during normal verification
- docs explain when to run it and how to interpret the result

## Verification

Planned verification:
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile core`
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation`
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helper`
- `dart run mobile_core_kit_cli:mobilekit lint`
- `dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests`
