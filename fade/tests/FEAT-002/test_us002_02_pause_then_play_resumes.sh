#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: pause freezes the age and play resumes from the same age
# AC: Pause then Play resumes from the same age
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
h.click('play'); h.advance(2000);
h.click('pause');
const paused = h.text('age');
if (paused === 'Age 0') fail('precondition: age should have advanced before pause', 'not Age 0', paused);
h.advance(3000);
if (h.text('age') !== paused) fail('age changed while paused', paused, h.text('age'));
h.click('play');
if (h.text('age') !== paused) fail('age jumped on resume', paused, h.text('age'));
// First frame after resume re-baselines the clock, so allow one extra frame.
h.advance(250 + 32);
const next = 'Age ' + (Number(paused.replace('Age ', '')) + 1);
if (h.text('age') !== next) fail('age one step after resume', next, h.text('age'));
console.log('PASS: pause holds the age and play resumes from ' + paused);
" "$HARNESS"
