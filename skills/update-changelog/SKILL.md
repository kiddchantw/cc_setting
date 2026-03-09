---
name: update-changelog
description: 自動從 session 文件更新 CHANGELOG.md 並推進版本號。當專案有新的 session 記錄但尚未更新 CHANGELOG 時使用。觸發詞：「更新 changelog」、「update changelog」、「版本發布」、「release version」
---

# 更新 CHANGELOG

## 工作流程

### 1. 解析 CHANGELOG 最新版本
讀取 `docs/CHANGELOG.md`，提取最新版本號和日期：
```markdown
## [1.0.7] - 2026-01-26
```

### 2. 掃描新 Session
找出 `docs/sessions/YYYY-MM/DD-*.md` 中日期 > CHANGELOG 日期的檔案。

**跳過**：`GUIDE.md`、`template.md`、`99-*.md`

### 3. 分類變更類型
根據 session 標題/內容關鍵字：
- **Fixed**：`fix`、`bug`、`修復`、`修正`
- **Added**：`add`、`new`、`新增`、`實作`
- **Changed**：`update`、`refactor`、`調整`、`重構`

### 4. 生成新版本條目
版本號：小版本 +1（`1.0.7` → `1.0.8`）

格式：
```markdown
## [1.0.8] - 2026-02-03

### Fixed
- **問題摘要** - 修復內容 ([Session](sessions/YYYY-MM/DD-xxx.md))

### Added
- **功能摘要** - 新增內容 ([Session](sessions/YYYY-MM/DD-xxx.md))

### Changed
- **變更摘要** - 調整內容
```

### 5. 更新版本號檔案
- Flutter：`pubspec.yaml` → `version: 1.0.8+1`
- Node.js：`package.json` → `"version": "1.0.8"`
- PHP：`composer.json` → `"version": "1.0.8"`

### 6. 寫入 CHANGELOG
插入新條目到 `## [Unreleased]` 之後。

## 完成檢查

- [ ] 新 session 已識別並分類
- [ ] 版本號已更新（CHANGELOG + pubspec/package.json）
- [ ] Session 連結路徑正確

## 下一步

1. `git add docs/CHANGELOG.md pubspec.yaml`
2. `@git-organize-commits` 整理 commit
3. `git tag v1.0.8`
