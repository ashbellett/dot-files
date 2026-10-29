#!/usr/bin/env bash
#
# Claude Code status line: "<model> | <directory> | <git branch>"
# Claude passes session info as JSON on stdin.

input="$(cat)"
model="$(jq -r '.model.display_name // "Claude"' <<<"$input")"
dir="$(jq -r '.workspace.current_dir // .cwd // "."' <<<"$input")"

line="$model | ${dir/#$HOME/~}"

if branch="$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)"; then
  line+=" | $branch"
fi

printf '%s\n' "$line"
