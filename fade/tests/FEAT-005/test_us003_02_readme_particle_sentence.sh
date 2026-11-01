#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: README states the particle field displays the engine's numbers and adds no randomness
# AC: README contains the sentence about the particle field and the engine
sec=$(sed -n '/^## What this is/,/^## /p' README.md)
grep -qiE 'particle field.*display of the engine' <<< "$sec" || fail "particle field sentence" "particle field is a display of the engine's numbers (under What this is)" "$sec"
grep -qiE 'no randomness' <<< "$sec" || fail "randomness sentence" "introduces no randomness into the calculation" "$sec"
echo "PASS: README states the particle field displays engine numbers with no randomness"
