#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: Reset shows the title again after it was hidden by Play
# AC: Reset brings the title back
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
h.click('play'); h.advance(700);
if (!h.els.title.hidden) fail('precondition: title hidden after Play', 'hidden=true', 'hidden=false');
h.click('reset'); h.advance(50);
if (h.els.title.hidden) fail('title after Reset', 'hidden=false', 'hidden=true');
if (h.els.title.classList.contains('fading')) fail('title opacity after Reset', 'no fading class', 'fading');
if (h.text('age') !== 'Age 0') fail('age after Reset', 'Age 0', h.text('age'));
console.log('PASS: Reset brings the title back');
" "$HARNESS"
