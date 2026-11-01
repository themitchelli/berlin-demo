#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: the marker circle x position moves right as the age increases and matches #age
# AC: The marker x position moves right as the age increases and matches #age
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp();
const ctx = h.ctx('chart');
function markerX() {
  // Only look at the most recent draw: everything after the last full-canvas clear.
  const lastClear = ctx.calls.map(c => c.m).lastIndexOf('fillRect');
  const draw = ctx.calls.slice(lastClear);
  const arcs = draw.filter(c => c.m === 'arc' && c.args[2] === 6);
  if (arcs.length !== 1) fail('exactly one 6px marker circle per draw', 1, arcs.length);
  return arcs[0].args[0];
}
const positions = [];
positions.push({ age: h.text('age'), x: markerX() });
h.click('play');
h.advance(32); // first frame after play only re-baselines the clock
for (let i = 0; i < 5; i++) { h.advance(250); positions.push({ age: h.text('age'), x: markerX() }); }
for (let i = 1; i < positions.length; i++) {
  const prevAge = Number(positions[i-1].age.replace('Age ', '')), curAge = Number(positions[i].age.replace('Age ', ''));
  if (curAge !== prevAge + 1) fail('age should increase by one per 250 ms', prevAge + 1, curAge);
  if (!(positions[i].x > positions[i-1].x)) fail('marker x should move right from ' + positions[i-1].age + ' to ' + positions[i].age, '> ' + positions[i-1].x, positions[i].x);
}
// x is linear in age: step 5 should sit at 5 steps of the per-year spacing from step 0.
const step = positions[1].x - positions[0].x;
const expected = positions[0].x + 5 * step;
if (Math.abs(positions[5].x - expected) > 0.5) fail('marker x linear in age', expected, positions[5].x);
// A 1px vertical line is drawn at the same x.
const vlines = ctx.calls.slice(ctx.calls.map(c => c.m).lastIndexOf('fillRect')).filter(c => c.m === 'moveTo' && c.lineWidth === 1 && c.strokeStyle === '#ffffff');
if (!vlines.some(c => Math.abs(c.args[0] - positions[5].x) < 0.01)) fail('vertical marker line at marker x', positions[5].x, vlines.map(c => c.args[0]).join(','));
console.log('PASS: marker x moves right one step per year and matches #age (' + positions.map(p => p.age + '@' + p.x.toFixed(1)).join(', ') + ')');
" "$HARNESS"
