# Goal Contract: <goal name>

## Status
<VALIDATED | NEEDS_DATA | BLOCKED | TOO_BROAD | DREAM | PROTOTYPE_ONLY>

## Goal ID
<YYYY-MM-DD-short-slug>

## Raw requirement
<original request>

## Interpreted human intent
<what the user is actually trying to achieve, in plain language>

## Goal
<one outcome-oriented goal statement>

## User / stakeholder
<who benefits and who owns the outcome>

## Current state
<what happens today>

## Current-state evidence
- <code/doc/data/user evidence — cite file:line or command output>

## Target state
<what should be true after implementation>

## Trackability
- Measurement source: <analytics event/log/test/manual QA/bench/proxy>
- Baseline: <known value, unknown, or assumption>
- Target: <target value or observable condition>
- Observation window: <when success can be evaluated>

## Success criteria
- <measurable business/product criterion>
- <measurable user-behavior criterion>
- <measurable technical/quality criterion>

## Acceptance criteria
- <specific behavior that must work>
- <specific edge case>
- <specific regression that must not happen>

## Non-goals
- <explicitly out of scope>

## Dependencies
| Dependency | Status | Evidence | Risk |
|---|---|---|---|
| <dependency> | <READY/UNKNOWN/BLOCKED/NOT_NEEDED> | <evidence or assumption> | <risk> |

## Constraints
- <technical/business/time/security/legal constraint>

## Assumptions
- <assumption and how to verify it>

## Risks and mitigations
- Risk: <risk>
  Mitigation: <mitigation>

## Implementation boundary
<minimal scope that should be implemented>

## Anti-hallucination checks
- Supported facts: <facts grounded in evidence>
- Assumptions: <claims not yet verified>
- Do not implement: <non-goals/scope boundaries>
- Do not assume ready: <unknown or blocked dependencies>

## Validation plan
<!-- Use ONLY the project's REAL commands. Detect them from CLAUDE.md "Validation reality",
     package.json / pyproject.toml / Makefile / CI config / test dirs. Never invent commands. -->
- Pre-implementation checks: <files/data to inspect — cite file:line>
- Implementation checks: <the project's real test / lint / typecheck / build / bench commands + the metric each proves>
- Post-release checks: <logs / analytics / manual QA steps>

## Decision
<why this should proceed, be blocked, be split, or be downgraded>

## Suggested handoff command
```txt
/goal-implement docs/goals/<goal-id>.goal.md
```
