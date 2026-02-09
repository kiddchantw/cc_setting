# 📝 變更歷史 (Changelog)


## 2026-02-09: Agent Teams 文件更新
**狀態**: ✅ 已完成 | **文件新增**: `team-templates.md`

**變更內容**:
- 新增 `team-templates.md`: 定義 Agent Teams 模板與操作指南。
- 更新 `AGENT-STRUCTURE.md`: 補充協作模式說明 (Subagents vs Teams)。
- 更新 `README.md`: 加入 Agent Teams 簡介。

**目標**:
- 釐清 Agent Teams 與 Subagents 的區別與適用場景。
- 提供實驗性功能的啟用方式與快捷鍵文件。



## 2026-01-21: Token 消耗優化 (Scheme C)
**狀態**: ✅ 已完成 | **總節省**: 34.3% (2,839 tokens)

**變更內容**:
- 實施「單檔案精簡優化」策略，壓縮 4 個核心 Agents。
- 強化 `laravel-conventions.md` (擴充至 7.0 KB) 以支援內容移轉。
- 保持 `flutter-conventions.md` 不變。

**優化成果**:
| Agent | 優化前 | 優化後 | 節省率 |
|-------|-------|-------|-------|
| `laravel-expert` | 2,580 | 1,599 | **38.1%** |
| `flutter-expert` | 1,980 | 1,253 | **36.7%** |
| `flutter-reviewer` | 2,010 | 1,362 | **32.2%** |
| `laravel-reviewer` | 1,710 | 1,227 | **28.0%** |
| **平均** | **2,070** | **1,360** | **34.3%** |

**決策要點**:
1. **保留核心決策**: Version 檢測、測試策略、Review Process 完整保留。
2. **移轉靜態知識**: 將教科書式的說明與詳細範例移至 Conventions。
3. **遵守官方限制**: 放棄子目錄結構，維持扁平化單檔案設計。

**效益**:
- 全系統 Token 消耗降低 21.4% (節省 $6.4/月)。
- Agent 回應更專注與快速。
- 維護性提升 (詳細規範集中管理)。

## 2026-01-20: 職責分離重構

**變更內容**:
- 拆分 `code-reviewer` 為 `laravel-reviewer` 和 `flutter-reviewer`
- 保持 `laravel-expert` 和 `flutter-expert` 專注於開發

**決策要點**:
1. **拆分混合角色**: 移除 `code-reviewer.md`，改用框架專屬審查專家
2. **專門化審查範圍**:
   - **Laravel**: 強化 N+1、安全漏洞、Eloquent 最佳實踐審查
   - **Flutter**: 專注 Widget 效能、狀態管理、Null Safety
3. **區分 Agents 與 Skills**:
   - **Agents**: 身份角色（專業背景與行為準則）
   - **Skills**: 工具流程（自動化腳本與任務步驟）

**效益**:
- 減少 token 消耗
- 提供更精確的錯誤偵測
- 符合單一職責原則

### 共享資源 (Shared Resources)
- `agent-scripts/` - 自動化腳本
- `agent-scripts/templates/` - 文件模板
