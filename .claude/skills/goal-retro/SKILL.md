---
name: goal-retro
description: Close the loop after a goal ships — compare the contract's assumptions against what actually turned out true, harvest deferrals and boundary deviations, and surface durable learnings worth carrying to the next goal (and to memory if the project has one). Read-mostly. Use when the user says /goal-retro, goal retro, retrospective, what did we learn, close out the goal, post-mortem the goal.
---

# Goal Retro Skill

The **reflect** stage of GDD. `spec-to-goal` records assumptions when a goal is *shaped*; `goal-implement` records what was *built*; `goal-debt` tracks shortcuts in the *code*. This skill closes the loop: once a goal is shipped, it checks the contract's predictions against reality and turns the difference into a durable learning — so the next contract starts smarter instead of repeating the same wrong assumption.

It is read-mostly: it reads the contract, progress log, implementation report, and diff, and writes at most a short retro note. It does not change code or reopen the goal.

## Input

A goal id or contract path (`docs/goals/<goal-id>.goal.md`). If none given, prefer the most recently implemented goal (one with a `*.implementation.md` or a completed `*.progress.md`); if ambiguous, list candidates and ask.

## Behavior

1. **Gather the trail.** Read the contract, its `*.progress.md`, its `*.implementation.md` (if any), and the diff that implemented it.

2. **Score the assumptions.** For each item under the contract's `## Assumptions` (and each `UNKNOWN` dependency), mark how it turned out:
   - `HELD` — the assumption was correct.
   - `BROKE` — it turned out false; say what was actually true and what that cost (rework, a deviation, a defer).
   - `UNTESTED` — implementation never exercised it; it's still an open risk.

3. **Harvest what changed shape:**
   - **Deferrals** — `gdd-defer` markers this goal introduced (run `goal-debt` mentally or cite it): what was deferred and the trigger that would force the upgrade.
   - **Boundary deviations** — anything implemented that differed from the `Implementation boundary` / touched a `Non-goal`, and why (from the progress log).
   - **Verification reality** — did the `Verification command` actually prove the goal, or did it pass while a gap slipped through (cross-check `goal-review` if it was run)?

4. **Extract durable learnings.** Distil 1–5 learnings that generalise beyond this goal — a wrong estimate pattern, a dependency that's always slower than assumed, a test that should exist, a threshold that matters. Each learning must be reusable on a *future* goal, not a restatement of what happened.

5. **Persist (lightly).** If the project has a memory / knowledge system, suggest (or, if asked, write) the durable learnings there — generically, using whatever mechanism the repo documents; invent none. Otherwise append a short `## Retro` block to the goal's `*.progress.md` (or write `docs/goals/<goal-id>.retro.md` if the user prefers). Keep it short.

## Output format

```txt
Retro: <goal-id>

| Assumption / unknown | Outcome | What was actually true / cost |
|---|---|---|
| <assumption> | HELD | — |
| <assumption> | BROKE | <reality + cost> |
| <dependency> | UNTESTED | <still-open risk> |

Deferrals:   <gdd-defer markers introduced, or none>
Deviations:  <boundary/non-goal deviations + why, or none>

Learnings (carry forward):
- <reusable learning 1>
- <reusable learning 2>
```

## Rules

- **Honest, not celebratory.** A retro that finds nothing wrong is a smell — name what was lucky, what's still untested, what nearly slipped. The value is in the `BROKE` and `UNTESTED` rows.
- Read-mostly: do not edit code or change the contract's goal. The only writes are the retro note and (with consent) memory entries.
- Distinguish a learning (generalises to future work) from a log entry (what happened this time). Only the former goes in "carry forward".
- Don't invent a memory mechanism the project lacks. If there's none, the progress-log note is enough.
- Keep it to the table + two summary lines + learnings. No essay.
