#!/bin/bash
# PostToolUse: 編輯 Dart 檔後自動 flutter analyze
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

FLUTTER_DIR="/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter"

if [[ "$FILE_PATH" == *.dart ]] \
  && [[ "$FILE_PATH" != *.g.dart ]] \
  && [[ "$FILE_PATH" != *.freezed.dart ]] \
  && [[ "$FILE_PATH" == "$FLUTTER_DIR"* ]]; then
    cd "$FLUTTER_DIR"
    RESULT=$(/opt/homebrew/bin/flutter analyze --no-pub "$FILE_PATH" 2>&1)
    echo "$RESULT" | grep -E 'error|warning|hint|No issues found' | tail -5
fi
