---
name: goal-lite
description: The lightweight GDD tier for a small-but-real change — state a one-line inline mini-contract (goal + boundary + verification command) in chat, then implement it under the same discipline, with NO .goal.md file. Use when the user says /goal-lite, goal lite, quick goal, small change but do it properly, or for a Tier-1 change too small for a full Goal Contract yet too real to "just edit".
---

# Goal Lite Skill

The **Tier-1** runtime of Goal-Driven Development: full discipline, zero paperwork. It exists for the gap between "trivial edit, just do it" and "ambiguous/multi-layer, write a full Goal Contract". A small, well-understood change still deserves a boundary and a verification gate — it just does not deserve a `docs/goals/*.goal.md` file.

`spec-to-goal` shapes a contract (no code) and `goal-implement` executes one. This skill collapses both into a single inline pass for work you already hold in your head.

## When to use — the three tiers

| Tier | Situation | This skill? |
|---|---|---|
| 0 — Raw | 1–2 line edit, typo, rename, config tweak; or a pure question / read-only investigation | NO — just do it (the Evidence & honesty rule still applies) |
| **1 — Lite** | **a real behavior/code change, but small, single-concern, scope already clear in your head (roughly ≤1 file or ≤~40 lines, one layer)** | **YES — `/goal-lite`** |
| 2 — Full | vague, multi-layer (≥2 layers / ≥3 files), or needs a measured target (latency, hit rate, accuracy) | NO — `/spec-to-goal` → `/goal-implement` |

When a task sits on the Tier-1/Tier-2 line, prefer Tier 2. Lite is for confidence, not for skipping rigour.

## Required behavior

1. **Gate the tier.** Confirm the change is genuinely Tier 1. If it is trivial (Tier 0), skip the ceremony and just edit. If it is ambiguous or multi-layer (Tier 2), STOP and hand off to `/spec-to-goal` — do not stretch lite to cover it.

2. **State the inline mini-contract** in chat before editing — 4 lines, no file:

   ```txt
   Goal:         <one outcome-oriented sentence>
   Boundary:     in = <what changes> ; out = <what must NOT change / non-goals>
   Verification: <ONE real command, exit 0 = done> | manual: <steps>
   Assumptions:  <only if any — label them; none → omit this line>
   ```

   The `Verification` command must be a REAL project command (detect it the way `spec-to-goal` does: `CLAUDE.md` "Validation reality", `package.json` / `pyproject.toml` / `Makefile` / CI / test dirs). Never invent one. If nothing can mechanically prove it, write `manual: <explicit steps>`.

3. **Implement inside the boundary**, under the same rules as `goal-implement`:
   - **Fix the cause, not the symptom.** No hardcoding/special-casing one input, no regex that only fits the example, no papering over a symptom. A narrow fix is fine only if it is genuinely correct for the general case, or honestly marked `gdd-defer`.
   - Behavior change → use the `test-driven-development` skill: failing test first, then code.
   - Mark any deliberate simplification with a `gdd-defer` comment (`<lead> gdd-defer: <ceiling> ; <upgrade trigger>` — no goal-id, since lite has no contract; it harvests as an ORPHAN, which is correct).
   - Touch nothing in `out =`.

4. **Run the Verification command.** Report PASS/FAIL with evidence (command output, `file:line`). Never claim it passed if it was not run. If it is `manual:`, perform the steps and record the observed result.

5. **Done-gate.** Stop only when the verification passed and nothing in `out =` was touched. If it FAILS, report the failure — do not declare success.

## Escalation — the one hard rule

If, mid-implementation, the change turns out to be bigger than Tier 1 (it needs a second layer, the boundary keeps growing, or a real metric/baseline is now in question), **STOP**. Do not quietly let lite balloon into uncontracted multi-layer work — that is exactly the scope creep GDD exists to prevent. Surface it and hand off to `/spec-to-goal`, carrying over what you have learned.

## Output style

Terse. Show the 4-line mini-contract, the change, then the verification result. No essay, no `.goal.md`, no progress log — those belong to Tier 2.
