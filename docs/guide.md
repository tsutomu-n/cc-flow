# Claude Code Flow – Full Guide

_A detailed manual for daily development with Claude Code_

---

## Table of Contents
1. [Background & Philosophy](#background--philosophy)
2. [Daily Workflow in Depth](#daily-workflow-in-depth)
3. [All Commands Reference](#all-commands-reference)
4. [Configuration Keys](#configuration-keys)
5. [Git Hooks & Scripts](#git-hooks--scripts)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

---

## Installation Options
You can set up Claude Code Flow manually or let it install itself.

### Manual (recommended)
Run once after cloning:
```bash
./bootstrap.sh
```

### Automatic (opt-in)
Create `.clauderc` with:
```bash
CCF_AUTO_BOOTSTRAP_ENABLED="true"
```
On your first prompt, the `UserPromptSubmit` hook will run `.claude/hooks/bootstrap.sh` and finish installation.

---

## Background & Philosophy
Claude Code Flow was born from the need to **share context quickly** between human devs and the Claude AI assistant.  
It favors _plain shell scripts_, minimal dependencies, and **explicit Git history** over opaque magic.

### Goals
- Make onboarding a new developer (or AI) < 5 min.
- One command to start the day, one to finish.
- Zero-config default that still works for multi-project setups.

---

## Daily Workflow in Depth
Below is the full timeline of a typical day. Each step links to the exact command usage and internal script flow.

| Step | Command / Script | Description |
|------|------------------|-------------|
| 1 | `bootstrap.sh` (once) | Installs hooks under `cc-hooks/` and symlinks commands. |
| 2 | `/cc-session-start` | Loads yesterday summary, `GOAL.md`, last commits, and proposes today tasks. |
| 3 | `/cc-edit` (`/edit` alias) | Ask Claude to modify code. Behind the scenes it triggers `git add` → staged diff preview → AI edit. |
| 4 | `/cc-task-done` | Writes a bullet entry in `CHANGELOG.md`, auto-formats, commits with conventional message. |
| 5 | `/cc-session-stop` | Summarizes work, writes hand-off note via `cc-note.sh`, auto-pushes if branch clean. |

<details>
<summary>Script call graph</summary>

```text
cc-session-start
└─ cc-hooks/detect-tools.sh (optional)
   └─ cc-note.sh --summary (yesterday context)
```

</details>

---

## All Commands Reference
### Core daily commands
| Command | Flags | Description |
|---------|-------|-------------|
| `/cc-session-start` | `--yes` | Start day, preload context. |
| `/cc-edit` (`/edit` alias) | `"prompt"` | Ask Claude to change code. |
| `/cc-task-done` | (none) | Mark task complete, auto commit. |
| `/cc-session-stop` | (none) | End session, write note, auto push. |

### Maintenance
| Command | Flags | Description |
|---------|-------|-------------|
| `/cc-update` | `-y` , `<version>` | Self-update scripts. |
| `/cc-note` | `--full`, `--config` | Manual note generation. |

---

## Configuration Keys
### `.ccflow/config`
See comments in `config.example`. Full list reproduced here:
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `project.name` | string | repo name | Title in notes. |
| `note.default_mode` | enum | `summary` | Template type used by `cc-note.sh`. |
| `note.extra_sections` | array | `[]` | Extra blocks (`ci_status`, `contacts`, `file.md`). |
| `ci.badge_url` | string | "" | Badge image for README / notes. |
| ... | ... | ... | ... |

### `.clauderc` (generated as `.clauderc.template`)
Rename the template and flip switches as needed:
```bash
# .clauderc
CCF_AUTO_COMMIT_ENABLED="true"
CCF_LINT_CHECKER_ENABLED="true"
CCF_PROTECT_RULES_ENABLED="true"
# CCF_DEBUG="false"
```
User-level toggles – read at runtime by hooks.

---

## Git Hooks & Scripts
```
cc-hooks/
├─ pre-commit           # ruff format, shellcheck
├─ commit-msg           # conventional message lint
├─ protect-rules.sh     # block dangerous paths
├─ cc-update.sh         # self-updater
└─ cc-note.sh           # hand-off note generator
```
Each hook prints colored output and exits non-zero on failure.

---

## Troubleshooting

### Bootstrap hiccups (July 2025)
| Symptom | Cause | Fix |
|---------|-------|-----|
| `invalid settings.json` on first start | Comments (`//`) or trailing commas broke JSON | Remove comments > `jq . settings.json` to validate |
| Hook blocks forever after **ASSISTANT_NOTICE** | CLI ≤ v0.56 decision:block bug | Update CLI (`npm i -g @anthropic-ai/claude-code@latest`) or run `bootstrap.sh` manually |
| `GOAL.md` / `NOTEBOOK.md` not tracked | `.gitignore` excluded them | Add exceptions `!GOAL.md` / `!.claude/NOTEBOOK.md` in `.gitignore` |

| Symptom | Cause | Fix |
|---------|-------|-----|
| "SAFETY_GATE: Action blocked" | Trying to /cc-edit protected file | Add to allowed list or modify manually. |
| Note generation empty | Missing `yq` | Install `yq` or /cc-edit config manually. |

---

## FAQ
**Q: Why shell scripts instead of Python?**  
A: Zero bootstrapping, works on any CI agent.

**Q: Can I disable auto-commit?**  
A: Yes, set `auto_commit` to `false` in `.clauderc`.

---

*(Feel free to expand this guide. Keep README short; put details here.)*
