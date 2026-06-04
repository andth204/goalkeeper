#!/usr/bin/env sh
# GDD nudge -- UserPromptSubmit hook (POSIX, for macOS/Linux).
# Reads the prompt JSON on stdin. If it looks like a multi-step/feature request,
# prints a ONE-LINE reminder to consider /spec-to-goal first. Otherwise prints
# nothing. Never blocks: always exit 0.
# Unix shells are UTF-8 native, so Vietnamese is matched with AND without accents.

raw=$(cat)
[ -z "$raw" ] && exit 0

# Extract the prompt field with jq if available; otherwise scan the raw payload.
if command -v jq >/dev/null 2>&1; then
  p=$(printf '%s' "$raw" | jq -r '.prompt // empty' 2>/dev/null)
  [ -z "$p" ] && p=$raw
else
  p=$raw
fi

# Lowercase + trim leading whitespace.
pl=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
pl=$(printf '%s' "$pl" | sed 's/^[[:space:]]*//')

# Skip slash commands and anything already in the GDD flow.
case "$pl" in
  /*) exit 0 ;;
esac
case "$pl" in
  *spec-to-goal*|*goal-implement*|*goal-status*) exit 0 ;;
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
