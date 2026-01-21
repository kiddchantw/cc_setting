# Skills 使用監控與優化方案

本文件提供實際的方法來監控 Skills 使用情況，並根據數據調整檔案結構。

---

## 📊 監控機制設計

### 1. 日誌收集 (Log Collection)

#### 方案 A：手動追蹤檔案

在 `.claude/skills/` 目錄建立監控記錄：

```
.claude/skills/
├── MONITORING.log              # 實時監控日誌
└── .monitoring/
    ├── daily-2026-01-21.json   # 每日統計
    ├── weekly-2026-w03.json    # 週統計
    └── monthly-2026-01.json    # 月統計
```

#### 日誌格式 (MONITORING.log)

```
[2026-01-21 10:15:32] SKILL_CALL: tdd-workflow
  - Duration: 45s
  - Files_Read: 3 (SKILL.md, examples/red.md, examples/green.md)
  - Tokens_Est: 1,740
  - User_Feedback: "很有幫助，例子清楚"
  - Context: "實作登入功能"

[2026-01-21 10:45:15] SKILL_CALL: laravel-security-review
  - Duration: 120s
  - Files_Read: 5 (SKILL.md, README, security-checklist, auth.md, validation.md)
  - Tokens_Est: 4,200
  - User_Feedback: "發現了 3 個安全問題"
  - Context: "審查 API 端點"

[2026-01-21 14:20:10] SKILL_CALL: tdd-workflow
  - Duration: 30s
  - Files_Read: 1 (SKILL.md only)
  - Tokens_Est: 990
  - User_Feedback: "只需要核心指令"
  - Context: "快速指導"
```

#### 自動化記錄腳本

建立 `.claude/agent-scripts/log-skill-usage.sh`：

```bash
#!/bin/bash
# log-skill-usage.sh - 記錄 Skill 使用情況

SKILL_NAME="$1"
DURATION="$2"
FILES_READ="$3"
TOKENS_EST="$4"
USER_FEEDBACK="$5"
CONTEXT="$6"

LOG_FILE=".claude/skills/MONITORING.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

cat >> "$LOG_FILE" << EOF
[$TIMESTAMP] SKILL_CALL: $SKILL_NAME
  - Duration: ${DURATION}s
  - Files_Read: $FILES_READ
  - Tokens_Est: $TOKENS_EST
  - User_Feedback: "$USER_FEEDBACK"
  - Context: "$CONTEXT"

EOF

echo "✅ 已記錄 $SKILL_NAME 的使用情況"
```

使用方式：
```bash
bash .claude/agent-scripts/log-skill-usage.sh \
  "tdd-workflow" "45" "3" "1740" "很有幫助" "實作功能"
```

---

### 2. 統計分析

#### 每日統計腳本 (daily-stats.sh)

```bash
#!/bin/bash
# daily-stats.sh - 生成每日統計報告

MONITOR_LOG=".claude/skills/MONITORING.log"
TODAY=$(date '+%Y-%m-%d')
OUTPUT_FILE=".claude/skills/.monitoring/daily-${TODAY}.json"

# 提取今天的記錄
grep "^\[$TODAY" "$MONITOR_LOG" | \
  awk '{
    # 提取 SKILL_NAME
    if ($0 ~ /SKILL_CALL: /) {
      match($0, /SKILL_CALL: (.+)/, arr)
      skill = arr[1]
    }

    # 提取 Duration, Tokens
    if ($0 ~ /Duration: /) {
      match($0, /Duration: ([0-9]+)s/, arr)
      duration = arr[1]
    }
    if ($0 ~ /Tokens_Est: /) {
      match($0, /Tokens_Est: ([0-9]+)/, arr)
      tokens = arr[1]
    }
  }
  END {
    print "統計已完成"
  }'

# 生成 JSON 統計
cat > "$OUTPUT_FILE" << 'EOF'
{
  "date": "$(date '+%Y-%m-%d')",
  "total_calls": $TOTAL_CALLS,
  "total_tokens": $TOTAL_TOKENS,
  "average_duration": $AVG_DURATION,
  "skills": [
    {
      "name": "tdd-workflow",
      "calls": 3,
      "tokens": 5220,
      "avg_files": 2.3,
      "satisfaction": "高"
    },
    {
      "name": "laravel-security-review",
      "calls": 1,
      "tokens": 4200,
      "avg_files": 5,
      "satisfaction": "高"
    }
  ]
}
EOF
```

