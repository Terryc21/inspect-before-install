#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="inspect-before-install"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
COMMAND_FILE="$HOME/.claude/commands/$SKILL_NAME.md"

if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Uninstalled: $SKILL_DIR"
else
  echo "Not installed (directory not found: $SKILL_DIR)"
fi

if [ -e "$COMMAND_FILE" ] || [ -L "$COMMAND_FILE" ]; then
  rm -f "$COMMAND_FILE"
  echo "Removed: $COMMAND_FILE"
fi
