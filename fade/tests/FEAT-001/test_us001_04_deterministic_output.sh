#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: running the generator twice produces byte-identical output
# AC: Running the generator twice gives byte-identical output (check with cmp)
node tools/generate-table.mjs > /dev/null 2>&1 || { echo "FAIL: first run failed"; exit 1; }
cp data/mortality.csv /tmp/fade-feat001-mortality-run1.csv
node tools/generate-table.mjs > /dev/null 2>&1 || { echo "FAIL: second run failed"; exit 1; }
if ! cmp -s /tmp/fade-feat001-mortality-run1.csv data/mortality.csv; then
  echo "FAIL: generator output not deterministic"; echo "Expected: identical files"; echo "Actual: cmp reports difference"
  cmp /tmp/fade-feat001-mortality-run1.csv data/mortality.csv; exit 1
fi
rm -f /tmp/fade-feat001-mortality-run1.csv
echo "PASS: generator output is byte-identical across runs"
exit 0
