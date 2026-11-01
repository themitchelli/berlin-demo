#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: tests/survival.test.mjs exists and passes under node --test
# AC: All of the above live in tests/survival.test.mjs and node --test passes
if [[ ! -f tests/survival.test.mjs ]]; then echo "FAIL: tests/survival.test.mjs missing"; exit 1; fi
out=$(node --test tests/survival.test.mjs 2>&1); rc=$?
if [[ $rc -ne 0 ]]; then echo "FAIL: node --test tests/survival.test.mjs"; echo "Expected: exit 0"; echo "Actual: exit $rc"; echo "$out" | tail -20; exit 1; fi
echo "PASS: tests/survival.test.mjs passes under node --test"
exit 0
