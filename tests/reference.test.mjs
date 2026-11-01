// Cross-check the JS survival engine against the independent Python reference.
// data/reference.json is produced by tools/reference.py and must not be edited.
// If this test fails, the engine is wrong until a human says otherwise.

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { parseTable } from '../src/engine/table.mjs';
import { survivors } from '../src/engine/survival.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..');
const csvText = readFileSync(join(root, 'data', 'mortality.csv'), 'utf8');
const reference = JSON.parse(readFileSync(join(root, 'data', 'reference.json'), 'utf8'));
const table = parseTable(csvText);
const COHORT = 1000000;
const TOLERANCE = 0.5;
const AGES = [30, 65, 90, 110];

for (const sex of ['male', 'female']) {
  const js = survivors(COHORT, table[sex], 0);
  for (const age of AGES) {
    test(`${sex} survivors at age ${age} match reference within 0.5 lives`, () => {
      const expected = reference[sex][String(age)];
      const actual = js[age];
      assert.ok(
        Math.abs(actual - expected) < TOLERANCE,
        `${sex} age ${age}: js=${actual} reference=${expected} diff=${actual - expected}`,
      );
    });
  }
}

test('reference.json holds exactly the eight expected values', () => {
  for (const sex of ['male', 'female']) {
    assert.deepEqual(Object.keys(reference[sex]).sort(), ['110', '30', '65', '90']);
  }
});
