# Example audit report

This is a real, lightly-trimmed example of what the skill produces. The user had pasted:

> `npx skills add HartreeWorks/skill--secure-mcp-install` — is this safe to install?

The skill cloned the repo in isolation, read every file, and reported the following **before
anything was installed.** It illustrates the two features that most distinguish this skill: the
**install-path reconciliation** (the command you were given doesn't run the repo you're reading)
and the **two-track verdict** (malice vs. operational risk, reported separately).

> Note: the target here is itself a security-tooling repo. A good audit doesn't take a repo's
> self-description on faith — it reads the code regardless of what the repo claims to be.

---

# Inspection report: `HartreeWorks/skill--secure-mcp-install`

**What it is:** A Claude Code skill providing a manual "trust-but-verify" workflow for
installing MCP servers — clone at a pinned commit, run a static-scan script, review, install
from the local clone with updates disabled.

**Provenance:** Created 12/23/2025, last pushed ~3½ months later, 15 commits, 7★, 2 forks, not a
fork, not archived. Reviewed SHA `8821369a3563b921c494dcf033ad8d3bc5be56d5`. Modest but real
history.

**Files:** 6 total — `SKILL.md`, `README.md`, two reference markdowns, one shell script,
`.gitignore`. Small, fully readable.

## The finding that matters

🟡 **The install command is not the repo I audited.** The README's install path is
`npx skills add HartreeWorks/skill--secure-mcp-install` — which runs a **third-party npm CLI
(`skills`)** that I did *not* inspect. I audited the skill's own files (clean); I did **not**
audit that `npx` installer. "The repo's files are clean" and "the install command is clean" are
different claims. **Recommendation:** install from source at the reviewed SHA instead — clone,
copy the files into `~/.claude/skills/`, done — which sidesteps the unaudited installer entirely.

## Everything else: clean

| Check | Result |
|---|---|
| Install script: no network / `sudo` / profile edits | ✅ the shipped `.sh` is a read-only static scanner; writes nothing, fetches nothing |
| No writes/deletes outside its dir | ✅ only `grep`s a target dir passed as an argument |
| No credential access / no exfil instructions in prompts | ✅ `SKILL.md` never tells the agent to read secrets or POST data |
| No package lifecycle hooks | ✅ no `package.json` / `setup.py` in the repo |
| No obfuscation / homoglyphs | ✅ pure ASCII; the alarming `attacker.com` / `analytics.example.com` URLs are **teaching examples** inside `references/red-flags.md`, confirmed by reading each line |
| HTML/JS phone-home | ✅ N/A — no web assets |

## Blocking checklist

- [x] Install command runs an in-repo script I audited — ⚠️ **EXCEPTION: routes through unaudited `npx skills` installer; risk named, mitigation given**
- [x] No network fetch / `sudo` / profile edits in install script
- [x] No writes or deletes outside the tool's own dir
- [x] No credential access, no exfiltration instructions in any prompt file
- [x] No package-manager lifecycle hooks
- [x] No second-stage download at install or first run
- [x] Dependencies pinned / N/A (no deps)
- [x] No obfuscated blobs or homoglyph/bidi tricks
- [x] HTML/JS assets have no phone-home surface
- [x] Provenance adequate for the trust level

## Verdict

- **Malice risk: LOW.** The skill's payload — script + prompt files — is benign and does exactly
  what it advertises.
- **Operational risk: LOW.** A read-only static scanner; it inspects, it doesn't act.
- **One open item:** the `npx skills` installer path is unaudited. Prefer the from-source install.

**Residual-risk statement:** this pass reliably catches careless and obvious-malicious patterns
in the repo's own files, but cannot vouch for the external `npx skills` installer, and cannot
guarantee safety against a determined attacker (runtime dependency compromise, conditional logic,
subtle prompt injection).

---

**→ Stopping here for your decision.** Install from source at the reviewed SHA, or hold off?
