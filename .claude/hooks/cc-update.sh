#!/usr/bin/env bash
# Claude Code Flow - Self-Updater (cc-update.sh)
# Purpose: Safely update local `.claude` workflow files to the latest/stated version.
# Usage : cc-update.sh [<version>]
# Note   : Must be invoked from project root. Requires `jq`, `git`, and either `curl` or `wget`.

set -euo pipefail

# --- Source dependencies ----------------------------------------------------
DETECTED_TOOLS=""
. "$(dirname "$0")/detect-tools.sh"

JQ=${JQ_CMD:-${JSON_CMD:-${CCF_JQ:-jq}}}
CURL=${CCF_CURL:-curl}
WGET=${CCF_WGET:-wget}

# --- Global flags ------------------------------------------------------------
YES_MODE=false

# ANSI color codes for summary
CLR_GREEN='\033[32m'
CLR_YELLOW='\033[33m'
CLR_RED='\033[31m'
CLR_RESET='\033[0m'

err() { printf "\033[31m[cc-update] %s\033[0m\n" "$1" >&2; }
log() { printf "[cc-update] %s\n" "$1"; }

# ----------------------------------------------------------------------------
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"
SETTINGS_JSON="${CLAUDE_DIR}/settings.json"
STAGING_DIR="${CLAUDE_DIR}/.update-staging"
# Upstream repository (raw and archive base)
UPSTREAM_REPO="https://raw.githubusercontent.com/tsutomu-n/cc-flow/main"
TAR_REPO="https://github.com/tsutomu-n/cc-flow"

# Ensure jq exists
# Helper: extract version even in JSON with comments
extract_version() {
  grep -m1 '"CLAUDE_TEMPLATE_VERSION"' "$SETTINGS_JSON" | \
    sed -E 's/.*"([0-9.]+)".*/\1/'
}

curr_ver=$(extract_version)
latest_ver=""

fetch_latest_version() {
    if [ -n "$latest_ver" ]; then return; fi
    if command -v "$CURL" >/dev/null 2>&1; then
        latest_ver=$("$CURL" -fsSL "${UPSTREAM_REPO}/VERSION" | tr -d '\n' || true)
    elif command -v "$WGET" >/dev/null 2>&1; then
        latest_ver=$("$WGET" -qO- "${UPSTREAM_REPO}/VERSION" | tr -d '\n' || true)
    else
        err "curl or wget required to fetch latest version"; exit 1;
    fi
    [ -z "$latest_ver" ] && { err "Unable to determine latest version"; exit 1; }
}

fetch_upstream_archive() {
    log "Fetching Claude Code Flow ${latest_ver} …"
    mkdir -p "$STAGING_DIR"
    tarball_url="${TAR_REPO}/archive/refs/tags/${latest_ver}.tar.gz"
    if command -v "$CURL" >/dev/null 2>&1; then
        "$CURL" -fsSL "$tarball_url" | tar -xz -C "$STAGING_DIR" --strip-components=1 .claude
    else
        "$WGET" -qO- "$tarball_url" | tar -xz -C "$STAGING_DIR" --strip-components=1 .claude
    fi
}

compare_and_summarise() {
    log "Generating diff summary…"
    summary_file="$STAGING_DIR/summary.txt"
    : > "$summary_file"
    while IFS= read -r -d '' f; do
        rel="${f#$STAGING_DIR/}"
        local_path="$PROJECT_ROOT/$rel"
        if [ ! -f "$local_path" ]; then
            printf "A %s\n" "$rel" >> "$summary_file"
        else
            if git --no-pager diff --quiet -- "$local_path" "$f"; then
                :
            else
                printf "M %s\n" "$rel" >> "$summary_file"
            fi
        fi
    done < <(find "$STAGING_DIR" -type f -print0)

    # Detect deletions
    while IFS= read -r -d '' lf; do
        rel="${lf#$PROJECT_ROOT/}"
        staged_path="$STAGING_DIR/$rel"
        if [ ! -f "$staged_path" ]; then
            printf "D %s\n" "$rel" >> "$summary_file"
        fi
    done < <(find "$CLAUDE_DIR" -type f -print0)

    log "\nChange summary:\n----------------"
    while read -r status path; do
        case "$status" in
            A) printf "${CLR_GREEN}A %s${CLR_RESET}\n" "$path" ;;
            M) printf "${CLR_YELLOW}M %s${CLR_RESET}\n" "$path" ;;
            D) printf "${CLR_RED}D %s${CLR_RESET}\n" "$path" ;;
        esac
    done < "$summary_file"

    if [ "$YES_MODE" = true ]; then
        log "YES mode active — proceeding automatically."
    else
        printf '\nProceed with update? [y/N]: '
        read -r ans
        case "$ans" in
            y|Y) ;;
            *) err "Update aborted by user"; exit 1;;
        esac
    fi
}

apply_update() {
    log "Applying update…"
    export CCF_PROTECT_OVERRIDE=1
    while IFS= read -r -d '' f; do
        rel="${f#$STAGING_DIR/}"
        dest="$PROJECT_ROOT/$rel"
        mkdir -p "$(dirname "$dest")"
        cp "$f" "$dest"
    done < <(find "$STAGING_DIR" -type f -print0)

    # Update version in settings.json
    # inline update CLAUDE_TEMPLATE_VERSION
    sed -i -E 's/"CLAUDE_TEMPLATE_VERSION": *"[0-9.]+"/"CLAUDE_TEMPLATE_VERSION": "'"$latest_ver"'"/' "$SETTINGS_JSON"

    # Stage changes and commit
    git add .claude
    git commit -m "chore(update): bump Claude Code Flow to ${latest_ver}" || true
    unset CCF_PROTECT_OVERRIDE
}

# Wrapper to allow local testing without network fetch
fetch_archive() {
    if [ "${SKIP_FETCH:-false}" = "true" ]; then
        log "SKIP_FETCH enabled — skipping remote archive fetch. Assuming $STAGING_DIR is pre-populated."
        return
    fi
    fetch_upstream_archive
}

main() {
    # --- Parse arguments ----------------------------------------------------
    version_arg=""
    for arg in "$@"; do
        case "$arg" in
            -y|--yes) YES_MODE=true ;;
            *) version_arg="$arg" ;;
        esac
    done
    [ -n "$version_arg" ] && latest_ver=$(printf '%s' "$version_arg" | tr -d '\n\r ')

    # If we're skipping fetch and no version explicitly provided, treat current as target
    if [ "${SKIP_FETCH:-false}" = "true" ] && [ -z "$version_arg" ]; then
        latest_ver="$curr_ver"
    fi

    fetch_latest_version
    [ "$curr_ver" = "$latest_ver" ] && { log "Already on latest version ($curr_ver)."; exit 0; }
    log "Current version: $curr_ver, Target version: $latest_ver"

    fetch_archive
    compare_and_summarise
    apply_update
    log "Update complete!"
}

main "$@"
