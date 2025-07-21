#!/usr/bin/env bash
# lint.sh — run language-specific linters before commit
set -euo pipefail

run() { echo "→ $*"; "$@"; }

EXIT=0

while read -r file; do
  case "$file" in
    *.py)
      if command -v ruff >/dev/null; then run ruff "$file" || EXIT=1; fi ;;
    *.js|*.ts)
      if command -v eslint >/dev/null; then run eslint "$file" || EXIT=1; fi ;;
    *.sh)
      if command -v shellcheck >/dev/null; then run shellcheck "$file" || EXIT=1; fi ;;
  esac
done < <(git diff --cached --name-only)

exit $EXIT
