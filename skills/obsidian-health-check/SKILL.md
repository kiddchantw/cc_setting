---
name: obsidian-health-check
description: 定期掃描 vault 健康狀況。找出孤立筆記（無人引用）、未解決問題（open devlog）、與潛在跨主題連結（keywords 重疊但尚未連結）。當用戶說「health check」、「掃 vault」、「健康檢查」、「找孤立筆記」時使用。
argument-hint: "[範圍：all / resources / inbox，預設 all]"
---

# Obsidian Health Check

掃描 vault 健康狀況，產出三維度報告並提供具體行動建議。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **掃描範圍**（預設 all）：
  - `0_inbox/`
  - `1_Projects/`
  - `2_Resources/`
  - `3_Archives/`
  - `4_side/`
- **排除目錄**：`5_Pic/`、`Templates/`、`.claude/`

---

## 執行步驟

### Step 1：收集基礎資料

**1A — 取得所有筆記路徑**

```bash
find "{Vault root}" \
  -path "{Vault root}/5_Pic" -prune -o \
  -path "{Vault root}/Templates" -prune -o \
  -path "{Vault root}/.claude" -prune -o \
  -name "*.md" -print \
  | grep -v "_Archive/"
```

記錄：總筆記數量。

**1B — 收集全 vault 的 wikilink 引用清單**

```bash
grep -rh "\[\[" "{Vault root}" \
  --include="*.md" \
  --exclude-dir="5_Pic" \
  --exclude-dir="Templates" \
  --exclude-dir=".claude"
```

從輸出中提取所有 `[[note-name]]` 或 `[[note-name|alias]]` 中的 `note-name`（去除路徑前綴、副檔名、alias 部分），建立「被引用筆記名稱集合」。

---

### Step 2：三維度掃描

#### 維度一：孤立筆記（Orphaned Notes）

**定義**：在整個 vault 中，沒有任何筆記以 `[[檔名]]` 形式引用到它的筆記。

**邏輯**：
1. 對每篇筆記，取其檔名（不含副檔名，不含路徑）
2. 檢查「被引用名稱集合」中是否存在該名稱
3. 不存在 → 孤立筆記

**範圍**：優先掃描 `2_Resources/`（最應被引用），其次 `3_Archives/`。`0_inbox/` 的筆記尚未整理，不列入。

**上限**：最多回報 20 篇。若超過 20 篇，顯示數量並只列最舊的 20 篇（按 `updated` 欄位排序）。

---

#### 維度二：懸案清單（Open Issues）

**定義**：`type: devlog` 且 `resolution: open` 的筆記，代表已知問題尚未解決。

**搜尋**：

```bash
grep -rl "resolution: open" "{Vault root}" --include="*.md"
```

對每個結果，讀取 frontmatter 取得：`project`、`updated`、筆記標題（檔名）。

**補充**：也找出 `type: session` 且 `status: draft` 且 `updated` 超過 30 天的筆記（可能是被遺忘的計劃）。

---

#### 維度三：潛在連結（Missing Links）

**定義**：兩篇筆記的 `keywords` 有 2 個以上重疊，但彼此都沒有 wikilink 引用對方。

**邏輯**：
1. 用 Grep 收集所有筆記的 `keywords:` 欄位
2. 建立 `{筆記名稱 → keywords 陣列}` 對照表
3. 對 `2_Resources/` 的筆記，兩兩比對 keywords 重疊數
4. 重疊 ≥ 2 個 且 互無 wikilink → 列為「潛在連結」

**上限**：最多回報 10 組。依重疊關鍵字數量降序排列。

> ⚠️ 此步驟較耗時，若筆記超過 200 篇，只比對 `2_Resources/` 內的筆記。

---

### Step 3：產出報告

以下列格式輸出健康報告：

```
## 🏥 Vault Health Check — {執行日期}

> 掃描範圍：{N} 篇筆記  |  耗時：約 {估算}

---

### 🔴 維度一：孤立筆記（{N} 篇）

| # | 筆記 | 所在目錄 | 最後更新 | 建議行動 |
|---|------|----------|----------|----------|
| 1 | [[xxx]] | 2_Resources | 2025-10-01 | 連結到 [[相關筆記]] 或移入 _Archive |
...

若超過 20 篇：「⚠️ 共 {N} 篇孤立筆記，以下顯示最舊 20 篇。」

---

### 🟡 維度二：懸案清單（{N} 篇）

| # | 筆記 | 專案 | 最後更新 | resolution |
|---|------|------|----------|-----------|
| 1 | [[yyy]] | a126 | 2025-09-15 | open |
...

---

### 🔵 維度三：潛在連結（{N} 組）

| # | 筆記 A | 筆記 B | 共同 keywords | 建議 |
|---|--------|--------|--------------|------|
| 1 | [[aaa]] | [[bbb]] | docker, deployment | 在 aaa 中加入 [[bbb]] 引用 |
...

---

### 📊 健康摘要

- 孤立筆記：{N} 篇（佔總筆記 {%}）
- 未解懸案：{N} 篇
- 潛在未連結：{N} 組
- 建議優先處理：{最值得關注的 1-2 項}
```

---

### Step 4：行動選項

報告輸出後，詢問用戶：

「你想從哪裡開始？
1. 處理孤立筆記（我可以逐篇幫你決定：連結 / 補充 / 歸檔）
2. 清理懸案清單（我可以幫你逐篇更新 resolution）
3. 補上潛在連結（我可以幫你在筆記中加入 wikilink）
4. 只看報告，我自己處理
5. 把這份報告存成筆記」

---

### Step 5（可選）：儲存報告

若用戶選擇儲存，在 `0_inbox/` 建立報告筆記：

```yaml
---
id: {YYYYMMDDHHmmss}
type: reference
sub-type: null
project: null
sub-project: null
tags: [obsidian, health-check]
keywords: [vault-health, orphaned-notes, open-issues]
aliases: []
status: active
resolution: null
maturity: null
updated: {YYYY-MM-DDTHH:mm}
completed: null
cssclasses:
  - checkbox-time-tracker
---
```

儲存位置：一律放置於 `0_inbox/` 目錄
檔名規則：`healthcheck_{YYYYMMDD}.md` (全小寫、底線分隔，如 healthcheck_20260406.md)

---

## 注意事項

- `_index_*.md`、`_Dashboard*.md`、`_Archive/` 子目錄內的筆記不列入孤立筆記判斷（index/dashboard 本來就是被查、不是被連的）
- 孤立筆記判斷只看「被別的筆記 wikilink」，不算 dashboard 的 dataview 查詢
- 執行時間估算：vault 約 100 篇約 30 秒，300 篇約 90 秒
