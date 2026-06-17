---
name: test-driven-development
description: Drive a behavior change with a failing test first, then write the code that makes it pass. Use when the user says /test-driven-development, TDD, write a test first, prove the fix, reproduce the bug — or when implementing a Goal Contract acceptance criterion that changes behavior. Generic; uses the project's own test harness.
---

# Test-Driven Development

The **method** skill of GDD. `spec-to-goal` shapes the goal and `goal-implement` enforces its boundary; this skill is *how* a behavior-changing acceptance criterion gets implemented inside that boundary: write the failing test first, then the code. It is generic — it uses whatever test harness the project already has (the commands named in `CLAUDE.md`'s "Validation reality"), and invents none.

## When to Use

- Implementing any new logic or behavior under a Goal Contract
- Fixing any bug (the Prove-It Pattern below)
- Modifying existing behavior, or adding edge-case handling
- Any change that could break existing behavior

**When NOT to use:** pure config, docs, or static-content changes with no behavioral impact. (Same threshold as GDD itself — don't ritualize it.)

## Relationship to the Goal Contract

- A behavior-changing **acceptance criterion** ⇒ its proof is a test. Write that test RED first.
- The contract's **`Verification command`** is the done-gate. The test you write here is what that command runs and what must end green. TDD makes the gate real instead of aspirational.
- If you cannot write the failing test as scoped (the contract's current-state evidence is wrong, or the criterion isn't testable as written), STOP and propose a contract revision — do not widen scope to force green.

## The TDD Cycle

```
    RED                 GREEN                REFACTOR
 Write a test     Write the minimum     Clean up without
 that FAILS  ──→  code to pass it  ──→  changing behavior  ──→  (repeat)
```

1. **RED** — write the test first; confirm it FAILS. A test that passes immediately proves nothing.
2. **GREEN** — smallest change that makes it pass. Don't gold-plate.
3. **REFACTOR** — improve names/structure/dedup with tests green; re-run after each step.

Run the project's test command (from "Validation reality") after each step — the suite, not intuition, says when a step is done.

## The Prove-It Pattern (bug fixes)

When a bug is reported, **do not start by fixing it.** Reproduce it with a test first.

```
Bug report → write a test that reproduces it → test FAILS (bug confirmed)
          → implement the fix → test PASSES → run the full suite (no regressions)
```

A bug fix with no reproduction test is unfinished: nothing stops the bug from coming back.

## The Test Pyramid

Invest effort by level — most tests small and fast, fewer at higher levels:

```
   E2E (~5%)          full user flows, real environment — critical paths only
   Integration (~15%) component / boundary interactions (API, DB, file system)
   Unit (~80%)        pure logic, isolated, milliseconds each
```

Classify by resources too: **small** (no I/O/network/DB — milliseconds), **medium** (localhost, test DB — seconds), **large** (external services — minutes). Most of the suite should be small.

## Writing Good Tests

- **Test state, not interactions.** Assert the *outcome*, not which internal methods were called — interaction tests break on refactor even when behavior is unchanged.
- **DAMP over DRY.** Each test reads like a spec; a little duplication beats a shared helper that hides what is verified.
- **Prefer real > fake > stub > mock.** The more real code a test exercises, the more confidence it gives. Mock only at boundaries that are slow or non-deterministic (network, clock, external APIs). Over-mocking passes while production breaks.
- **Arrange–Act–Assert**, one concept per test, names that read like a specification (`<behavior>_<condition>`).

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| Testing implementation details | Assert inputs→outputs, not internal structure |
| Flaky / order-dependent tests | Deterministic assertions; each test sets up and tears down its own state |
| Mocking everything | real > fake > stub > mock |
| Snapshot abuse | Use sparingly; review every change |
| Skipping/disabling a test to go green | Fix the code, or open a contract revision |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests after it works" | You won't, and after-the-fact tests test implementation, not behavior. |
| "Too simple to test" | The test documents intent; simple code grows complicated. |
| "Tests slow me down" | They slow you now and speed up every later change. |
| "I tested it manually" | Manual testing doesn't persist; tomorrow's change breaks it silently. |
| "Let me run the suite again to be sure" | After a clean run on unchanged code, re-running adds nothing. Run again only after an edit. |

## Red Flags

- Code changed with no corresponding test
- A test that passed on its very first run (may not test what you think)
- "All tests pass" claimed but no test was actually run this session
- A bug fix with no reproduction test
- Tests that assert framework behavior instead of your code

## Verification

After a behavior change:

- [ ] Every new behavior has a test; every bug fix has a reproduction test that failed before the fix
- [ ] The project's test command (from "Validation reality") is green
- [ ] The contract's `Verification command` passes — and it exercises the new behavior
- [ ] No test was skipped or disabled to force a pass
- [ ] A command is re-run only after an intervening edit — not as reassurance

---
*Adapted from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) `skills/test-driven-development` (MIT, © 2025 Addy Osmani). Trimmed and made framework-generic to fit GDD: examples removed, the Goal Contract / Verification-command tie-in added.*
