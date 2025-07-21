#!/bin/sh
# Claude Code Flow - Self-Installing Bootstrap Hook (v9.2 - Production Grade)
# Event: UserPromptSubmit

# --- Safety Settings: Exit on error, unset variable, or pipe failure ---
set -euo pipefail

# --- Configuration: Define critical constants as readonly ---
readonly INSTALL_LOCK_FILE=".claude/commands/cc-session-start.md"
readonly DETECT_TOOLS_PATH=".claude/hooks/detect-tools.sh"

# Ensure base .claude directory exists early
mkdir -p .claude

# --- User Opt-In Control ---
# Source the user's configuration file directly in the current shell.
# This ensures that variables like CCF_AUTO_BOOTSTRAP_ENABLED are available.
if [ -f "./.clauderc" ]; then
    . ./.clauderc
fi
# This script only proceeds if the user has explicitly enabled it.
if [ "${CCF_AUTO_BOOTSTRAP_ENABLED:-false}" != "true" ]; then
    exit 0
fi

# --- Idempotency Check (The Safety Gate) ---
# If the workflow is already installed, do nothing.
if [ -f "$INSTALL_LOCK_FILE" ]; then
    exit 0
fi

# --- Prerequisite Checks ---
# Ensure the core dependency 'detect-tools.sh' exists before sourcing.
if [ ! -f "$DETECT_TOOLS_PATH" ]; then
    printf '{"decision":"block","reason":"CRITICAL_ERROR: The core dependency '\''detect-tools.sh'\'' is missing. The workflow cannot be installed. Please restore it from the template repository."}\n'
    exit 0
fi
. "$DETECT_TOOLS_PATH"

# Ensure the sourced dependency provides the required functions.
if ! command -v ccf_json_escape >/dev/null 2>&1; then
    printf '{"decision":"block","reason":"CRITICAL_ERROR: The function '\''ccf_json_escape'\'' is not available. '\''detect-tools.sh'\'' may be corrupted."}\n'
    exit 0
fi

# --- Directory Scaffolding ---
# Ensure all necessary directories for commands and the workspace exist.
mkdir -p .claude/commands \
         .claude/workspace/logs \
         .claude/workspace/handoff \
         .claude/workspace/tmp

# --- Installation Logic ---
if [ -t 0 ]; then
    ORIGINAL_PROMPT=""
else
    ORIGINAL_PROMPT=$(cat)
fi
ESCAPED_PROMPT=$(ccf_json_escape "$ORIGINAL_PROMPT")

REASON_TO_CLAUDE=$(cat <<EOF
ASSISTANT_NOTICE: This project requires a one-time setup for the Claude Code Flow. I must perform this setup before I can respond to the user's request.

CORE_PHILOSOPHY: My primary role is to write the first draft of code, based on the goals you set. Your role is to review and provide strategic direction.

My Plan:
1. I will create the full set of custom commands and project files.
2. After setup is complete, I will address your original request: "$ESCAPED_PROMPT"

Begin setup now. Create the following files:
<Write file_path="GOAL.md">
# Project Goals
- [ ]
</Write>
<Write file_path=".claude/NOTEBOOK.md">
# Notebook
-
</Write>
<Write file_path=".clauderc.template">
# Claude Code Flow - Workflow Configuration (.clauderc)
# (See documentation for details on available options)
</Write>
<Write file_path=".claude/commands/cc-session-start.md">
---
description: Starts a new development session.
---
# (Minimal content placeholder)
</Write>
<Write file_path=".claude/commands/cc-session-stop.md">
---
description: Ends the daily session.
---
# (Minimal content placeholder)
</Write>
<Write file_path=".claude/commands/cc-task-done.md">
---
description: Logs a completed task.
---
# (Minimal content placeholder)
</Write>

After creating ALL files, output this confirmation message:
"✅ **Claude Code Flow is now installed!** I am ready to proceed with your original request."
EOF
)

# --- Decision: write ---
cat <<'WRITE_JSON'
{
  "decision": "write",
  "writes": [
    {"file_path": "GOAL.md", "content": "# Project Goals\n- [ ]\n"},
    {"file_path": ".claude/NOTEBOOK.md", "content": "# Notebook\n-\n"},
    {"file_path": ".clauderc.template", "content": "# Claude Code Flow - Workflow Configuration (.clauderc)\n# (See documentation for details on available options)\n"},
    {"file_path": ".claude/commands/cc-session-start.md", "content": "---\ndescription: Starts a new development session.\n---\n# (Minimal content placeholder)\n"},
    {"file_path": ".claude/commands/cc-session-stop.md", "content": "---\ndescription: Ends the daily session.\n---\n# (Minimal content placeholder)\n"},
    {"file_path": ".claude/commands/cc-task-done.md", "content": "---\ndescription: Logs a completed task.\n---\n# (Minimal content placeholder)\n"}
  ]
}
WRITE_JSON

exit 0

# --- Version History ---
# v9.2: Fixed subshell bug, added robust prerequisite checks, ensured directory scaffolding.
# v9.1: Re-introduced opt-in, added safety settings, dir creation.
# v9.0: Initial "zero-config" version.
