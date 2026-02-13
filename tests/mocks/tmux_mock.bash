#!/usr/bin/env bash

# モック用のグローバル変数
declare -A MOCK_SESSIONS
declare -A MOCK_SESSION_WINDOWS
MOCK_CURRENT_SESSION=""
MOCK_TMUX_CALLS=()

# tmuxコマンドのモック
tmux() {
    # コマンドログを記録
    MOCK_TMUX_CALLS+=("$*")

    local command="$1"
    shift

    case "$command" in
        has-session)
            # -t オプションからセッション名を取得
            local session=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -t)
                        session="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            if [[ -n "${MOCK_SESSIONS[$session]}" ]]; then
                return 0
            else
                return 1
            fi
            ;;

        new-session)
            local session=""
            local detached=0

            while [[ $# -gt 0 ]]; do
                case $1 in
                    -d)
                        detached=1
                        shift
                        ;;
                    -s)
                        session="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            MOCK_SESSIONS[$session]=1
            MOCK_SESSION_WINDOWS[$session]="0:bash"
            return 0
            ;;

        switch-client)
            local session=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -t)
                        session="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            if [[ -n "${MOCK_SESSIONS[$session]}" ]]; then
                MOCK_CURRENT_SESSION="$session"
                return 0
            else
                return 1
            fi
            ;;

        attach-session)
            local session=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -t)
                        session="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            if [[ -n "${MOCK_SESSIONS[$session]}" ]]; then
                MOCK_CURRENT_SESSION="$session"
                return 0
            else
                return 1
            fi
            ;;

        list-sessions)
            local format=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -F)
                        format="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            for session in "${!MOCK_SESSIONS[@]}"; do
                echo "$session"
            done
            return 0
            ;;

        display-message)
            local format=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -p)
                        format="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            # #W はウィンドウ名
            if [[ "$format" == "#W" ]]; then
                echo "test-window"
            fi
            return 0
            ;;

        new-window)
            local session=""
            local window_name=""
            local command=""

            while [[ $# -gt 0 ]]; do
                case $1 in
                    -t)
                        session="$2"
                        shift 2
                        ;;
                    -n)
                        window_name="$2"
                        shift 2
                        ;;
                    *)
                        command="$1"
                        shift
                        ;;
                esac
            done

            return 0
            ;;

        set)
            # set -t <session> status-style <style>
            return 0
            ;;

        *)
            echo "Unknown tmux command: $command" >&2
            return 1
            ;;
    esac
}

# モックのリセット
reset_tmux_mock() {
    MOCK_SESSIONS=()
    MOCK_SESSION_WINDOWS=()
    MOCK_CURRENT_SESSION=""
    MOCK_TMUX_CALLS=()
}

# モックのセットアップ
setup_tmux_mock() {
    reset_tmux_mock
    # デフォルトでいくつかのセッションを作成
    MOCK_SESSIONS["session1"]=1
    MOCK_SESSIONS["session2"]=1
    MOCK_SESSIONS["ai-project"]=1
}
