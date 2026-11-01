#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: applyImprovement scales rates and improves survival at every index
# AC: applyImprovement(male, 0.1)[80] within 1e-12 of 0.9 * male[80]; improved survivors >= baseline at every index
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);const imp=applyImprovement(male,0.1);const d=Math.abs(imp[80]-0.9*male[80]);if(d>=1e-12){console.log("DIFF "+d);process.exit(0);}if(imp===male||imp[80]===male[80]){console.log("NOT_NEW_ARRAY");process.exit(0);}const a=survivors(1000000,male,0),b=survivors(1000000,imp,0);for(let i=0;i<a.length;i++)if(b[i]<a[i]){console.log("WORSE idx "+i+" "+b[i]+" < "+a[i]);process.exit(0);}console.log("OK");});' 2>&1)
if [[ "$out" != "OK" ]]; then echo "FAIL: applyImprovement"; echo "Expected: scaled rate and improved survival"; echo "Actual: $out"; exit 1; fi
echo "PASS: applyImprovement scales rates and never lowers survival"
exit 0