生成的 JSON 格式：

```json
{
  "date": "2026-01-21",
  "total_calls": 12,
  "total_tokens": 18500,
  "average_duration_sec": 68,
  "skills": [
    {
      "name": "tdd-workflow",
      "calls": 5,
      "tokens_total": 8700,
      "tokens_avg": 1740,
      "avg_files_read": 2.4,
      "user_satisfaction": "9/10",
      "common_feedback": ["清楚", "實用", "範例好"],
      "contexts": [
        "實作登入功能",
        "快速指導",
        "重構控制器"
      ]
    },
    {
      "name": "laravel-security-review",
      "calls": 2,
      "tokens_total": 8400,
      "tokens_avg": 4200,
      "avg_files_read": 4.5,
      "user_satisfaction": "8.5/10",
      "common_feedback": ["發現問題", "很詳細"],
      "contexts": [
        "審查 API 端點",
        "驗證表單安全"
      ]
    },
    {
      "name": "test-planning",
      "calls": 5,
      "tokens_total": 1400,
      "tokens_avg": 280,
      "avg_files_read": 1.2,
      "user_satisfaction": "7/10",
      "common_feedback": ["簡潔", "有幫助"],
      "contexts": [
        "單元測試規劃",
        "特徵測試設計"
      ]
    }
  ]
}
```

---

## 📈 使用資料儀表板

### 建立月度報告 (SKILLS_REPORT.md)

每月自動生成，記錄在 `.claude/skills/.monitoring/` 中：

```markdown
# 2026 年 1 月 Skills 使用報告

生成時間: 2026-02-01
統計期間: 2026-01-01 ~ 2026-01-31

## 📊 整體統計

- **總呼叫次數**: 156 次
- **總 Token 消耗**: 285,000 tokens
- **平均每次消耗**: 1,827 tokens
- **平均執行時間**: 62 秒
- **使用者滿意度**: 8.2/10

## 🏆 最常使用的 Skills (Top 5)

| 排名 | Skill 名稱 | 呼叫次數 | Token 消耗 | 平均滿意度 | 趨勢 |
|------|-----------|---------|----------|----------|------|
| 1 | tdd-workflow | 48 | 83,520 | 9.1/10 | ↑↑ |
| 2 | laravel-security-review | 32 | 134,400 | 8.5/10 | ↑ |
| 3 | git-organize-commits | 28 | 42,000 | 8.0/10 | → |
| 4 | test-planning | 26 | 7,280 | 7.5/10 | ↓ |
| 5 | laravel-performance-review | 22 | 18,150 | 8.8/10 | ↑↑ |

## 📂 按需載入效果分析

### tdd-workflow 優化成果

| 指標 | 優化前 | 優化後 | 節省 |
|------|-------|-------|------|
| 平均文件讀取 | 3.2 個 | 2.1 個 | 34% |
| 平均 Token 消耗 | 2,400 | 1,740 | 27.5% |
| 僅讀核心 (%) | 15% | 45% | +200% ⚡ |
| 需要完整指南 (%) | 85% | 22% | -74% ⚡ |

**結論**: 按需載入效果顯著。簡單查詢的使用者現在 45% 的時間只讀核心文件。

### laravel-security-review 優化建議

目前平均文件讀取: **4.5 個**

使用者反饋:
- "太多文件，有點混亂" (20%)
- "很詳細，但可以再組織" (30%)
- "非常有幫助" (50%)

**建議**: 將 checklist 分為 3 層級 (基礎/中等/高級)

---

## 🎯 使用者反饋收集

### 1. 自動反饋提示

在 SKILL.md 結尾添加：

```markdown
## 📝 使用反饋

完成後，請選擇以下之一：
- ⭐⭐⭐⭐⭐ 完美！立即可用
- ⭐⭐⭐⭐ 很好，小改進
- ⭐⭐⭐ 可用，需要調整
- ⭐⭐ 有幫助，但不夠清楚
- ⭐ 需要改進

