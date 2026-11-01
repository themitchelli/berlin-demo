// Generates data/mortality.csv: a SYNTHETIC illustrative mortality table.
//
// Formula for ages x >= 1:  q(x) = min(1, A + B * exp(C * x))
//   Male:   A = 0.0002, B = 0.00003, C = 0.095
//   Female: A = 0.0002, B = 0.00002, C = 0.095
// Fixed points: q(0) = 0.004 (male), 0.0035 (female); q(120) = 1 for both.
// Terminal age convention: q(120) = 1, so everyone alive at 120 dies in that year.
//
// Deterministic: Math.exp only, no randomness, so repeated runs are byte-identical.

import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const MAX_AGE = 120;
const C = 0.095;
const MALE = { A: 0.0002, B: 0.00003, Q0: 0.004 };
const FEMALE = { A: 0.0002, B: 0.00002, Q0: 0.0035 };

function qx(params, age) {
  if (age === 0) return params.Q0;
  if (age === MAX_AGE) return 1;
  return Math.min(1, params.A + params.B * Math.exp(C * age));
}

export function buildCsv() {
  const lines = [
    '# SYNTHETIC illustrative mortality. Not for real actuarial use.',
    'age,qx_male,qx_female',
  ];
  for (let age = 0; age <= MAX_AGE; age++) {
    lines.push(
      `${age},${qx(MALE, age).toFixed(8)},${qx(FEMALE, age).toFixed(8)}`,
    );
  }
  return lines.join('\n') + '\n';
}

// Only write when run directly, so tests can import buildCsv without side effects.
const isMain = process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];
if (isMain) {
  const root = join(dirname(fileURLToPath(import.meta.url)), '..');
  mkdirSync(join(root, 'data'), { recursive: true });
  writeFileSync(join(root, 'data', 'mortality.csv'), buildCsv());
}
