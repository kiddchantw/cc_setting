---
name: obsidian-add-cards
description: 將一個 URL、一段文字、或一個問題/概念轉換成 Zettelkasten 知識卡片。URL 和文字存到 0_inbox；問題/概念存到 2_Resources（先確認是否已有類似資料）。
argument-hint: "[url, text, or question]"
---

# Add Zettelkasten Card

將 URL、文字內容或問題/概念轉換為 Zettelkasten 知識卡片。

## 固定路徑設定

- **Card Template**: `/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/Templates/Zettelkasten Card Template.md`
- **Inbox 目錄**: `/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/0_inbox/`
- **Resources 目錄**: `/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/2_Resources/`

## 執行步驟

### Step 1：判斷輸入類型

判斷 `$ARGUMENTS` 是（**按此優先順序依序檢查**）：
- **URL**：以 `http://` 或 `https://` 開頭 → 執行 **Step 2a**
- **問題**：以問號結尾，或以「請問」、「什麼是」、「如何」、「為什麼」等疑問詞開頭 → 執行 **Step 2c（問題流程）**
- **文字**：其他所有內容 → 執行 **Step 2b**

### Step 2a：輸入為 URL

1. 使用 WebFetch 抓取該網頁內容
2. 從頁面提取：
   - 主題/標題
   - 核心概念摘要
   - 詳細說明（技術文件、功能說明等）
   - 應用場景
3. **檔案名稱**：根據頁面主題命名，用中文或英文皆可，例如：
   - `Obsidian Bases 查詢功能.md`
   - `Laravel Octane 效能優化.md`
4. **`## 📚 參考來源`**：填入原始 URL
5. 執行 **Step 2d（Vault 交叉比對）**
6. 繼續 Step 3（**儲存到 `0_inbox`**）

### Step 2b：輸入為文字

1. 分析文字內容，理解其核心概念
2. **檔案名稱**：用 3-6 個中文字或英文詞命名，能代表這段文字的核心主題，例如：
   - `內部事實查核 Prompt.md`
   - `Claude Code 全域修正.md`
3. **`## 📚 參考來源`**：填入原始文字（用引號包住）
4. 執行 **Step 2d（Vault 交叉比對）**
5. 繼續 Step 3（**儲存到 `0_inbox`**）

### Step 2d：Vault 交叉比對（URL / 文字流程專用）

> Step 2a、2b 提取核心概念後，建卡之前執行此步驟。Step 2c（問題流程）已有自己的搜尋邏輯，不經過此步。

1. 從已提取的核心概念中，挑出 **2-4 個最具代表性的關鍵字**（英文或中文皆可）
2. 用 Grep 搜尋 vault 中的相關筆記（排除 `5_Pic`、`Templates`、`.claude`）：

```
# 搜尋 frontmatter keywords 與檔名
Grep pattern: "{關鍵字1}|{關鍵字2}|..."
path: K88Dev vault 根目錄
glob: "*.md"
```

> 若有多個關鍵字，合併為單次搜尋（regex alternation），不需逐一搜尋。

3. **處理搜尋結果**：
   - **找到相關筆記**：記下筆記檔名（不含路徑與 `.md`），供 Step 5 填入 `## 🔗 相關連結` 和 `## 💭 個人想法`
   - **無相關筆記**：正常繼續，`## 🔗 相關連結` 保留佔位

> ⚠️ 此步驟**不阻斷建卡流程**：不論有無找到相關筆記，都繼續建立卡片。這跟 Step 2c 的「找到就停止」邏輯不同。

---

### Step 2c：輸入為問題/概念

1. 從問題中提取**核心關鍵字**，例如：
   - 「請問滲透測試是什麼？」→ 關鍵字：`滲透測試`、`penetration test`
   - 「如何設定 nginx？」→ 關鍵字：`nginx`
2. 搜尋**整個 vault**（排除 `5_Pic` 和 `Templates`）是否已有類似主題的筆記：

> **⚠️ 此步驟不使用 Obsidian CLI**：純搜尋不涉及檔案移動或 `[[wikilink]]` 更新，直接用 `find` + `grep` 操作 vault 資料夾即可，效率更高。

```bash
# 搜尋檔名包含關鍵字的檔案（排除 5_Pic 和 Templates）
find "/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev" \
  -not -path "*/5_Pic/*" \
  -not -path "*/Templates/*" \
  -not -path "*/.claude/*" \
  -iname "*{關鍵字}*" \
  -name "*.md"

# 搜尋內容包含關鍵字的檔案（排除 5_Pic 和 Templates）
grep -ril "{關鍵字}" \
  --exclude-dir="5_Pic" \
  --exclude-dir="Templates" \
  --exclude-dir=".claude" \
  --include="*.md" \
  "/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev"
```

