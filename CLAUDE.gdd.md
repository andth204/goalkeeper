<!--
  GDD instructions block. Copy this into the target repo's CLAUDE.md
  (append to an existing CLAUDE.md, or use as the whole file).
  Then fill the ONE project-specific section: "Validation reality (FILL PER PROJECT)".
-->

# <Project name> — Goal-Driven Development

This repo uses **Goal-Driven Development (GDD)** to enforce three outcomes:

1. **Trackable goals** — every implemented goal has measurable criteria, validation evidence, and a progress/report trail.
2. **Realistic goals** — every goal is checked against current repo/product state, dependencies, constraints, and risks before implementation.
3. **Intent-aligned execution** — work stays inside the human-approved Goal Contract; no invented objectives, hidden assumptions, or scope expansion.

## Evidence & honesty (applies to EVERY response, not just GDD work)

Anti-fabrication rule. The failure mode it guards: confident, unverified claims stated as fact. Unlike the rest of GDD it governs the EXPLORE phase too, not only implementation.

- **Cite or label.** Every factual claim about the repo (a count, a behavior, "X works", "file Y does Z") is backed by command output or a `file:line` in the same response — or explicitly tagged `assumption` / `unverified`. No bare assertions.
- **Run before you claim.** Never say a test/check/command "passed", or that a behavior holds, unless it was actually run. A shallow or partial read is NOT verification — e.g. `git clone --depth 1` cannot reveal commit count; a function signature is not its runtime behavior.
- **Surface the gaps.** What could not be verified in the current environment goes in an explicit "could not verify" note. Do not smooth it over.
- **Prefer mechanical proof.** When a command can settle a question (exit code, test, grep, `git rev-list`), run it instead of reasoning about the likely answer.
- **Scope verification to stakes.** Research/audit answers and high-risk or ≥2-layer goals warrant an independent adversarial re-check before they ship; trivial edits, questions, and read-only explanations do not.

This is advisory — the only HARD gate is a Goal Contract's `Verification command` (an exit code does not lie). Lean on that for anything that matters.

## When GDD applies (activation threshold — three tiers)

GDD is not all-or-nothing. The **discipline** (Evidence & honesty above, fix-the-cause below) applies to *every* change; only the **artifact weight** scales with the work. Pick a tier:

| Tier | Situation | Action |
|---|---|---|
| **0 — Raw** | 1–2 line edit, typo, rename, config tweak; pure question / read-only investigation | Just do it. The Evidence & honesty rule still holds. |
| **1 — Lite** | A real behavior/code change, but small, single-concern, scope already clear (≈≤1 file / ≤~40 lines, one layer) | `/goal-lite` — state a 4-line inline mini-contract (goal · boundary · verification), implement, run the verify. No `.goal.md`. |
| **2 — Full** | Vague / open-ended ("improve X", "add a new kind of Y"); touches ≥2 layers or ≥3 files; needs a measured target (latency, hit rate, accuracy) | `/spec-to-goal` → `/goal-implement`. Full contract, progress log, validation plan. |

The key idea: **kỷ luật là hằng số, contract là biến** — the working standard is constant; the paperwork is what scales. When a task sits on a tier boundary, choose the heavier tier. When genuinely unsure, ask the user "Tier 1 (`/goal-lite`) or full contract (`/spec-to-goal`)?" instead of forcing either path. A `/goal-lite` change that grows past Tier 1 mid-flight must STOP and escalate to `/spec-to-goal` — never let lite balloon into uncontracted multi-layer work.

## Default workflow

For work that crosses the threshold above, do NOT implement the raw request directly.

First convert it into a validated Goal Contract using the `spec-to-goal` skill. Treat messages starting with `/spec-to-goal` as a request to use that skill.

Only implement after a Goal Contract exists and its status is `VALIDATED`. Implement via the `goal-implement` skill. Check overall portfolio status anytime with the `goal-status` skill.

```txt
/spec-to-goal <raw requirement or referenced spec>
/goal-implement docs/goals/<goal-id>.goal.md
/goal-review docs/goals/<goal-id>.goal.md     # before shipping a high-risk / ≥2-layer goal
/goal-retro docs/goals/<goal-id>.goal.md       # after it ships — capture learnings
```

