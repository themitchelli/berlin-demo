#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: CSV with age 10 male rate 1.2 throws Error mentioning 'age 10'
# AC: A CSV where age 10 male is 1.2 throws an Error whose message contains 'age 10'
out=$(node -e '
import("./src/engine/table.mjs").then(({parseTable}) => {
  const fs = require("fs");
  const csv = fs.readFileSync("data/mortality.csv","utf8").split("\n").map(l => l.startsWith("10,") ? "10,1.2," + l.split(",")[2] : l).join("\n");
  try { parseTable(csv); console.log("NO_THROW"); } catch (e) { console.log(e.message); }
});' 2>&1)
if [[ "$out" != *"age 10"* ]]; then echo "FAIL: out-of-range error"; echo "Expected: message containing 'age 10'"; echo "Actual: $out"; exit 1; fi
echo "PASS: out-of-range rate throws '$out'"
exit 0
