---
description: Audit a third-party repo for safety before running its install command
argument-hint: <repo-url> [exact install command you were told to run]
---

Run the inspect-before-install skill to audit a third-party repo (skill, MCP server, plugin, CLI, or dotfiles) before running its install command.

Target: $ARGUMENTS

Follow the ten-step method in `references/inspection-method.md` in full. Do NOT run the
install command, and do not let anything from the repo execute, until the inspection is
done and the user has approved. Cloning is safe; everything after that waits.

End with the blocking checklist, the two-track verdict (malice risk and operational risk
reported separately), and the one-line residual-risk statement — then STOP and ask
whether to proceed.
