# Claude Code Flow

Claude Code Flow は、**ChatGPT/Claude などの AI アシスタントと Git フックを組み合わせて、日々の開発を自動化・可視化するテンプレート** です。以下に示すフックとコマンドを導入するだけで、プロジェクトのルール維持・作業記録・アップデート管理を AI が支援します。

---
## 目次
1. [背景と目的](#背景と目的)
2. [主な機能](#主な機能)
3. [前提条件](#前提条件)
4. [インストール](#インストール)
5. [1 日のワークフロー](#1-日のワークフロー)
6. [セルフアップデータ (`cc-update`)](#セルフアップデータ-cc-update)
7. [設定ファイル (`.clauderc`)](#設定ファイル-clauderc)
8. [ディレクトリ構成](#ディレクトリ構成)
9. [コントリビュート方法](#コントリビュート方法)
10. [ライセンス](#ライセンス)

---
## 背景と目的
公式の Claude Code は高性能ですが、以下の課題が残っていました。

| 課題 | Claude Code Flow が提供する解決策 |
|------|--------------------------------------|
| 指示やルールを忘れてしまう | `GOAL.md` に長期ルールを保存し、常に参照 |
| 変更経緯が残りにくい | `auto-commit.sh` が変更ごとに Git コミット |
| テンプレートの更新が煩雑 | `cc-update` で 1 コマンド更新 (CI/cron 対応) |

---
## 主な機能
- **AI アシスタント連携** — `/cc-help` や `/edit` で AI に指示
- **Git Hooks** — 自動整形・自動コミット・機密チェック
- **Self-Updater** — `cc-update` でテンプレートを最新に保つ
- **自動ツール検出** — ripgrep / fd など高速ツールがあれば自動利用

---
## 前提条件
| ツール | バージョン | 備考 |
|-------|-----------|------|
| bash  | ≥ 3.2 | POSIX シェルでも可だが bash 推奨 |
| git   | ≥ 2.20 | Git フック利用 |
| curl or wget | 最新 | リモート取得に使用 |
| jq    | ≥ 1.6 | JSON パースに使用 |

> これらは多くの Linux/macOS 環境で既に入っています。

### 高速化オプション (自動検出)
`hooks/detect-tools.sh` が以下のツールを自動検知し、高速化します。
`rg` / `fd` / `bat` / `sd` / `mlr` / `delta`

---
## インストール
```bash
# 1. クローン
$ git clone https://github.com/tsutomu-n/cc-flow.git
$ cd cc-flow

# 2. ブートストラップ (フックをコピー)
$ sh cc-hooks/bootstrap.sh
```

---
## 1 日のワークフロー
> 毎朝 `bootstrap.sh` で生成された **`/cc-session-start`** コマンドを一度実行するだけで、AI は *昨日の作業サマリー・GOAL.md・最新コード状態* を読み込み、今日の最適なタスク計画を提案します。
```text
/cc-session-start   →  作業 (/edit など)  →  /cc-task-done
        ↓                                       ↓
(自動整形・コミット)            ←    Git Hook が実施
        ↓
/cc-session-stop    (1 日終了)
```

---
## セルフアップデータ (`cc-update`)
最新テンプレート取得や特定タグへのロールバックが 1 行で可能です。

```bash
# 最新版へ非対話更新
$ cc-hooks/cc-update.sh -y

# v0.1.0 へ固定
$ cc-hooks/cc-update.sh v0.1.0
```

| オプション/環境変数 | 説明 |
|--------------------|------|
| `<version>` | 更新先タグ。省略時は `VERSION`、なければ `main` へ |
| `-y, --yes` | すべて自動 Yes (CI/cron 用) |
| `SKIP_FETCH=true` | ネットを使わずローカルアーカイブで検証 |

変更サマリは **A** (追加・緑) / **M** (変更・黄) / **D** (削除・赤) で色分け表示されます。

---
## Configuration (`.ccflow/config`)
A project can override default behaviour with a small YAML file.
Start by copying `.ccflow/config.example` to `.ccflow/config` and edit the keys you need:

```bash
cp .ccflow/config.example .ccflow/config
```

Most common keys:
| Key | Meaning |
|-----|---------|
| `project.name` | Short project name shown in notes |
| `note.default_mode` | `summary` or `full` (template length) |
| `note.extra_sections` | `ci_status`, `contacts`, or any markdown file |
| `ci.badge_url` | URL of your CI status badge |

See comments inside `config.example` for all keys.

---
## 設定ファイル (`.clauderc`)
最小構成例:
```jsonc
{
  "auto_commit": true,
  "protect_rules": true,
  "update": { "auto": false, "channel": "main" }
}
```

---
## ディレクトリ構成
```text
.claude/commands      # テンプレート側コマンド
.claude/hooks         # テンプレート側フック
cc-commands           # 実働コマンド (ユーザーカスタム可)
cc-hooks              # 実働フック (Git hooksPath 指定)
.ccflow/NOTE        # 作業メモ・ハンドオフ
```

---
## コントリビュート方法
1. Fork & ブランチ作成 (`feat/<topic>`)
2. 変更と合わせて CHANGELOG を更新
3. PR 送信 (CI が自動テスト)

---
## ライセンス
MIT

> Git hooks & AI scripts to streamline development. Keep your local workflow template up to date with a single command.

---
## Claude Code Flow：目的と背景

### 背景
公式の Claude Code は強力ですが、そのままでは**毎回入力した指示を忘れがち**で、AI が「何をしたか」もプロジェクト履歴に残りませんでした。

### 目的
Claude Code Flow は AI に

- **プロジェクトのルールや文脈を保持する脳 — `GOAL.md`**
- **作業を漏れなく記録する手 — `auto-commit` Git フック**

を与え、あなたの開発サイクルに常駐する“専属メンバー”へと進化させます。

これにより、
- 毎朝「昨日の続きから」とだけ伝えれば、AI は文脈を完全に復元
- ルール違反を自動で検知・修正し、品質を維持
- すべての変更が自動コミットされ、議事録いらず

という体験を実現します。

---

## 🚀 クイックスタート
```bash
# 1. Clone & bootstrap
 git clone https://github.com/tsutomu-n/cc-flow.git && cd cc-flow
 sh cc-hooks/bootstrap.sh

# 2. Update template to latest (non-interactive)
 cc-hooks/cc-update.sh -y
```

## 🔄 セルフアップデータ (`cc-update`)
| 用途 | コマンド例 |
|------|------------|
| 最新版へ自動更新 (非対話) | `cc-hooks/cc-update.sh -y` |
| 特定タグへ固定 | `cc-hooks/cc-update.sh v0.1.0` |
| ローカルステージのみで検証 | `SKIP_FETCH=true cc-hooks/cc-update.sh` |

### オプション一覧
| オプション | 説明 |
|-----------|------|
| `-y, --yes` | すべての確認を *Yes* とみなし自動進行。
| `<version>` | 指定タグへ更新。省略時は `VERSION` ファイルを取得。存在しなければ `main` ブランチへフォールバック。
| `SKIP_FETCH=true` | ネットアクセスせず、`.update-staging` の既存アーカイブを使用。

### diff 色付け
```
A  追加 (緑)
M  変更 (黄)
D  削除 (赤)
```

### よくある質問
- **Q: バリデーションに失敗すると?**  → 非 0 で終了し、ファイルは変更されません。
- **Q: タグが無いリポジトリでは?**  → 自動で `main` ブランチのアーカイブを取得します。

## ✨ 主な機能
- **Git Hooks 自動整形** – `lint-checker.sh` が PR 前にコードを整形し、品質を一定に保つ。
- **AI アシスト** – `/cc-help` や `/edit` で ChatGPT 風の支援を受けながらコーディング。
- **Self-Updater** – `cc-update` でテンプレートを常に最新状態へ。
- **Auto Commit** – `auto-commit.sh` が作業ごとに粒度の細かいコミットを自動生成。
- **Protect Rules** – 機密情報 push をブロックし、セキュリティを担保。

## 🛠 前提条件とインストール
| ツール | バージョン | 入手方法 |
|-------|-----------|---------|
| bash  | ≥ 3.2 | macOS / Linux 標準 |
| git   | ≥ 2.20 | `brew`, `apt`, `yum` |
| curl *or* wget | 最新 | ネットワーク転送 |
| jq    | ≥ 1.6 | JSON 操作ツール |

### 任意の高速ツール (自動検出)
These tools are **auto-detected** by `hooks/detect-tools.sh` to enhance speed and UX.  無ければ標準コマンドへフォールバックします。
| ツール | 役割 |
|-------|------|
| `rg` (ripgrep) | 超高速 `grep` 代替 |
| `fd` | 高速 `find` 代替 |
| `bat` | カラー表示付き `cat` |
| `sd` | `sed` 互換の高速リプレーサ |
| `mlr` (miller) | `awk` を置き換える表形式ツール |
| `delta` | `git diff` カラー化 |

```bash
# 1. Clone repository
 git clone https://github.com/tsutomu-n/cc-flow.git && cd cc-flow

# 2. Bootstrap hooks & config
 sh cc-hooks/bootstrap.sh
```

## 🔁 1日の開発ワークフロー
```
/cc-session-start  →  コーディング / 編集 (/edit コマンドなど)
      ↓                         ↓
/cc-task-done      ←  Git hooks による自動整形・コミット
      ↓
/cc-session-stop   (1 日の作業を終了)
```

## ⚙️ 設定 (`.clauderc`)
`.clauderc` をプロジェクトルートに置くことで機能の有効/無効を制御できます。
```jsonc
{
  "auto_commit": true,
  "protect_rules": true,
  "update": {
    "auto": false,
    "channel": "main"
  }
}
```

## 📁 ディレクトリ構成 (抜粋)
```
.claude/commands      # /cc-* コマンド仕様書
.claude/hooks         # Git / Claude Code フック
.ccflow/NOTE        # ハンドオフ・メモ
```

## 🤝 コントリビュート方法
1. Fork リポジトリ
2. `feat/<topic>` ブランチを作成
3. PR と併せて CHANGELOG を更新

## 📜 ライセンス
MIT
