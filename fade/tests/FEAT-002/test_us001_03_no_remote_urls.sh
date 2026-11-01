#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: no http:// or https:// URLs in the page or its scripts/styles
# AC: View source shows no http:// or https:// URLs
hits=$(grep -nE 'https?://' index.html styles.css src/*.mjs src/engine/*.mjs 2>/dev/null)
if [[ -n "$hits" ]]; then echo "FAIL: remote URLs found"; echo "Expected: none"; echo "Actual:"; echo "$hits"; exit 1; fi
echo "PASS: no http:// or https:// URLs in index.html, styles.css or src/"
exit 0
