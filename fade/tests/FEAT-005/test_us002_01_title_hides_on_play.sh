#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: title present on load, fades on Play and is display:none within 1 second
# AC: The title is visible on load and invisible within 1 second of pressing Play
grep -qE '<div id="?title"?>1,000,000 LIVES</div>' index.html || fail "title markup" '<div id="title">1,000,000 LIVES</div>' "$(grep -n 'id="title"' index.html)"
t=$(rule '#title'); grep -qE 'transition:\s*opacity 600ms' <<< "$t" || fail "#title transition" "opacity 600ms" "$t"
grep -qE 'letter-spacing:\s*0\.08em' <<< "$t" || fail "#title letter-spacing" "0.08em" "$t"
grep -qE 'clamp\(64px,\s*10vw,\s*160px\)' <<< "$t" || fail "#title font-size" "clamp(64px, 10vw, 160px)" "$t"
grep -qE 'opacity:\s*0' <<< "$(rule '#title\.fading')" || fail "#title.fading" "opacity: 0" "$(rule '#title\.fading')"
grep -qE 'display:\s*none' <<< "$(rule '#title\[hidden\]')" || fail "#title[hidden]" "display: none" "$(rule '#title\[hidden\]')"
grep -qE 'TITLE_FADE_MS\s*=\s*600' src/app.mjs || fail "fade timer in app.mjs" "600 ms" "$(grep -n TITLE_FADE_MS src/app.mjs | head -1)"
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
if (h.els.title.hidden) fail('title visible on load', 'hidden=false', 'hidden=true');
if (h.els.title.classList.contains('fading')) fail('title opaque on load', 'no fading class', 'fading');
h.click('play'); h.advance(700);
if (!h.els.title.classList.contains('fading')) fail('title fading after Play', 'fading class', 'absent');
if (!h.els.title.hidden) fail('title hidden after fade', 'hidden=true', 'hidden=false');
console.log('PASS: title visible on load, fading then hidden after Play');
" "$HARNESS"
