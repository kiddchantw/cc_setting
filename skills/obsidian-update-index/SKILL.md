---
name: obsidian-update-index
description: 更新指定專案資料夾的 _index_*.md。支援兩種模式：(1) 增量更新—只補入尚未列於 index 的新筆記，(2) 完整重建—重新掃描整個資料夾。當用戶說「更新 index」、「update-index」、「obsidian-update-index」、「搬完更新一下 index」時使用。
argument-hint: "[資料夾名稱或路徑] [--rebuild]（例：a126、1_Projects/claw、a126 --rebuild）"
---

# Obsidian Update Index

更新指定專案資料夾的 `_index_*.md`，讓 agent 的入口索引隨時反映最新的筆記狀態。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **Vault 名稱**: `{Vault name}`

## 兩種執行模式

| 模式 | 觸發條件 | 說明 |
|------|---------|------|
| **增量更新**（預設） | index 已存在 且 未帶 `--rebuild` | 只補入 index 裡尚未列出的新筆記摘要 |
| **完整重建** | index 不存在，或帶 `--rebuild`，或資料夾工作筆記 < 5 篇 | 重新掃描整個資料夾，重建完整 index |

## 排除規則（兩種模式通用）

掃描工作筆記時，以下內容**不列入 index 摘要**：

- 資料夾名含 `imported_docs` 的子資料夾（從 repo 匯入的技術文件）
- `_index_*.md` 本身
- `README_*.md`（人類可讀版 index）
- `CLAUDE.md`、`README.md`（系統 / 說明文件）
- `_Archive/` 子資料夾（已歸檔，另外以區塊說明）
- 檔名以 `test-` 開頭或含 `_TEMPLATE` 的筆記（測試 / 模板）

## 執行步驟

### Step 0：解析參數

從 `$ARGUMENTS` 解析：

1. **目標資料夾**：可接受以下格式
   - 專案名稱（如 `a126`）→ 依序搜尋 `1_Projects/a126/`、`3_Archives/a126/`、`4_side/a126/`
   - 相對路徑（如 `1_Projects/claw`）→ 直接使用
   - 若未提供 → 詢問用戶：「請問要更新哪個資料夾的 index？」

2. **模式 flag**：
   - 有 `--rebuild` → 強制完整重建模式
   - 無 `--rebuild` → 預設增量更新（若 index 不存在自動切換重建）

### Step 1：定位 `_index_*.md`

```
Glob: {target_folder}/_index_*.md
```

- 找到 → 進入 Step 2A（增量）或 Step 2B（重建）
- 找不到 → 切換為完整重建模式，進入 Step 2B

### Step 2A：增量更新模式

#### 2A-1. 讀取現有 index

讀取 `_index_*.md`，從 `[[wikilink]]` 中提取**已列出的筆記名稱清單**。

#### 2A-2. 掃描目標資料夾

列出目標資料夾的所有 `.md` 工作筆記（依排除規則過濾），找出**不在現有 index 清單中的新筆記**。

若無新筆記 → 回報「index 已是最新，無需更新」，結束。

#### 2A-3. 讀取新筆記並生成摘要

對每篇新筆記：
1. 讀取前 40 行（frontmatter + 第一段內容）
2. 生成一句話摘要（20-35 字，說明這篇在講什麼）
3. 判斷 `completed` 欄位：
   - 有值 → 歸入「已完成」區塊
   - 空值或無欄位 → 歸入「進行中」區塊

#### 2A-4. 插入新摘要行

將新摘要行插入 index 的正確區塊：
- 「進行中」區塊：插在該區塊的最後一行
- 「已完成」區塊：插在該區塊的最後一行
- 若 index 沒有對應區塊 → 在文件末尾新增區塊

更新 frontmatter 的 `date modified` 為今天日期。

---

### Step 2B：完整重建模式

#### 2B-1. 掃描所有工作筆記

列出目標資料夾的所有 `.md` 工作筆記（依排除規則過濾）。

#### 2B-2. 讀取並生成摘要

**並行讀取**所有工作筆記（讀前 40 行），為每篇生成一句話摘要。

按 `completed` 欄位分組：
- 有值 → 已完成
- 空值或無欄位 → 進行中

#### 2B-3. 處理子資料夾

若目標資料夾有**非 imported / 非 _Archive 的子資料夾**（如 `zeroclaw/`、`openclaw/`）：
- 同樣掃描並生成摘要
- 在 index 裡以獨立區塊呈現（`## zeroclaw/ 筆記`）

若有 `_Archive/` 子資料夾：
- **不重新讀取**所有 archive 筆記
- 若現有 index 已有 `_Archive/` 區塊 → 保留不動
- 若沒有 → 加一行說明：`> 已歸檔筆記，如需查詢請直接搜尋 _Archive/ 子資料夾`

若有 `imported_docs*/` 子資料夾：
- 以一行說明取代：`- \`imported_docs*/\` — 從 repo 匯入的技術文件，按需直接搜尋`

#### 2B-4. 寫入 `_index_*.md`

使用以下格式：

```markdown
---
date created: {原有建立日期，若無則填今天}
date modified: {今天日期 YYYY-MM-DD HH:mm}
project: {專案名}
type: reference
tags: [index, {專案名}]
---

# {專案名大寫} — Agent Index

> 給 Claude Code 讀的摘要索引。先讀此檔定位目標筆記，再決定是否深入讀全文。

---

## 工作筆記

### 進行中

- [[筆記名]] — 一句話摘要

### 已完成（查歷史用）

- [[筆記名]] — 一句話摘要（completed: 日期）

---

## {子資料夾}/ 筆記（若有）

...

---

## 已歸檔（_Archive/）

> 全部 completed。如需查詢歷史問題請直接搜尋 `_Archive/` 子資料夾，或參考舊版 index 記錄。

---

## 技術文件（imported_docs — 數量多，按需搜尋）

> 從 repo 匯入的技術文件，不逐篇摘要。

- `imported_docs*/` — 說明用途
```

---

### Step 3：完成報告

回報結果：

```
✅ _index_{專案名}.md 已更新

模式：增量更新 / 完整重建
新增摘要：N 篇（進行中 X 篇、已完成 Y 篇）
略過：N 篇（imported_docs / _Archive / 測試筆記）
```

---

## 注意事項

- `type: reference` 是 CLAUDE.md 規定，`_index*.md` 必須使用此 type
- 純靜態列表，**不使用 Dataview**（Dataview 對 CLI / agent 無用）
- 摘要語言：繁體中文，20-35 字
- 若資料夾不存在，回報錯誤並結束
- 若 index 已是最新（無新筆記），明確告知用戶，不重複寫入
