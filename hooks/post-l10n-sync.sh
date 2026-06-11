#!/bin/bash
# PostToolUse: 編輯 app_en.arb 後警告 zh.arb 缺漏的 key
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [[ "$FILE_PATH" == *"app_en.arb" ]]; then
    python3 -c "
import json
base = '/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/l10n'
try:
    en = set(k for k in json.load(open(f'{base}/app_en.arb')) if not k.startswith('@'))
    zh = set(k for k in json.load(open(f'{base}/app_zh.arb')) if not k.startswith('@'))
    missing = sorted(en - zh)
    if missing:
        print(f'⚠️  zh.arb 缺少 {len(missing)} 個 key：{missing[:5]}')
        if len(missing) > 5:
            print(f'   ...還有 {len(missing)-5} 個，執行 /l10n-reviewer 查看全部')
    else:
        print('✅ en/zh arb 同步')
except Exception as e:
    print(f'l10n 檢查失敗：{e}')
"
fi
