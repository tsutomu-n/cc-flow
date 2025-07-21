# Claude Code Flow

_Efficient daily development assisted by AI_

---

## 1. Why Claude Code Flow?

Tired of juggling **git, formatting, commit messages, and hand-off notes** when you just want to code?  
_Claude Code Flow_ (CCF) is a lightweight shell toolkit that puts those chores on autopilot and turns Claude into a first-class pair-programmer.

### 🚀 Key Benefits
| &nbsp; |  |
|---|---|
| ⚡ **Stay in Flow** | One-liner commands handle staging, diff review, and conventional commits so you never leave your editor. |
| 🤝 **Seamless AI Pairing** | Slash-commands feed the right context to Claude and paste back code patches. |
| 📝 **Instant Handoff** | `/cc-session-stop` writes a structured Markdown summary ready for async teammates. |

### 30-Second Daily Loop
```text
bootstrap.sh   # one time
└── /cc-session-start
    ├── (code) → /cc-edit → /cc-task-done  [repeat]
    └── /cc-session-stop  # auto note & push
```

<details>
<summary>日本語補足 (click)</summary>
CCF は **Claude Code と並走するためのシェルツール集**です。日々の開発サイクル（開始→編集→タスク完了→作業内容や進捗をまとめて記録＆プッシュ→終わり）をワンライナーで支援し、フォーマット・コミット・引き継ぎノート作成・自動プッシュをすべて自動化します。
</details>

---

## 2. Quick Start
```bash
# 1. Clone your repo and run bootstrap once
./bootstrap.sh

# 2. Every morning
/cc-session-start   # AI loads GOAL.md & yesterday summary

# 3. Work as usual
/cc-edit "Implement feature X"
/cc-task-done       # mark task finished (auto commit)

# 4. End of day
/cc-session-stop
```
The AI proposes tasks, auto-formats code, and commits through Git hooks.

---

## 3. Getting Started: Installation

Below are three common ways to bring Claude Code Flow into your project. For full walk-throughs see **[docs/guide.md → Installation Options](docs/guide.md#installation-options)**.

<details>
<summary><strong>Option A – New Project (recommended)</strong></summary>

```bash
# 1. Create a repo from the GitHub template UI
# 2. Then locally:
git clone https://github.com/<you>/<new-project>.git
cd <new-project>
./bootstrap.sh   # one-time setup
claude           # open chat, then
> /cc-session-start
```
</details>

<details>
<summary><strong>Option B – Clone This Repo</strong></summary>

```bash
git clone https://github.com/tsutomu-n/cc-flow.git
cd cc-flow
# (optional) scrub history for a fresh start	rm -rf .git && git init && git add . && git commit -m "Initial commit"
./bootstrap.sh
```
You now have the workflow’s own history; ideal for hacking on CCF itself.
</details>

<details>
<summary><strong>Option C – Add to Existing Project</strong></summary>

```bash
# from your repo root
curl -L https://github.com/tsutomu-n/cc-flow/archive/main.zip -o ccf.zip
unzip ccf.zip -d ccf-tmp && rm ccf.zip
cp -r ccf-tmp/cc-flow-main/{cc-hooks,cc-commands,settings.json,.clauderc.template,bootstrap.sh} .
cat ccf-tmp/cc-flow-main/.gitignore >> .gitignore
rm -rf ccf-tmp
./bootstrap.sh
```
</details>

---


You can install Claude Code Flow in two ways.

### 3.1 Manual Install (recommended)
Run the bootstrap script once after cloning:

```bash
./bootstrap.sh
```

### 3.2 Automatic Install (opt-in)
Skip the manual step by adding this line to a `.clauderc` file at the project root:

```bash
CCF_AUTO_BOOTSTRAP_ENABLED="true"
```
When you send your first prompt to Claude, the workflow will self-install via the `UserPromptSubmit` hook.

---

### 3.3 Update / Rollback
```bash
# Install (run once to set up hooks)
./bootstrap.sh

# Update to latest version
cc-hooks/cc-update.sh -y

# Roll back to a tag
cc-hooks/cc-update.sh v0.1.0
```

---

## 4. Daily Workflow Commands
| Command | Purpose |
|---------|---------|
| `/cc-session-start` | Load yesterday’s context and suggest today’s plan |
| `/cc-edit` (`/edit` alias) | Ask Claude Code to edit / create code |
| `/cc-task-done`    | Log finished task and auto-commit |
| `/cc-session-stop` | Wrap up the day, generate hand-off note |
| `/cc-note`         | Manually create a note (`--full` or `--config`) |

---

## 5. Configuration (`.ccflow/config`)
Copy the example file and tweak:
```bash
cp .ccflow/config.example .ccflow/config
```
Common keys:
| Key | Meaning |
|-----|---------|
| `project.name` | Short project name |
| `note.default_mode` | `summary` or `full` |
| `note.extra_sections` | `ci_status`, `contacts`, or file paths |
| `ci.badge_url` | CI status badge URL |
See comments inside `config.example` for full list.

### `.clauderc` (generated as `.clauderc.template`)
Shell-style toggles that enable / disable core hooks at runtime. Rename the template and edit values:
```bash
# .clauderc
CCF_AUTO_COMMIT_ENABLED="true"   # auto commit & push
CCF_LINT_CHECKER_ENABLED="true"  # ruff/ shellcheck before write
CCF_PROTECT_RULES_ENABLED="true" # protect GOAL.md & critical files
# CCF_DEBUG="false"              # verbose hook logging
```
Enables / disables core hooks at runtime. Example:
```jsonc
{
  "auto_commit": true,
  "protect_rules": true,
  "update": { "auto": false, "channel": "main" }
}
```

---

## 6. Directory Layout
```text
bootstrap.sh           # one-time installer (creates symlinks)
.clauderc.template    # copy/rename to .clauderc for hook toggles
.claude/commands       # Slash-command descriptors read by Claude Code
cc-commands/        # Human-readable command help
cc-hooks/           # Git / daily workflow hooks and scripts
.ccflow/NOTE/       # Generated hand-off notes (git-ignored)
```

---

## 7. Help Files
Two help files serve different audiences:
| Path | Purpose |
|------|---------|
| `.claude/commands/cc-help.md` | **AI prompt** – tells the LLM how to answer `/cc-help`. |
| `cc-commands/cc-help.md`     | **Manual** – what users see when running `/cc-help`. |

---

## 8. Contributing
1. Fork repository  
2. Create branch `feat/<topic>`  
3. Open PR + update CHANGELOG

---

## 9. License
MIT
