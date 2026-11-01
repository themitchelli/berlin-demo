#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: playing from age 0 reaches Age 121 with 0 survivors in about 30 seconds and stops
# AC: Play from 0 reaches 'Age 121' and '0' survivors in about 30 seconds and stops
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
h.click('play');
h.advance(29000);
if (h.text('age') === 'Age 121') fail('reached 121 too early', 'not yet at 121 after 29 s', h.text('age'));
h.advance(2500);
if (h.text('age') !== 'Age 121') fail('#age after 31.5 s', 'Age 121', h.text('age'));
if (h.text('alive') !== '0') fail('#alive at 121', '0', h.text('alive'));
if (h.text('pct') !== '0.0%') fail('#pct at 121', '0.0%', h.text('pct'));
h.advance(5000);
if (h.text('age') !== 'Age 121') fail('should stop at 121', 'Age 121', h.text('age'));
console.log('PASS: play reaches Age 121 with 0 survivors between 29 and 31.5 s and stops');
" "$HARNESS"