可選：分享你的想法？
- "什麼最有幫助？"
- "什麼需要改進？"
- "缺少什麼？"
```

### 2. 反饋記錄格式

```json
{
  "date": "2026-01-21",
  "skill": "tdd-workflow",
  "rating": 5,
  "helpful_aspects": ["清楚的步驟", "好的範例", "紅-綠-重構流程"],
  "areas_for_improvement": ["可以加更多進階範例"],
  "missing_features": [],
  "comments": "很好用！幫我快速理解 TDD 流程",
  "execution_time": 45,
  "files_read": 3,
  "user_context": "實作登入功能"
}
```

### 3. 收集反饋的腳本

在 `.claude/agent-scripts/collect-feedback.sh`：

```bash
#!/bin/bash
# collect-feedback.sh - 收集和記錄使用者反饋

SKILL_NAME="$1"
RATING="${2:-3}"  # 預設 3 星
HELPFUL="${3:--}"
IMPROVEMENT="${4:--}"
MISSING="${5:--}"
COMMENTS="${6:--}"
EXEC_TIME="${7:-0}"
FILES_READ="${8:-1}"

FEEDBACK_DIR=".claude/skills/.monitoring/feedback"
mkdir -p "$FEEDBACK_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
FILENAME="$FEEDBACK_DIR/$(date '+%Y-%m-%d')-${SKILL_NAME}.jsonl"

# 追加到 JSONL 檔案
cat >> "$FILENAME" << EOF
{
  "timestamp": "$TIMESTAMP",
  "skill": "$SKILL_NAME",
  "rating": $RATING,
  "helpful": "$HELPFUL",
  "improvement": "$IMPROVEMENT",
  "missing": "$MISSING",
  "comments": "$COMMENTS",
  "exec_time": $EXEC_TIME,
  "files_read": $FILES_READ
}
EOF

echo "✅ 感謝反饋！已記錄。"
```

使用示例：
```bash
bash .claude/agent-scripts/collect-feedback.sh \
  "tdd-workflow" "5" "清楚的步驟,好的範例" "" "" "很有幫助" "45" "3"
```

---

## 📋 定期審查清單

### 週審查 (每週一)

檢查項目：
- [ ] 前一週最常用的 3 個 Skills
- [ ] 有沒有使用率下降的 Skills (可能有問題)
- [ ] 平均滿意度是否 > 8/10
- [ ] Token 消耗趨勢

簽核指令：
```bash
# 生成週報告
bash .claude/agent-scripts/generate-weekly-report.sh $(date '+%Y-w%V')

# 檢查關鍵指標
cat .claude/skills/.monitoring/weekly-$(date '+%Y-w%V').json | \
  jq '.skills[] | select(.calls > 10) | {name, calls, satisfaction}'
```

### 月審查 (月末)

檢查項目：
- [ ] 按需載入效果 (有沒有真正節省 token?)
- [ ] 使用者滿意度趨勢
- [ ] 有沒有需要重構的 Skills (文件太多、太複雜)
- [ ] 新增的 Skills 是否被使用
- [ ] 是否有功能重疊的 Skills

簽核指令：
```bash
# 生成月報告
bash .claude/agent-scripts/generate-monthly-report.sh $(date '+%Y-%m')

# 檢查滿意度趨勢
cat .claude/skills/.monitoring/monthly-$(date '+%Y-%m').json | \
  jq '.skills[] | {name, calls, satisfaction, trend}'
```

---

## 🔄 基於數據的優化流程

### 流程圖

```
每次使用 Skill
    ↓
自動記錄 (log-skill-usage.sh)
    ├─ Duration
    ├─ Files_Read
    ├─ Tokens_Est
    └─ Context
    ↓
收集反饋 (collect-feedback.sh)
    ├─ Rating (1-5)
    ├─ Helpful aspects
    ├─ Areas for improvement
    └─ Comments
    ↓
每日自動統計
    ├─ 生成 daily-YYYY-MM-DD.json
    ├─ 計算 Skills 排名
    └─ 識別異常
    ↓
週/月審查
    ├─ 檢查趨勢
    ├─ 識別問題
    └─ 提出優化建議
    ↓
優化執行
    ├─ 分離檔案 (按需載入)
    ├─ 重構文件結構
    └─ 測試新版本
    ↓
驗證效果
    ├─ 監控新指標
    ├─ 收集反饋
    └─ 重複
```

---

## 📊 主要監控指標

### 1. Token 效率

```
Token 效率 = 提供的價值 / Token 消耗

