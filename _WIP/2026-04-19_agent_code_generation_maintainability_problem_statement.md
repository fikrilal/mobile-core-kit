# Agent Code Generation Maintainability Problem Statement

## Context

This core kit has been applied successfully in a downstream product repository and has improved:
- code cleanliness
- custom lint enforcement
- agent execution-plan discipline
- general agent usability in day-to-day feature work

However, there is still a recurring maintainability problem in agent-authored code.

## Problem Summary

LLM coding agents are biased toward producing **locally-complete, defensively-plausible code**, while being weaker at **global abstraction, deduplication, and restraint**.

In practice, this shows up as two recurring failure patterns:

1. agents generate duplicated helpers instead of reusing or extracting shared utilities
2. agents overproduce local parser / fallback / type-check / defensive glue that makes code noisier than necessary

These are not separate problems. They are two symptoms of the same maintainability gap.

## Observed Failure Patterns

### 1. Duplication instead of shared abstraction

A common pattern is:
- feature A introduces a small helper for parsing, formatting, mapping, or normalization
- feature B later needs almost the same thing
- instead of discovering and reusing the existing helper, the agent generates a second local version

This creates:
- duplicate logic across features
- drift in behavior over time
- more review burden
- more places to update when rules change

Typical forms:
- date formatting helpers
- string normalization helpers
- error-message mapping helpers
- request/response parsing helpers
- small status-label / badge / formatting widgets

### 2. Over-eager defensive code generation

Agents also tend to add local defensive code beyond what the repo actually needs.

Typical forms:
- extra parsing wrappers
- extra fallback branches
- repeated `tryParse` / `null` / `trim` handling in many places
- speculative type checks
- local “safe” helpers that duplicate existing core utilities
- ad hoc normalization logic near the call site instead of using shared semantics

This often produces code that is:
- functionally acceptable
- mechanically verifiable
- but still more verbose and less maintainable than necessary

### 3. Local optimization instead of repository-level design

The agent often optimizes for:
- finishing the current file
- making the current function look robust
- satisfying immediate compile/lint/test pressure

It is weaker at:
- stepping back to ask whether the logic already exists elsewhere
- extracting a reusable utility when repetition first appears
- preferring the minimal semantic abstraction over another local helper
- distinguishing necessary resilience from speculative defensive noise

## Why This Happens

This appears to come from a combination of model tendencies and workflow constraints.

### Local completion bias

The model is strongly biased toward completing the immediate task in the immediate file. That makes local helper generation cheap and attractive.

### Generation is stronger than refactoring

Models are generally better at producing another working block than at performing repository-level deduplication and abstraction.

### Cross-file abstraction discovery is weak unless forced

Even when the repository already contains a reusable utility, the agent may not search broadly enough or may still choose local duplication because it is the shortest path to task completion.

### Maintainability is under-constrained by default

Compile checks, tests, and many lints do not punish:
- near-duplicate helpers
- speculative defensive code
- unnecessary fallback branches
- missed opportunities for shared abstraction

So the agent can “pass verification” while still degrading the codebase.

## Research / External Evidence

The broader pattern is supported by current literature and practitioner observations.

### Strongly supported

- Repetition and structural duplication are common in LLM-generated code.
- Code smells from training data can propagate into generated output.
- LLM-generated refactorings are still unreliable compared with human maintainability judgment.
- Function-scoped or local repairs often fail on problems that require file-level or module-level reasoning.

### More practitioner-driven but still credible

- Agents are often too eager to add parser/fallback/defensive glue.
- Agents tend to make code look safer locally even when the repository already has the correct shared abstraction.
- The maintainability degradation is often subtle rather than obviously broken.

## Clear Problem Statement For This Core Kit

The problem is not that agents cannot write working code.

The problem is that agents frequently:
- solve the current file instead of improving the current system
- generate a second local helper instead of reusing the first shared one
- add defensive logic that looks reasonable but is not justified by the repo’s actual needs

That leads to:
- duplication
- abstraction drift
- noisier feature code
- weaker long-term maintainability even when short-term correctness is preserved

## What This Is Not

This is not primarily:
- a syntax-quality problem
- a test-generation problem
- a compile-failure problem
- a single-model-version bug

It is a maintainability and architecture-discipline problem.

## Desired Next Step

Do not jump straight to solutions.

The next step should be to turn this into a repository-specific diagnosis:
- where the pattern appears most often
- which classes of duplication are most common
- which kinds of defensive code are legitimate vs noise
- which parts should be addressed by docs, lints, CLI verification workflows,
  or scaffolding

## Sources

- OpenAI, "Harness engineering: leveraging Codex in an agent-first world"
  - https://openai.com/index/harness-engineering/
- "Code Copycat Conundrum: Demystifying Repetition in LLM-based Code Generation"
  - https://arxiv.org/abs/2504.12608
- "Rethinking Repetition Problems of LLMs in Code Generation"
  - https://aclanthology.org/2025.acl-long.48.pdf
- "An Empirical Study of Code Smells in Transformer-based Code Generation Techniques" (SCAM 2022 summary)
  - https://s2e-lab.github.io/paper/research/llm/scam-2022/
- "Using LLMs to enhance code quality: A systematic literature review"
  - https://www.sciencedirect.com/science/article/abs/pii/S095058492500299X
- "CodeTaste: Can LLMs Generate Human-Level Code Refactorings?"
  - https://arxiv.org/abs/2603.04177
- "An evaluation study of large language models for addressing code quality issues"
  - https://link.springer.com/article/10.1007/s10664-026-10858-8
