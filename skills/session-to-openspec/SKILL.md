---
name: session-to-openspec
description: "從兩種來源建立 OpenSpec change：(1) 程式碼專案的 session 文件（提取後端 API 問題）、(2) Obsidian vault 筆記（提取需求/功能/Bug 規劃）。觸發詞：「session 轉 openspec」、「抓 API issue」、「從 session 開 change」、「這篇筆記開 change」、「vault note 轉 openspec」、「session-to-openspec」"
---

# Session / Vault Note → OpenSpec 規劃

## 概述

從兩種來源提取需求，在指定專案的 OpenSpec 目錄建立 change 並起草 proposal。

## Step 0：判斷輸入模式

收到請求後，先判斷來源類型：

| 模式 | 來源 | 判斷依據 |
|---|---|---|
| **Mode 1：程式碼 Session** | 開發專案的 session 文件（`docs/sessions/` 下的 `.md`） | 路徑含 `docs/sessions/`，或用戶說「從 session」 |
| **Mode 2：Vault 筆記** | Obsidian vault 任意筆記（inbox、session、knowledge card） | 路徑含 vault root，或用戶說「這篇筆記」、「vault note」 |

若無法判斷，詢問用戶：「來源是開發專案的 session 文件，還是 vault 裡的筆記？」

---

## Mode 1：程式碼 Session → OpenSpec

### 1-1. 定位 Session 文件

用戶提供路徑，或從對話上下文推斷。若未指定，列出最近 session：

```bash
ls -t {session-dir}/*.md | head -10
```

### 1-2. 分析 Session 內容

讀取文件，提取：
- **問題描述**：Bug 或功能需求
- **根本原因**：Root Cause Analysis 區塊
- **相關後端檔案**：Controller、Model、Trait、Service 等
- **建議修復方案**

**判斷是否適合建 change**：
- ✅ 問題根因在後端 API / Laravel 程式碼
- ✅ 需要修改 Controller、Model、Migration、Trait
- ✅ Session 標記為「待實施修復」或「Backend」
- ❌ 問題純屬前端 → 告知用戶不需建立後端 change

### 1-3. 確認目標 OpenSpec 路徑

從 session 路徑或對話上下文推斷對應的 Web 端 openspec 目錄。
若無法自動推斷，詢問用戶：「目標專案的 openspec 路徑是？」

---

## Mode 2：Vault 筆記 → OpenSpec

### 2-1. 定位 Vault 筆記

用戶提供筆記路徑，或從對話上下文推斷（通常是當前在討論的筆記）。

若未指定，詢問：「請提供要轉換的 vault 筆記路徑，或直接描述要規劃的需求。」

### 2-2. 分析筆記內容

讀取筆記，提取：
- **需求描述**：功能、Bug、改進方向
- **背景**：為什麼需要這個改動（frontmatter 的 project、tags 可輔助判斷）
- **相關技術點**：若有提到 API、DB、架構等
- **現有連結**：wikilink 指向的相關筆記可提供上下文

### 2-3. 確認目標專案與 OpenSpec 路徑

詢問或從筆記 frontmatter `project` 欄位推斷：

```
這篇筆記的目標專案是 {project}，OpenSpec 路徑是否為：
{project-web-path}/openspec/ ？
```

若 frontmatter 無 project 資訊，明確詢問。

---

## 共用步驟：建立 Change 與起草 Proposal

### Step A：產生 Change 名稱

從需求描述衍生 kebab-case 名稱：
- Bug 修復：`fix-{問題描述}`（例：`fix-product-sorting-softdeletes`）
- 功能新增：`add-{功能描述}`（例：`add-order-export-api`）
- 重構：`refactor-{目標}`（例：`refactor-payment-flow`）

向用戶確認名稱後再執行。

### Step B：建立 OpenSpec Change

```
/opsx:new {change-name}
```

在目標專案的 `openspec/` 下建立 change 目錄。

### Step C：起草 Proposal

填寫 `proposal.md`：

- **Why**：從來源文件的問題描述 / 背景提取
- **What Changes**：從建議修復方案 / 需求描述提取
- **Capabilities**：
  - 檢查目標 `openspec/specs/` 是否有相關既有 spec
  - 有 → Modified Capabilities
  - 無 → New Capabilities
- **Impact**：受影響的檔案或模組

### Step D：回寫來源文件

在原始來源文件（session 或 vault 筆記）新增「OpenSpec 規劃」區塊：

```markdown
---

## 🔗 OpenSpec 規劃

已建立 OpenSpec change 進行規劃：

- **Change**: `{change-name}`
- **路徑**: `{openspec-path}/changes/{change-name}/`
- **進度**: {N}/4 artifacts（proposal → design → specs → tasks）
```

**Mode 2 額外**：vault 筆記使用 wikilink 格式記錄；若目標專案有對應的 vault 筆記，也補上反向連結。

### Step E：詢問是否繼續推進

詢問是否繼續用 `/opsx:continue` 或 `/opsx:ff` 產生 design、specs、tasks。

## 完成檢查清單

- [ ] 來源文件已讀取並分析（Mode 1 / Mode 2）
- [ ] 目標 OpenSpec 路徑已確認
- [ ] Change 名稱已確認
- [ ] OpenSpec change 已建立
- [ ] Proposal 已起草
- [ ] 來源文件已回寫連結
- [ ] 已詢問是否繼續推進 artifacts

## 下一步

- `/opsx:continue` 或 `/opsx:ff` — 完成剩餘 artifacts
- `/opsx:apply` — 實作修復
- `/opsx:archive` — 完成後歸檔
