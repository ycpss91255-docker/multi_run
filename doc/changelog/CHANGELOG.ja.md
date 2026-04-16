# 変更履歴

フォーマットは [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) に基づき、
バージョン番号は[セマンティックバージョニング](https://semver.org/spec/v2.0.0.html)に準拠。

## [未リリース]

### 追加
- 5 スクリプト：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`
- `init.sh` サブコマンド：`--add`、`--remove`、`--list`（ワークスペース管理）
- `lib.sh`：共有関数（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `resolve_compose.py`：展開済み compose YAML から devel サービスを抽出・リネーム
- `workspace/` ディレクトリ：symlink ベースのワークスペース管理
- `docker compose config` 展開 + Python サービスリネーム（ユニークサービス名）
- 2 モード：workspace symlink スキャン / 直接パス引数
- 54 テスト（Bats 44 件 + Python 10 件）+ ShellCheck
- CI：ShellCheck + Bats + Python coverage + Kcov（docker compose 経由、DinD）
- Codecov 統合

### 変更
- `add.sh` / `remove.sh` を `init.sh --add` / `init.sh --remove` に統合
- `scripts/` を `script/` に、`workspaces/` を `workspace/` にリネーム

### 修正
- setup.sh パスを `template/script/docker/setup.sh` に変更（旧 `docker_template/setup.sh`）、template 形式の repo をサポート

### テスト
- `template` を git subtree（v0.8.1）として追加し、テストで実際の template 形式のフィクスチャをスキャフォールド可能に
- 偽の `mock_with_setup` フィクスチャを削除し、DinD 内で `template/init.sh` を実行して実リポ構造を生成する動的 E2E テストに置換
- カバレッジ ignore マーカーを全て削除（`# pragma: no cover`、`script/` kcov 除外、codecov `script/**/*` ignore）— 100% カバレッジが真実になり隠蔽なし
- 3 つのエラーメッセージ regression test を追加（`No workspace found`、`No compose.yaml`、`Failed to resolve compose`）
- `test_script_executes_as_main` を追加し、`runpy.run_path` で `if __name__ == "__main__"` ガードをカバー
- 最終カバレッジ：bash 127/127 (100%)、Python 32/32 (100%)、Bats 47 件 + Python 11 件 = 58 件

### 修正（本 PR）
- `_get_workspace_paths` は未登録時に空行を出力し、`mapfile` が空文字列 1 要素を含む配列を生成（空配列ではなく）。`_generate_compose` が `[""]` を受け取り `No workspace found` ガードをスキップ、`No compose.yaml` エラーに到達 — 間違ったメッセージ。非空時のみ出力するよう修正。

### テスト済みシナリオ
- 異なるワークスペース、異なるリポ
- 同ワークスペース、異なるリポ
- 異なるワークスペース、同リポ
