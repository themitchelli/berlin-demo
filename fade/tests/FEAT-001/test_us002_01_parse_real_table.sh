#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: parseTable on real CSV returns two arrays of length 121 with male[0] === 0.004
# AC: tests/table.test.mjs loads data/mortality.csv with fs, calls parseTable, asserts lengths 121 and male[0] === 0.004
if [[ ! -f tests/table.test.mjs ]]; then echo "FAIL: tests/table.test.mjs missing"; exit 1; fi
out=$(node -e '
import("./src/engine/table.mjs").then(({parseTable}) => {
  const fs = require("fs");
  const t = parseTable(fs.readFileSync("data/mortality.csv","utf8"));
  console.log(t.male.length, t.female.length, t.male[0]);
});' 2>&1)
if [[ "$out" != "121 121 0.004" ]]; then echo "FAIL: parseTable output"; echo "Expected: 121 121 0.004"; echo "Actual: $out"; exit 1; fi
echo "PASS: parseTable returns 121-length arrays with male[0] === 0.004"
exit 0
