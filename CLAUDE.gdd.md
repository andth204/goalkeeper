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

## When GDD applies (activation threshold)

GDD is for shaping ambiguous or multi-layer work — NOT every edit. Use judgment:

| Situation | Use GDD? |
|---|---|
| Vague / open-ended request ("improve X", "add a new kind of Y") | YES — `/spec-to-goal` first |
| Touches ≥2 layers or ≥3 files | YES |
| Performance/quality goal needing a measured target (latency, hit rate, accuracy) | YES |
| Single-file, obvious, ≤~20 lines (fix typo, tweak config, rename) | NO — just do it |
| Pure question / explanation / read-only investigation | NO |

When in doubt on a borderline case, ask the user "GDD contract first, or just edit?" instead of forcing either path.

## Default workflow

For work that crosses the threshold above, do NOT implement the raw request directly.

First convert it into a validated Goal Contract using the `spec-to-goal` skill. Treat messages starting with `/spec-to-goal` as a request to use that skill.

Only implement after a Goal Contract exists and its status is `VALIDATED`. Implement via the `goal-implement` skill. Check overall portfolio status anytime with the `goal-status` skill.

```txt
/spec-to-goal <raw requirement or referenced spec>
/goal-implement docs/goals/<goal-id>.goal.md
```

`goal-implement` is the implementation runtime that executes Goal Contracts. Do not invent a separate implementation mechanism for Goal Contracts.

## Goal Quality Gate

Before implementation, the Goal Contract must satisfy three gates. Full definitions live in `.claude/skills/spec-to-goal/SKILL.md`. Summary:

- **Trackability** — Goal ID, current/target state, success + acceptance criteria, validation plan, measurement source/proxy, implementation boundary. Unknown metric → label assumption/proxy; never invent baselines.
- **Reality** — current-state evidence from repo files / docs / tests / logs / issues / API inspection / explicit user context. Dependency status ∈ `READY | UNKNOWN | BLOCKED | NOT_NEEDED`. If unverifiable → `NEEDS_DATA | BLOCKED | TOO_BROAD | DREAM | PROTOTYPE_ONLY`, not `VALIDATED`.
- **Intent-alignment** — interpreted human intent, assumptions, non-goals, implementation boundary, anti-hallucination checks.

The agent must not: invent goals beyond stated intent, turn speculation into facts, add features outside the boundary, ignore non-goals, or proceed from unlabeled assumptions.

## Implementation rules

- Keep scope minimal. Map every material change to an acceptance criterion.
- Do not expand non-goals or create new product goals during implementation.
- Add/update tests when behavior changes (see validation reality below).
- Run relevant validation before the final response; clearly report any check that could not be run.
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
