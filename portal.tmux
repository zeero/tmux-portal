#!/usr/bin/env bash

# プラグインディレクトリを取得
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# メインスクリプトをPATHに追加
# ユーザーが直接コマンドを実行できるようにする
export PATH="$CURRENT_DIR/scripts:$PATH"
