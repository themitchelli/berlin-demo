#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: changing #sex or #startAge recomputes the baseline and updates the three figures
# AC: Changing #sex or #startAge recomputes baseline and updates the three figures immediately
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const { parseTable } = await import(process.argv[2] + '/src/engine/table.mjs');
const { survivors } = await import(process.argv[2] + '/src/engine/survival.mjs');
const { readFileSync } = await import('node:fs');
const table = parseTable(readFileSync(process.argv[2] + '/data/mortality.csv', 'utf8'));
const h = await loadApp();

// Play a few years so the figures are not at the start, then change startAge.
h.click('play'); h.advance(1300);
if (h.text('age') === 'Age 0') fail('precondition: age should have advanced', 'not Age 0', h.text('age'));
h.setValue('startAge', '60');
if (h.text('age') !== 'Age 60') fail('#age after startAge=60', 'Age 60', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive after startAge=60', '1,000,000', h.text('alive'));
if (h.text('pct') !== '100.0%') fail('#pct after startAge=60', '100.0%', h.text('pct'));

// Advance 4 years from 60 and compare with the engine for male, then switch sex and compare for female.
h.click('play'); h.advance(4 * 250 + 20); h.click('pause');
const age = Number(h.text('age').replace('Age ', ''));
const maleExpected = Math.round(survivors(1000000, table.male, 60)[age - 60]).toLocaleString('en-GB');
if (h.text('alive') !== maleExpected) fail('#alive male at age ' + age, maleExpected, h.text('alive'));

h.setValue('sex', 'female');
if (h.text('age') !== 'Age 60') fail('#age resets on sex change', 'Age 60', h.text('age'));
h.click('play'); h.advance(4 * 250 + 20); h.click('pause');
const age2 = Number(h.text('age').replace('Age ', ''));
const femaleExpected = Math.round(survivors(1000000, table.female, 60)[age2 - 60]).toLocaleString('en-GB');
if (h.text('alive') !== femaleExpected) fail('#alive female at age ' + age2, femaleExpected, h.text('alive'));
if (femaleExpected === maleExpected) fail('female and male baselines should differ', 'different', 'same');
const pctExpected = ((survivors(1000000, table.female, 60)[age2 - 60] / 1000000) * 100).toFixed(1) + '%';
if (h.text('pct') !== pctExpected) fail('#pct female', pctExpected, h.text('pct'));
console.log('PASS: sex and startAge changes recompute the baseline and update #age, #alive and #pct');
" "$HARNESS" "$ROOT"
