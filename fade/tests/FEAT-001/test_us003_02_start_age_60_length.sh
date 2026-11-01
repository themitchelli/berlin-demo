#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: survivors from age 60 has length 62
# AC: survivors(1000000, male, 60).length === 62
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);console.log(survivors(1000000,male,60).length);});' 2>&1)
if [[ "$out" != "62" ]]; then echo "FAIL: length from age 60"; echo "Expected: 62"; echo "Actual: $out"; exit 1; fi
echo "PASS: survivors from age 60 has length 62"
exit 0
