---
name: goal-status
description: Show the status of all Goal Contracts in docs/goals/. Lists each goal's ID, status (VALIDATED/NEEDS_DATA/BLOCKED/TOO_BROAD/DREAM/PROTOTYPE_ONLY), and whether it has a progress log or implementation report. Use when the user says /goal-status, goal status, list goals, what goals exist, which goals are validated/blocked, GDD overview, or asks about the goal portfolio.
---

# Goal Status Skill

Read-only overview of the Goal-Driven Development portfolio. Does not create, edit, or implement goals — only reports.

## Behavior

1. List files in `docs/goals/`:
   - `*.goal.md` — contracts
   - `*.progress.md` — progress logs
   - `*.implementation.md` — implementation reports
2. For each `*.goal.md`, read its `## Status` line and `## Goal` statement.
3. Match each contract to its progress/implementation siblings by goal-id prefix.
4. Render one summary table, then a short next-action line.

## Output format

```txt
| Goal ID | Status | Goal (short) | Progress? | Impl? |
|---|---|---|---|---|
| 2026-01-15-referral-earnings | VALIDATED | Show claimable referral earnings on the dashboard | yes | no |
```

Status legend (carry from the contract verbatim):
`VALIDATED` ready to implement · `NEEDS_DATA` lacks evidence/baseline · `BLOCKED` dependency blocks · `TOO_BROAD` must split · `DREAM` not actionable · `PROTOTYPE_ONLY` not production.

## Next-action summary

After the table, give a one-line recommendation per non-terminal goal:

- `VALIDATED` with no impl report → suggest `/goal-implement docs/goals/<id>.goal.md`
- `NEEDS_DATA` / `TOO_BROAD` → suggest re-running `/spec-to-goal` to refine/split
- `BLOCKED` → name the blocking dependency from the contract

If `docs/goals/` has no `*.goal.md`, say so and suggest `/spec-to-goal <requirement>` to create the first contract.

## Rules

- Do not infer a status the contract does not state. Read it from the file.
- Do not modify any file.
- Keep it to the table + next-action lines. No essay.
