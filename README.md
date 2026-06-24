# goalkeeper

**Goal-Driven Development for Claude Code** — a portable control layer that turns vague requirements into validated *Goal Contracts* before Claude writes production code.

A one-line summary: a checkpoint between *"vague request"* and *"writing code"* — it forces the agent to make a goal **trackable, realistic, and intent-aligned** before touching the codebase.

---

## Why this exists

Autonomous agents are useful, but raw feature requests are usually too ambiguous to implement safely. This kit enforces three checks before implementation:

1. **Trackability.** Every goal has an ID, current state, target state, success criteria, acceptance criteria, a validation plan, and an implementation boundary.
2. **Reality.** Every goal is checked against the actual repo, dependencies, constraints, and available evidence — no invented baselines, no assumed-ready dependencies.
3. **Intent alignment.** The Goal Contract keeps implementation inside the human-approved boundary instead of letting the agent invent scope.

> **A feature request is not a goal.** A goal is an outcome with a current-state baseline, constraints, dependencies, success criteria, a validation method, and an implementation boundary.

---

## Workflow

The full **Tier-2** path (smaller work uses fewer phases — see the tiers below):

```txt
Vague requirement
   │  /spec-to-goal        ◄── PHASE 1: SHAPING (no code)
   ▼
Goal Contract (.goal.md) → 3 gates: Trackable · Realistic · Aligned
   │  status == VALIDATED?  (if not: stop, report what's missing)
   ▼  /goal-implement      ◄── PHASE 2: IMPLEMENTATION (code now)
Code within the boundary + progress log + the real validation plan
   │  /goal-review         ◄── PHASE 3: ADVERSARIAL AUDIT — refute "it's done"
   ▼
SHIP / DO NOT SHIP
   │  /goal-retro          ◄── PHASE 4: REFLECT — score assumptions, harvest learnings
   ▼
Next goal starts smarter
```

### Three tiers — the discipline is constant, the paperwork scales

Not every change deserves a contract. Pick a tier; the Evidence & honesty rule applies to all three:

| Tier | Situation | Command |
| --- | --- | --- |
| **0 — Raw** | 1–2 line edit, typo, rename, config; pure question / read-only | *just do it* |
| **1 — Lite** | a real change, but small & single-concern (≈≤1 file, one layer) | `/goal-lite` — 4-line inline mini-contract, no file |
| **2 — Full** | vague / ≥2 layers / ≥3 files / needs a measured target | `/spec-to-goal` → `/goal-implement` |

The slash commands:

| Command | Skill | Role |
| --- | --- | --- |
| `/spec-to-goal <requirement>` | `spec-to-goal` | Shape a raw request into a Goal Contract. Does **not** write code. |
| `/goal-implement docs/goals/<id>.goal.md` | `goal-implement` | Execute a `VALIDATED` contract; keeps a progress log; runs validation; gates completion on its verify command. |
| `/goal-lite` | `goal-lite` | **Tier 1.** State a 4-line inline mini-contract (goal · boundary · verification) and implement it under full discipline — no `.goal.md`. Escalates to `/spec-to-goal` if it outgrows Tier 1. |
| `/goal-review docs/goals/<id>.goal.md` | `goal-review` | Adversarially audit the diff against the contract — refute each acceptance criterion, flag non-goal scope creep + unmarked shortcuts, re-run the verify. Read-only; `SHIP`/`DO NOT SHIP`. |
| `/goal-retro docs/goals/<id>.goal.md` | `goal-retro` | After ship: score the contract's assumptions against reality, harvest deferrals/deviations, distil durable learnings. Read-mostly. |
| `/goal-status` | `goal-status` | List every contract and its status. |
| `/goal-debt` | `goal-debt` | Harvest `gdd-defer` deferred-decision markers from the code into a ledger, each linked to its owning contract (or flagged orphan). Read-only. |

Plus a **method skill** invoked *during* implementation, not as a phase of its own:

| Command | Skill | Role |
| --- | --- | --- |
| `/test-driven-development` | `test-driven-development` | When an acceptance criterion changes behavior, write the failing test FIRST, then the code. Ties the test to the contract's `Verification command`. Generic — uses the project's own test harness. |

A contract carries one of six statuses: `VALIDATED` (ready) · `NEEDS_DATA` · `BLOCKED` · `TOO_BROAD` · `DREAM` · `PROTOTYPE_ONLY`. Only `VALIDATED` may be implemented.

---

## What's inside

```txt
goalkeeper/
├── README.md            # this file
├── LICENSE              # MIT
├── CLAUDE.gdd.md        # generic GDD rules — paste into the target repo's CLAUDE.md
├── gdd_audit.py         # retrospective compliance audit - scorecard over a goals dir
├── .gitattributes       # forces the .sh hook to stay LF across OSes
└── .claude/
    ├── settings.json    # registers the nudge hook (Windows default; see Install for unix)
    ├── hooks/
    │   ├── gdd-nudge.ps1  # nudge hook — Windows / PowerShell
    │   └── gdd-nudge.sh   # nudge hook — macOS / Linux
    └── skills/
        ├── spec-to-goal/      # Phase 1: requirement → Goal Contract (3 quality gates)
        │   ├── SKILL.md
        │   └── templates/goal-contract.md
        ├── goal-implement/    # Phase 2: implement a VALIDATED contract
        │   └── SKILL.md
        ├── goal-review/       # Phase 3: adversarial audit of the diff vs the contract
        │   └── SKILL.md
        ├── goal-retro/        # Phase 4: score assumptions vs reality, carry learnings
        │   └── SKILL.md
        ├── goal-lite/         # Tier 1: inline mini-contract, no .goal.md file
        │   └── SKILL.md
        ├── goal-status/       # portfolio overview
        │   └── SKILL.md
        ├── goal-debt/         # harvest gdd-defer markers into a ledger
        │   └── SKILL.md
        └── test-driven-development/  # method: failing test first, tied to the verify command
            └── SKILL.md
```

