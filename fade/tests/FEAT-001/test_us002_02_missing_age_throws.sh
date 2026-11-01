#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: CSV missing age 50 throws Error containing 'Missing age 50'
# AC: A CSV with age 50 removed throws an Error whose message contains 'Missing age 50'
out=$(node -e '
import("./src/engine/table.mjs").then(({parseTable}) => {
  const fs = require("fs");
  const csv = fs.readFileSync("data/mortality.csv","utf8").split("\n").filter(l => !l.startsWith("50,")).join("\n");
  try { parseTable(csv); console.log("NO_THROW"); } catch (e) { console.log(e.message); }
});' 2>&1)
if [[ "$out" != *"Missing age 50"* ]]; then echo "FAIL: missing-age error"; echo "Expected: message containing 'Missing age 50'"; echo "Actual: $out"; exit 1; fi
echo "PASS: missing age 50 throws '$out'"
exit 0
