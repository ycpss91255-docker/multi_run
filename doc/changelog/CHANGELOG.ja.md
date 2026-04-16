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

### テスト済みシナリオ
- 異なるワークスペース、異なるリポ
- 同ワークスペース、異なるリポ
- 異なるワークスペース、同リポ
