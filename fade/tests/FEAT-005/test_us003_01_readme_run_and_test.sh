#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: README has the required headings in order and its Run/Test commands work as written
# AC: A new reader can run the app and the tests from README alone
heads=$(grep -E '^## ' README.md | sed 's/^## //' | tr '\n' '|')
exp='What this is|The maths|Run it|Test it|Regenerate the table|Disclaimer|'
[[ "$heads" == "$exp" ]] || fail "README headings in order" "$exp" "$heads"
grep -qF 'python3 -m http.server 8080' README.md || fail "README run command" "python3 -m http.server 8080" "missing"
grep -qF 'http://localhost:8080/' README.md || fail "README URL" "http://localhost:8080/" "missing"
grep -qF 'node tools/generate-table.mjs' README.md || fail "README regenerate" "node tools/generate-table.mjs" "missing"
grep -qF 'python3 tools/reference.py' README.md || fail "README reference" "python3 tools/reference.py" "missing"
for s in 'l(x+1)' 'improvement' 'terminal'; do grep -qiF "$s" README.md || fail "README maths section mentions $s" "$s" "missing"; done

# Run the server exactly as documented (on a free port) and fetch the page
PORT=18085
python3 -m http.server $PORT --bind 127.0.0.1 > /dev/null 2>&1 &
PID=$!; trap 'kill $PID 2>/dev/null' EXIT
for i in $(seq 1 30); do curl -s -o /dev/null "http://127.0.0.1:$PORT/" && break; sleep 0.2; done
curl -s "http://127.0.0.1:$PORT/" | grep -q '1,000,000 LIVES' || fail "served page" "contains 1,000,000 LIVES" "not found"
kill $PID 2>/dev/null; wait $PID 2>/dev/null

# Run the test command from the README's "Test it" block
cmd=$(sed -n '/^## Test it/,/^## /p' README.md | grep -E '^node --test' | head -1)
[[ -n "$cmd" ]] || fail "README test command" "a node --test line under Test it" "none"
out=$(eval "$cmd" 2>&1); rc=$?
(( rc == 0 )) || fail "README test command '$cmd'" "exit 0" "exit $rc: $(tail -5 <<< "$out")"
grep -qE '(^|[^a-z])fail 0\b' <<< "$out" || fail "node --test failures" "# fail 0" "$(grep -E '(pass|fail) [0-9]+' <<< "$out")"
echo "PASS: README headings ordered; server and '$cmd' run as documented"
