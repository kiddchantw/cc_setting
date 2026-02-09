# 📁 Agent 結構與建立指南

每個 Agent 都是一個獨立的 `.md` 檔案，定義了 AI 的角色、專業領域與行為模式。

⚠️ **重要限制 (Official Limitations)**: 
根據 Claude Code 官方規範，Agent 必須是單一的 `.md` 檔案，直接位於 `.claude/agents/` 目錄下。**不支持任何子目錄結構** (如 `agent-name/README.md`)。

✅ **優化策略 (Scheme C)**:
我們採用「單檔案精簡優化」策略：
1. **Agent (`.md`)**: 只保留核心決策邏輯 (Decision Logic)，大小控制在 4-6 KB。
2. **Conventions (`*-conventions.md`)**: 將詳細規範、代碼範例移至共享文件。
3. **參照指引**: Agent 透過明確指引 (Reference Guidelines) 引導 AI 查閱 Conventions。

---

## 📋 建立新 Agent

遵循以下步驟，您可以快速建立一個新的專家 Agent。

### 1. 建立檔案
在 `.claude/agents/` 目錄下建立 `.md` 檔案。
```bash
touch .claude/agents/my-agent.md
```

### 2. 定義 Metadata (YAML Frontmatter)
在檔案頂部加入 YAML 區塊，定義 Agent 的基本資訊與自動觸發條件。

```yaml
---
name: agent-name              # Agent 識別名稱
description: "何時使用..."    # 自動觸發條件說明 (關鍵字、檔案類型、工作情境)
model: sonnet                 # 使用的 AI 模型 (如 sonnet, haiku)
---
```

### 3. 撰寫核心指令 (Instructions)
在 YAML 下方定義 Agent 的專業領域與行為規範。建議包含以下區塊：

```markdown
You are an expert [role description]...

## Core Competencies (核心能力)
- 列出 Agent 擅長的技術或領域
- 例如：Laravel API、Flutter UI、Security Review

## Review/Development Approach (開發與審查方式)
- 說明 Agent 的工作邏輯
- 檢查清單 (Checklist)
- 強調的原則 (如 SOLID, DRY)

## Output Format (輸出格式)
- 定義輸出的模板或風格
- 提供程式碼範例的格式

## Best Practices (最佳實踐)
- 建議遵循的規範
```

### 4. 更新導覽
在 `.claude/agents/README.md` 的「可用 Agents」區塊加入新 Agent 的說明，方便查閱。

---

## 🎨 Agent 設計原則

### 1. 單一職責 (Single Responsibility)
每個 Agent 應專注於一個明確的角色。
- ✅ `laravel-expert` (開發) 與 `laravel-reviewer` (審查) 應分開，以保持指令精簡且精確。
- ❌ 避免在同一個 Agent 中混合過多不相關的職責。

### 2. 強大的觸發條件 (Smart Discovery)
在 `description` 中明確說明觸發情境，這能幫助系統在對話中自動偵測並切換角色：
- **關鍵字**: "API endpoints", "database schema"
- **檔案類型**: `.php`, `.dart`, `composer.json`
- **使用者意圖**: "code review", "refactoring"

### 3. 結構化的輸出範本
提供清晰的輸出框架，能讓 AI 的回應更具一致性與專業感：
```markdown
## Code Review Summary

### Critical Issues
- [File:Line] Issue description
  - Problem: ...
  - Solution: ...
```

### 4. 跨系統整合 (Cross-Integration)
主動引導使用者使用相關的 Skills：
```markdown
**Note**: For comprehensive security review, use the `laravel-security-review` skill.
```

### 5. Token 效率 (Token Efficiency)
為了節省 Token 並提升回應速度，請遵循以下撰寫原則：
- **精簡內容**: 移除冗長的解說，改用要點清單 (Bullet points)。
- **外部引用**: 將詳細的代碼範例、最佳實踐移至 `*-conventions.md`。
- **僅保留決策**: Agent 應專注於「如何判斷」與「做什麼」，而非「教科書式的知識」。
- **大小限制**: 單個 Agent 建議不超過 6 KB (~2,000 tokens)。


### 6. 協作模式 (Collaboration Models)

除了單一 Agent 運作，我們支援兩種協作模式：

1. **Subagents (子代理)**:
   - **機制**: 在同一 Session 內切換身份 (如 `laravel-expert` -> `laravel-reviewer`)。
   - **特點**: 共享 Context，適合快速任務與線性流程。
   - **最佳實踐**: 透過 `description` 自動觸發。

2. **Agent Teams (多代理團隊)**:
   - **機制**: 多個獨立 Claude Session 平行運作。
   - **特點**: 獨立 Context，適合複雜架構探索與多面向協作。
   - **實作**: 參照 `../team-templates.md`。

---

## 🚀 最佳實踐精要 (Checklist)

- [ ] **清晰角色**: 使用 "You are an expert..." 開頭。
- [ ] **主動檢查**: 要求 Agent 主動發現潛在問題 (如 N+1)。
- [ ] **具體範例**: 在指令中包含「好」與「壞」的範例。
- [ ] **持續優化**: 根據實際使用結果調整 `description` 與核心指令。
