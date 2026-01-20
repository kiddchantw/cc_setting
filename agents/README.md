# Claude Code Agents

本目錄包含 Claude Code 的 AI Agent 定義。Agents 定義了 AI 的角色、專業領域和行為模式。

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

### 與其他專家文檔整合

Agents 可以互相參考規範：

---


---

## 📚 相關資源

### Claude 系統 (.claude)
- `.claude/README.md` - 系統總覽
- `.claude/skills/` - 可執行的工作流程
- `.claude/agents/` - AI 專家角色定義

### 本目錄相關文件

- [AGENT-STRUCTURE.md](AGENT-STRUCTURE.md) - Agent 結構、設計原則與重構歷史
