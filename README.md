# tmux-portal

AIエージェントとの作業を専用のtmuxセッションで管理し、通常の開発セッションと素早く切り替えるためのプラグインです。

セッションの切り替え、新規ウィンドウの作成、コマンド実行、ステータスラインのカスタマイズまで一括で行えます。

## Features

- **セッションスイッチャー** - 現在のセッション以外から素早く選択・切り替え（候補が1つなら自動選択）
- **コマンド統合** - セッション切り替えと同時に新規ウィンドウでコマンドを実行
- **カスタムステータススタイル** - ステータスラインの色を指定して視覚的に識別

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

### 基本的な使い方
セッションスイッチャーを表示して、選択したセッションに移動します。

```bash
tmux-portal
```

現在のセッション以外のすべてのセッションを対話的なメニューで表示します。数字で選択してください。

#### キーバインド例
`.tmux.conf` に以下のように設定することで、素早くアクセスできます。

```tmux
bind-key C-p run-shell "tmux-portal"
```

### AIエージェント専用セッションとの切り替え
AIエージェント（例：Claude）専用のセッションを作成し、コマンドを実行します。

```bash
# Claudeセッションを作成/切り替えして、claudeコマンドを実行
tmux-portal -s claude -c claude --status-style "fg=black,bg=orange"

# 通常セッションに戻る（スイッチャーから選択）
tmux-portal
```

## Options
(新規セクション - 別イシューで追加)

## Requirements

- tmux
- Bash

## License

MIT License - [LICENSE](LICENSE) を参照してください
