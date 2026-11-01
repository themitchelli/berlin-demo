#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: all-zero rates with q(120)=1 keeps cohort at 1000 through age 120 then 0
# AC: with a copy of the table where q(120)=1 and all other q=0, lx is 1000 up to age 120 and 0 at 121
out=$(node -e 'const fs=require("fs");Promise.all([import("./src/engine/table.mjs"),import("./src/engine/survival.mjs")]).then(([{parseTable},{survivors,applyImprovement}])=>{const t=parseTable(fs.readFileSync("data/mortality.csv","utf8"));const male=Array.from(t.male);const q=new Array(121).fill(0);q[120]=1;const lx=survivors(1000,q,0);let ok=lx.length===122;for(let i=0;i<=120;i++)if(lx[i]!==1000){ok=false;console.log("idx "+i+" = "+lx[i]);}if(lx[121]!==0){ok=false;console.log("idx 121 = "+lx[121]);}console.log(ok?"OK":"BAD");});' 2>&1)
if [[ "$out" != "OK" ]]; then echo "FAIL: zero-rate table"; echo "Expected: 1000 at 0..120, 0 at 121"; echo "Actual: $out"; exit 1; fi
echo "PASS: zero-rate table with q(120)=1 behaves correctly"
exit 0
