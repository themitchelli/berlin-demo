#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
fail() { echo "FAIL: $1"; echo "Expected: $2"; echo "Actual: $3"; exit 1; }
# Returns the declaration block for a selector in styles.css (comments stripped)
rule() { sed 's,/\*.*\*/,,g' styles.css | tr '\n' ' ' | grep -oE "(^|\})\s*$1\s*\{[^}]*\}" | head -1; }
# Test: disclaimer is in the markup and styled fixed at the bottom, 14px, 70% opacity
# AC: The disclaimer is visible at 1920x1080 and 1280x720
# A fixed-position footer with no media queries renders at every viewport size, so a static check suffices.
grep -qF '<footer id="disclaimer">Synthetic mortality assumptions for illustration only. Not for real actuarial use.</footer>' index.html \
  || fail "disclaimer markup" "footer#disclaimer with the exact sentence" "$(grep -n disclaimer index.html)"
d=$(rule '#disclaimer'); [[ -z "$d" ]] && fail "#disclaimer rule" "present in styles.css" "missing"
grep -qE 'position:\s*fixed' <<< "$d" || fail "#disclaimer position" "fixed" "$d"
grep -qE 'bottom:' <<< "$d" || fail "#disclaimer bottom" "bottom set" "$d"
grep -qE 'font-size:\s*14px' <<< "$d" || fail "#disclaimer font-size" "14px" "$d"
grep -qE 'opacity:\s*0?\.7' <<< "$d" || fail "#disclaimer opacity" "0.7" "$d"
grep -qE 'display:\s*none|visibility:\s*hidden' <<< "$d" && fail "#disclaimer hidden" "visible" "$d"
grep -q '@media' styles.css && fail "media queries could hide it" "no @media rules" "$(grep -n @media styles.css)"
grep -qE 'padding:[^;]*48px' <<< "$(rule '\.stage')" || fail ".stage reserves bottom space" "48px bottom padding" "$(rule '\.stage')"
echo "PASS: disclaimer present, fixed at the bottom, 14px, 70% opacity, no media queries"
