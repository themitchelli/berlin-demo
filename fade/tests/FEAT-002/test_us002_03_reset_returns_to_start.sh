#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: reset returns to the starting age with 1,000,000 shown and stops playing
# AC: Reset returns to the starting age with 1,000,000 shown
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
h.click('play'); h.advance(3000);
if (h.text('age') === 'Age 0') fail('precondition: age should have advanced', 'not Age 0', h.text('age'));
h.click('reset');
if (h.text('age') !== 'Age 0') fail('#age after reset', 'Age 0', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive after reset', '1,000,000', h.text('alive'));
if (h.text('pct') !== '100.0%') fail('#pct after reset', '100.0%', h.text('pct'));
h.advance(1000);
if (h.text('age') !== 'Age 0') fail('reset should stop playing', 'Age 0', h.text('age'));
// Reset with a non-zero start age returns to that age.
h.setValue('startAge', '40'); h.click('play'); h.advance(2000); h.click('reset');
if (h.text('age') !== 'Age 40') fail('#age after reset from startAge 40', 'Age 40', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive after reset from startAge 40', '1,000,000', h.text('alive'));
console.log('PASS: reset returns to the starting age with 1,000,000 and stops');
" "$HARNESS"
