#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: drawChart clears the canvas and draws the curve from the top-left at startAge to 0 at age 121 on the right
# AC: The curve starts at the top left at startAge and reaches 0 at 121 on the right
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const { drawChart } = await import(process.argv[2] + '/src/chart.mjs');
const { parseTable } = await import(process.argv[2] + '/src/engine/table.mjs');
const { survivors } = await import(process.argv[2] + '/src/engine/survival.mjs');
const { readFileSync } = await import('node:fs');
const table = parseTable(readFileSync(process.argv[2] + '/data/mortality.csv', 'utf8'));
const h = await loadApp();
const canvas = h.els.chart; canvas.width = 800; canvas.height = 400;
for (const startAge of [0, 60]) {
  const values = survivors(1000000, table.male, startAge);
  const ctx = canvas.getContext('2d'); ctx.calls.length = 0;
  drawChart(canvas, [{ values, colour: '#7fd1ff' }], startAge, startAge);
  const calls = ctx.calls;
  const first = calls[0];
  if (!first || !['fillRect', 'clearRect'].includes(first.m) || first.args.join(',') !== '0,0,800,400') fail('first call should clear the whole canvas', 'fillRect/clearRect(0,0,800,400)', JSON.stringify(first));
  // The curve is the 2px path with the series colour.
  const curve = calls.filter(c => c.lineWidth === 2 && c.strokeStyle === '#7fd1ff' && (c.m === 'moveTo' || c.m === 'lineTo'));
  if (curve.length !== values.length) fail('curve point count (startAge ' + startAge + ')', values.length, curve.length);
  const [x0, y0] = curve[0].args; const [xN, yN] = curve[curve.length - 1].args;
  const cx = curve.map(c => c.args[0]), cy = curve.map(c => c.args[1]);
  for (let i = 1; i < curve.length; i++) {
    if (!(cx[i] > cx[i-1])) fail('curve x must increase left to right (startAge ' + startAge + ')', '> ' + cx[i-1], cx[i]);
    if (cy[i] < cy[i-1] - 1e-9) fail('curve y must never rise (startAge ' + startAge + ')', '>= ' + cy[i-1], cy[i]);
  }
  if (!(xN > x0)) fail('curve spans left to right', '> ' + x0, xN);
  if (!(yN > y0)) fail('curve spans top to bottom (0 at the bottom)', '> ' + y0, yN);
  // The curve starts on the y axis: a 1px vertical line at x0 spanning y0..yN.
  const thin = calls.filter(c => c.lineWidth === 1 && (c.m === 'moveTo' || c.m === 'lineTo'));
  const yAxis = thin.some(c => Math.abs(c.args[0] - x0) < 0.01 && Math.abs(c.args[1] - y0) < 0.01) && thin.some(c => Math.abs(c.args[0] - x0) < 0.01 && Math.abs(c.args[1] - yN) < 0.01);
  if (!yAxis) fail('curve starts on the y axis at the top (startAge ' + startAge + ')', 'axis line at x=' + x0 + ' from y=' + y0 + ' to ' + yN, 'not found');
  // The curve ends at the right end of the x axis (y = 0 line).
  const xAxisEnd = thin.some(c => Math.abs(c.args[0] - xN) < 0.01 && Math.abs(c.args[1] - yN) < 0.01);
  if (!xAxisEnd) fail('curve ends at the right end of the x axis at 0 (startAge ' + startAge + ')', 'axis point at (' + xN + ',' + yN + ')', 'not found');
  if (values[values.length - 1] !== 0) fail('series must end at 0 survivors at 121', 0, values[values.length - 1]);
  // Axis labels: '200k' style every 200,000 and an age tick every 20 years.
  const labels = calls.filter(c => c.m === 'fillText').map(c => c.args[0]);
  for (const l of ['0', '200k', '400k', '600k', '800k', '1000k']) if (!labels.includes(l)) fail('y label ' + l + ' missing', l, labels.join(' '));
  for (let a = Math.ceil(startAge / 20) * 20; a <= 121; a += 20) if (!labels.includes(String(a))) fail('x label ' + a + ' missing', a, labels.join(' '));
}
console.log('PASS: curve runs from top-left at startAge to 0 at 121 on the right, canvas cleared, axes labelled');
" "$HARNESS" "$ROOT"
