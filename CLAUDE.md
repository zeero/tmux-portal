# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

tmux-portalは、tmux plugin manager (TPM)互換のプラグインで、AIエージェント（Claude、Aider、Cursorなど）のセッション管理を効率化します。

## 開発コマンド

### テスト実行
```bash
# すべてのテストを実行
bats tests/tmux-portal.bats

# 詳細モードでテスト実行
bats --verbose-run tests/tmux-portal.bats

# 特定のテストのみ実行
bats tests/tmux-portal.bats --filter "テスト名"
```

### スクリプト検証
```bash
# 構文チェック
bash -n scripts/tmux-portal.sh

# デバッグ実行（tmuxセッションは操作しない）
bash -x scripts/tmux-portal.sh --help
```

## アーキテクチャ

### TPMプラグイン構造

- **portal.tmux**: TPMエントリポイント。TPMがプラグインを読み込む際に実行され、`scripts/` ディレクトリをPATHに追加する
- **scripts/tmux-portal.sh**: メインスクリプト。すべての機能を実装

### 実行環境の検出

スクリプトは `$TMUX` 環境変数でtmux内/外を判定し、動作を切り替えます:
- tmux内（`$TMUX` が設定されている）: `tmux switch-client` を使用
- tmux外（`$TMUX` が未設定）: `tmux attach-session` を使用

### セッションスイッチャー

`show_session_switcher()` 関数は `select` コマンドで対話的にセッションを選択します。
テスト時の特別な挙動: `TEST_MODE=1` 環境変数が設定されている場合、対話なしで最初のセッションを自動選択します。

## テストアーキテクチャ

### モックの仕組み

テストでは実際のtmuxセッションを操作せず、モックを使用します:

1. **tests/mocks/tmux**: 実行可能なモックスクリプト。PATHの先頭に追加することで、実際の `tmux` コマンドの代わりに実行される
2. **共有データ**: モックは `${TMPDIR:-/tmp}/tmux-portal-test` にセッション情報を保存し、テスト間で共有
3. **クリーンアップ**: `setup_test_env()` と `teardown_test_env()` でテストごとにモックデータをリセット

### テスト実行フロー

1. `setup()`: PATH に `tests/mocks` を追加し、`TEST_MODE=1` を設定
2. テスト実行: モックの tmux が呼ばれる
3. アサーション: 終了コードとモックが作成したセッション情報を確認
4. `teardown()`: モックデータをクリーンアップ

## 重要な実装の詳細

### オプション解析のケース分け

main() 関数は以下の3つのケースを処理します:

1. **オプションなし**: `show_session_switcher()` でセッション選択 → 切り替え
2. **コマンド指定のみ**: セッション選択 → 新規ウィンドウでコマンド実行 → 切り替え
3. **セッション指定あり**: セッション作成（存在しなければ）→ コマンド実行（指定されていれば）→ 切り替え

### ステータスラインのカスタマイズ

`--status-style` オプションでセッション単位のステータスライン設定が可能。AIエージェント別に色分けして識別しやすくする用途を想定。

## コード修正時の注意点

- スクリプトはPOSIX互換ではなくBash固有の機能（配列、`[[ ]]` など）を使用
- 関数内の `local` 変数宣言を必ず行う（グローバル汚染を防ぐため）
- テストモード（`TEST_MODE`）の分岐を壊さないよう注意
- 新しい tmux コマンドを追加する場合、`tests/mocks/tmux` にもモック実装を追加
