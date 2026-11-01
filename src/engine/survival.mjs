// Survival engine. Pure functions, no DOM, no fetch, no fs, no randomness.
//
// Terminal age convention: q(120) = 1. Everyone alive at 120 dies in that year.
// So the survivor count at age 121 is always 0.
//
// survivors(cohort, qx, startAge) returns lx where lx[0] is the count alive at
// startAge and lx[i + 1] = lx[i] * (1 - qx[startAge + i]). The array runs to age
// 121, so its length is 121 - startAge + 1. No rounding is applied anywhere.
//
// applyImprovement(qx, pct) returns a new array where every rate is (1 - pct) * qx[x],
// with pct between 0 and 0.3 inclusive.

const MAX_AGE = 120;
const MAX_IMPROVEMENT = 0.3;

export function survivors(cohort, qx, startAge) {
  const lx = [cohort];
  for (let age = startAge; age <= MAX_AGE; age++) {
    lx.push(lx[lx.length - 1] * (1 - qx[age]));
  }
  return lx;
}

export function applyImprovement(qx, pct) {
  if (!(pct >= 0 && pct <= MAX_IMPROVEMENT)) {
    throw new Error('pct must be between 0 and 0.3');
  }
  return Array.from(qx, (q) => (1 - pct) * q);
}
