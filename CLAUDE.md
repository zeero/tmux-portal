# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

tmux-portalは、tmux plugin manager (TPM)互換のプラグインで、AIエージェント（Claude、Aider、Cursorなど）のセッション管理を効率化します。

## 開発コマンド

### テスト実行
```bash
# すべてのテストを実行（Taskfile 経由）
task test

# 直接実行
bats tests/tmux-portal.bats

# 詳細モードでテスト実行
bats --verbose-run tests/tmux-portal.bats

# 特定のテストのみ実行（テスト名は日本語なので部分一致で指定する）
bats tests/tmux-portal.bats --filter "プリフィクス"
```

### スクリプト検証
```bash
# 構文チェック
bash -n scripts/tmux-portal.sh

# デバッグ実行（tmuxセッションは操作しない）
bash -x scripts/tmux-portal.sh --help
```

## プロジェクト構成

```
tmux-portal/
├── portal.tmux              # TPMエントリポイント（scripts/ をPATHに追加するだけ）
├── Taskfile.yml             # go-task のタスク定義
├── scripts/
│   └── tmux-portal.sh       # メインスクリプト（全機能を実装）
├── tests/
│   ├── tmux-portal.bats     # テストケース（bats-core）
│   ├── test_helper.bash     # テストヘルパー（環境セットアップ/クリーンアップ）
│   └── mocks/
│       └── tmux             # tmuxコマンドのモック（実行可能スクリプト）
├── README.md                # ドキュメント（日本語）
└── README.en.md             # ドキュメント（英語）
```

## アーキテクチャ

スクリプトは単一ファイル（`scripts/tmux-portal.sh`）で完結し、状態は tmux 側にしか持たない。以下は複数箇所を読まないと繋がらない挙動。

### 実行環境の検出

`$TMUX` 環境変数でtmux内/外を判定し、動作を切り替えます:
- tmux内（`$TMUX` が設定されている）: `tmux switch-client` を使用
- tmux外（`$TMUX` が未設定）: `tmux attach-session` を使用

同じ判定が `get_current_session_name()` / `get_current_window_name()` にもあり、tmux外では空文字を返す（＝スイッチャーの除外もウィンドウ名の引き継ぎも起きない）。

### オプション解析と main() の関係

オプション解析の `while` ループはトップレベル（関数外）にあり、グローバル変数（`SESSION` / `COMMAND` など）へ書き込む。`main "$@"` は呼ばれるが引数は参照していない。オプションを追加するときは「解析ループ」「`show_help()`」「グローバル変数の初期化」の3箇所を揃える。

`main()` が処理するケースは3つ:

1. **セッションもコマンドも未指定**: `show_session_switcher()` でセッション選択 → 切り替えて即 `exit`
2. **コマンド指定のみ**: セッション選択 → 新規ウィンドウでコマンド実行 → 切り替え
3. **セッション指定あり**: セッション作成（存在しなければ）→ コマンド実行（指定されていれば）→ 切り替え

ケース1は「元のセッションに戻る」ための経路なので、`--status-style` を同時に渡しても**意図的に無視する**（戻り先セッションの見た目を書き換えないため）。この分岐は `--status-style` の有無を条件に含めてはいけない。

### セッションスイッチャー

`show_session_switcher()` は選択結果を **stdout に返す**（呼び出し側はコマンド置換で受ける）ため、ユーザ向けメッセージは stderr か `tmux display-message` に出す必要がある。

選択ロジックの優先順位:
1. 現在のセッションを候補から除外 → 候補ゼロなら `tmux display-message` で通知して失敗
2. 候補が1つなら対話なしで自動選択
3. `TEST_MODE` が設定されていれば最初の候補を自動選択（テスト用）
4. それ以外は `select` で対話選択

### ウィンドウ名の引き継ぎとプリフィクス

新規ウィンドウは「呼び出し元のウィンドウ名」を引き継ぐ。`get_current_window_name()` は**セッション作成より前**に呼ぶ必要がある（作成後だとカレントセッションが変わり、取得対象がズレる）。

`--window-prefix` は「**前回付けたプリフィクスを取り除いてから付け直す**」方式。ウィンドウ作成後に、付けたプリフィクスを tmux のウィンドウ変数 `@portal-window-prefix` へ記録し（`set_window_prefix()`）、次回起動時にそれを読んで先頭から剥がす（`get_current_window_prefix()`）。

