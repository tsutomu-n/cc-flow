# Claude Code 詳細ガイド (Part 1)
> **TL;DR** 公式ドキュメントの重要ポイントと CLI/設定体系を丸ごと把握できるリファレンス。

---

## 1. 概要
Claude Code は Anthropic が提供する AI アシスタント CLI なのだ。独自の **Model Context Protocol (MCP)** により外部ツールをプラグインし、Slash コマンドや Hooks を通じて AI とシェルの世界を橋渡しする。

- リポジトリ: <https://github.com/anthropics/claude-code>
- ドキュメント: <https://docs.anthropic.com/en/docs/claude-code>

## 2. CLI コマンド早見表
| コマンド | 要約 | 主要フラグ |
| --- | --- | --- |
| `claude` | 対話 REPL。セッション作成やツール呼び出し | `--print`, `--session`, `--tool-debug` |
| `claude update` | バイナリアップデート | `--beta` |
| `claude settings` | 設定ファイルを編集/確認 | `--open`, `--show` |
| `claude memory` | Memory ファイル操作 | `--import`, `--export` |

### 2.1 代表的フラグ解説
- `--print` : 対話を JSON 出力にしてパイプ処理しやすくする。
- `--session <id>` : 指定セッションへ合流、継続的な文脈共有が可能。
- `--mcp-config <file>` : MCP サーバーセットを YAML で差し替える。

## 3. 設定体系 (settings)
CLI は **3 階層** で設定を解決する。

1. `/etc/claude/settings.json` (システム)
2. `~/.claude/settings.json` (ユーザー)
3. `<project>/.claude/settings.json` + `.local.json` (プロジェクト)

同キーは下位が優先。環境変数 `CLAUDE_XXX` で最終上書き可。

| 主要キー | 型 | 既定値 | 説明 |
| --- | --- | --- | --- |
| `auto_update` | bool | true | 起動時に最新版を自動フェッチ |
| `verbose_logging` | bool | false | デバッグ用詳細ログ |
| `tool_timeout_sec` | int | 120 | MCP ツール呼び出しのデフォルトタイムアウト |
| `permissions` | obj | – | ツール別の実行許可 (read/write 等) |

## 4. Memory 機能
`CLAUDE.md` に自然文で永続メモを書き、AI がチャット中に自動参照。構造:

```markdown
# memory
- 好みのエディタ: vim
- API_KEY: (masked)

#import "./docs/README.md"
```

- `/memory add "text"` で追記。
- `#import` 行で Markdown のサブメモを再帰読込。

## 5. Slash Commands
カスタム自動化を Markdown 1 ファイル毎に定義。

```markdown
---
description: Run tests and open coverage
---
1. // turbo
   run_command: pytest -q
2. open_browser_url: http://localhost:8000/htmlcov
```

特徴:
- front-matter の `description` 必須。
- `// turbo` アノテーションで自動実行許可。
- `.windsurf/workflows` 以下に保存し `/my-command` で実行。

## 6. Hooks 概要
| Hook イベント | 目的 | 代表的 JSON 入力 |
| --- | --- | --- |
| `PreToolUse` | ツール実行前ガード | `{ "tool_input": {...} }` |
| `PostToolUse` | 実行後フォロー | `{ "tool_output": {...} }` |
| `UserPromptSubmit` | プロンプト送信時 | `{ "prompt": "..." }` |
| `Notification` | AI から人間向け通知 | – |

Hook スクリプトは **exit 0** しつつ `stdout` に JSON を返すことで、`decision:block` などの制御が可能。

### 6.1 セキュリティ
- Hooks は任意シェル実行なのでリポジトリ外部から導入時は要レビュー。
- `permissions` キーで特定ツールをグローバル拒否可。

## 7. MCP (Model Context Protocol)
外部ツールを AI に公開するメタプロトコル。サーバーごとにスキーマ付き関数を提供し、AI は ToolCall で動的呼び出し。

例: `filesystem` サーバー => `read_file`, `write_file`, `edit_file`。

- サーバーマニフェスト YAML を `~/.claude/mcp/` に配置。
- CLI 起動時に自動ロード。

## 8. 参考リンク
- CLI リファレンス: <https://docs.anthropic.com/en/docs/claude-code/cli-reference>
- settings: <https://docs.anthropic.com/en/docs/claude-code/settings>
- memory: <https://docs.anthropic.com/en/docs/claude-code/memory>
- slash-commands: <https://docs.anthropic.com/en/docs/claude-code/slash-commands>
- hooks: <https://docs.anthropic.com/en/docs/claude-code/hooks>
