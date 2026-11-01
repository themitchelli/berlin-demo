#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: rates are non-decreasing for both sexes from age 1 to 120
# AC: For both sexes q(x) <= q(x+1) for every x from 1 to 119
node tools/generate-table.mjs > /dev/null 2>&1 || { echo "FAIL: generator failed"; exit 1; }
out=$(awk -F, 'NR>2 && $1>=1 { if (prev_set && ($2 < pm || $3 < pf)) { printf "age %d: male %s<%s or female %s<%s\n", $1, $2, pm, $3, pf; bad=1 } pm=$2; pf=$3; prev_set=1 } END { exit bad }' data/mortality.csv)
if [[ $? -ne 0 ]]; then echo "FAIL: rates decrease somewhere"; echo "Expected: q(x) <= q(x+1) for x in 1..119"; echo "Actual: $out"; exit 1; fi
echo "PASS: rates are monotone non-decreasing for ages 1..120"
exit 0
