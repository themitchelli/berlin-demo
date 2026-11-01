#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
# Test: sanity bounds on reference values
# AC: Male 30 is above 980000 and male 110 is below 1000
out=$(python3 -c 'import json;d=json.load(open("data/reference.json"))["male"];m30=d["30"];m110=d["110"];print("OK" if m30>980000 and m110<1000 else f"BAD m30={m30} m110={m110}")')
if [[ "$out" != "OK" ]]; then echo "FAIL: sanity bounds"; echo "Expected: male30 > 980000 and male110 < 1000"; echo "Actual: $out"; exit 1; fi
echo "PASS: reference sanity bounds hold"
exit 0
