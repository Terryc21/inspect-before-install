#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="inspect-before-install"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
COMMAND_FILE="$HOME/.claude/commands/$SKILL_NAME.md"

# Handles both layouts: a real dir of symlinks (install.sh), or the whole clone
# symlinked in by hand. Note the missing trailing slash on "$SKILL_DIR" — that is
# load-bearing. `rm -rf symlink` unlinks the symlink; `rm -rf symlink/` would
# delete the *contents* of the clone it points at.
if [ -d "$SKILL_DIR" ] || [ -L "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Uninstalled: $SKILL_DIR"
else
  echo "Not installed (nothing found at: $SKILL_DIR)"
fi

if [ -e "$COMMAND_FILE" ] || [ -L "$COMMAND_FILE" ]; then
  rm -f "$COMMAND_FILE"
  echo "Removed: $COMMAND_FILE"
fi
