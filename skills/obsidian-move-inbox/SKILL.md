---
name: obsidian-move-inbox
description: 搬移 0_inbox 中已完成（completed 有值）的筆記到對應目錄。當用戶說「搬移 inbox」、「move inbox」、「清 inbox」時使用。支援指定單篇或多篇檔案。
argument-hint: "[檔案名稱1, 檔案名稱2, ...]（可選，不指定則掃描整個 inbox）"
---

# Move Inbox

搬移 `0_inbox/` 中 `completed` 欄位有值的筆記到對應的目的地目錄。

## 使用模式

1. **整批模式**（無參數）：掃描整個 `0_inbox/`，列出所有可搬移的筆記
   - 例：「搬移 inbox」、「move inbox」
2. **指定檔案模式**（有參數）：只處理用戶指定的檔案
   - 例：「move inbox SPF.md」、「搬移 inbox SPF.md, admin.md」
   - 接受檔案名稱（不含路徑），自動在 `0_inbox/` 下查找
   - 找不到的檔案在報告中標註「檔案不存在」

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **Vault 名稱**: `{Vault name}`
- **Inbox 目錄**: `{Inbox}`
- **Projects 目錄**: `{Projects}`
- **Resources 目錄**: `{Resources}`
- **Archives 目錄**: `{Archives}`
- **Side 目錄**: `{Side}`

## 前置檢查：偵測 Obsidian 官方 CLI

```bash
obsidian version 2>/dev/null && echo "CLI_AVAILABLE" || echo "CLI_UNAVAILABLE"
```

- `CLI_AVAILABLE` → 搬移操作優先使用官方 CLI（需要 Obsidian app 在背景執行）
- `CLI_UNAVAILABLE` → 使用 Bash `mv` 模式

## 排除清單

以下不處理（直接跳過）：
- `0_inbox/01promt/` — prompt 收集子資料夾
- 檔名以 `Untitled` 開頭的檔案
- `.base` 結尾的檔案

## 前提條件

- 只搬移 `completed` **有值**的筆記
- `completed` 為空 / null / 無此欄位 → 留在 inbox，報告中標註「尚未完成」

## 目的地查找規則（依 `project` 欄位）

1. `project` 為 null / 空 / 無此欄位 → **`2_Resources/`**
2. `project` 有值 → 依序檢查目錄是否存在：
   - `{Projects 目錄}{project}/` → 存在就搬
   - `{Archives 目錄}{project}/` → 存在就搬
   - `{Side 目錄}{project}/` → 存在就搬
   - 都找不到 → **留在 inbox**，標註「專案目錄不存在」

**注意：此 skill 不自行推斷 project 歸屬，完全依賴用戶已填入的 `project` 值。**

## 執行步驟

### Step 1：取得待處理檔案

- **整批模式**：列出 `{Inbox 目錄}` 下所有 `.md` 檔案（僅根目錄，不含子資料夾），排除「排除清單」中的項目。
- **指定檔案模式**：只處理用戶指定的檔案名稱，在 `{Inbox 目錄}` 下查找。找不到的檔案記錄下來，在報告中標註。排除清單不適用（用戶明確指定的檔案一律處理）。

### Step 2：篩選分類

讀取每篇筆記的 frontmatter，分為：
- **可搬移**：`completed` 有值（非空、非 null）
- **尚未完成**：`completed` 為空 / null / 無此欄位

### Step 3：產生分流報告

將所有筆記整理成一份表格：

```
| # | 檔案名稱 | completed | 目的地 | 專案 | 備註 |
|---|----------|-----------|--------|------|------|
| 1 | xxx.md   | 2026-03-01T14:30 | 2_Resources | — | |
| 2 | yyy.md   | 2026-03-02T10:00 | 1_Projects/a126 | a126 | |
| 3 | zzz.md   | 2026-03-02T15:00 | 4_side/beer | beer | |
| 4 | aaa.md   |           | 留在 inbox | — | 尚未完成 |
| 5 | bbb.md   | 2026-03-03T09:00 | 留在 inbox | q99 | 專案目錄不存在 |
```

在表格末尾附上統計摘要：
- N 篇 → 2_Resources
- N 篇 → 1_Projects（各專案分別列出）
- N 篇 → 3_Archives（各專案分別列出）
- N 篇 → 4_side（各專案分別列出）
- N 篇 → 留在 inbox（尚未完成）
- N 篇 → 留在 inbox（專案目錄不存在）

### Step 4：等待用戶確認

使用 AskUserQuestion 詢問用戶：「以上分流建議是否 OK？你可以指定調整某幾篇的目的地。」

選項：
- 全部執行
- 我想調整部分（讓用戶輸入調整內容）
- 取消

若用戶要求調整，修改對應項目後重新顯示表格，再次確認。

### Step 5：執行搬移

確認後，依序處理每篇可搬移的筆記。

---

#### 官方 CLI 模式（優先）— 自動更新內部連結

**搬到 2_Resources：**
```bash
obsidian move file="{filename}" to=2_Resources/
obsidian properties:set file="{filename}" type=zettelkasten
obsidian properties:set file="{filename}" project=null
```

**搬到 1_Projects、3_Archives 或 4_side：**
```bash
obsidian move file="{filename}" to=1_Projects/{project}/
# 或
obsidian move file="{filename}" to=3_Archives/{project}/
# 或
obsidian move file="{filename}" to=4_side/{project}/
```

> 官方 CLI 不需要 `vault=` 參數。`obsidian move` 會自動更新 vault 中所有指向該檔案的內部連結 `[[]]`。

---

#### Fallback 模式（無 CLI）

**搬到 2_Resources 的檔案：**
1. 用 Bash `mv` 搬移檔案到 `{Resources 目錄}`
2. 更新 frontmatter：
   - 設定 `type: zettelkasten`
   - 設定 `project: null`（通用知識不隸屬特定專案）
   - 保留原有的 `completed`、`status`、`tags`、`keywords` 等欄位

**搬到 1_Projects、3_Archives 或 4_side 的檔案：**
1. 用 Bash `mv` 搬移檔案到對應的專案目錄
2. 保留原有 frontmatter（`project` 值不變）

> Fallback 模式不會自動更新內部連結，搬移後可能需手動修正 `[[]]` 連結。

---

#### 專案目錄不存在的檔案：
- 不做任何操作，留在 inbox

### Step 6：完成報告

告知用戶：
- 搬移了幾篇、各去向幾篇
- 若排除清單外的 inbox 已清空，顯示「Inbox 已清空」
- 否則顯示剩餘幾篇尚未處理
