# テストドキュメント

合計 **58 件**（Bats 47 件 + Python 11 件）。カバレッジ：bash 100% (127/127)、Python 100% (32/32)。

## test/multi_run_spec.bats（47 件）

### ファイル存在 + 実行可能（5）

| テスト項目 | 説明 |
|------------|------|
| `init.sh exists and is executable` | ファイルチェック |
| `run.sh exists and is executable` | ファイルチェック |
| `exec.sh exists and is executable` | ファイルチェック |
| `stop.sh exists and is executable` | ファイルチェック |
| `status.sh exists and is executable` | ファイルチェック |

### シェル規約（5）

| テスト項目 | 説明 |
|------------|------|
| `init.sh uses set -euo pipefail` | シェル規約 |
| `run.sh uses set -euo pipefail` | シェル規約 |
| `exec.sh uses set -euo pipefail` | シェル規約 |
| `stop.sh uses set -euo pipefail` | シェル規約 |
| `status.sh uses set -euo pipefail` | シェル規約 |

### ヘルプフラグ（8）

| テスト項目 | 説明 |
|------------|------|
| `init.sh -h exits 0` | Help 正常終了 |
| `run.sh -h exits 0` | Help 正常終了 |
| `exec.sh -h exits 0` | Help 正常終了 |
| `stop.sh -h exits 0` | Help 正常終了 |
| `status.sh -h exits 0` | Help 正常終了 |
| `init.sh -h prints usage` | 出力に "Usage:" を含む |
| `run.sh -h prints usage` | 出力に "Usage:" を含む |
| `stop.sh -h prints usage` | 出力に "Usage:" を含む |

### ワークスペース管理 via init.sh（8）

| テスト項目 | 説明 |
|------------|------|
| `init.sh --add creates symlink in workspace/` | symlink 作成 |
| `init.sh --remove deletes symlink from workspace/` | symlink 削除 |
| `init.sh --list works` | 登録済みワークスペース表示 |
| `init.sh --add fails without arguments` | パス未指定時エラー |
| `init.sh --add fails for non-existent path` | 無効パス時エラー |
| `init.sh --add reports already exists for duplicate` | 重複検出 |
| `init.sh --remove fails without arguments` | 名前未指定時エラー |
| `init.sh --remove fails for non-existent name` | 名前不存在時エラー |

### lib.sh 関数（7）

| テスト項目 | 説明 |
|------------|------|
| `_log outputs [multi] prefix` | ログ形式 |
| `_error outputs ERROR prefix and exits 1` | エラー形式 + exit code |
| `_path_id generates unique ID from path` | ID 形式：`{IMAGE_NAME}_{hash}` |
| `_path_id falls back to dirname when no .env` | .env 無し時ディレクトリ名にフォールバック |
| `_path_id generates different ID for same repo different ws` | パスごとに異なるハッシュ |
| `_get_workspace_paths returns empty for empty workspace dir` | 空ディレクトリスキャン |
| `_get_workspace_paths returns symlink targets` | 解決済みターゲットを返す |

### エッジケース（4）

| テスト項目 | 説明 |
|------------|------|
| `_get_workspace_paths ignores non-symlinks` | 非 symlink をフィルタ |
| `status.sh -h prints usage` | 出力に "Usage:" を含む |
| `exec.sh fails without arguments` | サービス名未指定時エラー |
| `init.sh --list shows empty when workspace dir missing` | 存在しないディレクトリを処理 |

### 統合テスト（7、Docker daemon 必要）

| テスト項目 | 説明 |
|------------|------|
| `full lifecycle: init -> run -> status -> exec -> stop with mock repo` | エンドツーエンド直接パスモード |
| `workspace scan mode: add -> init (no args) -> run -> stop` | エンドツーエンド workspace モード |
| `init.sh fails with invalid workspace path` | 存在しないパス時エラー |
| `init.sh fails for repo without .env and no setup.sh` | .env 欠落時エラー |
| `e2e: init.sh uses real template setup.sh to generate .env` | 実 `template/init.sh` でリポをスキャフォールドし、multi_run が `template/script/docker/setup.sh` を呼び出して `.env` を自動生成することを検証 |
| `status.sh shows no active session when compose file missing` | セッション無し時の正常処理 |
| `init.sh --list shows registered workspace` | symlink 付きワークスペース表示 |

### エラーメッセージ regression（3）

| テスト項目 | 説明 |
|------------|------|
| `init.sh (no args, empty workspace) fails with 'No workspace found'` | 未登録時のエラーメッセージ |
| `init.sh fails with 'No compose.yaml' when repo lacks compose.yaml` | compose.yaml 欠落時エラー |
| `init.sh fails with 'Failed to resolve compose' on malformed compose.yaml` | 不正 YAML 時エラー（Docker 必要） |

## test/test_resolve_compose.py（11 件）

### resolve() 関数（6）

| テスト項目 | 説明 |
|------------|------|
| `test_extracts_devel_service` | devel サービスの抽出・リネーム |
| `test_removes_container_name` | container_name フィールド削除 |
| `test_skips_when_no_devel_service` | devel 無し時サイレントスキップ |
| `test_fails_on_empty_input` | 空入力時エラー |
| `test_output_is_indented` | 出力の正しいインデント |
| `test_preserves_environment_and_volumes` | 環境変数と volume 設定を保持 |

### main() 関数（5）

| テスト項目 | 説明 |
|------------|------|
| `test_main_no_args` | 引数未指定時 exit 1 で usage 表示 |
| `test_main_normal` | 正常時 YAML を stdout に出力 |
| `test_main_error` | 空入力時エラー出力 |
| `test_main_no_devel` | devel 無し時 exit 0 |
| `test_script_executes_as_main` | `runpy.run_path` で `if __name__ == '__main__'` をカバー |
