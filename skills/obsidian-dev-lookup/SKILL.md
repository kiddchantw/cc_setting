---
name: obsidian-dev-lookup
description: 從 vault 中搜尋與當前開發任務相關的過往筆記、踩坑紀錄、解法。當用戶說「查一下」、「dev-lookup」、「有沒有相關紀錄」時使用。
argument-hint: "[搜尋主題，例如：ssl 憑證更新]"
---

# Dev Lookup — 開發前查詢

從 vault 中搜尋與當前開發任務相關的過往紀錄，包含踩坑經驗、解法、知識卡片等。

## 固定路徑設定

- **Vault 根目錄**: `/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/`
- **Vault 名稱**: `Documents`
- **搜尋範圍**：整個 vault，排除以下目錄：
  - `5_Pic/`（圖片資料夾）
  - `Templates/`（模板不是實際紀錄）

## 前置檢查：偵測 Obsidian CLI

執行以下指令判斷 CLI 是否可用：
```bash
obsidian version 2>/dev/null && echo "CLI_AVAILABLE" || echo "CLI_UNAVAILABLE"
```

- 輸出含 `CLI_AVAILABLE` → 使用 **CLI 模式**（Step 2A）
- 輸出含 `CLI_UNAVAILABLE` → 使用 **Fallback 模式**（Step 2B）

## 執行步驟

### Step 1：提取搜尋關鍵字

從用戶的 `$ARGUMENTS` 中提取：
- **英文技術關鍵字**：將中文描述轉換為對應的英文技術詞（例如「憑證更新」→ `ssl`, `certbot`, `certificate`, `renew`）
- 產生 3-6 個搜尋詞，全小寫

---

### Step 2A：CLI 模式（優先）

#### 2A-1. Property 搜尋（keywords 欄位）

對每個關鍵字執行：
```bash
obsidian vault=Documents search query="[keywords:{keyword}]" format=json
```

#### 2A-2. 全文搜尋

對每個關鍵字執行：
```bash
obsidian vault=Documents search:context query="{keyword}" limit=20 format=json
```

#### 2A-3. Tag 搜尋

對映關鍵字到相關 tag 後執行：
```bash
obsidian vault=Documents search query="[tag:{tagname}]" format=json
```

將三輪結果合併去重，跳到 Step 3。

---

### Step 2B：Fallback 模式（無 CLI）

#### 2B-1. 第一輪 — 精準搜尋（keywords 欄位）

使用 Grep 搜尋 `keywords:` 欄位中包含關鍵字的筆記：

```
對每個關鍵字，搜尋 pattern: `keywords:.*{keyword}`
搜尋路徑: 依序搜尋四個目錄
檔案類型: *.md
```

收集所有匹配的檔案路徑。

#### 2B-2. 第二輪 — 擴大搜尋（全文 + 檔名）

1. **全文搜尋**：用 Grep 搜尋筆記內容中包含關鍵字的檔案（排除已在第一輪找到的）
2. **檔名搜尋**：用 Glob 搜尋檔名中包含關鍵字的檔案

#### 2B-3. 第三輪 — Tag 搜尋

使用 Grep 搜尋 `tags:` 欄位中包含相關 tag 的筆記（參考 `2_Resources/_Index.md` 中的 Tag 清單來對映關鍵字到 tag）。

---

### Step 3：整理結果

將搜尋結果去重後，對每篇筆記：

1. 讀取檔案的 frontmatter（取 `keywords`、`tags`、`type`、`status`）
   - CLI 模式可用 `obsidian vault=Documents properties file="{filename}"` 取得
   - Fallback 模式用 Read 工具讀取
2. 搜尋是否有 `## 解法`、`## 結論`、`## 結論 / 解法`、`## 關鍵收穫` 區塊
3. 若有，提取該區塊的前 2-3 行作為摘要

### Step 4：呈現結果

按相關度排序（property 匹配 > 全文匹配 > tag 匹配），以下列格式呈現：

```
### 找到 N 篇相關筆記

| # | 筆記 | 路徑 | keywords | tags | 摘要 |
|---|------|------|----------|------|------|
| 1 | 標題 | 相對路徑 | [...] | [...] | 解法/結論摘要 |
```

- 最多顯示 10 篇最相關的結果
- 若某篇筆記有 `type: devlog` 且 `status: resolved`，在摘要欄加上 `[已解決]` 標記
- 若找到的筆記缺少 `keywords` 欄位，在結果下方提示：「以下 N 篇筆記尚未補上 keywords，建議執行 triage-inbox 補齊」

### Step 5：無結果處理

若搜尋都沒找到結果：
- 回報「無相關紀錄」
- 列出使用的搜尋關鍵字，供用戶確認是否需要調整

## 注意事項

- 搜尋時忽略大小寫（Grep 使用 `-i` flag）
- 不搜尋 `Templates/` 目錄（模板不是實際紀錄）
- 不搜尋 `.base` 檔案
- Fallback 模式第二輪全文搜尋時，限制每個關鍵字最多 20 筆結果，避免噪音過多
