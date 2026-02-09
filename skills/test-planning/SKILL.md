---
name: test-planning
description: Plan tests and architecture using SOLID principles before implementation
model: claude-3-5-sonnet
---

# Test Planning

> **📖 詳細中文說明**: `README_zh_TW.md`
> 
> **🎯 適用框架**: Laravel (Pest) | Flutter (Dart)

## Overview

Universal test planning workflow using SOLID principles. Works for both backend (Laravel) and frontend (Flutter) development.

## Workflow

### 1. Analyze Requirements
- Read spec/user story
- Identify core business logic
- List all scenarios

### 2. Break Down Test Cases (SOLID-driven)
- **S**: One test per behavior
- **O**: Design extensible interfaces
- **L**: Ensure substitutability
- **I**: Small, focused interfaces
- **D**: Plan Mock/Stub strategy

### 3. Test Scenarios
- ✅ Happy Path
- 🔢 Boundary Conditions
- ❌ Error Handling
- 🔒 Authorization
- 🔗 Integration

### 4. Architecture Design
- Define interfaces
- Plan dependency injection
- Design Mock/Stub strategy

### 5. Prioritize
1. Core business logic (high risk)
2. Boundary conditions (error-prone)
3. Error handling (stability)
4. Integration (completeness)

## Output

**重要規則**:
1. **不要建立新的獨立檔案** - 測試計劃應直接寫入當前正在處理的 Session 文件
2. **動態識別 Session 文件** - 根據用戶當前打開或引用的 session 文件來添加測試計劃
3. **更新現有的 Testing Phase** - 在 Session 文件中找到 `Phase X: Testing` 區塊並更新，如果不存在則新增

**實作方式**:
- 檢查用戶當前打開的文件或引用的 session 文件
- 在該文件的 `Phase X: Testing` 區塊中添加測試計劃內容
- 如果沒有 Testing Phase，在 Implementation Checklist 區塊中新增一個

**輸出內容** (直接寫入 Session 文件):

- [ ] Test case checklist (Markdown) - 寫入 Session 文件的 Testing Phase
- [ ] Architecture design (optional) - 寫入 Session 文件的 Testing Phase
- [ ] Mock/Stub strategy - 寫入 Session 文件的 Testing Phase
- [ ] Priority order - 寫入 Session 文件的 Testing Phase

**格式範例** (添加到當前 Session 文件):
```markdown
### Phase X: Testing [📋 Test Planning Completed]

#### Test Planning (測試規劃)

##### 1. 需求分析 (Requirements Analysis)
...

##### 2. 測試案例拆解 (SOLID-driven Test Cases)
...

##### 3. 測試場景 (Test Scenarios)
...

##### 4. 架構設計 (Architecture Design)
...

##### 5. 測試優先順序 (Priority Order)
...
```

**注意**: 
- 不要建立 `*-test-plan.md` 之類的新檔案
- 不要寫死特定 session 文件路徑
- 根據用戶當前上下文動態識別要更新的 session 文件

## Laravel Testing Database

### ⚠️ Critical Rules
- **Use SQLite** for tests (in-memory or file-based)
- **NEVER** use production database
- **NEVER** run `migrate:fresh` or `db:wipe` in tests
- Use `RefreshDatabase` trait (auto-rollback)

### Setup
```env
# phpunit.xml or .env.testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### Test Traits
```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserTest extends TestCase {
    use RefreshDatabase;  // ✅ Safe: auto-rollback
}
```

## Next Step

Use `@tdd-workflow` to execute Red-Green-Refactor cycle.
