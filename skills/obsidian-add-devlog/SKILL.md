---
name: obsidian-add-devlog
description: 建立輕量隨記筆記，用於捕捉一閃而過的靈感、公司指派的任務、或任何尚未開始的想法。當用戶說「記一下」、「add-devlog」、「隨記」、「靈感」、「指派任務」時使用。
argument-hint: "[可選：筆記主題或內容簡述]"
---

# Add DevLog — 輕量隨記

快速建立一篇隨手記筆記，不要求完整結構，重點是**低摩擦地把想法留下來**。

> Frontmatter 欄位規格依照 `[[frontmatter-schema.md]]`，type 固定為 `devlog`。

## 固定路徑設定

- **Vault 根目錄**: `/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/`
- **存放目錄**: `0_inbox/`

## 筆記類型（status）

依照 `[[frontmatter-schema.md]]` Status 選項表，type = `devlog` 的選項：`assigned` / `note` / `open` / `workaround` / `resolved`

## 執行步驟

### Step 1：取得內容

- 若用戶有提供 `$ARGUMENTS` → 直接作為主題／內容
- 若無 → 從當前對話 context 提取用戶想記錄的內容

### Step 2：判斷 status

根據內容判斷：
- 「老闆說要做…」、「被指派了…」、「需要處理…」→ `assigned`
- 純粹觀察、備忘 → `note`
- 有明確問題但尚未解決 → `open`
- 有完整解法 → `resolved`
- 有暫時繞過方法 → `workaround`

### Step 3：產生時間與 ID

```bash
date +"%Y%m%d%H%M%S"    # id
date +"%Y-%m-%dT%H:%M"  # updated / completed
date +"%Y-%m-%d %H:%M"  # date created / date modified
```

### Step 4：產生 keywords 與 tags

依照 `[[frontmatter-schema.md]]` 規則：
- **keywords**：3-8 個英文技術關鍵字，全小寫，連字號連接
- **tags**：參考 `2_Resources/_Index.md` Tag 清單選 1-3 個（⚠️ 全部英文）
- 若內容太簡短、無技術關鍵字 → keywords / tags 可留空陣列 `[]`

### Step 5：決定檔名

格式：`{簡短主題}.md`，能一眼看出內容即可。

### Step 6：建立筆記

使用 Write 工具建立。Frontmatter 依照 `[[frontmatter-schema.md]]` devlog 規格填入所有欄位，`type` 固定為 `devlog`。

內容格式：

```markdown
<用戶的內容，盡量保留原話，不要過度整理>

## 下一步
（可選，若內容有明確的行動項目才填，否則省略）
```

### Step 7：回報

告知：
- 筆記標題與存放路徑
- status
