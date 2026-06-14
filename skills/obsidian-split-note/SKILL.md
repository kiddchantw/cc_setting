---
name: obsidian-split-note
description: 將「知識 + 行動」混在一起的筆記拆分為知識卡片與行動 session。當筆記同時包含可複用知識（原理、指令、比較）和待追蹤行動（套用到哪些 server/專案、還沒測試的項目）時使用。當用戶說「拆分筆記」、「split note」、「照 mysql 那套拆」、「知識行動分離」時使用。
argument-hint: "[筆記路徑或檔名]"
---

# Split Note — 知識 / 行動分離

把一篇混合筆記拆成兩個各司其職的容器：

- **知識**（為什麼、怎麼做，跨專案成立）→ `zettelkasten` → `2_Resources/`
- **行動**（套用到哪裡、做了沒）→ `session` 的 Implementation Checklist → 對應專案資料夾

核心原則：**行動必須住在有 `completed` 欄位的容器裡**，否則它對 Dataview / Dashboard 永遠隱形。

## 為什麼需要拆分

埋在知識筆記內文裡的行動（「之後要測還原」「其他 server 也要套用」）沒有 frontmatter 可查詢，session 的 `completed` 機制管不到它，最終被遺忘。拆分後：

- 知識卡片進 `2_Resources/`，跨專案可搜尋、可被 hook 撈到
- 行動進 session，未完成就一直留在 Dashboard「進行中」區塊
- 兩者 wikilink 互連，知識卡的 backlinks 即是「採用清單」

## 適用判斷

```
筆記同時有「可複用知識」和「未完成行動」？
├─ 是 → 用本 skill 拆分
├─ 只有知識（無待辦）→ 用 obsidian-relocate-resources 搬 2_Resources 即可
├─ 只有行動（無複用價值）→ 補 frontmatter 成 session / devlog 即可
└─ 行動全部已完成 → 知識搬 2_Resources，行動段落保留為紀錄，不開 session
```

**知識的判斷標準**：把專案名稱遮掉後內容依然成立（原理、通用指令、工具操作、比較分析）。
**行動的判斷標準**：有「對象 × 狀態」結構（哪台 server 套用了沒、哪個測試做了沒）。

> [!important] 隱性行動也算行動
> 行動不一定有「之後要做」的明示文字。**SOP / 指令寫了具體生產環境目標（如 `prod_A123-xxx`）卻沒有任何套用狀態紀錄**，就是隱性的未完成行動，適用拆分。
> 反之，`- [ ] first read` 等閱讀提醒、`💭 個人想法` 段落不是行動——它們是知識卡片自身的一部分，保留在原筆記。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。
> Frontmatter 規格見 `.claude/frontmatter-schema.md`；模板在 `{SkillTemplates}/`。

## 執行步驟

### Step 1：讀取與盤點

1. 讀取目標筆記全文
2. 標出哪些段落是知識、哪些是行動（含「已完成的行動」——它們進 checklist 時直接打勾）
3. 執行 FATAL-003 檢查：`grep -F "[[檔名"` 全 vault 搜尋（用 `-F` 處理檔名含空格 / 括號；搜尋前綴即可涵蓋 `[[檔名|alias]]`、`[[檔名#段落]]` 變形），記錄所有 backlink

### Step 2：產生拆分計畫並確認

向用戶報告：

```
知識卡片：{原檔名}
  → 搬到 2_Resources/，type: zettelkasten，project: null（若跨專案）
  → backlink 影響：N 篇（列出清單）

行動 session：{新檔名，格式 YYYYMMDD_英文-slug.md，如 20260611_mysql-gzip-backup-rollout.md}
  → 放在 1_Projects/{歸屬專案}/，type: session
  → status: 有任一行動已完成 → active；全部未開始 → draft
  → Checklist 項目：（列出，已完成的標 [x]）
```

用 AskUserQuestion 確認。若用戶已說「直接執行」、「照流程跑」可略過。

**session 歸屬專案的判斷**：行動橫跨多台 server / 多專案 → `server-ops`；只屬於單一專案 → 該專案資料夾。粒度是「一次推廣 / 一個任務」一篇，**不要**每個套用對象開一篇。

### Step 3：升級知識卡片並搬移

1. **先在原位置**把 frontmatter 升級為 v2 `zettelkasten`（依 frontmatter-schema）：
   - `id`：沿用原建立時間 `YYYYMMDDHHmmss`
   - `project`: 跨專案知識填 `null`
   - `maturity`: `linked`（拆分後必然與 session 互連）
   - 補齊 `keywords`（3-8 個）、`aliases`
   - **已是 v2 格式**：只調整需要的欄位（`project`、`maturity`、`updated`），不重寫整份
   - **欄位超出規格**：正規化裁剪（tags 上限 3、keywords 3-8 個全小寫連字號）
   - `status` 維持 `active`（zettelkasten 用 `maturity` 追蹤成熟度，沒有 `done` 終態）
2. 把行動段落從內文移除（移去 session），知識內容保留
   - 指令範例中的具體路徑 / 專案名**可保留作為實例**（如「以 A108 為例」），搬走的是「套用狀態」不是「範例」
3. 在 `## 🔗 相關連結` 加入指向新 session 的 wikilink
4. 搬移到 `2_Resources/`（優先 `obsidian move`，無 CLI 則 `mv`；遵守 FATAL-005 單一副本）
5. 若 Step 1 發現 backlink 且檔名有變動，逐篇更新引用

### Step 4：建立行動 session

用 `{SkillTemplates}/Session Template.md` 建立，重點欄位：

- `status: active`（已有部分行動完成）或 `draft`（純規劃）
- `🎯 Overview`：一句話目標 + 「知識依據：[[知識卡片]]」
- `📋 Implementation Checklist`：每個對象一項，**已完成的標 `[x]` 並註記日期**；驗證類行動（如還原測試）獨立一項
- `🔗 References`：連回知識卡片
- 內文涉及的腳本、cron、操作細節**不要複製**，用 wikilink 指向知識卡片

### Step 5：更新 Index（兩邊都要）

依 vault `CLAUDE.md` 的 Index 更新規則：

- 知識卡片 → `2_Resources/_Index.md` 最相關 section 末尾加 `- [[檔名]] — 一句話摘要`
- session → 執行 `obsidian-update-index {專案}`（或手動依該 index 現有格式插入對應區塊）
- 若原筆記在某專案 index 中有條目，移除該條目

### Step 6：驗證與回報

1. 驗證：原位置無殘留檔案、雙向 wikilink 都存在（`grep` 確認）、兩邊 index 已更新
2. 回報：兩個檔案的最終路徑、checklist 項目數（已完成/待辦）、backlink 更新數

## 常見錯誤

| 錯誤 | 修正 |
|------|------|
| 每個套用對象開一篇 session | 一次推廣一篇 session，checklist 列所有對象 |
| 知識卡片留著 `project: a126` | 跨專案知識 `project: null`，出生專案只是歷史偶然 |
| 行動細節複製到 session 又留在知識卡 | 知識只放一份，session 用 wikilink 引用 |
| 先搬移再改 frontmatter 卻忘了改 | 固定順序：原地改好 → 再搬 |
| 拆完忘記更新 index | Step 5 兩邊 index 都是必要步驟，不可省略 |
| 把已完成的行動丟掉 | 已完成行動進 checklist 標 `[x]` 加日期，是珍貴的採用紀錄 |

## 參考範例

實際拆分案例：`2_Resources/mysql-backup-sql-vs-sqlgz.md`（知識）+ `1_Projects/server-ops/20260611_mysql-gzip-backup-rollout.md`（行動），2026-06-11 拆分。
