# Agent Team 模板

本專案常用的 Agent Team 組合。複製貼上即可建立 team。

---

## 全端開發 Team

```
建立 agent team 開發新功能，每個 teammate 請先讀取對應的 .claude/agents/*.md 作為指引：
- openspec-expert: 負責撰寫 proposal、specs、design、tasks
- laravel-expert: 負責後端 API、資料庫、驗證邏輯
- react-expert: 負責前端 React 元件、頁面、狀態管理
```

---

## 規格審查 Team

```
建立 agent team 審查規格：
- Teammate A: 從技術可行性角度審查
- Teammate B: 從使用者體驗角度審查
- Teammate C: 扮演 Devil's Advocate，挑戰假設
```

---

## Code Review Team

```
建立 agent team 進行 code review，每個 teammate 請先讀取對應的 .claude/agents/*-reviewer.md：
- laravel-reviewer: 審查後端程式碼
- react-reviewer: 審查前端程式碼
- 安全審查員: 檢查安全漏洞
```

---

## Flutter + Laravel Team

```
建立 agent team 開發 mobile app 功能：
- openspec-expert: 規格撰寫
- laravel-expert: API 開發
- flutter-expert: Flutter app 開發
```

---

## 使用方式

1. 複製上面任一模板
2. 貼到 Claude Code
3. 根據需求調整成員或任務描述



---
啟用方式
在你的 settings.json 加入：


{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
或設定環境變數：


export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1



---

## Agent Teams vs 你的 Subagents / Agents

在此說明 **Agent Teams** (多代理團隊) 與你專案 `.claude/agents/` 中現有 **Subagents** (子代理) 的區別：

| 特性 | Subagents (`.claude/agents/`) | Agent Teams (實驗功能) |
| :--- | :--- | :--- |
| **定義** | 你的專案特定工具 | 全新的 Claude 協作實例 |
| **機制** | 單一 session 內執行任務 | 多個獨立 session 平行運作 |
| **Context** | 共享同一個 context window | 每個 agent 有獨立 context (較深) |
| **溝通** | 只能回報給主 agent | 彼此可以直接對話、廣播 |
| **觸發** | 根據 description 自動選用 | 用自然語言描述建立 Team |
| **適合** | 快速、專注的具體任務 | 複雜架構探索、多角度協作 |
| **Token** | 較低 (共享) | 較高 (多個實例累加) |

> **注意**：Agent Teams 的 teammates 是新建立的 **Claude 實例**，目前不會自動載入你 `.claude/agents/` 裡的客製化檔案，除非你明確指示他們去讀取。

## Team 操作快捷鍵

| 操作 | 說明 |
| :--- | :--- |
| `Shift+Up/Down` | 切換 teammate |
| `message [name]: [msg]` | 傳訊息給特定 teammate |
| `broadcast: [msg]` | 廣播給所有 teammate |
