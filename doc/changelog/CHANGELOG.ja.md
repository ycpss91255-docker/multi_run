# 変更履歴

フォーマットは [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) に基づき、
バージョン番号は[セマンティックバージョニング](https://semver.org/spec/v2.0.0.html)に準拠。

## [未リリース]

### 追加
- 7 スクリプト：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`、`add.sh`、`remove.sh`
- `lib.sh`：共有関数（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `workspaces/` ディレクトリ：symlink ベースのワークスペース管理
- `docker compose config` 展開 + Python サービスリネーム（ユニークサービス名）
- 26 件の Bats テスト + ShellCheck
- 2 モード：workspace symlink スキャン / 直接パス引数
- CI：ShellCheck + Bats（docker compose 経由）

### テスト済みシナリオ
- 異なるワークスペース、異なるリポ
- 同ワークスペース、異なるリポ
- 異なるワークスペース、同リポ
