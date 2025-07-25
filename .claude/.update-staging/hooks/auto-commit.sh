#!/bin/sh
# Claude Code Flow - Robust Auto Commit Hook (v0.1)
# Event: PostToolUse
# Purpose: Safely and intelligently commits file changes made by the AI.

# --- Source Dependencies ---
. "$(dirname "$0")/detect-tools.sh"
if [ -f ".clauderc" ]; then
    . ./.clauderc
fi

# --- Main Logic ---
main() {
    # If this feature is disabled by the user in .clauderc, exit immediately.
    if [ "${CCF_AUTO_COMMIT_ENABLED:-true}" != "true" ]; then
        exit 0
    fi

    local hook_data
    hook_data=$(cat)

    # Safely extract the file path.
    local file_path
    file_path=$(ccf_json_extract ".tool_input.file_path" < "$hook_data")
    [ -z "$file_path" ] && exit 0

    # --- Pre-Commit Safety Checks ---

    # 1. Do not commit files within the temporary workspace.
    case "$file_path" in
        *.claude/workspace/*)
            log "auto-commit: Skipping commit for file in workspace."
            exit 0
            ;;
    esac

    # 2. Ensure we are in a valid Git repository.
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log "auto-commit: Not a git repository. Skipping commit."
        exit 0
    fi
    
    # 3. Avoid committing during messy git states (merge, rebase, etc.).
    if [ -d "$(git rev-parse --git-dir)/rebase-merge" ] || [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
        log "auto-commit: Merge/rebase in progress. Skipping commit."
        exit 0
    fi
    
    # 4. Avoid committing in a detached HEAD state.
    if ! git symbolic-ref -q HEAD >/dev/null; then
        log "auto-commit: Detached HEAD state. Skipping commit."
        exit 0
    fi

    # --- Commit Logic ---

    # Check if there are actual staged or unstaged changes to the specific file.
    # `git diff --quiet` checks unstaged, `git diff --cached --quiet` checks staged.
    if git diff --quiet HEAD -- "$file_path" && git diff --cached --quiet -- "$file_path"; then
        log "auto-commit: No changes detected for $file_path. Skipping commit."
        exit 0
    fi

    # Stage the file to ensure we commit exactly what the AI wrote.
    if ! git add "$file_path"; then
        log "auto-commit: Failed to 'git add' the file $file_path. Aborting commit."
        exit 0
    fi

    # Calculate changed lines from the staged version.
    local lines
    lines=$(git diff --cached --numstat "$file_path" | $AWK_CMD '{s+=$1+$2} END{print s}')

    # Only commit if the change is non-trivial.
    if [ -n "$lines" ] && [ "$lines" -gt 3 ]; then
        local filename
        filename=$(basename "$file_path")
        local commit_message
        commit_message=$(printf "feat: Auto-commit %s (%s lines)\n\nGenerated by Claude Code Flow." "$filename" "$lines")

        # Perform the commit and handle potential errors (e.g., from user's pre-commit hooks).
        if git commit -m "$commit_message" > /dev/null 2>&1; then
            log "auto-commit: Successfully committed $file_path."
        else
            log "auto-commit: 'git commit' failed (user pre-commit hook?). Unstaging file."
            # If commit fails, unstage the file to return to the pre-hook state.
            git reset HEAD -- "$file_path" > /dev/null 2>&1
        fi
    else
        log "auto-commit: Trivial change ($lines lines). Unstaging file."
        # If the change is too small, unstage it to avoid cluttering history.
        git reset HEAD -- "$file_path" > /dev/null 2>&1
    fi
}

main
exit 0