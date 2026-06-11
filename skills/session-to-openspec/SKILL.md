---
name: session-to-openspec
description: "從 Flutter 端 session 文件中提取後端 API 相關問題，在 Web 端建立 OpenSpec change 進行規劃，並回寫連結到原始 session。觸發詞：「session 轉 openspec」、「抓 API issue」、「從 session 開 change」、「session-to-openspec」"
---

# Session → OpenSpec 跨專案規劃

## 概述

此 skill 自動化「從 Flutter 端 session 發現後端問題 → 在 Web 端建立 OpenSpec change 規劃修復」的跨專案工作流程。

## 前提

- Flutter 端 session 文件已存在（通常在 `a126_kompraa_flutter/docs/sessions/` 下）
- Web 端 OpenSpec 目錄已初始化（`A126-kompraa_web/openspec/`）

## 工作流程

### 1. 定位 Session 文件

**輸入**：用戶提供 session 文件路徑，或從最近的對話上下文推斷。

若未指定，列出最近的 session 文件讓用戶選擇：
```bash
ls -t a126_kompraa_flutter/docs/sessions/$(date +%Y-%m)/*.md | head -10
```

### 2. 分析 Session 內容

讀取 session 文件，提取以下資訊：

- **問題描述**：Bug 或功能需求
- **根本原因**：Root Cause Analysis 區塊
- **相關後端檔案**：Controller、Model、Trait、Service 等
- **建議修復方案**：如果 session 中有記錄

**判斷標準**：以下情況適合轉為 OpenSpec change：
- 問題根因在後端 API / Laravel 程式碼
- 需要修改 Controller、Model、Migration、Trait 等
- Session 中標記為「待實施修復」或「Backend」

若問題純屬 Flutter 端，告知用戶不需建立 Web 端 change。

### 3. 產生 Change 名稱

從問題描述衍生 kebab-case 名稱：
- Bug 修復：`fix-{問題描述}`（例：`fix-product-sorting-softdeletes`）
- 功能新增：`add-{功能描述}`（例：`add-order-export-api`）
- 重構：`refactor-{目標}`（例：`refactor-payment-flow`）

### 4. 建立 OpenSpec Change

使用 `/opsx:new` 在 Web 端建立 change：

```
/opsx:new {change-name}
```

**OpenSpec 路徑**：`A126-kompraa_web/openspec/`

### 5. 起草 Proposal

根據 session 分析結果，自動填寫 proposal.md：

- **Why**：從 session 的 Problem / Root Cause Analysis 提取
- **What Changes**：從 session 的建議修復方案提取
- **Capabilities**：
  - 檢查 `A126-kompraa_web/openspec/specs/` 是否有相關的既有 spec
  - 若有 → Modified Capabilities
  - 若無 → New Capabilities
- **Impact**：從 session 的相關檔案列表提取

### 6. 繼續推進 Artifacts（可選）

詢問用戶是否要繼續用 `/opsx:continue` 產生 design、specs、tasks。

若用戶同意，依序建立：
1. **design.md** — 從 session 的方案分析提取技術決策
2. **specs/** — 建立或修改相關 capability 的 delta spec
3. **tasks.md** — 從 session 的建議分解為可追蹤任務

### 7. 回寫 Session 文件

在原始 Flutter session 文件中新增「Web 端修復規劃」區塊：

```markdown
---

## 🔗 Web 端修復規劃

後端修復已透過 OpenSpec 進行規劃，位於：

- **Change**: `{change-name}`
- **路徑**: `A126-kompraa_web/openspec/changes/{change-name}/`
- **Schema**: spec-driven（proposal → design → specs → tasks）
- **進度**: {N}/4 artifacts complete（{已完成的 artifacts}）
- **修改的既有 Spec**: `{spec-name}`（若有）

Flutter 端無需修改，此為純後端修復。（或說明 Flutter 端需要的配合修改）
```

## 完成檢查清單

- [ ] Session 文件已讀取並分析
- [ ] 後端問題已確認（非純 Flutter 問題）
- [ ] OpenSpec change 已建立
- [ ] Proposal 已起草（至少）
- [ ] 原始 Session 文件已更新連結
- [ ] 用戶已確認是否繼續推進 design/specs/tasks

## 下一步

- 使用 `/opsx:continue` 或 `/opsx:ff` 完成剩餘 artifacts
- 使用 `/opsx:apply` 實作修復
- 完成後使用 `/opsx:archive` 歸檔
