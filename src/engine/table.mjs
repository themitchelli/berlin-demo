// Mortality table loader. Pure: takes CSV text as a string.
// No DOM, no fetch, no fs. Callers read the file and pass the text in.
//
// Expected CSV: comment lines starting with '#', a header line
// "age,qx_male,qx_female", then one row per age 0..120.
// Returns { male, female }: Float64Array(121) of qx indexed by age.
// Terminal age convention: q(120) = 1. Everyone alive at 120 dies in that year.

const MIN_AGE = 0;
const MAX_AGE = 120;
const TABLE_LENGTH = MAX_AGE - MIN_AGE + 1;

export function parseTable(csvText) {
  const male = new Float64Array(TABLE_LENGTH);
  const female = new Float64Array(TABLE_LENGTH);
  const seen = new Uint8Array(TABLE_LENGTH);
  let headerSkipped = false;

  for (const rawLine of csvText.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (line === '' || line.startsWith('#')) continue;

    if (!headerSkipped) {
      headerSkipped = true;
      if (line.split(',')[0].trim() === 'age') continue;
    }

    const cells = line.split(',');
    const age = Number(cells[0]);
    if (!Number.isInteger(age) || age < MIN_AGE || age > MAX_AGE) {
      throw new Error(`Invalid age ${cells[0]}`);
    }
    if (seen[age]) {
      throw new Error(`Duplicate age ${age}`);
    }
    seen[age] = 1;

    const qMale = Number(cells[1]);
    const qFemale = Number(cells[2]);
    if (!(qMale >= 0 && qMale <= 1)) {
      throw new Error(`Rate out of range at age ${age}`);
    }
    if (!(qFemale >= 0 && qFemale <= 1)) {
      throw new Error(`Rate out of range at age ${age}`);
    }
    male[age] = qMale;
    female[age] = qFemale;
  }

  for (let age = MIN_AGE; age <= MAX_AGE; age++) {
    if (!seen[age]) {
      throw new Error(`Missing age ${age}`);
    }
  }

  return { male, female };
}
