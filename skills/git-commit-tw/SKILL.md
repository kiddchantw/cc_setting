---
name: git-commit-tw
description: Generate professional Git commit messages following Conventional Commits specification with Traditional Chinese descriptions, and automatically handle git staging and committing. Use when the user asks to create, write, or generate a git commit, or needs to commit changes with Chinese messages.
---

# Git Commit 訊息產生器與自動提交

專為產生符合 Conventional Commits 規範且使用繁體中文描述的 Git commit 訊息而設計，並自動處理 git staging 和 commit 操作。

## 基本格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Header（必要）

格式：`<type>(<scope>): <subject>`

- **type**（必要）：commit 的類別，必須是以下之一：
  - `feat`: 新增/修改功能
  - `fix`: 修補 bug
  - `docs`: 文件變更
  - `style`: 格式調整（不影響程式碼運行）
  - `refactor`: 重構
  - `perf`: 效能改善
  - `test`: 測試相關
  - `chore`: 建構或工具變動
  - `revert`: 撤銷先前的 commit

- **scope**（選用）：影響範圍，例如：模組名稱、功能區域、檔案名稱
  - 如變更範圍廣泛或難以定義，可省略

- **subject**（必要）：簡短描述
  - 不超過 50 個字元
  - 使用繁體中文
  - 結尾不加句號
  - 使用祈使句或陳述句

### Body（選用）

詳細說明本次變更：

- 每行不超過 72 個字元
- 使用繁體中文
- 說明程式碼變動的項目與原因
- 與先前行為的對比
- 可分多段，段落間空一行

### Footer（選用）

- **任務編號**：關聯的 Issue 或 Ticket 編號
  - 格式：`Refs: #123` 或 `Closes: #456`
  
- **Breaking Changes**：不相容的重大變更
  - 以 `BREAKING CHANGE:` 開頭
  - 說明變動內容、原因及遷移方法

## 執行步驟

1. **檢查 Git 狀態**
   - 執行 `git status` 查看目前的變更狀態
   - 識別已修改（M）、新增（??）、已刪除（D）的檔案
   - 列出所有變更給使用者確認

2. **分析程式碼變更**
   - 使用 `git diff` 檢視已修改檔案的具體變更
   - 使用 `git diff --staged` 檢視已 staged 的變更
   - 識別變更的主要目的和影響範圍
   - 判斷適合的 type 和 scope

3. **詢問使用者**
   - 列出所有變更的檔案清單
   - 詢問使用者要 commit 哪些檔案
   - 如果有新增檔案（untracked files），特別確認是否要包含
   - 選項：
     * 全部檔案（包含新增檔案）
     * 只有已修改的檔案（排除新增檔案）
     * 自訂選擇特定檔案

4. **Stage 檔案**
   - 根據使用者選擇執行對應的 `git add` 指令：
     * 全部：`git add .`
     * 已修改：`git add -u`
     * 特定檔案：`git add <file1> <file2> ...`
   - 再次執行 `git status` 確認 staged 的檔案

5. **撰寫 Commit 訊息**
   - **Header**：選擇正確的 type，若適用加入 scope，用一句話總結變更（不超過 50 字元）
   - **Body**（如需要）：列點說明主要變更項目，解釋變更原因和影響
   - **Footer**（如需要）：加入相關的任務編號，標記 Breaking Changes

6. **執行 Commit**
   - 使用 HEREDOC 格式執行 git commit，確保訊息格式正確
   - 指令範例：
     ```bash
     git commit -m "$(cat <<'EOF'
     feat(auth): 新增 Google OAuth 登入功能

     - 整合 Google OAuth 2.0 認證流程
     - 新增使用者資料同步機制

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     EOF
     )"
     ```

7. **確認結果**
   - 執行 `git log -1` 查看剛建立的 commit
   - 執行 `git status` 確認工作目錄狀態
   - 向使用者報告 commit 成功訊息

## 範例

### 範例 1：簡單功能新增

```
feat(auth): 新增 Google OAuth 登入功能

- 整合 Google OAuth 2.0 認證流程
- 新增使用者資料同步機制
- 更新登入頁面 UI

Refs: #234
```

### 範例 2：Bug 修復

```
fix(cart): 修正購物車總價計算錯誤

當購物車包含折扣商品時，總價計算不正確。
現已修正折扣金額的計算邏輯，確保總價準確。

Closes: #456
```

### 範例 3：重大變更

```
feat(api): 更新 API 回應格式為 RESTful 標準

- 統一所有 API 端點的回應結構
- 改用標準 HTTP 狀態碼
- 加入分頁支援

BREAKING CHANGE: API 回應格式已變更。
舊格式：{ data: [], status: "success" }
新格式：{ data: [], meta: { status: 200 } }

遷移方法：請更新前端 API 串接邏輯，參考新的 API 文件。

Refs: #789
```

### 範例 4：無 Body 的簡短 Commit

```
docs(readme): 更新安裝說明
```

## 類型選擇指南

不確定使用哪個 type 時，請參考 `references/commit-types.md` 取得詳細說明和更多範例。

## 注意事項

### Commit 訊息規範
- Subject 使用繁體中文，簡潔明瞭
- Body 和 Footer 同樣使用繁體中文
- 優先考慮可讀性和實用性
- 如變更簡單明確，Body 可省略
- Breaking Changes 務必明確標示
- Scope 若不明確可省略，不要強加

### Git 操作注意事項
- **永遠先檢查 git status**：了解當前狀態再進行操作
- **新增檔案需要明確確認**：避免意外 commit 不該提交的檔案（如 `.env`、credentials 等）
- **敏感檔案警告**：如果發現以下檔案，必須警告使用者：
  - `.env`、`.env.local` 等環境變數檔案
  - `credentials.json`、`secrets.json` 等憑證檔案
  - `*_rsa`、`*.pem`、`*.key` 等金鑰檔案
  - `node_modules/`、`vendor/` 等依賴目錄（應該在 .gitignore 中）
- **使用 HEREDOC 格式**：確保多行 commit 訊息格式正確
- **加入 Claude Code 署名**：所有 commit 都應包含 Claude Code 產生標記
- **pre-commit hooks**：如果 commit 失敗且有 pre-commit hook 修改，最多重試一次（使用 amend）
- **不要自動 push**：除非使用者明確要求，否則不要執行 `git push`
