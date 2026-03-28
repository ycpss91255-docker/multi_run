
## docker_template 改名為 template

GitHub URL 已經是 `ycpss91255-docker/docker_template`，`docker_` 前綴冗餘。

**影響範圍**：
- 15 個 consumer repo 的 subtree prefix `docker_template/`
- 所有腳本路徑引用（`docker_template/setup.sh`、`docker_template/config/`）
- CLAUDE.md、README、CI workflows
- 需要 v3.0.0 BREAKING CHANGE

**何時實施**：下次大版本更新時。
