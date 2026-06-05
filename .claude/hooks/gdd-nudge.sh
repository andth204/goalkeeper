#!/usr/bin/env sh
# GDD nudge -- UserPromptSubmit hook (POSIX, for macOS/Linux).
# Reads the prompt JSON on stdin. If it looks like a multi-step/feature request,
# prints a ONE-LINE reminder to consider /spec-to-goal first. Otherwise prints
# nothing. Never blocks: always exit 0.
# Unix shells are UTF-8 native, so Vietnamese is matched with AND without accents.

raw=$(cat)
[ -z "$raw" ] && exit 0

# Extract the prompt field. Prefer jq; without it, pull the JSON "prompt"
# string value with POSIX sed so the question/keyword checks below see the
# prompt TEXT, not the surrounding JSON (a raw payload ends in '}', which
# silently defeats the trailing-'?' and leading-question-word guards and
# breaks parity with the PowerShell hook on jq-less hosts).
if command -v jq >/dev/null 2>&1; then
  p=$(printf '%s' "$raw" | jq -r '.prompt // empty' 2>/dev/null)
  [ -z "$p" ] && p=$raw
else
  # Best-effort, POSIX-only (no GNU \| alternation): take text after the
  # first "prompt":" up to the next quote. Falls back to the raw payload.
  p=$(printf '%s' "$raw" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"//p' | sed 's/".*//')
  [ -z "$p" ] && p=$raw
fi

# Lowercase + trim leading and trailing whitespace (trailing trim mirrors the
# PowerShell hook's TrimEnd so a trailing-'?' after spaces is still caught).
pl=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
pl=$(printf '%s' "$pl" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

# Skip slash commands and anything already in the GDD flow.
case "$pl" in
  /*) exit 0 ;;
esac
case "$pl" in
  *spec-to-goal*|*goal-implement*|*goal-status*) exit 0 ;;
esac

# Skip questions / explanations: GDD nudges REQUESTS to build, not questions
# about the codebase. A trailing '?' or a question-word lead = not a build task.
case "$pl" in
  *[?]) exit 0 ;;
esac
case "$pl" in
  what*|how*|why*|which*|where*|when*|who*|explain*) exit 0 ;;
  "tai sao"*|"vi sao"*|"the nao"*|"nhu the nao"*|"co phai"*|"giai thich"*) exit 0 ;;
  "tại sao"*|"vì sao"*|"thế nào"*|"như thế nào"*|"có phải"*|"giải thích"*) exit 0 ;;
esac

# Feature / multi-step intent keywords (VN with + without accents, EN).
for k in \
  "them tinh nang" "tinh nang moi" "them chuc nang" "chuc nang moi" \
  "cai thien" "cai tien" "toi uu" "nang cap" \
  "thêm tính năng" "tính năng mới" "thêm chức năng" "chức năng mới" \
  "cải thiện" "cải tiến" "tối ưu" "nâng cấp" \
  "refactor" "implement" "build feature" "add feature" "xay dung" "xây dựng"
do
  case "$pl" in
    *"$k"*)
      printf '%s\n' "[GDD] Yeu cau co ve da-buoc. Can nhac /spec-to-goal truoc khi code (xem CLAUDE.md - nguong kich hoat). Bo qua neu la sua nho."
      exit 0
      ;;
  esac
done
exit 0
