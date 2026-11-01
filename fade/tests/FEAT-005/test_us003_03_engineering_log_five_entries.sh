#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: ENGINEERING_LOG.md has one entry per PRD FEAT-001..FEAT-005 with the required fields
# AC: ENGINEERING_LOG.md has five entries, one per PRD
[[ -f ENGINEERING_LOG.md ]] || fail "ENGINEERING_LOG.md exists" "file present" "missing"
n=$(grep -cE '^## FEAT-00[1-5]' ENGINEERING_LOG.md)
(( n == 5 )) || fail "entry count" "5" "$n"
for i in 1 2 3 4 5; do
  entry=$(sed -n "/^## FEAT-00$i/,/^## /p" ENGINEERING_LOG.md)
  [[ -n "$entry" ]] || fail "entry FEAT-00$i" "present" "missing"
  grep -qE 'Date:.*20[0-9]{2}-[0-9]{2}-[0-9]{2}' <<< "$entry" || fail "FEAT-00$i date" "a YYYY-MM-DD date" "$(grep -i date <<< "$entry")"
  grep -qi 'Decisions' <<< "$entry" || fail "FEAT-00$i decisions" "Decisions line" "missing"
  grep -qi 'node --test' <<< "$entry" || fail "FEAT-00$i test command" "node --test" "missing"
  grep -qi 'limitations' <<< "$entry" || fail "FEAT-00$i known limitations" "Known limitations line" "missing"
done
echo "PASS: ENGINEERING_LOG.md has five dated entries with decisions, test command and limitations"
