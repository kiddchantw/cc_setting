# Claude Code 系統配置

本目錄包含 Claude Code AI Agents 與 Skills 配置，用於 Q03 專案開發。

## 📁 目錄結構

```
.claude/
├── README.md                          # 本文件 (系統總覽)
├── agents/                            # AI 專家角色
│   ├── README.md                      # 導覽與概述
│   ├── AGENT-STRUCTURE.md             # 建立指南
│   ├── CHANGELOG.md                   # 變更歷史
│   ├── laravel-expert.md              # Laravel 開發
│   ├── laravel-reviewer.md            # Laravel 審查
│   ├── flutter-expert.md              # Flutter 開發
│   └── flutter-reviewer.md            # Flutter 審查
│
└── skills/                            # 可執行工作流程
    ├── README.md                      # 導覽與概述
    ├── SKILL-STRUCTURE.md             # 建立指南
    ├── CHANGELOG.md                   # 變更歷史
    ├── create-session/                # 新建 Session
    ├── tdd-workflow/                  # TDD 循環
    ├── test-planning/                 # 測試規劃
    ├── git-organize-commits/          # Git 整理
    ├── laravel-security-review/       # 安全審查
    ├── laravel-performance-review/    # 效能審查
    ├── flutter-openapi-generator/     # OpenAPI 生成
    ├── flutter-performance-review/    # 效能審查
    ├── flutter-platform-integration/  # 平台整合
    ├── flutter-security-review/       # 安全審查
    ├── react-best-practices/          # React 最佳實踐
    │
    │   # Obsidian 筆記庫技能
    ├── obsidian-add-cards/            # 新增 Zettelkasten 卡片
    ├── obsidian-add-conclusion/       # 補結論 / 解法
    ├── obsidian-add-devlog/           # 輕量隨記
    ├── obsidian-add-projects-session/ # 新增專案 Session
    ├── obsidian-dev-lookup/           # 開發前查詢
    ├── obsidian-enrich-frontmatter/   # 補齊 Frontmatter
    ├── obsidian-move-inbox/           # 搬移完成的 Inbox
    └── obsidian-update-index/         # 更新專案資料夾的 _index_*.md
```

## 📚 Agents vs Skills

| 特性 | Agents | Skills |
|------|--------|--------|
| **觸發** | 自動 (隱式) | 手動呼叫 |
| **用途** | AI 角色/專業背景 | 具體工作任務 |
| **結構** | 單一 `.md` | `SKILL.md` + resources |
| **使用** | 自動檢測 | `/skill-name` 指令 |
| **範例** | 提及 "API" → `laravel-expert` 啟動 | `/tdd-workflow` 開始 TDD |

## 快速導覽

### 🤖 Agents (自動觸發)
AI 專家角色根據對話內容自動啟動，詳見 [agents/README.md](agents/README.md)

- **Laravel**: `laravel-expert` (開發), `laravel-reviewer` (審查)
- **Flutter**: `flutter-expert` (開發), `flutter-reviewer` (審查)

### ⚡ Skills (手動呼叫)
可執行的工作流程，使用 `/skill-name` 格式呼叫，詳見 [skills/README.md](skills/README.md)

**關鍵 Skills**:
- 📝 `/tdd-workflow` - Red-Green-Refactor 循環
- 🧪 `/test-planning` - 測試規劃與設計
- 📋 `/git-organize-commits` - Git 提交整理
- 🆕 `/create-session` - 新建開發 Session
- 🔒 `/laravel-security-review` - Laravel 安全審查

**Obsidian 筆記庫 Skills**:
- 📝 `/obsidian-add-cards` - 新增 Zettelkasten 知識卡片
- 📓 `/obsidian-add-devlog` - 輕量隨記（靈感、備忘、踩坑）
- 📋 `/obsidian-add-projects-session` - 新增專案 Session 紀錄
- 🔎 `/obsidian-dev-lookup` - 從筆記庫搜尋過往紀錄
- ✏️ `/obsidian-add-conclusion` - 為筆記補上結論/解法
- 🧹 `/obsidian-enrich-frontmatter` - 補齊 Frontmatter 欄位
- 📦 `/obsidian-move-inbox` - 搬移已完成的 Inbox 筆記
- 🗂️ `/obsidian-update-index` - 更新專案資料夾的 `_index_*.md`（增量補入或完整重建）

## 🏗️ 系統架構

```mermaid
graph TB
    subgraph Agents[".claude/agents/ - AI 專家角色"]
        LA[laravel-expert]
        LR[laravel-reviewer]
        FA[flutter-expert]
        FR[flutter-reviewer]
    end

    subgraph Skills[".claude/skills/ - Claude Code Skills"]
        SM[SKILL.md]
        RES[Resources]
        SM --> RES
    end

    subgraph Scripts["agent-scripts/ - 共享腳本與模板"]
        SCR["*.sh<br/>Shell Scripts"]
        TPL["templates/<br/>*.md"]
    end

    Agents -->|觸發啟動| Skills
    Skills -->|執行操作| SCR
    Skills -->|填寫模板| TPL
```

## 🔄 資源調用模式

```mermaid
graph LR
    Agent["Agent Role"] -->|啟動| Skill["Skill (SKILL.md)"]

    subgraph "Skill 執行資源"
        Skill -->|執行| Script["Shell Scripts (*.sh)"]
        Skill -->|讀取| Template["Templates (*.md)"]
        Skill -->|遵循| Rule["Expert Rules (.claude/agents/*.md)"]
    end
```

## 📋 開發流程整合

```mermaid
flowchart TD
    Start(["開始開發"]) --> Plan{"需要規劃?"}

    Plan -->|是| CreateSession["@create-session"]
    CreateSession --> ReadSpec["讀取 /spec"]

    Plan -->|否| Dev["開始開發"]
    ReadSpec --> Dev

    Dev --> TDD["@tdd-workflow"]
    TDD --> Test{"測試通過?"}

    Test -->|否| Fix["修正程式碼"]
    Fix --> TDD

    Test -->|是| Security["@laravel-security-review"]
    Security --> SecOK{"安全檢查通過?"}

    SecOK -->|否| FixSec["修正安全問題"]
    FixSec --> Security

    SecOK -->|是| Commit["@git-organize-commits"]
    Commit --> End(["完成"])
```

## 💡 設計原則

- **單一職責**: 每個 Agent/Skill 專注一件事
- **可組合性**: Skills 可互相整合
- **資源共享**: 參照 `agent-scripts/` 與 `agent-scripts/templates/`
- **明確觸發**: Agents 在 `description` 中清楚說明觸發條件

## 📚 相關資源

- 專案指引: [../CLAUDE.md](../CLAUDE.md)
- Docker 設定: [../laradock_setting.md](../laradock_setting.md)
- 自動化腳本: [../agent-scripts/](../agent-scripts/)
- 文件模板: [../agent-scripts/templates/](../agent-scripts/templates/)