Everything is **generic** — no project-specific commands or paths are baked in. The only thing you fill in per repo is one section of `CLAUDE.gdd.md`.

---

## Install — per project (3 steps)

(For a personal toolkit across *all* projects, skip to **Global install** below.)

### 1. Copy the kit into your target repo

```bash
cp -r goalkeeper/.claude .          # skills + hooks + settings
cp goalkeeper/CLAUDE.gdd.md .       # the instruction template
```

If the target already has a `.claude/`, merge the `skills/` and `hooks/` folders and the `settings.json` hook block.

### 2. Wire the rules into CLAUDE.md

Copy the contents of `CLAUDE.gdd.md` into your repo's `CLAUDE.md` (create it, or append). Then fill the one required section, `## Validation reality (FILL PER PROJECT)`, with the repo's **real** test / lint / build / bench commands.

> This is the core idea: GDD never invents validation commands. The `spec-to-goal` skill also auto-detects them from `package.json` / `pyproject.toml` / `Makefile` / `.github/workflows` / test dirs — but filling them in once is more precise.

### 3. Configure the hook for your OS

`settings.json` defaults to the PowerShell hook (Windows).

- **Windows** — leave it as is.
- **macOS / Linux** — change the `command` in `.claude/settings.json` to:

  ```json
  "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/gdd-nudge.sh\""
  ```

  then `chmod +x .claude/hooks/gdd-nudge.sh`.

Restart Claude Code, type `/`, and confirm the `goal-*` skills (`spec-to-goal`, `goal-implement`, `goal-lite`, `goal-review`, `goal-retro`, `goal-status`, `goal-debt`) appear. (Project skills load at session start.)

To disable the nudge entirely, remove the `UserPromptSubmit` block from `settings.json`.

---

## Global install — one toolkit for every project

The 3 steps above install GDD into a *single* repo. To make it your **personal default across all projects** without copying it into each one, install at the user level instead. Skills and rules in `~/.claude/` apply to every project Claude Code opens.

1. **Skills + hook → user level.** Symlink (recommended, so `git pull` updates everywhere) or copy this repo's skills into `~/.claude/skills/`:

   ```bash
   git clone https://github.com/andth204/goalkeeper.git ~/goalkeeper
   ln -s ~/goalkeeper/.claude/skills/* ~/.claude/skills/        # macOS / Linux
   ```

   On Windows: `New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills\goalkeeper" -Target "$HOME\goalkeeper\.claude\skills"`. Register the nudge hook in `~/.claude/settings.json` (same block as project `settings.json`, but it applies globally).

2. **Rules → global `CLAUDE.md`.** Paste the contents of `CLAUDE.gdd.md` into `~/.claude/CLAUDE.md` (your user-level instructions for all projects). This makes the three tiers + Evidence & honesty rule the default everywhere.

3. **Validation reality stays per-project.** The one thing that is NOT global: the `## Validation reality` table — each repo has its own real test/build/bench commands. Leave that section in each repo's *own* `CLAUDE.md`. `spec-to-goal` also auto-detects commands from `package.json` / `pyproject.toml` / `Makefile` / CI, so a fresh repo still works before you fill it in.

**Update everywhere at once:** `cd ~/goalkeeper && git pull` — symlinked skills pick up changes on the next session. This is the "one repo, many projects, auto-update" model.

> Trade-off: global skills load in *every* project, including ones where GDD is irrelevant. That's cheap — skills only run when slash-invoked, and the nudge is ≈0 tokens on a no-match. The global `CLAUDE.gdd.md` rules also apply the anti-fabrication discipline to small repos, which is usually what you want.

---

## The nudge hook

On each prompt, if it looks like a multi-step / feature request (keywords in English + Vietnamese, accent-insensitive: `add feature`, `refactor`, `implement`, `cải thiện`, `tối ưu`, …), the hook prints a single-line reminder to consider `/spec-to-goal` first. No match → prints nothing (≈0 tokens). It skips `/…` slash commands, always exits 0, and never blocks a prompt.

To cut false positives, it also stays silent on **questions and explanations** — a prompt ending in `?` or starting with a question word (`what`, `how`, `why`, `tại sao`, `giải thích`, …). GDD nudges requests to *build*, not questions *about* the codebase (e.g. "is the cache optimized?" or "explain how X works" no longer trigger it).

> The `.ps1` variant forces UTF-8 stdin because Windows PowerShell 5.1 otherwise mis-decodes accented input. The `.sh` variant needs no such workaround. To change the trigger words, edit the `$kw` array (ps1) or the `for k in` list (sh).

---

## When NOT to use GDD

Be honest, so it doesn't become bureaucracy:

- Small 1–2 line edits (Tier 0) → writing a contract is pure overhead. Just edit — the Evidence & honesty rule still applies.
- Small but real, scope already in your head (Tier 1) → don't write a `.goal.md`; use `/goal-lite` for an inline mini-contract that keeps the verification gate without the paperwork.
- Risk of paperwork sprawl: piles of unread `.goal.md` files → use `/goal-status` to review and prune.

A **full contract** (Tier 2) is for **ambiguous / multi-layer** work, not a ritual for every commit. The three-tier activation threshold lives in `CLAUDE.gdd.md`.

---

## License

MIT — see [LICENSE](LICENSE).
