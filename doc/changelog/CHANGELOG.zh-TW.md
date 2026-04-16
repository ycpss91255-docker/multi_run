# 變更記錄

格式基於 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)，
版本號遵循[語意化版本](https://semver.org/spec/v2.0.0.html)。

## [未發布]

### 新增
- 5 個腳本：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`
- `init.sh` 子指令：`--add`、`--remove`、`--list`（工作區管理）
- `lib.sh`：共用函式（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `resolve_compose.py`：從展開的 compose YAML 提取並重命名 devel service
- `workspace/` 目錄：基於 symlink 的工作區管理
- `docker compose config` 展開 + Python service 重命名（唯一 service name）
- 兩種模式：workspace symlink 掃描 / 直接路徑參數
- 58 個測試（47 Bats + 11 Python）+ ShellCheck
- CI：ShellCheck + Bats + Python coverage + Kcov（透過 docker compose，DinD）
- Codecov 整合

### 變更
- 合併 `add.sh` / `remove.sh` 至 `init.sh --add` / `init.sh --remove`
- 重命名 `scripts/` 為 `script/`、`workspaces/` 為 `workspace/`

### 修正
- setup.sh 路徑改為 `template/script/docker/setup.sh`（原為 `docker_template/setup.sh`），支援 template 格式的 repo
- README（4 語言）：把過時的 `docker_template` 連結更新為現行的 `template` repo。CHANGELOG 中描述歷史改名的條目保留不動。

### 測試
- 加入 `template` git subtree（v0.8.1），讓測試可以 scaffold 出真實的 template 格式 fixture
- 移除假的 `mock_with_setup` fixture，改用動態 E2E：在 DinD 裡跑 `template/init.sh` 產出真實 repo 結構，再讓 multi_run 對它操作
- 移除所有覆蓋率 ignore marker（`# pragma: no cover`、`script/` kcov exclusion、codecov `script/**/*` ignore），讓 100% 覆蓋率是真實的不是假的
- 加入 3 個錯誤訊息 regression test（`No workspace found`、`No compose.yaml`、`Failed to resolve compose`）
- 加入 `test_script_executes_as_main`，用 `runpy.run_path` 覆蓋 `if __name__ == "__main__"` guard
- 最終覆蓋率：bash 127/127 (100%)、Python 32/32 (100%)、47 Bats + 11 Python = 58 tests

### 修正（本 PR）
- `_get_workspace_paths` 在沒有註冊任何 workspace 時會印出一個空行，導致 `mapfile` 得到含一個空字串的陣列（而非空陣列）。`_generate_compose` 收到 `[""]` 會跳過 `No workspace found` 檢查，直接跑到 `No compose.yaml` — 錯誤訊息不對。修正為只在非空時印出。

### 已測試場景
- 不同工作區、不同 repo
- 同工作區、不同 repo
- 不同工作區、同 repo
