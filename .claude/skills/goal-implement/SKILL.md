---
name: goal-implement
description: Implement a VALIDATED Goal Contract produced by spec-to-goal. Treats the contract as the authoritative execution boundary — implements only what is in scope, keeps a progress log, runs the validation plan, and stops when acceptance criteria pass. Use when the user says /goal-implement, goal implement, implement goal, implement docs/goals/*.goal.md, or hands off a validated Goal Contract.
---

# Goal Implement Skill

Claude's implementation runtime for Goal-Driven Development. This is the Claude equivalent of Codex's `/goal` command. It executes a Goal Contract; it does NOT create or reshape goals.

## Input

A path to a Goal Contract: `docs/goals/<goal-id>.goal.md`.

If no path is given, ask for one or list `docs/goals/*.goal.md` and ask which to implement.

## Preconditions — refuse to implement unless all hold

1. The contract file exists and is readable.
2. Its `## Status` is `VALIDATED`. If status is `NEEDS_DATA`, `BLOCKED`, `TOO_BROAD`, `DREAM`, or `PROTOTYPE_ONLY`, STOP. Report the status and propose the smallest next step to make it implementable (usually: re-run `spec-to-goal`).
3. Repo reality still matches the contract's `Current state` / `Current-state evidence`. Spot-check before writing code. If reality conflicts with the contract, STOP and propose a contract revision instead of expanding scope.

## Execution rules

- The Goal Contract is the source of truth. Implement ONLY the `Implementation boundary`.
- Do not implement anything under `Non-goals`.
- Do not invent new product goals during implementation.
- Do not assume a dependency marked `UNKNOWN` or `BLOCKED` is ready — verify or stop.
- Keep scope minimal. Map every material change back to an acceptance criterion.
- Add or update tests when behavior changes (if the project has a test harness).
- Work in checkpoints. After each checkpoint, append to the progress log.

## Progress log

Maintain `docs/goals/<goal-id>.progress.md`. Append (do not overwrite) one entry per checkpoint:

```md
## <checkpoint label>
- Changed: <files / what>
- Maps to: <acceptance criterion>
- Validation run: <command> → <result>
- Next: <next checkpoint or DONE>
```

## Validation

Run the contract's `## Validation plan`:

- Pre-implementation checks: inspect the named files/data/commands first.
- Implementation checks: run the project's tests / lint / typecheck / build / bench as specified.
- Report any check you could NOT run and why. Never claim a check passed if it did not run.

## Completion

Stop only when:

- every acceptance criterion is demonstrably met,
- the validation plan is complete (or unrunnable checks are explicitly flagged),
- no `Non-goals` were touched.

Final response must include an implementation report:

- which acceptance criteria passed, with evidence (command output, file:line)
- which checks could not be run and why
- any contract deviation found and how it was resolved
- optionally save the report to `docs/goals/<goal-id>.implementation.md`

If acceptance criteria cannot all be met, do NOT declare success. Report what blocks completion and propose the next step.
