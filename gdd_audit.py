#!/usr/bin/env python
"""GDD retrospective compliance audit.

Deterministically scores GDD-in-practice from a goals directory: for every
`*.goal.md` it reports verification coverage, trail completeness, and whether a
validation was actually recorded. It measures COMPLIANCE (was GDD followed?),
NOT EFFICACY (is GDD better than not using it?) — efficacy needs a no-GDD
counterfactual that does not exist and is deliberately out of scope.

Usage:
    python gdd_audit.py [GOALS_DIR=docs/goals] [--check]

--check: exit non-zero if zero contracts are found or any contract is
unparseable (missing `## Status`); otherwise exit 0. Without --check it always
exits 0 after printing the scorecard. Output is deterministic (sorted, no
clock/random), so two runs on an unchanged corpus are byte-identical.
"""
import re
import sys
from pathlib import Path

SECTION_RE = re.compile(r"^##\s+(.*)$")
COMMENT_OPEN, COMMENT_CLOSE = "<!--", "-->"


def sections(text):
    """Split a contract into {header: body_text} by `## ` headings."""
    out, cur, buf = {}, None, []
    for line in text.splitlines():
        m = SECTION_RE.match(line)
        if m:
            if cur is not None:
                out[cur] = "\n".join(buf).strip()
            cur, buf = m.group(1).strip(), []
        elif cur is not None:
            buf.append(line)
    if cur is not None:
        out[cur] = "\n".join(buf).strip()
    return out


def clean(body):
    """Drop ``` fences and <!-- --> comments; return meaningful lines."""
    lines, in_comment = [], False
    for raw in body.splitlines():
        s = raw.strip()
        if in_comment:
            if COMMENT_CLOSE in s:
                in_comment = False
            continue
        if s.startswith(COMMENT_OPEN):
            if COMMENT_CLOSE not in s:
                in_comment = True
            continue
        if s.startswith("```") or not s:
            continue
        lines.append(s)
    return lines


def classify_verification(secs):
    if "Verification command" not in secs:
        return "missing"
    lines = clean(secs["Verification command"])
    if not lines:
        return "missing"
    return "manual" if lines[0].lower().startswith("manual:") else "command"


def first_value(secs, header):
    lines = clean(secs.get(header, ""))
    return lines[0] if lines else ""


def audit(goals_dir):
    gdir = Path(goals_dir)
    goals = sorted(gdir.glob("*.goal.md"))
    rows, errors = [], []
    for gf in goals:
        gid = gf.name[: -len(".goal.md")]
        secs = sections(gf.read_text(encoding="utf-8"))
        if "Status" not in secs:
            errors.append(f"{gf.name}: missing '## Status' (unparseable)")
        status = first_value(secs, "Status").split()[0] if secs.get("Status") else "?"
        prog = gdir / f"{gid}.progress.md"
        impl = gdir / f"{gid}.implementation.md"
        # gdd-defer(2026-06-22-gdd-roi-retrospective-audit): validation_run is a PROXY
        # — presence of a "Validation run:"/"Verification command" line, not proof it
        # passed ; upgrade by parsing PASS/FAIL/exit-code to measure real pass-rate.
        validation_run = False
        if prog.exists():
            ptext = prog.read_text(encoding="utf-8")
            validation_run = ("Validation run:" in ptext) or ("Verification command" in ptext)
        rows.append({
            "id": gid, "status": status,
            "verification": classify_verification(secs),
            "progress": prog.exists(), "impl": impl.exists(),
            "validation_run": validation_run,
        })
    return rows, errors


def yn(b):
    return "yes" if b else "no"


def pct(n, d):
    return f"{(100 * n // d) if d else 0}%"


def render(rows, errors, goals_dir):
    n = len(rows)
    out = [f"# GDD compliance scorecard - `{goals_dir}`", ""]
    out.append("> Measures COMPLIANCE (was GDD followed?). **NOT measured: causal efficacy**")
    out.append("> (does GDD beat *not* using it?) - that needs a no-GDD baseline that does not")
    out.append("> exist; deferred to a separate PROTOTYPE goal. No quality/efficacy claim is made here.")
    out.append("")
    out.append("| Goal ID | Status | Verification | Progress | Impl report | Validation run (proxy) |")
    out.append("|---|---|---|---|---|---|")
    for r in rows:
        out.append(f"| {r['id']} | {r['status']} | {r['verification']} | "
                   f"{yn(r['progress'])} | {yn(r['impl'])} | {yn(r['validation_run'])} |")
    out.append("")
    cmd = sum(r["verification"] == "command" for r in rows)
    man = sum(r["verification"] == "manual" for r in rows)
    miss = sum(r["verification"] == "missing" for r in rows)
    prog = sum(r["progress"] for r in rows)
    impl = sum(r["impl"] for r in rows)
    vrun = sum(r["validation_run"] for r in rows)
    out.append("## Summary")
    out.append(f"- Contracts: **{n}**")
    out.append(f"- Verification command: {cmd} command, {man} manual, **{miss} missing** "
               f"({pct(cmd + man, n)} have one)")
    out.append(f"- Progress log: {prog}/{n} ({pct(prog, n)})")
    out.append(f"- Implementation report: {impl}/{n} ({pct(impl, n)})")
    out.append(f"- Validation actually recorded (proxy): {vrun}/{n} ({pct(vrun, n)})")
    flagged = [r["id"] for r in rows if r["verification"] == "missing"]
    if flagged:
        out.append(f"- WARNING - missing a Verification command: {', '.join(flagged)}")
    novr = [r["id"] for r in rows if not r["validation_run"]]
    if novr:
        out.append(f"- WARNING - no recorded validation run: {', '.join(novr)}")
    if errors:
        out.append("")
        out.append("## Parse errors")
        out.extend(f"- {e}" for e in errors)
    return "\n".join(out)


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    check = "--check" in argv
    goals_dir = args[0] if args else "docs/goals"
    rows, errors = audit(goals_dir)
    print(render(rows, errors, goals_dir))
    if check and (not rows or errors):
        print(f"\nCHECK FAILED: {len(rows)} contracts, {len(errors)} parse errors", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
