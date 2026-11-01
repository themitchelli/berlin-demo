import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { parseTable } from '../src/engine/table.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const csvPath = join(here, '..', 'data', 'mortality.csv');
const csvText = readFileSync(csvPath, 'utf8');

// Replace one data row (by age) in the CSV text, keeping every other line.
function replaceRow(text, age, newRow) {
  return text
    .split('\n')
    .map((line) => (line.startsWith(`${age},`) ? newRow : line))
    .join('\n');
}

function removeRow(text, age) {
  return text
    .split('\n')
    .filter((line) => !line.startsWith(`${age},`))
    .join('\n');
}

test('loads data/mortality.csv into 121-element male and female arrays', () => {
  const { male, female } = parseTable(csvText);
  assert.equal(male.length, 121);
  assert.equal(female.length, 121);
  assert.equal(male[0], 0.004);
  assert.equal(female[0], 0.0035);
  assert.equal(male[120], 1);
  assert.equal(female[120], 1);
});

test('throws "Missing age 50" when age 50 is absent', () => {
  const text = removeRow(csvText, 50);
  assert.throws(() => parseTable(text), /Missing age 50/);
});

test('throws a message naming age 10 when male age 10 is 1.2', () => {
  const text = replaceRow(csvText, 10, '10,1.2,0.001');
  assert.throws(() => parseTable(text), /age 10/);
});

test('throws "Duplicate age" when a row is repeated', () => {
  const lines = csvText.split('\n');
  const row = lines.find((line) => line.startsWith('30,'));
  const text = lines.concat(row).join('\n');
  assert.throws(() => parseTable(text), /Duplicate age 30/);
});

test('throws when a rate is negative', () => {
  const text = replaceRow(csvText, 20, '20,-0.001,0.001');
  assert.throws(() => parseTable(text), /Rate out of range at age 20/);
});
