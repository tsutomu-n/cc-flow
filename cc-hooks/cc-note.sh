#!/usr/bin/env bash
# cc-note.sh - Generate session hand-off note template
# ---------------------------------------------
# Usage:  cc-hooks/cc-note.sh [--yes]
#   --yes   : non-interactive; overwrite existing file if any
#
# This script creates a Markdown hand-off note under
#   ./.ccflow/NOTE/YYYY-MM-DD-HHMM-handoff.md
# with a pre-formatted template.  It is safe to rerun; if the target file
# already exists it opens the file in $EDITOR unless --yes is given.
# ---------------------------------------------
set -euo pipefail

YES_MODE=false
FULL_MODE=false
for arg in "$@"; do
  case "$arg" in
    --yes) YES_MODE=true ;;
    --full) FULL_MODE=true ;;
  esac
  shift || true
done

# --------------------------------------------------
# Load project configuration (YAML) if present
# --------------------------------------------------
CCFLOW_DIR=".ccflow"
CONFIG_FILE="$CCFLOW_DIR/config"
YQ_BIN="$(command -v yq || true)"

# --------------------------------------------------
# Helper: load YAML config only if yq exists
# --------------------------------------------------
load_config() {
  if [ -n "$YQ_BIN" ] && [ -f "$CONFIG_FILE" ]; then
    MODE=$("$YQ_BIN" e '.note.mode // "summary"' "$CONFIG_FILE" 2>/dev/null) || MODE="$DEFAULT_MODE"
    TEMPLATE_PATH=$("$YQ_BIN" e -r '.note.template // ""' "$CONFIG_FILE" 2>/dev/null) || true
    mapfile -t INCLUDE_SECTIONS < <("$YQ_BIN" e -r '.note.include_sections[]' "$CONFIG_FILE" 2>/dev/null || true)
    mapfile -t EXTRA_SECTIONS < <("$YQ_BIN" e -r '.note.extra_sections[]' "$CONFIG_FILE" 2>/dev/null || true)
    CI_BADGE=$("$YQ_BIN" e -r '.ci.badge_url // ""' "$CONFIG_FILE" 2>/dev/null) || true
  else
    MODE="$DEFAULT_MODE"
  fi
}

load_config
DEFAULT_MODE="summary"
TEMPLATE_PATH=""
INCLUDE_SECTIONS=()
EXTRA_SECTIONS=()
OWNERS=()
CI_BADGE=""

if [[ -f "$CONFIG_FILE" ]]; then
  echo "[cc-note] Using config $CONFIG_FILE" >&2
  if [[ -n "$YQ_BIN" ]]; then
    DEFAULT_MODE="$($YQ_BIN e '.note.default_mode // "summary"' "$CONFIG_FILE" 2>/dev/null)"
    TEMPLATE_PATH="$($YQ_BIN e '.note.template // ""' "$CONFIG_FILE" 2>/dev/null)"
    mapfile -t INCLUDE_SECTIONS < <($YQ_BIN e '.note.include_readme_sections[]' "$CONFIG_FILE" 2>/dev/null || true)
    mapfile -t EXTRA_SECTIONS < <($YQ_BIN e '.note.extra_sections[]' "$CONFIG_FILE" 2>/dev/null || true)
    mapfile -t OWNERS < <($YQ_BIN e '.project.owners[]' "$CONFIG_FILE" 2>/dev/null || true)
    CI_BADGE="$($YQ_BIN e '.ci.badge_url // ""' "$CONFIG_FILE" 2>/dev/null)"
  else
    # minimal parser: key: value at root level
    while IFS=: read -r key val; do
      key=$(echo "$key" | xargs)
      val=$(echo "$val" | xargs)
      case "$key" in
        default_mode) DEFAULT_MODE="$val" ;;
      esac
    done < <(grep -E 'default_mode:' "$CONFIG_FILE" || true)
  fi
fi

if [[ $FULL_MODE == false && $DEFAULT_MODE == "full" ]]; then
  FULL_MODE=true
fi

# Determine timestamp (local time)
TS=$(date +"%Y-%m-%d-%H%M")
NOTE_DIR=".ccflow/NOTE"
FILE="${NOTE_DIR}/${TS}-handoff.md"

mkdir -p "$NOTE_DIR"

if [[ -f "$FILE" && $YES_MODE == false ]]; then
  echo "[cc-note] $FILE already exists. Open in \$EDITOR? [y/N]" >&2
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

cat > "$FILE" <<EOF
# Session Handoff Note - ${TS}

## 🎯 Session Summary
- **Start Time**: <!-- e.g. 2025-07-21 09:00 -->
- **End Time**: <!-- e.g. 2025-07-21 17:30 -->
- **Environment**: <!-- bash 5.1, git 2.40 etc. -->
- **Elapsed Time**: <!-- e.g. 6h 30m -->

## ✅ Completed Work
### [L] Low Complexity Tasks
- 
### [M] Medium Complexity Tasks
- 
### [H] High Complexity Tasks
- 

## 🔄 In-Progress Work
### Current Status
- 
### Technical Decisions
- 
### Issues Found
- 

## 📋 Handoff to Next Session
1. 
2. 

## 🧠 Recommended Next Actions
- 

## 📊 Performance Metrics
- 

## 🗺 Project Milestone
- **Milestone**: <!-- e.g. v1.0 Alpha -->
- **Due Date**: <!-- e.g. 2025-07-31 -->

## 🔀 Branch & Recent Commits
- **Branch**: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(unknown)")
- **Commit**:  $(git log -1 --pretty="%h %s" 2>/dev/null || echo "(unknown)")

## ⭕ Pending Tasks
- [ ] <!-- Priority: Who does what, estimate -->

## 🗂 Project Overview
$(if [[ $FULL_MODE == true ]]; then
  # Extract: README "Background & Purpose" section (from heading to next ---)
  awk '/^## Background & Purpose/{flag=1;next}/^---/{flag=0}flag' README.md | sed 's/^/- /'
fi)

## 📂 Key Directories & Files
$(if [[ $FULL_MODE == true ]]; then
  awk '/^## Directory Layout/{flag=1;next}/^---/{flag=0}flag' README.md
fi)

## 🚀 Quick Start
$(if [[ $FULL_MODE == true ]]; then
  awk '/^## 🚀 Quick Start/{flag=1;next}/^##/{if(flag && NR>1)exit}flag' README.md
fi)

## ➕ Additional Information
$(for sec in "${EXTRA_SECTIONS[@]}"; do
  case "$sec" in
    ci_status)
      if [[ -n "$CI_BADGE" ]]; then
        echo "### CI Status"
        echo "![CI Status]($CI_BADGE)"
        echo
      fi
      ;;
    contacts)
      if [[ ${#OWNERS[@]} -gt 0 ]]; then
        echo "### Contacts"
        for o in "${OWNERS[@]}"; do echo "- $o"; done
        echo
      fi
      ;;
    *)
      # treat as file path if exists
      if [[ -f "$sec" ]]; then
        echo "### $(basename "$sec")"
        cat "$sec"
        echo
      fi
      ;;
  esac
done)

---
*Generated by cc-note.sh (${FULL_MODE:+full})*
EOF

printf "[cc-note] Created %s\n" "$FILE"
