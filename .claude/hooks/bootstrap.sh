#!/bin/sh
# Claude Code Flow - Self-Installing Bootstrap Hook (v0.1)
# Event: UserPromptSubmit

# --- Configuration ---
# The presence of this file acts as the "installation lock".
# If this file exists, the bootstrap process will not run again.
INSTALL_LOCK_FILE=".claude/commands/cc-session-start.md"

# --- Idempotency Check ---
# If the workflow is already installed, do nothing and exit immediately.
# This ensures the script is safe to run on every prompt.
if [ -f "$INSTALL_LOCK_FILE" ]; then
    exit 0
fi

# --- Source Dependencies ---
# Load helper functions for robust JSON manipulation.
# We need this to safely handle the user's original prompt.
. "$(dirname "$0")/detect-tools.sh"

# --- First-Run Installation Logic ---

# Capture the user's original prompt from stdin.
ORIGINAL_PROMPT=$(cat)
# Safely escape the prompt to prevent JSON injection.
ESCAPED_PROMPT=$(ccf_json_escape "$ORIGINAL_PROMPT")

# This is the meta-prompt that hijacks the first turn. It contains the
# complete set of instructions for the AI to create the entire workflow.
# Using a heredoc (cat <<EOF) is a robust way to handle multiline strings.
REASON_TO_CLAUDE=$(cat <<EOF
ASSISTANT_NOTICE: This project requires a one-time setup for the Claude Code Flow. I must perform this setup before I can respond to the user's request.

My Plan:
1. I will create the full set of custom commands and project files using the 'Write' tool.
2. After the setup is complete, I will immediately address the user's original, postponed request.

Begin setup now. Create the following files with the exact content specified:

<Write file_path="GOAL.md">
# Project Goals & Strategic Roadmap

This file contains the high-level goals for this project. The AI assistant will use this as a guide for its development tasks.

## Key Objectives
- [ ] (P1) **[NEEDS_SPEC]** Define the core feature of the application.
- [ ] (P2) Set up the initial project structure.

## How to Use This File
- **Priorities**: (P1) = Highest, (P2) = Medium, (P3) = Low.
- **Tags**: Use \`[NEEDS_SPEC]\` for tasks that require a formal design process before implementation.
</Write>

<Write file_path=".claude/NOTEBOOK.md">
# Project Notebook

This is a dynamic workspace for daily thoughts, temporary notes, and tactical instructions for the AI assistant.

- Workflow initialized.
</Write>

<Write file_path=".clauderc.template">
# Claude Code Flow - Workflow Configuration (.clauderc)
#
# INSTRUCTIONS:
# 1. To activate, rename this file to ".clauderc".
# 2. Uncomment features and set their values to "true" or "false".

# Enable the auto-commit hook.
# CCF_AUTO_COMMIT_ENABLED="true"

# Enable the pre-write lint checker.
# CCF_LINT_CHECKER_ENABLED="true"

# Enable protection for critical files.
# CCF_PROTECT_RULES_ENABLED="true"

# Enable detailed debug logging.
# CCF_DEBUG="false"
</Write>

<Write file_path=".claude/commands/cc-session-start.md">
---
description: Starts a new development session and restores context.
allowed-tools: Bash(git status *)
---
## Task: Start Session
Based on the context below, summarize the project status and propose a plan for today.

## Context
- **Goals**: @GOAL.md
- **Notebook**: @.claude/NOTEBOOK.md
- **Git Status**: !\`git status --porcelain -b\`
- **Handoff**: @.claude/workspace/handoff/latest.md
</Write>

<Write file_path=".claude/commands/cc-session-stop.md">
---
description: Ends