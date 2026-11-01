#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: age 0 and age 120 rows have the fixed values
# AC: Row for age 0 is 0,0.00400000,0.00350000 and row for age 120 is 120,1.00000000,1.00000000
node tools/generate-table.mjs > /dev/null 2>&1 || { echo "FAIL: generator failed"; exit 1; }
r0=$(grep '^0,' data/mortality.csv)
if [[ "$r0" != "0,0.00400000,0.00350000" ]]; then echo "FAIL: age 0 row"; echo "Expected: 0,0.00400000,0.00350000"; echo "Actual: $r0"; exit 1; fi
r120=$(grep '^120,' data/mortality.csv)
if [[ "$r120" != "120,1.00000000,1.00000000" ]]; then echo "FAIL: age 120 row"; echo "Expected: 120,1.00000000,1.00000000"; echo "Actual: $r120"; exit 1; fi
echo "PASS: age 0 and age 120 rows correct"
exit 0
