#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="inspect-before-install"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
COMMANDS_DIR="$HOME/.claude/commands"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing $SKILL_NAME skill..."

mkdir -p "$SKILL_DIR"

if [ -L "$SKILL_DIR/SKILL.md" ]; then
  rm "$SKILL_DIR/SKILL.md"
fi

if [ -e "$SKILL_DIR/references" ] || [ -L "$SKILL_DIR/references" ]; then
  rm -rf "$SKILL_DIR/references"
fi

ln -s "$REPO_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
ln -s "$REPO_DIR/references" "$SKILL_DIR/references"

# Also register the slash command so /inspect-before-install shows in the prompt picker.
# The skill (above) lets Claude auto-invoke it; the command file makes it explicitly typeable.
mkdir -p "$COMMANDS_DIR"
if [ -e "$COMMANDS_DIR/$SKILL_NAME.md" ] || [ -L "$COMMANDS_DIR/$SKILL_NAME.md" ]; then
  rm -f "$COMMANDS_DIR/$SKILL_NAME.md"
fi
ln -s "$REPO_DIR/commands/$SKILL_NAME.md" "$COMMANDS_DIR/$SKILL_NAME.md"

echo "Installed: $SKILL_DIR/SKILL.md -> $REPO_DIR/SKILL.md"
echo "Installed: $SKILL_DIR/references -> $REPO_DIR/references"
echo "Installed: $COMMANDS_DIR/$SKILL_NAME.md -> $REPO_DIR/commands/$SKILL_NAME.md"
echo "Keep this clone in place — the skill reads from it via symlink."
echo "Restart Claude Code to pick up the new skill and /$SKILL_NAME command."
echo "Usage: /$SKILL_NAME <repo-url>"
