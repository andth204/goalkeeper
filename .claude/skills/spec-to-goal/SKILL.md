---
name: spec-to-goal
description: Convert a raw software requirement, feature request, PRD, issue, or vague product spec into a trackable, realistic, intent-aligned Goal Contract before implementation. Use when the user says /spec-to-goal, spec to goal, requirement to goal, define goal, validate realism, success criteria, dependencies, or asks to clarify before coding.
---

# Spec to Goal Skill

Use this skill to transform a raw software requirement into a realistic, validated, implementation-ready Goal Contract.

This skill is for product and engineering shaping. Do NOT implement code while using this skill. Implementation happens in a separate phase via the `goal-implement` skill, and only after a valid Goal Contract exists.

## Why this skill exists

This skill enforces three outcomes:

1. **Make the goal trackable.** Convert vague intent into a goal with an ID, current state, target state, success criteria, acceptance criteria, and validation plan.
2. **Make the goal realistic.** Validate the goal against the actual current situation: codebase, dependencies, constraints, data, risks, and available evidence.
3. **Align human intent with agent execution.** Translate the user's intent into a bounded contract so the implementation agent does not hallucinate objectives, invent fake evidence, or expand scope.

## Core principle

A feature request is not a goal. A goal is an outcome with a current-state baseline, constraints, dependencies, success criteria, a validation method, and an implementation boundary.

Pipeline:

```txt
Raw requirement
→ Requirement intake
→ Draft goal
→ Reality validation
→ Goal Quality Gate
→ Goal Contract
→ Handoff to implementation (goal-implement skill)
```

## Required behavior

When invoked:

1. Read the user's raw requirement, referenced files, docs, issues, code, or context.
2. Identify ambiguity and missing information.
3. Inspect the repository when useful to validate the current state. Prefer the project's code-intelligence / dedicated search tools (e.g. a code-graph MCP, your editor's index) over guessing. Detect the project's REAL validation commands here too: read `CLAUDE.md` (a "Validation reality" section if present), then `package.json` scripts, `pyproject.toml` / `pytest.ini` / `tox.ini`, `Makefile`, `justfile`, CI config (`.github/workflows`), and test dirs. Use those exact commands in the validation plan. NEVER invent commands (`npm test`, `pytest`, ...) the repo does not actually have.
4. Convert the raw requirement into an outcome-oriented goal.
5. Validate whether the goal is realistic given current code, dependencies, team constraints, and available evidence.
6. Apply the Goal Quality Gate: trackable, realistic, and intent-aligned.
7. Produce a Goal Contract.
8. Save the contract to `docs/goals/<YYYY-MM-DD>-<short-slug>.goal.md` unless the user asks for chat-only output.
9. End with an exact `goal-implement` handoff command only if the contract status is `VALIDATED`.

## Non-negotiable rules

- Do not treat a requested feature as the goal by default.
- Do not produce implementation tasks until the goal has passed reality validation.
- Do not invent metrics. If real metrics are unavailable, mark them as assumptions and propose proxy metrics.
- Do not invent current-state evidence. Evidence must come from the repo, docs, data, logs, tests, user context, or explicit assumptions.
- Do not hide blockers. Classify blocked work as blocked.
- Do not allow vague success criteria such as "works well", "good UX", "fast", or "secure" without measurable verification.
- Do not expand scope beyond the stated goal.
- If the goal is too large, split it into a smaller valid goal and list the deferred goals.
- Preserve the user's intent. Do not replace it with an agent-invented objective.

## Flow nodes

### 1. Requirement intake

Extract:

- Raw requirement
- Request source, if known
- User or stakeholder
- Interpreted human intent
- Claimed problem
- Desired behavior
- Product area
- Existing related files, routes, APIs, DB tables, contracts, jobs, tests, docs, or analytics
- Known constraints
- Unknowns

Ask at most three clarifying questions only when they are blocking. Otherwise, proceed with explicit assumptions.

### 2. Draft goal

Rewrite the requirement as an outcome.

Bad:

```txt
Build a referral dashboard.
```

Good:

```txt
Increase creator-driven acquisition by making referral earnings visible, understandable, and claimable from the user dashboard.
```

The draft goal must name:

- Who benefits
- What behavior should change
- Why the change matters
- What should not be solved yet

### 3. Reality validation

Validate the draft goal against reality before accepting it.

Check:

- Current state: what exists now in the product/codebase?
- Evidence: what data, logs, user feedback, tickets, docs, tests, or code proves the current state?
- Dependencies: design, backend, database, vector store, cache, API, auth, analytics, infrastructure, legal, ops, external services.
- Constraints: time, complexity, risk, team capacity, migration cost, performance, security, compliance.
- Failure modes: what could make the goal impossible, unsafe, misleading, or too expensive?

Dependency status must be one of:

```txt
READY | UNKNOWN | BLOCKED | NOT_NEEDED
```

Classify the result as exactly one of:

- `VALIDATED`: realistic enough to implement now.
- `NEEDS_DATA`: plausible but lacks required evidence or baseline.
- `BLOCKED`: dependency prevents implementation.
- `TOO_BROAD`: must be split before implementation.
- `DREAM`: desirable but not currently actionable.
- `PROTOTYPE_ONLY`: can be explored, but should not be treated as production goal.

### 4. Goal Quality Gate

Before creating the final contract, verify these gates.

#### Trackability gate

The goal must have:

- Goal ID
- Current state
- Target state
- Success criteria
- Acceptance criteria
- Validation plan
- Measurement source or proxy measurement

If the goal cannot be measured at all, it is not `VALIDATED`.

#### Reality gate

The goal must be grounded in current situation and dependency status.

Required:

- Current-state evidence
- Dependency list with status
- Constraints
- Risks and mitigations
- Clear decision: proceed, block, split, downgrade, or prototype only

If the agent cannot verify the current situation, do not pretend it is verified.

#### Intent-alignment gate

The goal must constrain execution.

Required:

- Interpreted human intent
- Assumptions
- Non-goals
- Implementation boundary
- Anti-hallucination checks

Anti-hallucination checks must include:

- Which claims are supported by evidence
- Which claims are assumptions
- Which parts must not be implemented
- Which dependencies must not be assumed ready

### 5. Goal Contract

Create a Goal Contract using the structure in `templates/goal-contract.md`.

### 6. Handoff

If the Goal Contract status is `VALIDATED`, produce a concise implementation handoff:

- goal file path
- implementation boundary
- validation commands
- suggested `goal-implement` handoff (see below)

If the status is not `VALIDATED`, do not produce an implementation command. Produce the smallest next action required to make it valid.

Handoff command (Claude has no Codex `/goal`; use the companion `goal-implement` skill instead):

```txt
/goal-implement docs/goals/<goal-id>.goal.md
```

## Output style

Be direct. Separate facts from assumptions. Prefer concrete checks over abstract advice. Use tables only when they reduce ambiguity.
