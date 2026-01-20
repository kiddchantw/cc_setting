---
name: tdd-workflow
description: Execute Red-Green-Refactor cycle with minimal implementation
model: claude-3-5-haiku
---

# TDD Workflow

> **📖 詳細中文說明**: `README_zh_TW.md`
> 
> **🎯 適用框架**: Laravel (Pest) | Flutter (Dart)

## Overview

Universal TDD workflow: Red-Green-Refactor cycle. Core principles apply to both Laravel and Flutter, with framework-specific commands noted below.

## Red-Green-Refactor Cycle

### 🔴 Red - Write Failing Test
1. Pick test case from `@test-planning`
2. Write test
3. **Ensure it fails** (reason: feature not implemented)

**Checklist**:
- [ ] Test name describes behavior
- [ ] Test fails (red)
- [ ] Failure message is expected

### 🟢 Green - Minimal Implementation
1. Write **minimum code** to pass
2. Hardcode/duplicate OK
3. **Ensure test passes**

**Checklist**:
- [ ] Test passes (green)
- [ ] Only necessary code written
- [ ] No over-engineering

### 🔵 Refactor - Verify SOLID
1. Compare with `@test-planning` design
2. Refactor to match architecture
3. **Ensure tests still pass**

**SOLID Checklist**:
- [ ] **S**: One responsibility per class/method
- [ ] **O**: Extend without modifying
- [ ] **L**: Subclass substitutable
- [ ] **I**: Small, focused interfaces
- [ ] **D**: Depend on abstractions

## Execution

### 1. Pick Test Case
- High priority first
- Simple to complex
- One at a time

### 2. Run Tests
```bash
# Laravel
php artisan test --filter="test name"

# Flutter
flutter test test/path/file_test.dart
```

### 3. Commit
```bash
git add .
git commit -m "test: add XXX test and implementation"
```

### 4. Run All Tests
```bash
# Laravel
php artisan test

# Flutter
flutter test
```

## Common Pitfalls

- ❌ Skip Red: Write code first, test later
- ❌ Over-engineer in Green: Write too much code
- ❌ Skip Refactor: Accumulate tech debt
- ❌ Change behavior in Refactor: Tests should still pass

## Completion Checklist

- [ ] Tests pass (green)
- [ ] Code follows SOLID
- [ ] All tests still pass
- [ ] Git commit
- [ ] Update `@test-planning` checklist

## Next Steps

1. Run full test suite
2. Check coverage
3. Update docs
4. Code review
