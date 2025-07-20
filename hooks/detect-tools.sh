#!/bin/sh
# Claude Code Flow - Adaptive Tool Detection (v0.1)
#
# This script safely detects the best available tools on the system
# and exports their commands and capabilities as environment variables.
# It is designed to be sourced by other hook scripts.

# --- Initialization ---
# Ensures a clean slate for every run to prevent environment pollution.
unset_vars() {
    unset GREP_CMD CAT_CMD FIND_CMD SED_CMD AWK_CMD JSON_CMD DIFF_CMD
    unset SED_MODERN AWK_MODERN JSON_AVAILABLE DETECTED_TOOLS
}
unset_vars

# --- Debug Logging ---
# Uses a temporary file to avoid polluting stdout, which is critical for hooks.
LOG_FILE="/tmp/ccf_log_$$"
log() {
    if [ "${CCF_DEBUG:-false}" = "true" ]; then
        timestamp=$(date +"%Y-%m-%d %T")
        printf "[%s] detect-tools: %s\n" "$timestamp" "$1" >> "$LOG_FILE"
    fi
}

log "Starting tool detection..."

# --- Tool Definitions (Declarative & Extensible) ---
# To add a new tool, simply add a new line to this definition block.
# Format: "ToolName:ENV_VAR_PREFIX:ModernFlag:BinaryName"
TOOL_DEFINITIONS="
jq:JSON:JSON_AVAILABLE:jq
ripgrep:GREP::rg
fd-find:FIND::fd
bat:CAT::bat
sd:SED:SED_MODERN:sd
miller:AWK:AWK_MODERN:mlr
delta:DIFF::delta
"

# --- Core Detection Logic ---
# Generic function to process each tool definition.
detect_tool() {
    local tool_name="$1"
    local var_prefix="$2"
    local modern_flag="$3"
    local binary_name="$4"

    local executable_path
    executable_path=$(command -v "$binary_name" 2>/dev/null)

    if [ -n "$executable_path" ]; then
        # Modern tool found
        eval export "${var_prefix}_CMD"="'$executable_path'"
        [ -n "$modern_flag" ] && eval export "$modern_flag"="'true'"
        DETECTED_TOOLS="${DETECTED_TOOLS} $binary_name"
        log "$tool_name ($binary_name) found at $executable_path. Activating enhanced mode."
    else
        # Fallback to default POSIX tool
        local default_cmd
        default_cmd=$(echo "$var_prefix" | tr '[:upper:]' '[:lower:]')
        eval export "'${var_prefix}_CMD'='$default_cmd'"
        [ -n "$modern_flag" ] && eval export "$modern_flag"="'false'"
        log "$tool_name ($binary_name) not found. Using standard '$default_cmd'."
    fi
}

# --- Main Execution Loop ---
# Iterate over the definitions and detect each tool.
IFS_OLD=$IFS
DETECTED_TOOLS=""
IFS='
'
for tool_def in $TOOL_DEFINITIONS; do
    # Skip empty lines from heredoc
    [ -z "$tool_def" ] && continue

    # POSIX-compliant parsing of the definition string
    _name=$(echo "$tool_def" | cut -d: -f1)
    _var=$(echo "$tool_def" | cut -d: -f2)
    _flag=$(echo "$tool_def" | cut -d: -f3)
    _bin=$(echo "$tool_def" | cut -d: -f4)

    detect_tool "$_name" "$_var" "$_flag" "$_bin"
done
IFS=$IFS_OLD


# --- Namespaced Helper Functions ---

# Safely parse JSON from stdin, preferring jq but with a robust shell fallback.
# Usage: local my_var=$(ccf_json_extract ".my.key")
ccf_json_extract() {
    local json_key="$1"
    local stdin_data
    stdin_data=$(cat)

    if [ "${JSON_AVAILABLE:-false}" = "true" ]; then
        printf '%s' "$stdin_data" | "$JSON_CMD" -r "$json_key // empty"
    else
        # Fallback for simple key-value pairs. Highly limited.
        # Example key: "tool_input.file_path"
        local grep_key
        grep_key=$(echo "$json_key" | sed 's/.*\.\([^.]*\)$/\1/')
        printf '%s' "$stdin_data" | grep -o "\"$grep_key\": *\"[^\"]*\"" | head -n 1 | sed 's/.*: *"//' | sed 's/"$//'
    fi
}

# Safely escape a string for use inside a JSON value.
# Usage: local escaped_text=$(ccf_json_escape "$my_text")
ccf_json_escape() {
    printf '%s' "$1" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/`/\`/g' |
    awk '{printf "%s\\n", $0}' |
    sed -e '$ s/\\n$//' -e ':a;N;$!ba;s/\n/\\n/g'
}

log "Detection complete. Enabled modern tools:${DETECTED_TOOLS}"