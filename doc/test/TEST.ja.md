# テストドキュメント

合計 **26 件**。

## test/multi_run_spec.bats

### ファイル存在 + 実行可能（7）

| テスト項目 | 説明 |
|------------|------|
| `* exists and is executable` | 全スクリプト（7 件） |

### シェル規約（7）

| テスト項目 | 説明 |
|------------|------|
| `* uses set -euo pipefail` | 全スクリプト（7 件） |

### ヘルプフラグ（8）

| テスト項目 | 説明 |
|------------|------|
| `* -h exits 0` | 全スクリプト（7 件） |
| `init.sh -h prints usage` | 出力に "Usage:" を含む |

### ワークスペース管理（2）

| テスト項目 | 説明 |
|------------|------|
| `add.sh creates symlink in workspaces/` | symlink 作成 |
| `remove.sh deletes symlink from workspaces/` | symlink 削除 |

### パス ID（2）

| テスト項目 | 説明 |
|------------|------|
| `_path_id generates unique ID from path` | ID 形式：`{IMAGE_NAME}_{hash}` |
| `_path_id generates different ID for same repo different ws` | パスごとに異なるハッシュ |