> 若有多個關鍵字，使用 regex alternation 合併為單次搜尋，例如將 `{關鍵字}` 替換為 `(滲透測試|penetration test)`，不需對每個關鍵字分別執行搜尋。

3. **判斷結果**：
   - **找到類似筆記**（1 個或多個）：
     - 列出找到的筆記（**檔名 + 完整路徑**），方便用戶直接開啟
     - 根據找到的位置分類顯示，例如：`1_Projects/`、`2_Resources/`、`0_inbox/` 等
     - 告知用戶「已有相關資料」並停止，不建立新卡片
     - 若用戶仍希望建立（例如現有資料不夠完整），則繼續 Step 4
   - **無類似筆記**：
     - 用已知知識生成這個主題的知識卡片內容
     - **`## 📚 參考來源`**：填入原始問題（用引號包住）
     - 繼續 **Step 4（儲存到 `2_Resources`）**

---

### Step 3：儲存到 0_inbox 的流程

#### Step 3-1：檢查檔案名稱重複

在確定檔案名稱後、建立檔案前，執行以下指令掃描 `0_inbox/` 和 `2_Resources/` 是否已有同名檔案：

```bash
find "/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/0_inbox" "/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/2_Resources" -name "{檔案名稱}.md"
```

- **無結果**：繼續建立
- **有結果**：在檔案名稱後加上數字後綴，例如 `Obsidian Bases 查詢功能 2.md`，再次檢查直到名稱不重複為止

#### Step 3-2：產生卡片 ID 與日期

```bash
date +"%Y%m%d%H%M%S"   # for id
```

> 建立卡片時寫入 `updated` 為當下時間（`YYYY-MM-DDTHH:mm`）。`created` 不需要，交給系統 `created time` 追蹤。

#### Step 3-3：建立卡片並儲存到 0_inbox

讀取 Card Template，依照 Step 5 規則填入內容，儲存到 `{Inbox 目錄}/{檔案名稱}.md`。

---

### Step 4：儲存到 2_Resources 的流程（問題/概念專用）

#### Step 4-1：確定檔案名稱

用 3-6 個中文字或英文詞命名，能代表這個概念的核心主題，例如：
- `滲透測試 Penetration Testing.md`
- `nginx 基本設定.md`

#### Step 4-2：再次確認 2_Resources 無重複

```bash
find "/Users/kiddchan/Library/Mobile Documents/iCloud~md~obsidian/Documents/K88Dev/2_Resources" -name "{檔案名稱}.md"
```

- **有結果**：加數字後綴直到不重複

#### Step 4-3：產生卡片 ID 與日期

```bash
date +"%Y%m%d%H%M%S"   # for id
```

#### Step 4-4：建立卡片並儲存到 2_Resources

讀取 Card Template，依照 Step 5 規則填入內容，儲存到 `{Resources 目錄}/{檔案名稱}.md`。

---

### Step 5：卡片內容填寫規則

讀取 Card Template，填入以下內容：

**Frontmatter：** 依照 `.claude/frontmatter-schema.md` 的 `zettelkasten` 類型規格填入。
⚠️ **注意：所有的 `tags` 與 `keywords` 必須全為英文。**
- `id`: 當前時間戳
- `type`: `zettelkasten`
- `status`: `exploring`（新建卡片預設值）
- `completed`: `null`
- 其餘共用欄位（`project`、`tags`、`keywords`、`updated`）見 schema

**各 Section 填入規則：**
- `## 💡 核心概念`：一段話（2-4 句）說明核心重點
- `## 📝 詳細說明`：詳細內容，URL 來源可包含功能說明、步驟；文字/問題來源則將概念完整展開說明
- `## 🔗 相關連結`：
  - 若 Step 2d 找到相關筆記 → 列出 `[[筆記名稱]] - 一句話說明關聯`（每筆一行）
  - 若未找到或未經過 Step 2d → 保留 `[[]] -` 佔位
- `## 📚 參考來源`：URL 填連結；文字/問題填原始輸入（用引號包住）
- `## 🏷️ 應用場景`：推斷這個知識什麼情況下會用到
- `## 💭 個人想法`：
  - 若 Step 2d 找到相關筆記 → 第一行寫 `vault 已有相關：[[筆記A]]、[[筆記B]]，可對照閱讀`，第二行保留 `- [ ] first read`
  - 若未找到 → 只保留 `- [ ] first read`

---

### Step 6：完成通知

建立完成後告知用戶：
- 卡片標題（檔案名稱）
- 完整儲存路徑（`0_inbox` 或 `2_Resources`）
- 摘要說明填入的核心概念
