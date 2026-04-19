# Agent Duplication Detection Priority

## Context

A recurring agent-authored maintainability problem in this core kit is silent duplication.

The code usually still:
- compiles
- passes tests
- passes linting
- looks locally reasonable

But the repository slowly accumulates:
- repeated helpers
- repeated formatting logic
- repeated parsing logic
- repeated mapping logic
- repeated tiny presentational widgets

This is one of the highest-ROI harness problems to solve because it appears frequently and compounds quietly.

## Why This Is High ROI

This class of duplication is:
- frequent
- cheap for agents to generate
- easy to miss during review
- expensive to clean later
- exactly the kind of drift that makes the codebase less coherent over time

It creates the worst kind of debt:
- nothing is obviously broken
- verification still passes
- but the codebase gets noisier and less maintainable every week

## Priority Target: Tier 1 Duplication

These are the most valuable duplication classes to surface first.

### 1. Small parser helpers

Examples:
- `tryParse...`
- `fromString...`
- local enum or status parsing

Why first:
- repeated often
- structurally easy to detect
- usually a strong signal that a shared semantic conversion is missing

### 2. Formatting helpers

Examples:
- date formatting helpers
- label formatting helpers
- display-name builders

Why first:
- repeated often across screens and subfeatures
- frequently duplicated with only small naming or context changes
- easy to drift if not centralized

### 3. Repeated mapping logic

Examples:
- API error -> failure mapping
- model -> entity mapping
- status -> badge / text / color mapping

Why first:
- agents often re-create mapping logic locally rather than reusing or extracting it
- repeated mappings create semantic drift quickly
- the duplication is usually meaningful enough to justify reviewer attention

### 4. Fallback / normalization helpers

Examples:
- trim/null/default wrappers
- “safe” conversion helpers
- local normalization of blank/null/unknown values

Why first:
- these helpers are a common symptom of agent defensive overproduction
- they often look harmless but spread semantic duplication throughout the repo
- they are usually good candidates for consolidation once repeated

## Phase 2 Target: Repeated Tiny Presentational Widgets

Examples:
- badges
- cards
- pills
- info rows

These matter, but they should come later.

Why not first:
- UI similarity is noisier than helper duplication
- some repetition is intentional and acceptable
- bad detection here will generate more false positives and reduce trust in the signal

So these should be part of the overall problem, but not the first rollout target.

## Recommended Priority Order

The best ROI order is:

1. parser helpers
2. formatters
3. mappers
4. normalization / fallback helpers
5. tiny repeated UI widgets

## Why This Ordering Makes Sense

The first four categories are:
- more common
- more mechanically detectable
- lower-noise
- easier to judge as extractable or not

The widget category is still important, but should come after the signal quality of the first four categories is proven.

## Core Insight

The real problem is not only duplication.

The deeper problem is that agents are good at generating another local helper, but weak at deciding when the helper should become shared.

That means:
- prompt guidance alone is not enough
- reviewer memory alone is not enough
- duplication needs to be surfaced as a first-class harness signal

## Problem Framing For The Repo

The objective is not:
- eliminate all duplicate code

The objective is:
- make agent-generated maintainability duplication visible before it compounds

The first detection pass should optimize for:
- duplicated small helpers
- duplicated formatting / parsing / mapping logic
- repeated local normalization behavior

## Next Step

The next step should define:
- which duplication categories to detect mechanically first
- where the signal should appear in the workflow
- what should remain human judgment vs automation
- what output format would be actionable without becoming noisy
