#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: on window resize the canvas pixel width follows its CSS width and the chart is redrawn at the new size
# AC: Resizing the window keeps the chart legible (canvas width set from its CSS width on resize, then redrawn)
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const h = await loadApp({ chartWidth: 800, chartHeight: 400 });
const canvas = h.els.chart; const ctx = h.ctx('chart');
if (canvas.width !== 800) fail('initial canvas width from CSS width', 800, canvas.width);
ctx.calls.length = 0;
h.resize(1200, 500);
if (canvas.width !== 1200) fail('canvas.width after resize', 1200, canvas.width);
if (canvas.height !== 500) fail('canvas.height after resize', 500, canvas.height);
const clear = ctx.calls.find(c => c.m === 'fillRect' || c.m === 'clearRect');
if (!clear) fail('chart redrawn after resize', 'a clear/fill of the canvas', 'no drawing calls');
if (clear.args.join(',') !== '0,0,1200,500') fail('redraw uses new canvas size', '0,0,1200,500', clear.args.join(','));
const xs = ctx.calls.filter(c => c.m === 'lineTo').map(c => c.args[0]);
if (Math.max(...xs) <= 800) fail('curve should extend across the wider canvas', '> 800', Math.max(...xs));
if (h.text('age') !== 'Age 0' || h.text('alive') !== '1,000,000') fail('figures preserved across resize', 'Age 0 / 1,000,000', h.text('age') + ' / ' + h.text('alive'));
console.log('PASS: resize sets canvas size from CSS size and redraws the chart');
" "$HARNESS"
