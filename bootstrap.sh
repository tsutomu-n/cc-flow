#!/usr/bin/env bash
# Claude Code Flow - Manual Bootstrap Script
# This script sets up symlinks so that Claude Code can discover hooks and commands.
# Usage: ./bootstrap.sh    (run once after cloning)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$ROOT_DIR/.claude"

# Create expected Claude directories
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/hooks"

link_if_missing() {
  local src=$1 dst=$2
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    return
  fi
  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

# Symlink all command markdown files
for cmd in "$ROOT_DIR"/cc-commands/*; do
  [ -e "$cmd" ] || continue
  dst="$CLAUDE_DIR/commands/$(basename "$cmd")"
  link_if_missing "$cmd" "$dst"
done

# Symlink hooks directory as a whole
link_if_missing "$ROOT_DIR/cc-hooks" "$CLAUDE_DIR/hooks"

# Copy .clauderc.template if not present
if [ ! -f "$ROOT_DIR/.clauderc.template" ]; then
  cat > "$ROOT_DIR/.clauderc.template" <<'TEMPLATE'
# Claude Code Flow - Workflow Configuration (.clauderc)
# Uncomment to override defaults. Rename to .clauderc to activate.

# Enable the auto-commit hook.
# CCF_AUTO_COMMIT_ENABLED="true"

# Enable the pre-write lint checker.
# CCF_LINT_CHECKER_ENABLED="true"

# Enable protection for critical files.
# CCF_PROTECT_RULES_ENABLED="true"

# --- INSTALLATION ---
# Enable automatic bootstrapping on the first prompt in a new project.
# If set to "true", you can skip running ./bootstrap.sh manually.
# CCF_AUTO_BOOTSTRAP_ENABLED="false"

# Enable detailed debug logging.
# CCF_DEBUG="false"
TEMPLATE
  echo "Generated .clauderc.template"
fi

echo "Bootstrap complete. You may now rename .clauderc.template to .clauderc and edit as needed."
