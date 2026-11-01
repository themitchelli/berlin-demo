#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: applyImprovement rejects pct outside 0..0.3
# AC: applyImprovement(male, 0.31) and applyImprovement(male, -0.01) both throw
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);const r=[];for(const p of [0.31,-0.01]){try{applyImprovement(male,p);r.push("NO_THROW("+p+")");}catch(e){r.push("THROW");}}console.log(r.join(" "));});' 2>&1)
if [[ "$out" != "THROW THROW" ]]; then echo "FAIL: applyImprovement range check"; echo "Expected: THROW THROW"; echo "Actual: $out"; exit 1; fi
echo "PASS: applyImprovement throws for 0.31 and -0.01"
exit 0
