# inspect-before-install

[![License: MIT](https://img.shields.io/github/license/Terryc21/inspect-before-install?color=blue)](LICENSE)
[![Built for Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-D97757)](https://claude.com/claude-code)
[![Type: Skill](https://img.shields.io/badge/type-skill-8b5cf6)](https://docs.claude.com/en/docs/claude-code/skills)
[![GitHub stars](https://img.shields.io/github/stars/Terryc21/inspect-before-install?style=flat)](https://github.com/Terryc21/inspect-before-install/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/Terryc21/inspect-before-install)](https://github.com/Terryc21/inspect-before-install/issues)
[![Last commit](https://img.shields.io/github/last-commit/Terryc21/inspect-before-install)](https://github.com/Terryc21/inspect-before-install/commits/main)

> **TL;DR** — Before you run a stranger's install command, this Claude Code skill clones the repo in isolation, reads every script and agent-instruction file, scans for both hidden malice *and* dangerous-by-design behavior, and hands you a pass/fail checklist plus a plain verdict — then stops and lets you decide. Inspect first, execute second. **[See a real audit it produced →](examples/example-report.md)**

**Read the install script before you run it.** A [Claude Code](https://claude.com/claude-code) skill that audits a third-party repo — a skill, MCP server, plugin, CLI tool, or dotfiles — *before* you run its install command, then stops and reports so you can decide.

Running a stranger's `install.sh` (or `npx … add`, or `curl … | bash`) is a real trust decision, not a formality. A clean-looking installer can hide a second-stage download, a package-manager lifecycle hook, or an agent-instruction file that tells Claude to exfiltrate your data. And a repo with *perfectly clean code* can still be something you shouldn't run casually — because of what it's designed to do when it works (spend money, act on an account, evade a service's bot detection).

This skill enforces one rule: **inspect first, execute second.**

---

## What it does

When you're about to install something from a repo you don't fully trust, this skill:

1. **Clones it in isolation** (a temp dir, `--depth 1`) — nothing runs on a `git clone`.
2. **Records provenance** — the exact commit SHA you're approving, plus repo age / stars / history as a trust signal.
3. **Reconciles the install command against the repo** — if the README says to install via an *external* installer (`npx foo add`, `uvx`, `pip install`, a brew tap) that isn't a file in the clone, that path is flagged as **unaudited**.
4. **Reads every executable and every agent-instruction file** in full — install scripts *and* `SKILL.md` / `CLAUDE.md` / `AGENTS.md`, because a prompt file is a trust surface too (injection, exfiltration, permission-weakening).
5. **Checks for deferred payloads** — package-manager lifecycle hooks (`postinstall`, `build.rs`, `setup.py` hooks), second-stage fetches at first *run*, and dependency pinning. Floating version ranges + no committed lockfile is a named finding: the dependency tree is unaudited and the review expires the moment you install.
6. **Scans for red flags** — `curl | bash`, shell-profile / PATH / launchd / cron edits, `sudo`, writes outside the install dir, credential access, exfiltration instructions, and obfuscation / homoglyph / bidi tricks. Every hit is located and read in context, and marked **live code** vs. **doc example / comment** — a scary URL in a README is not the same as one in a running script.
7. **Assesses operational blast radius** — the danger *even when the code is clean*. What real-world authority does the tool get when it runs? Does it spend money, act on an account, send messages as you, perform destructive ops? Does it ship anti-detection / ToS-evasion tooling? This is reported **separately** from the malice scan, because clean code that does a dangerous thing on purpose is a category a malware scan misses entirely.

Then it ends with a **blocking checklist** — any single `FAIL` stops auto-approval — plus a two-track verdict (malice risk *and* operational risk, since they can diverge) and an honest residual-risk statement. It **stops and asks** before anything touches your machine.

> It is a significantly-better-than-nothing review, not a guarantee. It reliably catches careless and obvious-malicious patterns; it cannot promise safety against a determined attacker (runtime dependency compromise, conditional logic, subtle injection) or assess service-side consequences like ToS enforcement. The skill says so, every time.

The seven points above are a summary. [`references/inspection-method.md`](references/inspection-method.md) is the single source of truth — it holds the full ten-step method and the blocking checklist, and it wins wherever this README or `SKILL.md` is terser or out of date.

The ten-step method was hardened against five real repos across four shapes — a symlink skill, an npm MCP server, a Go CLI, a `curl | bash` dotfiles tool, and a browser-automation MCP. Each surfaced a gap that's now part of the method.

**See it in action:** [`examples/example-report.md`](examples/example-report.md) is a real audit run — it shows the blocking checklist, the two-track verdict, and the "the install command isn't the repo you're reading" catch.

---

## Install

```bash
git clone https://github.com/Terryc21/inspect-before-install.git
cd inspect-before-install
bash install.sh
```

Restart Claude Code (or start a new session) to pick up the skill.

`install.sh` symlinks `SKILL.md`, `references/`, and `examples/` into `~/.claude/skills/inspect-before-install/`, and the slash command into `~/.claude/commands/` so `/inspect-before-install` appears in the prompt picker. Because it's a symlink install, **keep the clone somewhere permanent** — deleting it breaks the skill, and a later `git pull` updates it in place. To remove it: `bash uninstall.sh`.

Symlinking the whole clone instead — `ln -s /path/to/inspect-before-install ~/.claude/skills/inspect-before-install` — also works, and is what you get if you installed by hand. Claude Code only needs `SKILL.md` at the skill root; the tradeoff is that `.git/`, `install.sh`, and `LICENSE` end up visible inside your skills tree. Either layout is fine; `uninstall.sh` handles both.

If you installed from a git clone, `install.sh` also symlinks `scripts/pre-commit` into `.git/hooks/` (it won't overwrite a hook you already have). That hook guards the parts of this repo that exist in more than one file — the ten-step method, the blocking checklist, and the README's description of what `install.sh` links — and fails the commit when the copies disagree. Bypass with `git commit --no-verify`.

> Yes, the irony is intended: before you run *this* repo's `install.sh`, read it. It's short — it only creates symlinks, makes no network calls, and touches nothing outside `~/.claude/skills/`, `~/.claude/commands/`, and this repo's own `.git/hooks/`.

## Usage

The skill triggers on its own when you're about to install or run a third-party skill / MCP / plugin / CLI / dotfiles from a repo you don't fully trust — for example when you paste an install one-liner or ask "is this safe to install?". You can also invoke it explicitly:

```text
/inspect-before-install https://github.com/some/repo
```

Give it the repo URL and, if you have one, the exact install command you were told to run.

---

## My other Claude Code skills

Audit & code-quality skills:

- [radar-suite](https://github.com/Terryc21/radar-suite) — 5 audit skills that find bugs in your Swift/SwiftUI app before your users do. One install, complete audit pipeline.
- [data-model-radar](https://github.com/Terryc21/data-model-radar) — audits the SwiftData/Core Data model layer for field completeness, serialization gaps, relationship integrity, and migration safety.
- [capstone-radar](https://github.com/Terryc21/capstone-radar) — unified A–F grading and ship/no-ship decisions for the radar family.
- [workflow-audit](https://github.com/Terryc21/workflow-audit) — Xcode SwiftUI workflow auditing.
- [bug-echo](https://github.com/Terryc21/bug-echo) — after you fix a bug, finds and rates other instances of the same pattern, then proposes fixes on approval.
- [bug-prospector](https://github.com/Terryc21/bug-prospector) — mines for hidden bugs that pattern-based auditors miss: logic errors, broken assumptions, state-machine gaps.
- [one-star-risk](https://github.com/Terryc21/one-star-risk) — re-scores audit findings for App Store one-star-review risk, with named, overridable triggers.

Workflow & meta skills:

- [skill-reviewer](https://github.com/Terryc21/skill-reviewer) — candid reviews of Claude Code skills, with file:line citations and ranked actions.
- [prompter](https://github.com/Terryc21/prompter) — rewrites your prompts for clarity before they run.
- [unforget](https://github.com/Terryc21/unforget) — a single source of truth for deferred work, so you don't lose track of what you've punted.
- [tutorial-creator](https://github.com/Terryc21/tutorial-creator) — generates personalized coding lessons from your own codebase.
- [xcode-workflow-skills](https://github.com/Terryc21/xcode-workflow-skills) — a collection of Xcode / Claude Code skills.

---

## License

MIT — see [LICENSE](LICENSE).