計算方式:
- 高滿意度 (≥ 8/10) = 1.2x 價值倍數
- 中滿意度 (5-8) = 1.0x 價值倍數
- 低滿意度 (< 5) = 0.8x 價值倍數

目標: 所有 Skills 的平均效率 > 1.0
```

### 2. 按需載入比例

```
按需載入比例 = 只讀核心檔案的呼叫次數 / 總呼叫次數

目標:
- 簡單 Skill (tdd-workflow): > 40%
- 中等 Skill (security-review): > 20%
- 複雜 Skill (performance-review): > 10%
```

### 3. 使用成長度

```
使用成長度 = (本月呼叫數 - 上月呼叫數) / 上月呼叫數

正成長: 表示 Skill 有價值
負成長: 需要調查原因 (太複雜? 有問題?)
```

### 4. 滿意度指數

```
整體滿意度 = ∑(各 Skill 的評分 × 呼叫權重) / 總權重

目標: ≥ 8.0/10

低於 7.0 的 Skill:
- 標記為「需要改進」
- 安排重構
- 收集詳細反饋
```

---

## 🛠️ 實施檢查清單

### Phase 1：基礎監控 (第 1 週)

- [ ] 建立 `.monitoring/` 目錄結構
- [ ] 編寫 `log-skill-usage.sh` 腳本
- [ ] 編寫 `collect-feedback.sh` 腳本
- [ ] 在 5 個主要 Skills 中添加反饋提示
- [ ] 開始手動記錄使用情況 (可用於建立基線)

**預期成果**: 有基本的使用數據

### Phase 2：自動化統計 (第 2 週)

- [ ] 編寫 `generate-daily-stats.sh`
- [ ] 編寫 `generate-weekly-report.sh`
- [ ] 編寫 `generate-monthly-report.sh`
- [ ] 設定自動執行 (cron job 或類似)
- [ ] 建立監控儀表板模板

**預期成果**: 自動生成的日/週/月報告

### Phase 3：數據驅動優化 (第 3 週+)

- [ ] 分析前 2 週的數據
- [ ] 識別需要優化的 Skills
- [ ] 執行優化 (分離檔案、重構等)
- [ ] 監控優化效果
- [ ] 根據反饋調整

**預期成果**: 量化的改進成果

---

## 📝 範例：基於監控數據的優化決策

### 案例 1：laravel-security-review 太複雜

**監控數據**:
- 平均讀取 4.5 個檔案
- 滿意度 8.5/10 但有改進建議
- 反饋: "太多檔案，有點混亂"
- Token 消耗: 4,200 (較高)

**決策**:
```
優化方向: 分層結構
- 基礎層: 5 個核心檢查清單 (SKILL.md)
- 中級層: 詳細的安全最佳實踐 (README.md)
- 進階層: 特定情景的深度指南 (references/)

預期結果:
- 45% 的簡單檢查只讀 SKILL.md (節省 60%)
- 35% 的中等檢查讀 SKILL.md + README
- 20% 的複雜檢查讀完整資源
```

### 案例 2：test-planning 使用率下降

**監控數據**:
- 上月 35 次呼叫 → 本月 26 次 (-26%)
- 滿意度 7.5/10 (低於平均)
- 反饋: "簡潔，但缺少進階例子"

**決策**:
```
調查選項:
1. 過時了? → 檢查是否有新的測試工具/方法
2. 太簡單? → 添加進階例子或相關 Skills 連結
3. 有替代品? → 與其他 Skills 合併?

行動:
- 添加 3-5 個進階測試場景
- 加入特定框架 (PHPUnit, Pest) 的例子
- 連結到 laravel-security-review (安全測試)
```

---

## 🎓 結論

通過以下方式實現「監控實際使用」：

1. **自動記錄** - 每次 Skill 呼叫都記錄使用情況
2. **收集反饋** - 定期收集使用者的星評和評論
3. **統計分析** - 自動生成日/週/月報告
4. **識別問題** - 基於數據找出需要優化的 Skills
5. **數據驅動決策** - 根據實際數據進行優化，而非猜測

**關鍵指標**:
- Token 效率 > 1.0
- 按需載入比例 > 目標值
- 使用成長度趨勢向上
- 滿意度指數 ≥ 8.0/10

**預期時間**: 3 週建立完整監控系統，之後進入持續優化迴圈。
