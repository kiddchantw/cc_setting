# Claude Code Skills

本目錄包含 Q03 專案的 Claude Code Skills 配置與整合文檔。Skills 是可執行的工作流程，旨在自動化開發任務、強化 AI 的技能或整合專案工具。

---

## 🎯 快速開始

### 1. 使用現有 Skills
在對話中使用 `/skill-name` 格式呼叫特定工作流：
- `/create_session`: 建立新的開發 session
- `/tdd_workflow`: 啟動 TDD 開發流程
- `/git_organize-commits`: 整理並優化 Git Commit 訊息

### 2. 理解 Token 消耗 (按需載入)
Skills 採用「延遲載入」設計以節省成本。
- **基本使用**: 僅載入核心指令 (~2KB)。
- **詳細說明**: 視需求主動載入配套的 `README_zh_TW.md` (~10-20KB)。
→ 效益詳見：[SKILL-STRUCTURE.md](SKILL-STRUCTURE.md#⚡-效能與-token-優化-lazy-loading)

---

## 📊 設計原理圖
```
使用者查詢
    ↓
    ├─→ 簡單問題？ ─→ 只讀 SKILL.md (3.3KB, 990 tokens)
    │       ↓
    │   節省 87.2% tokens ⚡
    │
    ├─→ 中等複雜？ ─→ SKILL.md + 1-2 個例子 (5.8KB, 1,740 tokens)
    │       ↓
    │   節省 77.7% tokens ⚡
    │
    └─→ 複雜問題？ ─→ SKILL.md + README (20.3KB, 6,090 tokens)
            ↓
        節省 21.9% tokens ⚡
```

### 為什麼按需載入有效？

1. **AI 理解層級**
   - SKILL.md 包含 80% 的核心邏輯
   - README_zh_TW.md 是補充案例和實現細節
   - AI 能夠根據請求自動判斷需要深入哪部分

2. **使用者行為分析**
   - 簡單問題: 90% 的時間只需要 SKILL.md
   - 複雜問題: 需要部分額外的範例或詳情
   - 極少需要加載所有文件

3. **文件設計**
   - 核心清單式設計，易於快速掃描
   - 詳情文檔有清晰的結構和索引
   - 易於引導 AI 讀取特定部分



---

---

## 🛠️ 可用 Skills

| 類別 | 用途 | Skill 呼叫方法 | 資源參照 |
| :--- | :--- | :--- | :--- |
| **開發流程** | 🆕 建立新的開發 Session | `/create_session` | `agent-scripts/` |
| | 🧪 Red-Green-Refactor TDD 循環 | `/tdd_workflow` | `agents/laravel-expert.md` |
| | 📝 測試規劃與設計 | `/tdd_planning` | - |
| **Git 管理** | 📋 整理變更並撰寫 Conventional Commits | `/git_organize-commits` | `agents/git-commit-tw.md` |
| | 📝 從 Session 更新 CHANGELOG 並推進版本號 | `/update-changelog` | - |
| **程式碼審查** | 🔒 Laravel 安全性審查 | `/laravel_security-review` | `agents/laravel-reviewer.md` |
| | ⚡ Laravel 效能審查 | `/laravel_performance-review` | `agents/laravel-reviewer.md` |
| | 🔒 Flutter 安全性審查 | `/flutter_security-review` | - |
| | ⚡ Flutter 效能審查 | `/flutter_performance-review` | - |
| **工具整合** | 🔄 Flutter OpenAPI Client 生成 | `/flutter_openapi-generator` | - |
| | 📱 Flutter 平台整合 | `/flutter_platform-integration` | - |
| | ⚛️ React/Next.js 優化指南 | `/frontend_react-best-practices` | - |
| **Obsidian 筆記庫** | Vault 路徑定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段 | | |
| | 📝 新增 Zettelkasten 知識卡片 | `/obsidian-add-cards` | `frontmatter-schema.md` |
| | 📓 輕量隨記（靈感、備忘、踩坑） | `/obsidian-add-devlog` | `frontmatter-schema.md` |
| | 📋 新增專案 Session 紀錄 | `/obsidian-add-projects-session` | `frontmatter-schema.md` |
| | 🔎 從筆記庫搜尋過往紀錄 | `/obsidian-dev-lookup` | - |
| | ✏️ 為筆記補上結論 / 解法 | `/obsidian-add-conclusion` | `frontmatter-schema.md` |
| | 🧹 補齊 Frontmatter 欄位 | `/obsidian-enrich-frontmatter` | `frontmatter-schema.md` |
| | 📦 搬移已完成的 Inbox 筆記 | `/obsidian-move-inbox` | - |

---

## 📖 文檔導覽

| 文檔 | 用途 | 適合對象 |
| :--- | :--- | :--- |
| [SKILL-STRUCTURE.md](SKILL-STRUCTURE.md) | **建立指南**：結構定義、整合模式與檢查清單 | 🛠️ 開發/維護者 |
| [CHANGELOG.md](CHANGELOG.md) | **變更歷史**：系統演進與重構記錄 | 📝 所有使用者 |
| [ARCHITECTURE](../SKILL_ARCHITECTURE.md) | **架構分析**：Token 效能與按需載入機制 | 🎨 視覺化理解 |

---

## 🤝 貢獻與開發

建立新 Skill 時，請務必遵循 [SKILL-STRUCTURE.md](SKILL-STRUCTURE.md) 規範：
1. **單一職責**: 一個 Skill 只解決一個特定問題。
2. **延遲載入**: 詳細說明與範例應與核心 `SKILL.md` 分離至 `README_zh_TW.md`。
3. **相對路徑**: 優先引用 `../../agent-scripts/` 中的共享資源。
