# cc-flow 詳細ガイド (Part 2) — プロジェクト概要とワークフロー
> **TL;DR** cc-flow は Claude Code を核に "毎日の開発ルーチン" を自動化するシェルツールキットだ。

---

## 1. プロジェクト目的
- **Flow 維持**: Git 操作・フォーマット・コミット文生成など “雑務” を AI とシェルが肩代わり。
- **ゼロ依存**: Bash + Git さえあれば動作、CI/WSL/Alpine でも導入容易。
- **透明性**: すべてプレーンテキスト & Git 管理、履歴で経緯を追える。

## 2. ディレクトリ構造
```text
cc-flow/
 ├─ cc-hooks/            # 主要フックスクリプト群
 ├─ .claude/             # Claude Code ローカル設定・commands
 │   ├─ commands/        # Slash コマンドテンプレ
 │   └─ hooks/           # サブプロジェクト用 (detect-tools など重複配置)
 ├─ .ccflow/             # ノート・設定
 │   ├─ NOTE/            # 日次ハンドオフノート
 │   └─ config           # YAML 設定 (オプション)
 ├─ docs/                # ガイド & 詳細ドキュメント
 └─ README.md / guide.md # 人間向け概要
```

## 3. 日常ワークフロー
| ステップ | コマンド | 概要 |
| --- | --- | --- |
| 1 | `/cc-session-start` | 新しい開発セッションを開始しタスク記録を初期化 |
| 2 | 編集 & AI 対話 | Claude Code 上でコード生成・修正 |
| 3 | `/cc-task-done` | タスク完了を AI に伝達、TODO 更新 |
| 4 | `/cc-session-stop` | ハンドオフノート生成 + リポジトリ push |

### 3.1 自動化スクリプト連携
- ファイル保存 → `link-checker.sh` (PreToolUse) が lint & quality gate
- AI 書込後 → `auto-commit.sh` (PostToolUse) が差分コミット
- セッション終了時 `/cc-note` → `cc-note.sh` により Markdown まとめ

## 4. 主要コマンド一覧
| Command | 役割 | 実体 |
| --- | --- | --- |
| `/cc-session-start` | 1 日の作業開始宣言 | `.claude/commands/cc-session-start.md` |
| `/cc-edit` | AI にファイル修正依頼 | `.claude/commands/cc-edit.md` |
| `/cc-task-done` | TODO → DONE 移動 | `.claude/commands/cc-task-done.md` |
| `/cc-note` | ハンドオフノート生成 | `.claude/commands/cc-note.md` |
| `/cc-session-stop` | push & cleanup | `.claude/commands/cc-session-stop.md` |
| `/cc-update` | テンプレ自己更新 | `.claude/commands/cc-update.md` |

## 5. 設定ファイル
### 5.1 `.clauderc`
ユーザー毎に置く環境変数シェルスクリプト。
```bash
# 自動コミット有効
export CCF_AUTO_COMMIT_ENABLED=true
# protect / lint ゲート無効化例
export CCF_PROTECT_RULES_ENABLED=false
```

### 5.2 `.ccflow/config` (YAML)
```yaml
note_template: handoff.md
branch_prefix: feature/
```
テンプレパスや名前付けルールを上書き可能。

## 6. デザイン哲学
1. **Minimal First**: 現状の最小フローを壊さず導入 → 拡張は opt-in。
2. **Human > AI**: GOAL.md 等クリティカル文書は AI 書換禁止 (protect-rules)。
3. **Transparent Automation**: 自動コミットは Conventional Commits で履歴読みやすさを担保。

## 7. 導入手順 (手動)
```bash
git clone https://github.com/tsutomu-n/cc-flow.git
cd cc-flow
./cc-hooks/bootstrap.sh   # または ./.claude/hooks/bootstrap.sh
```
`CCF_AUTO_BOOTSTRAP_ENABLED=true` を `.clauderc` で設定すると新規プロジェクト毎に自動 scaffold される。

## 8. FAQ 抜粋
| Q | A |
| --- | --- |
| JSON パースエラーが出る | 過去の `detect-tools.sh` が古い可能性 → `./cc-update` |
| AI が `.env` を書換えようとする | protect-rules がブロック、`.clauderc` で override 可 |

---
次パート → **cc-hooks Deep Dive** で各スクリプトを詳細に解説する。
