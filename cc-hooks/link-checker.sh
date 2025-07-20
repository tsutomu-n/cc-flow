#!/bin/sh
# Claude Code Flow - Robust Lint Checker Hook (v0.1)
# Event: PreToolUse
# Purpose: Statically analyzes code content before it's written to disk.

# --- Source Dependencies ---
. "$(dirname "$0")/detect-tools.sh"
if [ -f ".clauderc" ]; then
    . ./.clauderc
fi

# --- Main Logic ---
main() {
    # If this feature is disabled by the user in .clauderc, exit immediately.
    if [ "${CCF_LINT_CHECKER_ENABLED:-true}" != "true" ]; then
        exit 0
    fi

    local hook_data
    hook_data=$(cat)

    # This hook's reliability depends heavily on jq for safely parsing multiline content.
    if [ "${JSON_AVAILABLE:-false}" != "true" ]; then
        log "lint-checker: jq not found, skipping lint check to avoid errors with complex content."
        exit 0
    fi

    # Safely extract file_path and content using jq.
    local file_path content
    file_path=$(printf '%s' "$hook_data" | "$JSON_CMD" -r '.tool_input.file_path // empty')
    content=$(printf '%s' "$hook_data" | "$JSON_CMD" -r '.tool_input.content // empty')

    # If file_path or content is empty, there is nothing to lint.
    if [ -z "$file_path" ] || [ -z "$content" ]; then
        exit 0
    fi

    # Determine the linter command based on the file extension.
    local linter_cmd linter_name
    case "$file_path" in
        *.py)
            linter_name="ruff"
            linter_cmd="ruff check --stdin-filename $file_path -"
            ;;
        *.js|*.ts|*.tsx)
            linter_name="eslint"
            linter_cmd="eslint --stdin --stdin-filename $file_path"
            ;;
        *.sh)
            linter_name="shellcheck"
            linter_cmd="shellcheck -"
            ;;
        *)
            # No linter configured for this file type.
            exit 0
            ;;
    esac

    # Check if the linter executable is available.
    if ! command -v "$linter_name" >/dev/null 2>&1; then
        local reason
        reason="ASSISTANT_NOTICE: The linter '$linter_name' for '$file_path' is not installed. Code quality cannot be automatically verified. I will proceed with the file write, but please advise the user to install it for better code reliability."
        # This is a non-blocking warning sent to the AI's context.
        printf '{"reason":"%s"}\n' "$(ccf_json_escape "$reason")"
        exit 0
    fi

    # Run the linter, passing the code content via stdin.
    local lint_errors
    lint_errors=$(printf '%s' "$content" | $linter_cmd 2>&1)
    
    # If the linter returns a non-zero exit code (found issues), block the write.
    if [ $? -ne 0 ]; then
        local reason
        # Instruct the AI that it MUST fix the issues before proceeding.
        reason=$(printf "QUALITY_GATE: My code for '%s' did not pass the %s check. I MUST fix the following issues before writing the file:\n\n---\n%s\n---" \
            "$file_path" "$linter_name" "$lint_errors")
        
        # Feedback the errors to Claude, blocking the tool use.
        printf '{"decision":"block","reason":"%s"}\n' "$(ccf_json_escape "$reason")"
        exit 0
    fi
}

main
exit 0