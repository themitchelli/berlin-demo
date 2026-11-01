#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: no external fonts or stylesheets are referenced by the page or its CSS
# AC: No external fonts or stylesheets
for f in index.html styles.css; do
  if grep -nE '@import|@font-face|https?://|//fonts\.|\.woff|\.ttf|\.otf' "$f"; then
    fail "external font/stylesheet reference in $f" "none" "see lines above"
  fi
done
links=$(grep -oE '<link[^>]*>' index.html)
if grep -vqE 'href="styles\.css"' <<< "$links"; then
  fail "only local stylesheet link" 'href="styles.css"' "$links"
fi
grep -qE 'font-family:\s*-apple-system,\s*"?Segoe UI"?,\s*Roboto,\s*sans-serif' <<< "$(rule 'body')" \
  || fail "system font stack" "-apple-system, Segoe UI, Roboto, sans-serif" "$(rule 'body')"
echo "PASS: no external fonts or stylesheets; system font stack in use"
