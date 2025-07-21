# Part 1 — Getting Started with **cc-minimal**

Welcome! This guide walks a junior software engineer through installing and running *cc-minimal* for the **very first time**, without connecting to GitHub.

---

## 1. Requirements

| Tool | Why it’s needed | Install (Ubuntu/WSL) |
|------|-----------------|----------------------|
| Git  | Version control | `sudo apt install git`
| Bash | Run the scripts | pre-installed
| jq   | Parse JSON      | `sudo apt install jq` |
| Claude Code CLI | AI assistance | See [official docs](https://docs.anthropic.com/…)

> Optional linters: `ruff` (Python), `eslint` (JS), `shellcheck` (Shell).

---

## 2. Clone the Repository

```bash
cd ~/projects
git clone https://github.com/tsutomu-n/cc-flow cc-flow-mini
```

This directory contains **`cc-minimal/`** — the sub-folder we actually use.

---

## 3. Add to PATH

Edit `~/.zshrc` (or `~/.bashrc`).

```bash
export CCFLOW_HOME="$HOME/projects/cc-flow-mini"
export PATH="$CCFLOW_HOME/cc-minimal/bin:$PATH"
```

Reload:

```bash
source ~/.zshrc  # or ~/.bashrc
```

Verify:

```bash
cc-doctor
```
If you see a dependency checklist, you’re set!

---

## 4. Install Git Hooks (optional but recommended)

Git hooks enforce linting and protect you from committing API keys.

**Quick way – run bootstrap script**
```bash
$ $CCFLOW_HOME/bootstrap.sh  # creates symlinks into .git/hooks
```

**Manual way**
```bash
ln -s $CCFLOW_HOME/cc-minimal/hooks/* .git/hooks/
chmod +x .git/hooks/*
```
You can verify with `ls .git/hooks` that `pre-commit` etc. are linked.

---

## 5. Initial Configuration

Copy the sample config and customise if desired.

```bash
cp $CCFLOW_HOME/cc-minimal/templates/.ccflowrc.sample .ccflowrc
```

Key knobs:
```ini
[core]
auto_commit = true
commit_threshold = 2

[lint]
python = ruff
javascript = eslint
shell = shellcheck
```

---

## 6. First Session (local-only)

```bash
cc-start "bootstrap app"
# edit some code …
cc-doc app.py            # add docstrings via AI
cc-review --staged       # get AI review
cc-done "bootstrap app"  # mark task done & commit
cc-stop                  # generate note, *no push*
```

Because no `origin` remote exists yet, `cc-stop` will just finish locally.

---

## 7. Later: Connect to GitHub (optional)

1. Create a repo with `gh repo create` **or** GitHub web UI.
2. Add the remote:
   ```bash
   git remote add origin git@github.com:<user>/<repo>.git
   git push -u origin main
   ```
3. From now on `cc-stop` will detect the remote and push branches automatically.

*You are now ready to explore the commands!* — Continue to **Part 2**.
