---
name: goal-debt
description: Harvest deferred-decision markers (gdd-defer) from the codebase into a ledger, each linked to its owning Goal Contract — so deliberate simplifications stay visible and "later" does not become "never". Read-only. Use when the user says /goal-debt, goal debt, show deferred decisions, list shortcuts, what did we defer, technical-debt ledger, gdd-defer.
---

# Goal Debt Skill

Read-only harvester for the GDD deferred-decision ledger. It scans the codebase for `gdd-defer` markers — deliberate simplifications taken during implementation — and renders them as a ledger, linking each to its owning Goal Contract or flagging it as orphaned scope creep. It does NOT create, edit, resolve, or remove anything.

This is the code-layer companion to the `## Assumptions` that `spec-to-goal` records in a contract: assumptions are tracked when a goal is *shaped*; `gdd-defer` markers track the shortcuts taken while the code is *written*. Together they keep the **Trackability** pillar honest at both layers.

## The marker it harvests

Authored during implementation (see `goal-implement`):

```
<comment-leader> gdd-defer[(<goal-id>)]: <known ceiling / simplification> ; <upgrade path or trigger condition>
```

- `gdd-defer` — the required literal token (the only thing this skill greps on).
- `(<goal-id>)` — OPTIONAL owning goal: a `docs/goals/` slug, e.g. `2026-06-22-cache-warmup`. Absent → the marker is an ORPHAN.
- After `:` — free text; a `;` separates the **ceiling** (what the shortcut is + its known limit) from the **upgrade trigger** (the condition that would require replacing it).

## Behavior

1. Scan with git, never a raw recursive grep:

   ```
   git grep -nI --untracked "gdd-defer" -- ':(exclude)*.md'
   ```

   - `--untracked` so shortcuts in not-yet-committed working-tree code are caught.
   - git respects `.gitignore`, so vendored / ignored trees (`node_modules/`, nested ignored repos) are skipped automatically.
   - `':(exclude)*.md'` drops documentation self-matches (this skill, `CLAUDE.md`, the contracts) so the ledger holds only real code markers.
2. For each hit, parse `file:line`, optional `(<goal-id>)`, ceiling, and upgrade trigger.
3. Resolve the owning goal:
   - has `(<goal-id>)` and `docs/goals/<goal-id>.goal.md` exists → **LINKED** (show the id).
   - has `(<goal-id>)` but the goal file is missing → **BROKEN-LINK** (never silently link).
   - no `(<goal-id>)` → **ORPHAN** (possible silent scope creep).
4. Render one ledger table, then a short summary.

## Output format

```txt
| file:line | Owning goal | Ceiling (simplification) | Upgrade trigger | Status |
|---|---|---|---|---|
| backend/src/cache/plan.py:42 | 2026-06-09-plan-cache-llm-intent | module-level dict, single process | swap to Redis if multi-worker | LINKED |
| backend/src/nav/route.py:88 | — | O(n^2) scan over species | index by name if list > 1k | ORPHAN |
| backend/src/seed.py:7 | 2026-01-01-missing | naive heuristic | replace with model | BROKEN-LINK |
```

Status legend: `LINKED` belongs to an existing goal · `ORPHAN` no owning goal — review for silent scope creep · `BROKEN-LINK` names a goal contract that does not exist.

## Summary

After the table:

- total markers, with a count per status.
- call out every ORPHAN and BROKEN-LINK by `file:line` — these are the ones that rot into "never".
- if zero markers: say the ledger is empty (no deferred decisions recorded) and stop.

## Rules

- Read-only. Do not modify code, markers, or goal files; do not "fix" or delete a shortcut.
- Do not invent a marker's owning goal — read it from `(<goal-id>)` or report ORPHAN.
- Always scan via `git grep` as above; never recurse into ignored trees, never scan `*.md`.
- Keep it to the ledger table + summary. No essay.
- Resolving a deferral is normal implementation work under its owning goal — if it needs a contract, re-run `spec-to-goal` / `goal-implement`. This skill only reports.
