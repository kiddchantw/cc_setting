# Claude Code Agents

本目錄包含 Claude Code 的 AI Agent 定義。Agents 定義了 AI 的角色、專業領域和行為模式。

> ✅ **Token Optimized**: 所有 Agents 皆已採行「單檔案精簡」策略，平均減少 34.3% Token 消耗。

---

## 🤖 可用 Agents

### 開發專家

#### `laravel-expert`
**用途**: Laravel 後端開發專家

**觸發時機**:
- 開發 Laravel API endpoints
- 設計資料庫 schema 和 migrations
- 實作 Eloquent 關聯
- 撰寫 middleware、validation、service layer
- Laravel 效能優化
- 撰寫 Feature/Unit 測試

**模型**: Sonnet

---

#### `flutter-expert`
**用途**: Flutter 前端開發專家

**觸發時機**:
- 開發 Flutter UI 元件
- 實作 state management
- 跨平台功能開發
- Flutter 效能優化
- 偵測到 `.dart` 檔案或 `pubspec.yaml`

**模型**: Sonnet

---

### 程式碼審查

#### `laravel-reviewer`
**用途**: Laravel 程式碼審查專家

**觸發時機**:
- 完成 Laravel 功能實作後
- 提交程式碼前
- 重構 Laravel 程式碼時
- 需要安全性/效能審查

**審查範圍**:
- ✅ 安全性（SQL injection, XSS, CSRF, mass assignment, auth/authz）
- ✅ 效能（N+1 queries, indexes, caching, query optimization）
- ✅ 架構（SOLID principles, thin controllers, service layer, repository pattern）
- ✅ 測試（Coverage, quality, edge cases, test database setup）
- ✅ Laravel 最佳實踐（Form Requests, Resources, Policies, Eloquent usage）

**模型**: Sonnet

---

#### `flutter-reviewer`
**用途**: Flutter 程式碼審查專家

**觸發時機**:
- 完成 Flutter 功能實作後
- 提交程式碼前
- 重構 Flutter widgets 或 state management
- 需要效能/架構審查

**審查範圍**:
- ✅ Widget 架構（Composition, const usage, key management, rebuild efficiency）
- ✅ State management（Scope correctness, proper disposal, patterns, unnecessary rebuilds）
- ✅ 效能（List rendering, image optimization, animation performance, memory management）
- ✅ Null safety（Proper handling, avoid `!` assertions）
- ✅ Flutter 最佳實踐（Dart style guide, naming conventions, error handling）

**模型**: Sonnet

---

## 🎯 使用方式

### 自動觸發

Agents 會根據 `description` 自動觸發：

```
# 當你編輯 .dart 檔案時
→ flutter-expert 自動啟動

# 當你開發 Laravel API 時
→ laravel-expert 自動啟動

# 當你完成功能要審查時
→ laravel-reviewer 或 flutter-reviewer 自動啟動
```

### 手動指定（如果需要）

在對話中提到特定 agent：

```
請使用 laravel-reviewer 審查這段程式碼
請用 flutter-expert 幫我實作這個 widget
```

---

## 🔗 與其他系統整合

### 與 Skills 整合

Agents 可以建議使用相關 skills：

```markdown
# 在 laravel-expert.md 中
**Note**: For comprehensive security review, use the `laravel-security-review` skill.

# 在 flutter-expert.md 中
**Note**: For API client generation, use the `flutter-openapi-generator` skill.
```

### 與 Conventions (規範) 整合

為了節省 Token 並保持一致性，詳細的規範與代碼範例已移至共享文件：

- **`laravel-conventions.md`**: 架構、效能、安全與測試規範 (7.0 KB)
- **`flutter-conventions.md`**: Widget 架構、狀態管理與 Null Safety 規範 (2.8 KB)

Agent 會在需要時引導或參考這些文件，而非在每次對話中重複加載所有細節。

---

## 📚 相關資源

### Claude 系統 (.claude)
- `.claude/README.md` - 系統總覽
- `.claude/skills/` - 可執行的工作流程
- `.claude/agents/` - AI 專家角色定義

### Agent Teams (實驗功能)

除了單一 Agent，我們也支援 **Agent Teams** (多代理團隊) 協作模式。

- **定義文件**: `../team-templates.md`
- **用途**: 透過複製模板建立多個獨立的 Claude 實例進行協作 (如：全端開發 Team、規格審查 Team)。
- **差異**: Team 成員擁有獨立 Context，適合複雜任務；單一 Agent 共享 Context，適合快速任務。

---

### 本目錄相關文件

- [AGENT-STRUCTURE.md](AGENT-STRUCTURE.md) - Agent 結構、設計原則與重構歷史
