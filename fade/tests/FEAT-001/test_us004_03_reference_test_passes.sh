#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: tests/reference.test.mjs passes under node --test
# AC: tests/reference.test.mjs passes under node --test
if [[ ! -f tests/reference.test.mjs ]]; then echo "FAIL: tests/reference.test.mjs missing"; exit 1; fi
out=$(node --test tests/reference.test.mjs 2>&1); rc=$?
if [[ $rc -ne 0 ]]; then echo "FAIL: node --test tests/reference.test.mjs"; echo "Expected: exit 0"; echo "Actual: exit $rc"; echo "$out" | tail -20; exit 1; fi
echo "PASS: tests/reference.test.mjs passes under node --test"
exit 0
