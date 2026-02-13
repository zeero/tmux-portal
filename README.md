# tmux-portal

tmuxのセッション切り替えを効率化するプラグインです。セッション切り替え、新規ウィンドウ作成、指定したコマンドを実行まで一括で行う。

- ユースケース:
  - AIエージェントとのセッションを専用のtmuxセッションに切り出して集中管理する

## Features

- **セッションスイッチャー** - tmuxセッション間を素早く移動
- **現在のセッションはスイッチ候補から除外** - 切り替え時は他のセッションのみ表示
- **セッション自動選択** - 選択肢が1つだけの場合はメニューを表示せず自動選択
- **カスタムステータススタイル** - ステータスラインの色を指定して視覚的に識別
- **コマンド統合** - 特定のセッション内に新規ウィンドウを作成してコマンドを実行

## Installation

### tpm (recommended)

`~/.tmux.conf` に以下を追加:

```tmux
set -g @plugin 'zeero/tmux-portal'
```

その後、`prefix + I` でインストールします。

### Manual Installation

```bash
git clone https://github.com/zeero/tmux-portal ~/.tmux/plugins/tmux-portal
```

`~/.tmux.conf` に以下を追加:

```tmux
run-shell ~/.tmux/plugins/tmux-portal/portal.tmux
```

tmuxを再読み込み: `tmux source-file ~/.tmux.conf`

## Usage

| Option | Description |
|--------|-------------|
| `-s, --session <name>` | セッション名（存在しない場合は作成） |
| `-c, --command <cmd>` | 新規ウィンドウで実行するコマンド |
| `--status-style <style>` | tmuxステータスバースタイル（例: `fg=black,bg=yellow`） |
| `-h, --help` | ヘルプメッセージを表示 |

### AIエージェント専用のセッションと相互に切り替える

```bash
tmux-portal -s claude -c claude --status-style "fg=black,bg=orange"

# 通常セッションに戻る
tmux-portal
```

### 基本的なセッション切り替え

```bash
# セッションスイッチャーを表示して選択したセッションに移動
tmux-portal
```

現在のセッション以外のすべてのセッションを対話的なメニューで表示します。数字で選択してください。

### 名前付きセッションの作成/切り替え

```bash
# 特定のセッションに切り替え（存在しない場合は作成）
tmux-portal --session my-project
tmux-portal -s my-project
```

セッションが存在しない場合、tmux-portalは切り替える前に作成します。

### セッション内でのコマンド実行

```bash
# メニューからセッションを選択してclaudeを起動
tmux-portal --command claude

# 特定のセッションでclaudeを起動
tmux-portal -s claude -c claude
```

対象セッション内に新規ウィンドウを作成してコマンドを実行します。

### ステータススタイルによる視覚的な識別

```bash
# Claudeセッションを黄色のステータスバーで色分け
tmux-portal -s claude --status-style "fg=black,bg=yellow"

# Codexセッションには別の色を設定
tmux-portal -s codex --status-style "fg=white,bg=blue"
```

どのAIエージェントを使用しているか一目で識別できます。

## Example Workflow

```bash
# 異なるAIエージェント用に色分けされたセッションを設定
tmux-portal -s claude -c claude --status-style "fg=black,bg=yellow"
tmux-portal -s codex -c codex --status-style "fg=white,bg=blue"
tmux-portal -s cursor -c cursor-agent --status-style "fg=black,bg=green"

# その後、素早く切り替え
tmux-portal  # 表示内容: codex, cursor（現在のセッションは除外）
```

## Requirements

- tmux
- Bash

## License

MIT License - [LICENSE](LICENSE) を参照してください
