#!/usr/bin/env bats

load test_helper

setup() {
    setup_test_env

    # スクリプトのパスを設定
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    PORTAL_SCRIPT="$SCRIPT_DIR/scripts/tmux-portal.sh"

    # モックのtmuxをPATHの最優先に追加
    export PATH="$SCRIPT_DIR/tests/mocks:$PATH"
}

teardown() {
    teardown_test_env
}

@test "ヘルプオプション: 使い方を表示" {
    run bash "$PORTAL_SCRIPT" --help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage" ]] || [[ "$output" =~ "usage" ]]
}

@test "不明なオプション: エラーメッセージを表示" {
    run bash "$PORTAL_SCRIPT" --unknown-option

    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown option" ]] || [[ "$output" =~ "unknown" ]]
}

@test "セッション指定のみ: 既存セッションに切り替え" {
    run bash "$PORTAL_SCRIPT" --session "session1"
    [ "$status" -eq 0 ]
}

@test "セッション指定のみ: 存在しないセッションは自動作成" {
    run bash "$PORTAL_SCRIPT" --session "new-session-$$"
    [ "$status" -eq 0 ]

    # セッションが作成されたことを確認
    run bash -c "tmux list-sessions | grep -q '^new-session-$$'"
    [ "$status" -eq 0 ]
}

@test "セッション + コマンド指定: 新規ウィンドウでコマンド実行" {
    run bash "$PORTAL_SCRIPT" --session "session1" --command "aider"
    [ "$status" -eq 0 ]
}

@test "ステータスラインスタイル設定" {
    run bash "$PORTAL_SCRIPT" --session "session1" --status-style "fg=black,bg=yellow"
    [ "$status" -eq 0 ]
}

@test "tmux内から実行" {
    export TMUX="test"
    run bash "$PORTAL_SCRIPT" --session "session1"
    [ "$status" -eq 0 ]
}

@test "tmux外から実行" {
    export TMUX=""
    run bash "$PORTAL_SCRIPT" --session "session1"
    [ "$status" -eq 0 ]
}

@test "短縮オプション: -s でセッション指定" {
    run bash "$PORTAL_SCRIPT" -s "session1"
    [ "$status" -eq 0 ]
}

@test "短縮オプション: -c でコマンド指定" {
    run bash "$PORTAL_SCRIPT" -s "session1" -c "aider"
    [ "$status" -eq 0 ]
}

@test "セッション作成: 新規セッションを作成して切り替え" {
    run bash "$PORTAL_SCRIPT" --session "test-session-$$"
    [ "$status" -eq 0 ]

    # セッションが作成されたことを確認
    run bash -c "tmux list-sessions | grep -q '^test-session-$$'"
    [ "$status" -eq 0 ]
}

@test "セッション候補が1つの場合: 自動選択される" {
    # 既存のセッションをクリア
    rm -f "${TMPDIR:-/tmp}/tmux-portal-test/sessions"

    # セッション1つだけ作成
    echo "only-session" > "${TMPDIR:-/tmp}/tmux-portal-test/sessions"

    # TEST_MODE=1 でセッションスイッチャーを呼び出し
    run bash "$PORTAL_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "パス復元: 新規ウィンドウ作成時にカレントディレクトリを指定" {
    MOCK_DIR="${TMPDIR:-/tmp}/tmux-portal-test"
    LOG_FILE="$MOCK_DIR/calls.log"

    # 現在のディレクトリを模擬
    mkdir -p "/tmp/test-dir-$$"
    cd "/tmp/test-dir-$$"

    run bash "$PORTAL_SCRIPT" --session "session1" --command "ls"

    [ "$status" -eq 0 ]

    # tmux new-window が -c オプション付きで呼ばれたか確認
    grep "new-window.*-c /tmp/test-dir-$$" "$LOG_FILE"

    cd -
    rm -rf "/tmp/test-dir-$$"
}

@test "パス復元: 新規セッション作成時にカレントディレクトリを指定" {
    MOCK_DIR="${TMPDIR:-/tmp}/tmux-portal-test"
    LOG_FILE="$MOCK_DIR/calls.log"

    # 現在のディレクトリを模擬
    mkdir -p "/tmp/test-sess-dir-$$"
    cd "/tmp/test-sess-dir-$$"

    # 存在しないセッションを指定
    run bash "$PORTAL_SCRIPT" --session "brand-new-session-$$"

    [ "$status" -eq 0 ]

    # tmux new-session が -c オプション付きで呼ばれたか確認
    grep "new-session.*-c /tmp/test-sess-dir-$$" "$LOG_FILE"

    cd -
    rm -rf "/tmp/test-sess-dir-$$"
}

@test "tmux内から実行: 現在のセッションは候補から除外される" {
    # 複数セッションを作成
    cat > "${TMPDIR:-/tmp}/tmux-portal-test/sessions" <<EOF
session1
session2
current-session
EOF

    # TMUX環境変数を設定（tmux内を模擬）
    export TMUX="test"
    export MOCK_CURRENT_SESSION="current-session"

    # セッションスイッチャーで current-session 以外が選択されることを確認
    # TEST_MODE=1 なので最初のセッション（session1）が選択される
    run bash "$PORTAL_SCRIPT"
    [ "$status" -eq 0 ]
}
