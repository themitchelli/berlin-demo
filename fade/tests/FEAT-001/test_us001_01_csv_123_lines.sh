#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: generator exits 0 and data/mortality.csv has exactly 123 lines
# AC: node tools/generate-table.mjs exits 0 and data/mortality.csv has exactly 123 lines (comment, header, 121 rows)
node tools/generate-table.mjs > /dev/null 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then echo "FAIL: generator exit code"; echo "Expected: 0"; echo "Actual: $rc"; exit 1; fi
lines=$(wc -l < data/mortality.csv | tr -d ' ')
if [[ "$lines" != "123" ]]; then echo "FAIL: line count of data/mortality.csv"; echo "Expected: 123"; echo "Actual: $lines"; exit 1; fi
first=$(head -1 data/mortality.csv)
if [[ "$first" != "# SYNTHETIC illustrative mortality. Not for real actuarial use." ]]; then echo "FAIL: comment line"; echo "Actual: $first"; exit 1; fi
second=$(sed -n 2p data/mortality.csv)
if [[ "$second" != "age,qx_male,qx_female" ]]; then echo "FAIL: header line"; echo "Actual: $second"; exit 1; fi
echo "PASS: generator exits 0 and CSV has 123 lines with correct comment and header"
exit 0
