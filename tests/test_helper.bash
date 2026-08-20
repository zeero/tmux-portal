#!/usr/bin/env bash

# テスト用のプロジェクトルートディレクトリを取得
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# tmux のモックは source ではなく PATH 経由で効かせる（tests/mocks/tmux）。
# テスト対象は別プロセスで起動するため、シェル関数のオーバーライドは届かない。

# テスト用の環境変数設定
setup_test_env() {
    export TMUX=""  # デフォルトはtmux外
    export TEST_MODE=1

    # モックデータのクリーンアップ
    MOCK_DIR="${TMPDIR:-/tmp}/tmux-portal-test"
    rm -rf "$MOCK_DIR"
    mkdir -p "$MOCK_DIR"
}

# テスト後のクリーンアップ
teardown_test_env() {
    unset TMUX
    unset TEST_MODE

    # モックデータのクリーンアップ
    MOCK_DIR="${TMPDIR:-/tmp}/tmux-portal-test"
    rm -rf "$MOCK_DIR"
}
