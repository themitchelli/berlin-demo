import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { parseTable } from '../src/engine/table.mjs';
import { survivors, applyImprovement } from '../src/engine/survival.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const csvText = readFileSync(join(here, '..', 'data', 'mortality.csv'), 'utf8');
const { male } = parseTable(csvText);

test('survivors from age 0 starts at the cohort, has 122 entries and ends at 0', () => {
  const lx = survivors(1000000, male, 0);
  assert.equal(lx[0], 1000000);
  assert.equal(lx.length, 122);
  assert.equal(lx[lx.length - 1], 0);
});

test('survivors from age 60 has length 62', () => {
  assert.equal(survivors(1000000, male, 60).length, 62);
});

test('survivor counts never increase with age', () => {
  const lx = survivors(1000000, male, 0);
  for (let i = 0; i + 1 < lx.length; i++) {
    assert.ok(lx[i + 1] <= lx[i], `increase at index ${i}`);
  }
});

test('zero mortality to 119 and q(120)=1 keeps everyone alive to 120 and none at 121', () => {
  const qx = new Array(121).fill(0);
  qx[120] = 1;
  const lx = survivors(1000, qx, 0);
  for (let i = 0; i <= 120; i++) {
    assert.equal(lx[i], 1000, `index ${i}`);
  }
  assert.equal(lx[121], 0);
});

test('certain death at age 30 leaves no survivors from index 31 onwards', () => {
  const qx = new Array(121).fill(0);
  qx[30] = 1;
  qx[120] = 1;
  const lx = survivors(1000000, qx, 0);
  assert.equal(lx[30], 1000000);
  for (let i = 31; i < lx.length; i++) {
    assert.equal(lx[i], 0, `index ${i}`);
  }
});

test('applyImprovement(male, 0.1) at age 80 is 0.9 times the baseline rate', () => {
  const improved = applyImprovement(male, 0.1);
  assert.ok(Math.abs(improved[80] - 0.9 * male[80]) < 1e-12);
});

test('improved survivors are at least the baseline at every index', () => {
  const base = survivors(1000000, male, 0);
  const improved = survivors(1000000, applyImprovement(male, 0.1), 0);
  assert.equal(improved.length, base.length);
  for (let i = 0; i < base.length; i++) {
    assert.ok(improved[i] >= base[i], `index ${i}`);
  }
});

test('applyImprovement returns a new array and leaves the input unchanged', () => {
  const before = male[80];
  const improved = applyImprovement(male, 0.1);
  assert.notEqual(improved, male);
  assert.equal(male[80], before);
});

test('applyImprovement throws for pct above 0.3 and below 0', () => {
  assert.throws(() => applyImprovement(male, 0.31), /pct must be between 0 and 0.3/);
  assert.throws(() => applyImprovement(male, -0.01), /pct must be between 0 and 0.3/);
});
