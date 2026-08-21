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

## Example Workflow

AIエージェントを `agents` セッションに集約し、作業中のディレクトリのまま起動して、元のセッションに戻る、という流れです。

### 1. キーバインドを登録する

`~/.tmux.conf` に以下を追加し、`tmux source-file ~/.tmux.conf` で読み込みます。

```tmux
# エージェントを起動する
bind C-c run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c claude -p '✻ ' --status-style 'fg=black,bg=orange' --direnv"
bind C-f run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c 'claude --model fable' -p '🦋 ' --status-style 'fg=black,bg=orange' --direnv"
bind C-x run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c codex -p '❂ ' --status-style 'fg=black,bg=orange' --direnv"

# セッションを行き来する
bind W run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh"
```

`#{TMUX_PLUGIN_MANAGER_PATH}` は tpm がプラグイン置き場のパスに展開します。手動インストールの場合は `~/.tmux/plugins/tmux-portal/scripts/tmux-portal.sh` に読み替えてください。

どのエージェントを動かしているウィンドウかは、`-p` で付けた印がウィンドウ名に出ます。

### 2. `prefix + C-c` で Claude を起動する

`myproject` ディレクトリで作業しているウィンドウで押します。

- `agents` セッションが作られ、そこへ移動する
- `myproject` と同じディレクトリで新規ウィンドウが開き、`claude` が起動する
- ウィンドウ名は元のウィンドウ名を引き継いで `✻ myproject` になる
- ステータスバーがオレンジになり、エージェント用のセッションにいることが分かる

### 3. `prefix + C-x` で同じディレクトリに Codex を追加する

`✻ myproject` ウィンドウにいるまま押します。

- 同じ `agents` セッションに、同じディレクトリで新規ウィンドウが開き、`codex` が起動する
- ウィンドウ名は `✻ ` が取り除かれて `❂ myproject` になる
- Claude のウィンドウは残るので、tmux のウィンドウ切り替えで両方を行き来できる

### 4. `prefix + W` で元のセッションに戻る

- `agents` 以外のセッションへ移動する（候補が1つなら選択メニューは出ない）
- エージェントは `agents` セッションで動き続ける
- もう一度 `prefix + W` を押せば `agents` に戻れる

## Usage

| Option | Description |
|--------|-------------|
| `-s, --session <name>` | セッション名（存在しない場合は作成） |
| `-c, --command <cmd>` | 新規ウィンドウで実行するコマンド |
| `--status-style <style>` | tmuxステータスバースタイル（例: `fg=black,bg=yellow`） |
| `--window-status-current-style <style>` | 現在タブのスタイル（省略時は `--status-style` の fg/bg を入れ替えて自動設定） |
| `-p, --window-prefix <str>` | 新規ウィンドウ名に付けるプリフィクス（前回付けたものは自動で置き換わる） |
| `--direnv` | コマンド実行時に `direnv exec` 経由で環境変数をロード |
| `-h, --help` | ヘルプメッセージを表示 |

### AIエージェント専用のセッションと相互に切り替える

```bash
tmux-portal -s agents -c claude --status-style "fg=black,bg=orange"

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
tmux-portal -s agents -c claude
```

対象セッション内に新規ウィンドウを作成してコマンドを実行します。

### ステータススタイルによる視覚的な識別

```bash
# エージェント用セッションを黄色のステータスバーで色分け
# → 現在タブの文字色は fg=yellow,bg=black に自動設定される
tmux-portal -s agents --status-style "fg=black,bg=yellow"

# エージェントごとにセッションを分ける場合は、セッションごとに色を変えられる
tmux-portal -s codex --status-style "fg=white,bg=blue"

# 現在タブのスタイルを明示指定したい場合
tmux-portal -s aider --status-style "fg=black,bg=green" --window-status-current-style "fg=green,bg=black,bold"
```

どのAIエージェントを使用しているか一目で識別できます。

`--status-style` に `fg` と `bg` を両方指定した場合、現在タブ（`window-status-current-style`）には自動的に fg/bg を入れ替えたスタイルが設定されます。`--window-status-current-style` で上書きすることも可能です。

> [!TIP]
> tmux のデフォルト設定では `status-left-length` が **10** のため、セッション名が途中で切れることがあります。
> `~/.tmux.conf` に以下を追加して表示幅を広げてください。
>
> ```tmux
> set -g status-left-length 20
> ```

### ウィンドウ名にエージェントの印を付ける

新規ウィンドウは呼び出し元のウィンドウ名を引き継ぎます。`-p` を付けると、その名前の先頭に印を置けます。

```bash
# ウィンドウ名 "myproject" から実行すると "✻ myproject" になる
tmux-portal -s agents -c claude -p '✻ '

# そのウィンドウから別のエージェントを起動すると "❂ myproject" になる（印は積み上がらない）
tmux-portal -s agents -c codex -p '❂ '
```

前回付けた印は tmux のウィンドウ変数に記録されるため、別のコマンドの印であっても取り除いてから付け直されます。ウィンドウ名を手動で変更した場合も、印が先頭に残っていれば置き換わります。

## Requirements

- tmux
- Bash

## License

MIT License - [LICENSE](LICENSE) を参照してください
