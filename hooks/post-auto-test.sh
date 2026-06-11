#!/bin/bash
# PostToolUse: 編輯 lib/features/X/ 後自動跑 test/unit/X/
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

FLUTTER_DIR="/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter"
[[ "$FILE_PATH" != "$FLUTTER_DIR"* ]] && exit 0

python3 -c "
import os, re, subprocess, sys

path = '''$FILE_PATH'''
m = re.search(r'lib/features/([^/]+)/', path)
if not m:
    sys.exit(0)

feature = m.group(1)
test_dir = '/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/test/unit/' + feature

if not os.path.isdir(test_dir):
    sys.exit(0)

print(f'🧪 自動跑 test/unit/{feature}/')
result = subprocess.run(
    ['/opt/homebrew/bin/flutter', 'test', test_dir, '--no-pub', '--reporter', 'compact'],
    capture_output=True, text=True,
    cwd='/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter'
)
output = (result.stdout + result.stderr)
print(output[-600:] if len(output) > 600 else output)
"
