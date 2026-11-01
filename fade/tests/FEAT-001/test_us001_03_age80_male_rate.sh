#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: age 80 male rate is 0.06015 to 5 decimal places
# AC: Row for age 80 male is 0.06015 to 5 decimal places (0.0002 + 0.00003 * exp(7.6) = 0.0601459)
node tools/generate-table.mjs > /dev/null 2>&1 || { echo "FAIL: generator failed"; exit 1; }
male80=$(grep '^80,' data/mortality.csv | cut -d, -f2)
rounded=$(node -e "console.log(Number(process.argv[1]).toFixed(5))" "$male80")
if [[ "$rounded" != "0.06015" ]]; then echo "FAIL: age 80 male rate"; echo "Expected: 0.06015"; echo "Actual: $male80 (rounded $rounded)"; exit 1; fi
echo "PASS: age 80 male rate is $male80"
exit 0
