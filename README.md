# Claude-Code Flow

> Git hooks & AI scripts to streamline development. Keep your local workflow template up to date with a single command.

## 🚀 Quick Start
```bash
# 1. Clone & bootstrap
 git clone https://github.com/tsutomu-n/cc-flow.git && cd cc-flow
 sh .claude/hooks/bootstrap.sh

# 2. Update template to latest (non-interactive)
 .claude/hooks/cc-update.sh -y
```

## 🔄 Self-Updater (`cc-update`)
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

### FAQ
- **Q: バリデーションに失敗すると?**  → 非 0 で終了し、ファイルは変更されません。
- **Q: タグが無いリポジトリでは?**  → 自動で `main` ブランチのアーカイブを取得します。

## 📁 ディレクトリ構成 (抜粋)
```
.claude/commands      # /cc-* コマンド仕様書
.claude/hooks         # Git / Claude Code フック
.kiroflow/NOTE        # ハンドオフ・メモ
```

## 🤝 Contributing
1. Fork リポジトリ
2. `feat/<topic>` ブランチを作成
3. PR と併せて CHANGELOG を更新

## 📜 License
MIT
