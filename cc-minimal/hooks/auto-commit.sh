#!/usr/bin/env bash
# auto-commit.sh — commit staged changes if meaningful
set -euo pipefail

THRESHOLD=${CCFLOW_COMMIT_THRESHOLD:-2}

LINES_CHANGED=$(git diff --cached --numstat | awk '{sum+=$1+$2} END {print sum}')
if [ -z "$LINES_CHANGED" ]; then LINES_CHANGED=0; fi

if [ "$LINES_CHANGED" -le "$THRESHOLD" ]; then
  echo "auto-commit: change ( $LINES_CHANGED ) below threshold ( $THRESHOLD ), skipping commit."
  exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_MSG="chore(${BRANCH}): auto commit ($LINES_CHANGED lines)"

git commit -m "$COMMIT_MSG"

echo "Auto committed $LINES_CHANGED lines."