`goal-implement` is the implementation runtime that executes Goal Contracts. Do not invent a separate implementation mechanism for Goal Contracts. For a Tier-1 change, `goal-lite` collapses shaping + implementation into one inline pass (no contract file).

## Goal Quality Gate

Before implementation, the Goal Contract must satisfy three gates. Full definitions live in `.claude/skills/spec-to-goal/SKILL.md`. Summary:

- **Trackability** — Goal ID, current/target state, success + acceptance criteria, validation plan, measurement source/proxy, implementation boundary. Unknown metric → label assumption/proxy; never invent baselines.
- **Reality** — current-state evidence from repo files / docs / tests / logs / issues / API inspection / explicit user context. Dependency status ∈ `READY | UNKNOWN | BLOCKED | NOT_NEEDED`. If unverifiable → `NEEDS_DATA | BLOCKED | TOO_BROAD | DREAM | PROTOTYPE_ONLY`, not `VALIDATED`.
- **Intent-alignment** — interpreted human intent, assumptions, non-goals, implementation boundary, anti-hallucination checks.

The agent must not: invent goals beyond stated intent, turn speculation into facts, add features outside the boundary, ignore non-goals, or proceed from unlabeled assumptions.

## Implementation rules

- Keep scope minimal. Map every material change to an acceptance criterion.
- **Fix the cause, not the symptom — no careless or band-aid fixes.** Address the actual problem at the right altitude, not just the single input that triggered it. Banned: hardcoding or special-casing to make one case pass, a regex/heuristic that only fits the example and doesn't generalize, papering over a symptom while the cause remains, or faking a result to turn a check green. A narrow fix is acceptable ONLY if it is genuinely correct for the general case, or it is an honest `gdd-defer`-marked simplification (ceiling + upgrade trigger) — never a disguised one.
- Mark every deliberate simplification taken inside the boundary with a `gdd-defer` comment that names its ceiling and upgrade trigger — `<lead> gdd-defer[(<goal-id>)]: <ceiling> ; <upgrade trigger>` — referencing the owning goal id. Harvest them any time into a ledger with the `goal-debt` skill; unmarked shortcuts become invisible debt.
- Do not expand non-goals or create new product goals during implementation.
- Behavior change → use the `test-driven-development` skill: write the failing test first, then the code. The contract's `Verification command` is that test (see validation reality below).
- Run relevant validation before the final response; clearly report any check that could not be run.
- For a high-risk or ≥2-layer goal, the `Verification command` passing is necessary but not sufficient: run the `goal-review` skill to adversarially audit the diff against every acceptance criterion (and for non-goal scope creep + unmarked shortcuts) before declaring done. This is the independent re-check the Evidence & honesty rule requires.
- After a goal ships, run `goal-retro` to score the contract's assumptions against reality and carry durable learnings into the next goal.
- If repo reality conflicts with the Goal Contract, STOP and propose a contract revision instead of expanding scope.

## Validation reality (FILL PER PROJECT)

<!-- ►►► REQUIRED: replace this block with THIS repo's real, verified commands. ◄◄◄
     The point of GDD is to never invent validation. List only commands that exist here.
     Detect them from: package.json scripts / pyproject.toml / pytest.ini / Makefile /
     justfile / .github/workflows / test directories. Example shape: -->

| Check | Command | Notes |
|---|---|---|
| Unit tests | `<e.g. npm test / pytest -q>` | <offline? infra needed?> |
| Lint / typecheck | `<e.g. npm run lint / ruff check / mypy>` | |
| Build | `<e.g. npm run build / cargo build>` | |
| Perf / bench (if any) | `<command>` | metric: `<what it proves>` |
| e2e / manual | `<how to run the app + what to click/curl>` | ports, services |

Rule for contracts: cite the relevant command(s) above in every validation plan, name the metric for performance goals, and **never claim a check passed if it was not run** — report skipped checks explicitly.

## Artifact locations

- Goal Contracts: `docs/goals/*.goal.md`
- Progress logs: `docs/goals/*.progress.md`
- Implementation reports: in the final response, or `docs/goals/*.implementation.md` when useful.
