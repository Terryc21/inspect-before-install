#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="inspect-before-install"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
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

echo "Installed: $SKILL_DIR/SKILL.md -> $REPO_DIR/SKILL.md"
echo "Installed: $SKILL_DIR/references -> $REPO_DIR/references"
echo "Keep this clone in place — the skill reads from it via symlink."
echo "Restart Claude Code to pick up the new skill."
echo "Usage: /inspect-before-install <repo-url>"
