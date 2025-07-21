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

## 3. Install / Update
```bash
# Install (already done if you used the template)
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

### `.clauderc`
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
.claude/commands    # Slash-command descriptors read by Claude Code
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
