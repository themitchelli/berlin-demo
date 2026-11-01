#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: q(30)=1 zeroes survivors from index 31 onwards
# AC: With q(30)=1 in a copy of the table, survivors from age 0 is 0 from index 31 onwards
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);const q=male.slice();q[30]=1;const lx=survivors(1000000,q,0);let ok=lx[30]>0;for(let i=31;i<lx.length;i++)if(lx[i]!==0){ok=false;console.log("idx "+i+" = "+lx[i]);}console.log(ok?"OK":"BAD lx[30]="+lx[30]);});' 2>&1)
if [[ "$out" != "OK" ]]; then echo "FAIL: q(30)=1 case"; echo "Expected: lx[31..] all 0"; echo "Actual: $out"; exit 1; fi
echo "PASS: q(30)=1 zeroes survivors from index 31"
exit 0
