# Claude Code Skills

本目錄包含 Q03 專案的 Claude Code Skills 配置與整合文檔。Skills 是可執行的工作流程，旨在自動化開發任務、強化 AI 的技能或整合專案工具。

---

## 🎯 快速開始

### 1. 使用現有 Skills
在對話中使用 `@skill-name` 標記即可呼叫特定工作流：
- `@create-session`: 建立新的開發 session
- `@tdd-workflow`: 啟動 TDD 開發流程
- `@git-organize-commits`: 整理並優化 Git Commit 訊息

### 2. 理解 Token 消耗 (按需載入)
Skills 採用「延遲載入」設計以節省成本。
- **基本使用**: 僅載入核心指令 (~2KB)。
- **詳細說明**: 視需求主動載入配套的 `README_zh_TW.md` (~10-20KB)。
→ 效益詳見：[SKILL-STRUCTURE.md](SKILL-STRUCTURE.md#⚡-效能與-token-優化-lazy-loading)

---

## 🛠️ 可用 Skills

| 類別 | 用途 | Skill 呼叫方法 | 資源參照 |
| :--- | :--- | :--- | :--- |
| **開發流程** | 🆕 建立新的開發 Session | `@create-session` | `agent-scripts/` |
| | 🧪 Red-Green-Refactor TDD 循環 | `@tdd-workflow` | `agents/laravel-expert.md` |
| | 📝 測試規劃與設計 | `@test-planning` | - |
| **Git 管理** | 📋 整理變更並撰寫 Conventional Commits | `@git-organize-commits` | `agents/git-commit-tw.md` |
| **程式碼審查** | 🔒 Laravel 安全性審查 | `@laravel-security-review` | `agents/laravel-reviewer.md` |
| | ⚡ Laravel 效能審查 | `@laravel-performance-review` | `agents/laravel-reviewer.md` |
| | 🔒 Flutter 安全性審查 | `@flutter-security-review` | - |
| | ⚡ Flutter 效能審查 | `@flutter-performance-review` | - |
| **工具整合** | 🔄 Flutter OpenAPI Client 生成 | `@flutter-openapi-generator` | - |
| | 📱 Flutter 平台整合 | `@flutter-platform-integration` | - |
| | ⚛️ React/Next.js 優化指南 | `@react-best-practices` | - |

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
