#!/usr/bin/env bash
# protect.sh — block writes to critical files
set -euo pipefail

readonly BLOCKED=(".env" "CLAUDE.md" "GOAL.md")

for file in "$@"; do
  for b in "${BLOCKED[@]}"; do
    if [[ "$file" == *"$b"* ]]; then
      echo "::error::cc-flow protect: write blocked to $b" >&2
      exit 1
    fi
  done
done

exit 0
