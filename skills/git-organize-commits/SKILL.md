---
name: git-organize-commits
description: Organize multiple unrelated file changes in git working directory into separate, logical commits. Use when user has many uncommitted changes that should be split into distinct commits.
---

# Git 變更整理與分組 Commit

將工作目錄中的多個不相關變更，整理成獨立且邏輯清晰的 commits。

## 路徑參數

若呼叫時有傳入路徑（例如 `/git-organize-commits /path/to/repo`），**所有 git 指令必須在該路徑下執行**：

```bash
cd /path/to/repo && git status
cd /path/to/repo && git diff
cd /path/to/repo && git add <files>
cd /path/to/repo && git commit -m "..."
```

未傳入路徑時，使用當前工作目錄。

## 工作流程

1. **確認工作目錄**：有路徑參數則切換至該路徑，再執行 `git status` 和 `git diff` 分析所有變更
2. **識別群組**：根據 **目錄相依性 (Directory Affinity)** 和內容識別邏輯群組
    - 優先將 **同一資料夾內** 的新增與修改視為同一組變更
    - 檢查是否有漏掉同目錄下的 Untracked files (`git add` 新增的檔案)
3. **提出計畫**：列出群組及每個 commit 包含的檔案，等待確認
4. **分步執行**：逐一處理每個群組
5. **精準暫存**：只將該群組相關檔案加入 stage
6. **撰寫訊息**：使用 Conventional Commits 格式（`type(scope): description`）
7. **重複流程**：完成後展示剩餘變更，直到工作目錄乾淨

## Commit 格式

```
<type>(<scope>): <subject>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

詳細定義請參考：[Commit Types Reference](commit-types.md)

## 注意事項

- 永遠先 `git status` 確認狀態
- 避免 commit 敏感檔案（`.env*`, `*.key`, `credentials.json`）
- 不自動 push，除非明確要求
