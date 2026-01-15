---
name: test-planning
description: Plan tests and architecture using SOLID principles before implementation
model: claude-3-5-sonnet
---

# Test Planning

> **📖 詳細中文說明**: `docs_claude/skills/test-planning/README_zh_TW.md`
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

- [ ] Test case checklist (Markdown)
- [ ] Architecture design (optional)
- [ ] Mock/Stub strategy
- [ ] Priority order

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
