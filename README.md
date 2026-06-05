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

```txt
Vague requirement
   │  /spec-to-goal        ◄── PHASE 1: SHAPING (no code)
   ▼
Goal Contract (.goal.md) → 3 gates: Trackable · Realistic · Aligned
   │  status == VALIDATED?  (if not: stop, report what's missing)
   ▼  /goal-implement      ◄── PHASE 2: IMPLEMENTATION (code now)
Code within the boundary + progress log + run the real validation plan
```

Three skills map to three slash commands:

| Command | Skill | Role |
| --- | --- | --- |
| `/spec-to-goal <requirement>` | `spec-to-goal` | Shape a raw request into a Goal Contract. Does **not** write code. |
| `/goal-implement docs/goals/<id>.goal.md` | `goal-implement` | Execute a `VALIDATED` contract; keeps a progress log; runs validation. |
| `/goal-status` | `goal-status` | List every contract and its status. |

A contract carries one of six statuses: `VALIDATED` (ready) · `NEEDS_DATA` · `BLOCKED` · `TOO_BROAD` · `DREAM` · `PROTOTYPE_ONLY`. Only `VALIDATED` may be implemented.

---

## What's inside

```txt
goalkeeper/
├── README.md            # this file
├── LICENSE              # MIT
├── CLAUDE.gdd.md        # generic GDD rules — paste into the target repo's CLAUDE.md
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
        └── goal-status/       # portfolio overview
            └── SKILL.md
```

Everything is **generic** — no project-specific commands or paths are baked in. The only thing you fill in per repo is one section of `CLAUDE.gdd.md`.

---

## Install (3 steps)

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

Restart Claude Code, type `/`, and confirm `spec-to-goal`, `goal-implement`, and `goal-status` appear. (Project skills load at session start.)

To disable the nudge entirely, remove the `UserPromptSubmit` block from `settings.json`.

---

## The nudge hook

On each prompt, if it looks like a multi-step / feature request (keywords in English + Vietnamese, accent-insensitive: `add feature`, `refactor`, `implement`, `cải thiện`, `tối ưu`, …), the hook prints a single-line reminder to consider `/spec-to-goal` first. No match → prints nothing (≈0 tokens). It skips `/…` slash commands, always exits 0, and never blocks a prompt.

To cut false positives, it also stays silent on **questions and explanations** — a prompt ending in `?` or starting with a question word (`what`, `how`, `why`, `tại sao`, `giải thích`, …). GDD nudges requests to *build*, not questions *about* the codebase (e.g. "is the cache optimized?" or "explain how X works" no longer trigger it).

> The `.ps1` variant forces UTF-8 stdin because Windows PowerShell 5.1 otherwise mis-decodes accented input. The `.sh` variant needs no such workaround. To change the trigger words, edit the `$kw` array (ps1) or the `for k in` list (sh).

---

## When NOT to use GDD

Be honest, so it doesn't become bureaucracy:

- Small 1–2 line edits → writing a contract is pure overhead. Just edit.
- Solo work with a scope you already hold in your head → the "align human ↔ agent" value drops.
- Risk of paperwork sprawl: piles of unread `.goal.md` files → use `/goal-status` to review and prune.

GDD is a tool for **ambiguous / multi-layer** work, not a ritual for every commit. The activation threshold lives in `CLAUDE.gdd.md`.

---

## License

MIT — see [LICENSE](LICENSE).
