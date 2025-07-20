# Claude-Code Flow

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
 sh .claude/hooks/bootstrap.sh

# 2. Update template to latest (non-interactive)
 .claude/hooks/cc-update.sh -y
```

## 🔄 セルフアップデータ (`cc-update`)
| 用途 | コマンド例 |
|------|------------|
| 最新版へ自動更新 (非対話) | `.claude/hooks/cc-update.sh -y` |
| 特定タグへ固定 | `.claude/hooks/cc-update.sh v0.1.0` |
| ローカルステージのみで検証 | `SKIP_FETCH=true .claude/hooks/cc-update.sh` |

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
 sh .claude/hooks/bootstrap.sh
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
.kiroflow/NOTE        # ハンドオフ・メモ
```

## 🤝 コントリビュート方法
1. Fork リポジトリ
2. `feat/<topic>` ブランチを作成
3. PR と併せて CHANGELOG を更新

## 📜 ライセンス
MIT
