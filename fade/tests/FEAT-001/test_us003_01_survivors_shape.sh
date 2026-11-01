#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: survivors from age 0 starts at cohort, has length 122, ends at 0
# AC: survivors(1000000, male, 0)[0] === 1000000, its length is 122, and its last element is 0
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);const lx=survivors(1000000,male,0);console.log(lx[0],lx.length,lx[lx.length-1]);});' 2>&1)
if [[ "$out" != "1000000 122 0" ]]; then echo "FAIL: survivors shape"; echo "Expected: 1000000 122 0"; echo "Actual: $out"; exit 1; fi
echo "PASS: survivors(1000000, male, 0) has correct first, length, last"
exit 0
