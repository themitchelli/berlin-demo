#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: node --test passes for the table test file
# AC: node --test passes
out=$(node --test tests/table.test.mjs 2>&1); rc=$?
if [[ $rc -ne 0 ]]; then echo "FAIL: node --test tests/table.test.mjs"; echo "Expected: exit 0"; echo "Actual: exit $rc"; echo "$out" | tail -20; exit 1; fi
echo "PASS: tests/table.test.mjs passes under node --test"
exit 0