この方式を採る理由:

- プリフィクスの一覧を持たなくても、別コマンドのプリフィクス（`❂ ` の上に `♊ `）が積み上がらない
- 手動で `rename-window` してもプリフィクスが先頭に残っていれば剥がせる。プリフィクスごと消されていた場合は先頭一致しないので、何も剥がさず新しいプリフィクスを付ける
- 同じプリフィクスの再実行は「剥がして同じものを付ける」ので結果が変わらない

`--window-prefix` 未指定でも剥がす処理は走る（前のコマンドの印が残ったままになるのを避けるため）。記録は `-c` でウィンドウを作った場合のみ行う。

### ステータスラインのカスタマイズ

`--status-style` はセッション単位のステータスライン設定（AIエージェント別の色分け用途）。付随する非自明な点が2つある:

- `--window-status-current-style` 未指定時は、`--status-style` の `fg=` / `bg=` を入れ替えて自動導出する（両方揃っている場合のみ）
- `set_status_style()` は **ウィンドウ作成の前後で2回** 呼ぶ。`new-window` でカレントウィンドウが変わり、`-w` 指定の設定が意図した対象に乗らないため

### direnv 連携

`--direnv` 指定時、`direnv` コマンドが存在し、かつ起動ディレクトリに `.envrc` がある場合にのみ、コマンドを `direnv exec '<dir>' <cmd>` でラップする。条件を満たさなければ黙って通常実行にフォールバックする。

## テストアーキテクチャ

### モックの仕組み

テストでは実際のtmuxセッションを操作せず、モックを使用します:

1. **tests/mocks/tmux**: 実行可能なモックスクリプト。`setup()` が PATH の先頭に `tests/mocks` を追加することで、実際の `tmux` の代わりに実行される。**モックはシェル関数ではなく実行可能ファイルでなければならない**（テスト対象を `run bash "$PORTAL_SCRIPT"` と別プロセスで起動するため、`export -f` しない関数定義は届かない）
2. **共有データ**: モックは `${TMPDIR:-/tmp}/tmux-portal-test` にセッション一覧（`sessions`）と全コマンドの呼び出しログ（`calls.log`）を保存する。tmux 引数のアサーションは `calls.log` を grep して行う
3. **初期セッション**: `sessions` が空のとき `session1` / `session2` / `ai-project` を自動投入する。テストはこの3つを前提に書かれている
4. **カレント状態の差し替え**: `MOCK_CURRENT_SESSION` / `MOCK_CURRENT_WINDOW` / `MOCK_CURRENT_PATH` を export すると `display-message -p` の戻り値を制御できる。`MOCK_WINDOW_PREFIX` は `show-options -wqv @portal-window-prefix` の戻り値を制御する
5. **クリーンアップ**: `setup_test_env()` と `teardown_test_env()` でテストごとにモックデータディレクトリごと削除する

### テスト実行フロー

1. `setup()`: PATH に `tests/mocks` を追加し、`TEST_MODE=1` を設定
2. テスト実行: モックの tmux が呼ばれる
3. アサーション: 終了コード、`sessions`、`calls.log` を確認
4. `teardown()`: モックデータをクリーンアップ

## ドキュメント管理

- **SSOT**: `scripts/tmux-portal.sh` の `show_help()` がオプション一覧の信頼できる情報源
- **README**: 日本語版（`README.md`）と英語版（`README.en.md`）の二言語管理。機能追加・変更時は両方を同期する（Usageテーブル、セクション構成、使用例の対応を確認）
- **テスト一覧のドキュメントは作らない**: bats のテスト名が日本語で自己説明的なので、`grep '^@test' tests/tmux-portal.bats` を正とする（かつて `tests/CLAUDE.md` に一覧とカバレッジ表があったが、陳腐化して実態と食い違ったため削除した）

## コード修正時の注意点

- スクリプトはPOSIX互換ではなくBash固有の機能（配列、`[[ ]]` など）を使用
- 関数内の `local` 変数宣言を必ず行う（グローバル汚染を防ぐため）
- テストモード（`TEST_MODE`）の分岐を壊さないよう注意
- 新しい tmux サブコマンドを使う場合、`tests/mocks/tmux` にもケースを追加する（未知のコマンドは exit 1 になりテストが落ちる）
