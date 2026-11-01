#!/bin/bash
# Resolve repo root from this script's location so tests run from anywhere
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT" || exit 1
HARNESS="$ROOT/fade/tests/FEAT-002/harness.mjs"
# Test: served over HTTP, index.html contains the starting figures and loads the module without errors
# AC: python3 -m http.server 8080 then http://localhost:8080/ shows 'Age 0', '1,000,000' and '100.0%' with no console errors
PORT=18082
python3 -m http.server $PORT --bind 127.0.0.1 > /dev/null 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null' EXIT
for i in $(seq 1 30); do curl -s -o /dev/null "http://127.0.0.1:$PORT/" && break; sleep 0.2; done

html=$(curl -s "http://127.0.0.1:$PORT/")
for needle in 'Age 0' '1,000,000' '100.0%' 'id="sex"' 'id="startAge"' 'id="play"' 'id="pause"' 'id="reset"' 'id="chart"' 'id="age"' 'id="alive"' 'id="pct"' 'styles.css' 'type="module" src="src/app.mjs"'; do
  if ! grep -qF -- "$needle" <<< "$html"; then echo "FAIL: index.html missing $needle"; echo "Expected: contains $needle"; echo "Actual: not found"; exit 1; fi
done
for path in src/app.mjs src/chart.mjs styles.css data/mortality.csv src/engine/table.mjs src/engine/survival.mjs; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/$path")
  if [[ "$code" != "200" ]]; then echo "FAIL: $path not served"; echo "Expected: 200"; echo "Actual: $code"; exit 1; fi
done
kill $PID 2>/dev/null

# No console errors: run the app against the fake DOM and check the rendered starting figures.
node --input-type=module -e "
const { loadApp, fail } = await import(process.argv[1]);
const errors = []; console.error = (...a) => errors.push(a.join(' '));
const h = await loadApp();
if (errors.length) fail('console errors during load', 'none', errors.join('; '));
if (h.text('age') !== 'Age 0') fail('#age', 'Age 0', h.text('age'));
if (h.text('alive') !== '1,000,000') fail('#alive', '1,000,000', h.text('alive'));
if (h.text('pct') !== '100.0%') fail('#pct', '100.0%', h.text('pct'));
console.log('PASS: page served with Age 0, 1,000,000 and 100.0% and no console errors');
" "$HARNESS"
