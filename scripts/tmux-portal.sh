#!/usr/bin/env bash

# デフォルト値
SESSION=""
COMMAND=""
STATUS_STYLE=""

# ヘルプメッセージを表示
show_help() {
    cat <<EOF
Usage: tmux-portal [OPTIONS]

tmux-portalは、AIエージェントセッションを効率的に管理するためのツールです。

OPTIONS:
    -s, --session <name>        セッション名を指定（なければ作成）
    -c, --command <cmd>         新規ウィンドウで実行するコマンド
    --status-style <style>      ステータスラインスタイル（tmux形式）
    -h, --help                  このヘルプを表示

EXAMPLES:
    # セッション一覧から選択して切り替え
    tmux-portal

    # 指定したセッションに切り替え（なければ作成）
    tmux-portal --session my-project
    tmux-portal -s my-project

    # セッション内に新規ウィンドウを作成してコマンド実行
    tmux-portal --session my-project --command aider
    tmux-portal -s my-project -c "claude-code --project ."

    # セッションを選択してコマンド実行
    tmux-portal --command aider

    # ステータスラインのスタイルを設定
    tmux-portal -s my-project --status-style "fg=black,bg=yellow"
EOF
}

# セッション存在確認
session_exists() {
    local session_name="$1"
    tmux has-session -t "$session_name" 2>/dev/null
}

# セッション作成
create_session() {
    local session_name="$1"
    tmux new-session -d -s "$session_name"
}

# セッション切り替え
switch_to_session() {
    local session_name="$1"

    if [ -n "$TMUX" ]; then
        # tmux内から実行
        tmux switch-client -t "$session_name"
    else
        # tmux外から実行
        tmux attach-session -t "$session_name"
    fi
}

# セッションスイッチャー（selectコマンドを使用）
show_session_switcher() {
    local sessions=()
    while IFS= read -r session; do
        sessions+=("$session")
    done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)

    if [ ${#sessions[@]} -eq 0 ]; then
        echo "No sessions found" >&2
        return 1
    fi

    # テストモードの場合は最初のセッションを自動選択
    if [ -n "$TEST_MODE" ]; then
        echo "${sessions[0]}"
        return 0
    fi

    echo "Select a session:" >&2
    select session in "${sessions[@]}"; do
        if [ -n "$session" ]; then
            echo "$session"
            return 0
        fi
    done

    # selectコマンドが中断された場合
    return 1
}

# 現在のウィンドウ名を取得
get_current_window_name() {
    if [ -n "$TMUX" ]; then
        tmux display-message -p '#W'
    else
        echo ""
    fi
}

# 新規ウィンドウでコマンド実行
create_window_with_command() {
    local session_name="$1"
    local command="$2"
    local window_name="$3"

    if [ -n "$window_name" ]; then
        tmux new-window -t "$session_name" -n "$window_name" "$command"
    else
        tmux new-window -t "$session_name" "$command"
    fi
}

# ステータスラインスタイル設定
set_status_style() {
    local session_name="$1"
    local style="$2"

    if [ -n "$style" ]; then
        tmux set -t "$session_name" status-style "$style"
    fi
}

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--session)
            SESSION="$2"
            shift 2
            ;;
        -c|--command)
            COMMAND="$2"
            shift 2
            ;;
        --status-style)
            STATUS_STYLE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "" >&2
            show_help
            exit 1
            ;;
    esac
done

# メイン処理
main() {
    # ケース1: オプションなし → セッションスイッチャー
    if [ -z "$SESSION" ] && [ -z "$COMMAND" ]; then
        local selected_session
        selected_session=$(show_session_switcher)
        if [ -n "$selected_session" ]; then
            switch_to_session "$selected_session"
        fi
        exit 0
    fi

    # ケース2: コマンド指定のみ（セッションなし）
    if [ -z "$SESSION" ] && [ -n "$COMMAND" ]; then
        local selected_session
        selected_session=$(show_session_switcher)
        if [ -z "$selected_session" ]; then
            exit 1
        fi
        SESSION="$selected_session"
    fi

    # セッションが存在しない場合は作成
    if ! session_exists "$SESSION"; then
        create_session "$SESSION"
    fi

    # ステータスラインスタイル設定
    if [ -n "$STATUS_STYLE" ]; then
        set_status_style "$SESSION" "$STATUS_STYLE"
    fi

    # ケース3: コマンド指定あり
    if [ -n "$COMMAND" ]; then
        local window_name
        window_name=$(get_current_window_name)
        create_window_with_command "$SESSION" "$COMMAND" "$window_name"
    fi

    # セッションに切り替え
    switch_to_session "$SESSION"
}

main "$@"
