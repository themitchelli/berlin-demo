#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: reference.py exits 0 and reference.json contains exactly eight numbers
# AC: python3 tools/reference.py exits 0 and data/reference.json has exactly eight numbers
# Run in a temp copy so the committed data/reference.json is never rewritten by the test
tmp=$(mktemp -d /tmp/fade-feat001-ref.XXXXXX)
mkdir -p "$tmp/data" "$tmp/tools"
cp data/mortality.csv "$tmp/data/"; cp tools/reference.py "$tmp/tools/"
( cd "$tmp" && python3 tools/reference.py > /dev/null 2>&1 ); rc=$?
if [[ $rc -ne 0 ]]; then echo "FAIL: reference.py exit code"; echo "Expected: 0"; echo "Actual: $rc"; rm -rf "$tmp"; exit 1; fi
count=$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));n=[v for s in d.values() for v in s.values() if isinstance(v,(int,float))];print(len(n) if set(d)=={"male","female"} else -1)' "$tmp/data/reference.json")
rm -rf "$tmp"
if [[ "$count" != "8" ]]; then echo "FAIL: reference.json number count"; echo "Expected: 8 numbers under male/female"; echo "Actual: $count"; exit 1; fi
echo "PASS: reference.py writes eight numbers"
exit 0
