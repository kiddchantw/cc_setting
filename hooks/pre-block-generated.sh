#!/bin/bash
# PreToolUse: 攔截直接編輯 generated 檔案
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [[ "$FILE_PATH" == *.g.dart ]] || [[ "$FILE_PATH" == *.freezed.dart ]]; then
    echo "⛔ 不可直接編輯 generated 檔案：$(basename $FILE_PATH)"
    echo "   請修改 source 檔案，再執行 build_runner"
    exit 1
fi
