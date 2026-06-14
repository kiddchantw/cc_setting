---
name: obsidian-sync
description: Use when 用戶說「更新到 obsidian」、「同步 obsidian」、「sync obsidian」、「有什麼可以更新到 obsidian 的嗎」，或對話收尾時需要把本次對話的進度、決策、知識點寫回 Obsidian vault。
---

# Obsidian Sync — 把對話成果同步回 vault

## 概述

檢視當前對話，找出值得保存的內容，**優先更新既有筆記，掛靠不上才新增**。

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

## 執行步驟

### Step 1：掃描對話，按 4 種類型分類

| 類型 | 判斷 | 去向 |
|---|---|---|
| **專案進度** | 完成了既有 session/checklist 中的事項 | 更新既有 session（打勾、補 Outcome、改 `updated`） |
| **新任務／待辦** | 決定要做但還沒做的事 | 簡單 → `obsidian-add-devlog`；需要規劃 → 新 session 放 `1_Projects/<project>/` |
| **通用知識** | 跨專案可重用的概念、踩坑、機制 | `obsidian-add-cards` 規範存 `2_Resources/`（先查重） |
| **既有手法重用** | 這次套用了 vault 已記錄的解法 | 在既有卡片加「重用紀錄」區塊 + 雙向連結 |

一個對話可能同時命中多種類型，逐一處理。沒有命中任何類型 → 直接回報「無需更新」，不要硬寫。

### Step 2：搜尋 vault 確認掛靠點

寫入前必做：用 Grep 搜 `{Vault root}` 找相關既有筆記（session、知識卡、index）。

- 找到相關 session → 更新它，**不要**另開重複筆記
- 找到同主題知識卡 → 更新或補充，**不要**建重複卡片

### Step 3：寫入

- 既有筆記：保留原結構，更新 frontmatter `updated`（`date +"%Y-%m-%dT%H:%M"`）
- 新筆記：遵循對應 skill（`obsidian-add-devlog` / `obsidian-add-cards`）的 frontmatter schema
- 相關筆記之間加 `[[wikilink]]` 雙向連結

### Step 4：回報

列出：更新了哪些檔案（路徑）、新增了哪些檔案、各自記了什麼（一行摘要）。

## 注意事項

- **敏感資料**：密碼、API key、token 寫入 vault 前先向用戶確認（vault 走 iCloud 同步）
- **不要記**：repo 已記錄的內容（code、commit history）、只對本次對話有意義的細節
- 對話中已經同步過的內容不要重複寫入，只處理增量
