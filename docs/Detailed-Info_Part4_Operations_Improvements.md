# cc-flow 運用ガイド & 改善提案 (Part 4)
> **TL;DR** 日々の運用ノウハウと、将来へ向けた拡張ポイントを一挙整理する。

---

## 1. 設定ファイル deep dive
### 1.1 `.clauderc` — シェル変数トグル
| 変数 | 既定 | 説明 |
| --- | --- | --- |
| `CCF_AUTO_COMMIT_ENABLED` | true | AI が書いたファイルを自動コミット |
| `CCF_PROTECT_RULES_ENABLED` | true | 重要ファイル保護を有効 |
| `CCF_LINT_CHECKER_ENABLED` | true | lint ゲートを有効 |
| `CCF_AUTO_BOOTSTRAP_ENABLED` | false | 新規リポジトリで自動 scaffold |
| `CCF_DEBUG` | false | detect-tools の詳細ログ |

> Tips: チーム用に `.clauderc.example` を共有し、個人は `.gitignore` で非追跡に。

### 1.2 `.ccflow/config` — YAML 上書きポイント
```yaml
note_template: .ccflow/templates/daily.md   # ノートテンプレ
lint:
  py: ruff
  js: eslint --max-warnings 0
protect_extra:
  - docs/ARCHITECTURE.md
```
- `note_template` で `.ccflow/NOTE/*` の初期文面を差し替え。
- `lint` セクションを `link-checker.sh` が参照 (将来拡張案実装時)。
- `protect_extra` にファイルパターンを追加し `protect-rules` が読む設計が可能。

---

## 2. セキュリティベストプラクティス
1. **PR レビュー必須** — Hooks は任意シェル実行。外部 contrib 受領時は diff を確認。
2. **Least-Privilege** — CI 実行用 PAT は read/write scope を最小化。
3. **Secrets 管理** — `.env` は git 追跡外 + protect-rules で AI 書換禁止。
4. **Auto-Update 管理** — `claude settings` で `auto_update=false` し、更新は `/cc-update` に集約すると再現性が高い。

---

## 3. よくあるトラブルシューティング
| 症状 | 原因 | 解決策 |
| --- | --- | --- |
| GPT JSON parse error | `detect-tools.sh` の簡易 grep fallback | jq をインストール or `brew install jq` |
| `auto-commit` が走らない | `.clauderc` で無効化 or diff ≤3 lines | 行数閾値を下げる / 手動 commit |
| eslint が失敗 | Node 環境 or eslint 未導入 | `npm i -D eslint` + `.eslintrc` |
| `/cc-update` で curl エラー | 社内 proxy | `export https_proxy=http://proxy:port` |

---

## 4. CI/CD 統合例
### GitHub Actions
```yaml
name: cc-flow Checks
on: [push]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node & Python
        uses: actions/setup-node@v4
      - run: npm ci && pip install ruff
      - name: Run AI-generated lint gates
        run: ./.claude/hooks/link-checker.sh < /dev/null || exit 1
```
- commit 前と同じ lint ロジックを PR でも再実行し品質担保。

---

## 5. 改善アイデアまとめ
| カテゴリ | 提案 | 期待効果 |
| --- | --- | --- |
| Config | `.ccflow/config` に `lint` & `protect_extra` を公式実装 | 拡張性アップ |
| Tool | `auto-commit` に multi-file batching | commit 履歴のノイズ削減 |
| Security | `link-checker` の sandbox 実行 (docker) | 脆弱性ある linter の隔離 |
| Doc | `update` の diff サマリを `NOTE` に自動貼付 | 監査性向上 |
| UX | `/cc-session-start` で Today’s Goal 確認プロンプト | 作業指針の可視化 |

---

## 6. 参考リンク
- ruff: <https://github.com/astral-sh/ruff>
- shellcheck: <https://www.shellcheck.net>
- Conventional Commits: <https://www.conventionalcommits.org>
- mermaid sequence: <https://mermaid.js.org>


