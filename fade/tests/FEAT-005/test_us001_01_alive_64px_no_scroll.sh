#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: at 1920x1080 #alive renders at least 64px tall and the page cannot scroll
# AC: At 1920x1080 the #alive figure is at least 64px tall and there are no scrollbars
# Static check of styles.css: clamp(48px, 6vw, 96px) at 1920 wide is min(max(48,115.2),96) = 96px >= 64px.
alive=$(rule '#alive'); [[ -z "$alive" ]] && alive=$(rule '#age,\s*#alive')
[[ -z "$alive" ]] && fail "#alive rule in styles.css" "a rule for #alive" "none found"
grep -qE 'font-size:\s*clamp\(48px,\s*6vw,\s*96px\)' <<< "$alive" || fail "#alive font-size" "clamp(48px, 6vw, 96px)" "$alive"
grep -qE 'font-weight:\s*700' <<< "$alive" || fail "#alive font-weight" "700" "$alive"
vw=$(( 1920 * 6 / 100 )); px=$vw; (( px > 96 )) && px=96; (( px < 48 )) && px=48
(( px >= 64 )) || fail "#alive computed size at 1920" ">= 64px" "${px}px"
# No scrollbars: html/body overflow hidden and the grid is exactly one viewport tall
body=$(rule 'html,\s*body')
grep -qE 'overflow:\s*hidden' <<< "$body" || fail "html,body overflow" "overflow: hidden" "$body"
stage=$(rule '\.stage')
grep -qE 'height:\s*100vh' <<< "$stage" || fail ".stage height" "100vh" "$stage"
grep -qE 'box-sizing:\s*border-box' <<< "$stage" || fail ".stage box-sizing" "border-box" "$stage"
grep -qE 'background:\s*#05070d' <<< "$(rule 'body')" || fail "body background" "#05070d" "$(rule 'body')"
echo "PASS: #alive is ${px}px at 1920 wide, page overflow hidden, 100vh grid"
