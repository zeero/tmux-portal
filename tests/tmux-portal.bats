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
