# cc-hooks Deep Dive (Part 3)
> **TL;DR** 主要 7 スクリプトを仕様・フロー・安全対策の順に徹底解説する。

---

## 1. detect-tools.sh — 環境適応ユーティリティ
| 項目 | 詳細 |
| --- | --- |
| 役割 | jq/rg/fd などモダンツールを検出し `JSON_CMD` などの変数に束ねる |
| 機能 | `TOOL_DEFINITIONS` を宣言的にループ、モダンツールが無ければ POSIX 代替へフォールバック |
| 提供関数 | `ccf_json_extract`, `ccf_json_escape`, `log` |
| デバッグ | `CCF_DEBUG=true` で `/tmp/ccf_log_<pid>` に出力 |
| 改善案 | XDG_RUNTIME_DIR などにログを移すとクリーン。

## 2. protect-rules.sh — 重要ファイル保護ゲート
| 項目 | 詳細 |
| --- | --- |
| イベント | PreToolUse |
| 設定フラグ | `CCF_PROTECT_RULES_ENABLED` (default true) |
| ガード内容 | `.env*`, `GOAL.md`, `.gitignore`, `.claude/settings.json` など + パストラバーサル防止 |
| ブロック方式 | `stdout` に `{"decision":"block"}` を返しツール実行を中止 |
| 改善案 | YAML 外部リスト化、正規表現拡張

## 3. link-checker.sh — Lint & Quality Gate
| 項目 | 詳細 |
| --- | --- |
| イベント | PreToolUse |
| 対応拡張子 | `.py→ruff`, `.js/.ts→eslint`, `.sh→shellcheck` |
| エラー処理 | linter 非インストール時は警告のみ、lint エラー時は block |
| 設定フラグ | `CCF_LINT_CHECKER_ENABLED` |
| 改善案 | linter マップを `.ccflow/config` で拡張

## 4. auto-commit.sh — 差分コミット自動化
| 項目 | 詳細 |
| --- | --- |
| イベント | PostToolUse |
| コミット条件 | 行数合計 >3 行, `.clauderc` で enable |
| 安全チェック | merge/rebase/detached HEAD/ workspace 内 ファイルはスキップ |
| commit msg | `feat: Auto-commit <file> (<lines> lines)` |
| 改善案 | 複数ファイルまとめコミットモード

## 5. cc-note.sh — ハンドオフノート生成
| 項目 | 詳細 |
| --- | --- |
| 呼出 | ユーザー `/cc-note` コマンド |
| 生成物 | `.ccflow/NOTE/<date>_<branch>.md` |
| 内容 | 完了タスク, 次アクション, Git commit 情報, README 抜粋 |
| インタラクティブ | 既存ファイル上書き確認/`--yes` フラグ |
| 改善案 | issue/pr リンク自動挿入

## 6. cc-update.sh — テンプレ自己更新
| 項目 | 詳細 |
| --- | --- |
| 呼出 | `/cc-update` or CLI 直実行 |
| 処理 | GitHub タグ tarball ダウンロード → `.claude` 差分表示 → 上書き |
| 重要 env | `CCF_PROTECT_OVERRIDE` で protect-rules 無効化 |
| 安全 | 色付き diff + y/N 確認 (`-y` 非対話) |
| 改善案 | Proxy/社内ミラー対応

## 7. bootstrap.sh — 初回インストール自動化
| 項目 | 詳細 |
| --- | --- |
| イベント | UserPromptSubmit |
| ロック | `.claude/commands/cc-session-start.md` 存在でスキップ |
| 用户 opt-in | `.clauderc: CCF_AUTO_BOOTSTRAP_ENABLED=true` |
| 動作 | `<Write>` ブロックで GOAL.md など scaffold → Claude に通知 |
| 改善案 | バージョン取得 & progress bar

---

## 8. 相互作用フロー図
```mermaid
sequenceDiagram
  participant User
  participant Claude
  participant cc-hooks
  User->>Claude: /edit foo.py
  Claude->>protect-rules: PreToolUse JSON
  protect-rules-->>Claude: ok / block
  Claude->>link-checker: PreToolUse JSON
  link-checker-->>Claude: ok / block
  Claude->>Filesystem: write foo.py
  Claude->>auto-commit: PostToolUse JSON
  auto-commit->>Git: add/commit
  User->>Claude: /cc-note
  Claude->>cc-note: generate NOTE
```

---
次パート → **運用ガイド & 改善提案** に進む。
