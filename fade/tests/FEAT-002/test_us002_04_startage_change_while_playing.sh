#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: changing startAge to 60 while playing resets to Age 60 with 1,000,000 and stops
# AC: Changing startAge to 60 while playing shows 'Age 60' and 1,000,000
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
h.click('play'); h.advance(2000);
h.setValue('startAge', '60');
if (h.text('age') !== 'Age 60') fail('#age after startAge=60 while playing', 'Age 60', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive after startAge=60', '1,000,000', h.text('alive'));
if (h.text('pct') !== '100.0%') fail('#pct after startAge=60', '100.0%', h.text('pct'));
h.advance(1000);
if (h.text('age') !== 'Age 60') fail('setting change should behave like reset (stop playing)', 'Age 60', h.text('age'));
// Changing sex while playing behaves the same way.
h.click('play'); h.advance(1000); h.setValue('sex', 'female');
if (h.text('age') !== 'Age 60') fail('#age after sex change while playing', 'Age 60', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive after sex change', '1,000,000', h.text('alive'));
console.log('PASS: changing startAge to 60 while playing shows Age 60 and 1,000,000');
" "$HARNESS"
