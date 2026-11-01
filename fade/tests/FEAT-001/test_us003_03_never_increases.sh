#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: survivor counts never increase
# AC: For every i, lx[i+1] <= lx[i] (never increases)
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);for(const s of [0,30,60]){const lx=survivors(1000000,male,s);for(let i=0;i+1<lx.length;i++){if(lx[i+1]>lx[i]){console.log("INCREASE start="+s+" i="+i+" "+lx[i]+" -> "+lx[i+1]);process.exit(0);}}}console.log("OK");});' 2>&1)
if [[ "$out" != "OK" ]]; then echo "FAIL: survivors increased"; echo "Expected: monotone non-increasing"; echo "Actual: $out"; exit 1; fi
echo "PASS: survivors are monotone non-increasing"
exit 0
