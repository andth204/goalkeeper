---
name: goal-review
description: Adversarially audit an implementation against its Goal Contract — try to REFUTE that each acceptance criterion is met, check for non-goal scope creep and unmarked shortcuts, and re-run the verification command independently. Read-only; it judges, it does not fix. Use when the user says /goal-review, goal review, review the goal, verify the goal is done, audit against the contract, or before shipping a goal-implement result.
---

# Goal Review Skill

The **adversarial done-gate** of GDD. `goal-implement` runs the contract's `Verification command` (exit 0) — but an exit code only proves *one* command ran clean, not that every acceptance criterion is genuinely met, that no non-goal was touched, and that no shortcut was slipped in unmarked. This skill is the independent re-check the Evidence & honesty rule demands for high-risk or ≥2-layer goals: it actively tries to **refute** "this goal is done" before it ships.

It is read-only on the code. It produces a verdict, not a fix. If it finds a gap, the fix is normal work back under `goal-implement` (or `goal-lite`).

## Distinction from a generic code review

A generic code reviewer asks "is this code good?". This skill asks a narrower, sharper question: **"does this diff deliver exactly the contracted goal — no less, no more, no faking?"** It is anchored to one Goal Contract and audits conformance + anti-fabrication, not general style.

## Input

- A goal id or contract path (`docs/goals/<goal-id>.goal.md`). If none given, list `docs/goals/*.goal.md` and ask which — or, for a `goal-lite` change, take the inline mini-contract from the conversation.
- The change under review: by default the working-tree/branch diff (`git diff` against the base branch, plus staged + untracked). State which range you reviewed.

## Behavior

1. **Load the contract.** Extract: acceptance criteria, success criteria, non-goals, implementation boundary, and the `Verification command`.

2. **Get the diff** and the list of files it touches. Name the exact range reviewed.

3. **Refute each acceptance criterion.** For every criterion, the default stance is *not met until proven*. Find the code that satisfies it and cite `file:line`, OR fail it. One of three verdicts each:
   - `MET` — cite the `file:line` that satisfies it and how it's proven (a test, the verification run, observed behavior).
   - `NOT MET` — the criterion has no corresponding implementation, or the implementation is wrong/incomplete. Say what's missing.
   - `UNVERIFIED` — cannot be checked in this environment (e.g. needs live infra). Say why; never upgrade a guess to `MET`.

4. **Check the boundary both ways:**
   - **Scope creep** — did the diff change anything listed under `Non-goals` or outside the `Implementation boundary`? Flag each.
   - **Hidden shortcuts** — any simplification / heuristic / special-case in the diff that is NOT marked with a `gdd-defer` comment? Flag it: it's either invisible debt or a band-aid masquerading as a fix.

5. **Re-run the `Verification command` independently** from the repo root. Record exit code and a one-line result. If `manual:`, perform the steps. If it cannot run here, say so — do not assume it passes.

6. **Render the verdict** (below), then a single recommendation: `SHIP` / `DO NOT SHIP`. `DO NOT SHIP` if any acceptance criterion is `NOT MET`, any non-goal was touched, or the verification FAILED.

## Output format

```txt
Reviewed: <goal-id> @ <diff range>

| Acceptance criterion | Verdict | Evidence / gap |
|---|---|---|
| <criterion> | MET | <file:line — how proven> |
| <criterion> | NOT MET | <what is missing> |
| <criterion> | UNVERIFIED | <why it can't be checked here> |

Boundary:    <clean | NON-GOAL TOUCHED: file:line …>
Shortcuts:   <none | UNMARKED: file:line … (should carry gdd-defer)>
Verification: <command> → exit <n> (<one-line result>)

Recommendation: SHIP | DO NOT SHIP — <one-line reason>
```

## Rules

- **Read-only.** Do not edit code, the contract, or markers. Report; the fix is separate work.
- **Refute, don't rubber-stamp.** Default every criterion to unmet and make the code prove it. A review that confirms everything on the first pass probably didn't try.
- **Never claim a check passed if it was not run.** `UNVERIFIED` is an honest verdict; a fabricated `MET` is the exact failure GDD guards against.
- Keep it to the verdict table + the three summary lines + the recommendation. No essay.
- If repo reality no longer matches the contract's `Current state`, say so — the contract may need a `spec-to-goal` revision, not a pass/fail.
